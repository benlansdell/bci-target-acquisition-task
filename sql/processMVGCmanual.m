function processMVGCmanual(conn, modelID, blackrock, labviewpath, nevfile1, BCnevfile, nevfile2, expt_id, paramcode)
	nevs = {nevfile1, nevfile2};
	%Load parameters
	eval(paramcode);
	%Get which units are BCI units, get the mat file for this nev file
	bcunits = fetch(exec(conn, ['SELECT `unit` FROM `bci_units` WHERE `ID` = "' BCnevfile '"']));
	%bcunits = num2str(cell2mat(bcunits.Data));
	bcunits = bcunits.Data;
	if size(bcunits,1) < 2
		display(['Warning: fewer than 2 BCI units are labeled within ' nevfile1])
	end
	matfile = fetch(exec(conn, ['SELECT `labview file`,`duration` FROM `recordings` rec WHERE rec.`nev file` = "' BCnevfile '"']));
	duration = matfile.Data{2};
	matfile = matfile.Data{1};
	matpath = [labviewpath matfile];

	if duration < dur
		display(['Recording is shorter than specified ' num2str(dur) ' seconds. Skipping'])
		return
	end

	%Tag with computer run on, date, last git commit
	host = hostname();
	stamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
	comm = currCommit();

	previous = fetch(exec(conn, ['SELECT id FROM analyses WHERE `experiment_id` = "' num2str(expt_id) '" AND modelID = ' num2str(modelID)]));
	if ~strcmp(previous.Data{1}, 'No Data')
		display(['modelID ' num2str(modelID) ' and experiment_id ' num2str(expt_id) ' already analysed. Skipping'])
		return
	end

	%Setup an analysis
	%Insert into analyses
	tablename = 'analyses';
	fitcols = {'modelID', '`experiment_id`', 'unit', 'unitnum', 'ncoeff', 'computer', '`analysis date`', 'commit'};
	sqldata = { modelID, expt_id, 'NULL', 1, 1, host, stamp, comm};
	datainsert(conn,tablename,fitcols,sqldata);
	%Get the analysis_id used
	analysis_id = fetch(exec(conn, 'SELECT LAST_INSERT_ID()'));
	analysis_id = analysis_id.Data{1};

	%Run the model for each nev file
	for idx = 1:length(nevs)
		nevfile = nevs{idx};
		nevpath = [blackrock nevfile];
		%Get how many units are above threshold from units
		units = fetch(exec(conn, ['SELECT `unit` FROM `units` WHERE `nev file` = "' nevfile '" AND `firingrate` > ' num2str(threshold)]));
		units = units.Data;
		%If more than 30 units...take a random sample
		if length(units) > nU
			units = randsample(units, nU);
		end
		%Add the BCI units if not already there
		units = unique([units; bcunits]);
	
		%%Preprocess data
		processed = preprocess_spline_lv(nevpath, matfile, binsize, threshold, offset, [], [], units);
		%Truncate to specified duration
		processed = truncate_recording(processed, dur);
	
		nUtotal = length(processed.unitnames);
		%If all units have been analyzed then return
		if nUtotal == 0
			display(['All units in ' nevfile ' have been analyzed by model number ' modelID '. Continuing'])
			return
		end

		taskaxes = fetch(exec(conn, ['SELECT `axis` FROM `recordings` rec WHERE rec.`nev file` = "' nevfile '"']));
		taskaxes = taskaxes.Data{1};

		%Make data matrix
		if strcmp(taskaxes, 'horiz')
			idx = [1];
		elseif strcmp(taskaxes, 'vert')
			idx = [2];
		elseif strcmp(taskaxes, '2D')
			idx = [1, 2];
		else
			display([nevfile ' does not specify the task axes.'])
			return;
		end
	
		%MVGC
		X = [processed.cursor(:,idx), processed.rates]';
		%X = [processed.binnedspikes]';
		%Y = resample(X', 1, 2)';
		results = mvgcBCI(X, [], [], pval);
	
		nC = results.morder;
		causaldensity = sum(results.pwcgc_sig(1,2:end))/(nUtotal);
	
		if strcmp(taskaxes, '2D')
			units = {'cursX', 'cursY'};
			unitnums = [1, 2];
		else
			units = {'curs'};
			unitnums = 1;
		end
	
		for i = 1:length(units)
			unit = units{i};
			unitnum = unitnums(i);
	
			%Insert into fits
			tablename = 'fits';
			fitcols = {'modelID', '`analyses_id`', '`nev file`', 'unit', 'unitnum', 'ncoeff', 'computer', '`analysis date`', 'commit'};
			sqldata = { modelID, analysis_id, nevfile, unit, unitnum, nC, host, stamp, comm};
			datainsert(conn,tablename,fitcols,sqldata);
			%Get the fit id used
			fitid = fetch(exec(conn, 'SELECT LAST_INSERT_ID()'));
			fitid = fitid.Data{1};
		
			%Insert into fits_mvgc
			tablename = 'fits_mvgc';
			fitcols = {'id', 'alpha', 'units', 'causaldensity'};
			sqldata = { fitid, pval, nUtotal, causaldensity};
			datainsert(conn,tablename,fitcols,sqldata);
		
			%For each unit, save the results 
			tablename = 'estimates_granger';
			fitcols = {'id', 'fromnum', 'fromunit', 'score', 'pval', 'significant'};
			nG = length(units);
			for j = (nG+1):(nUtotal+nG)
				%Extract and save regression fiticients
				unit = processed.unitnames{j-nG};
				%Extract deviance
				score = results.pwcgc(i,j);
				p = results.pwcgc_pval(i,j);
				sig = results.pwcgc_sig(i,j);
			
				%Insert into fits_mvgc
				sqldata = {fitid, j-nG, unit, score, p, sig};
				datainsert(conn,tablename,fitcols,sqldata);
			end	
		end
	end
end
