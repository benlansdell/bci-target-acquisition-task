function processMVGCmanual(conn, modelID, blackrock, labviewpath, nevfile, BCnevfile, paramcode)
	nevpath = [blackrock nevfile];
	%Load parameters
	eval(paramcode);
	%Get which units are BCI units, get the mat file for this nev file
	bcunits = fetch(exec(conn, ['SELECT `unit` FROM `BCIUnits` WHERE `ID` = "' BCnevfile '"']));
	%bcunits = num2str(cell2mat(bcunits.Data));
	bcunits = bcunits.Data;
	if size(bcunits,1) < 2
		display(['Warning: fewer than 2 BCI units are labeled within ' nevfile])
	end
	matfile = fetch(exec(conn, ['SELECT `labview file`,`duration` FROM `Recordings` rec WHERE rec.`nev file` = "' nevfile '"']));
	duration = matfile.Data{2};
	matfile = matfile.Data{1};
	matpath = [labviewpath matfile];
	taskaxes = fetch(exec(conn, ['SELECT `axis` FROM `Recordings` rec WHERE rec.`nev file` = "' nevfile '"']));
	taskaxes = taskaxes.Data{1};
	%Get how many units are above threshold from Units
	units = fetch(exec(conn, ['SELECT `unit` FROM `Units` WHERE `nev file` = "' nevfile '" AND `firingrate` > ' num2str(threshold)]));
	units = units.Data;
	units = unique([units; bcunits]);
	if duration < dur
		display(['Recording is shorter than specified ' num2str(dur) ' seconds. Skipping'])
		return
	end

	%%Preprocess data
	processed = preprocess_spline_lv(nevpath, matfile, binsize, threshold, offset, [], [], units);
	%Truncate to specified duration
	processed = truncate_recording(processed, dur);
	nUtotal = length(processed.unitnames);

	%Make data matrix
	if strcmp(taskaxes, 'horiz')
		idx = [1];
	elseif strcmp(taskaxes, 'vert')
		idx = [2];
	elseif strcmp(taskaxes, '2D')
		idx = [1, 2];
	else
		error([nevfile ' does not specify the task axes.'])
	end

	%MVGC
	X = [processed.cursor(:,idx), processed.rates]';
	%X = [processed.binnedspikes]';
	%Y = resample(X', 1, 2)';
	results = mvgcBCI(X, [], [], pval);

	nC = results.morder;
	causaldensity = sum(results.pwcgc_sig(1,2:end))/(nUtotal);

	%Tag with computer run on, date, last git commit
	host = hostname();
	stamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
	comm = currCommit();

	%Get the fitID
	%fitid = getFitID(conn);
	%fitid = randi(1e9);

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

		previous = fetch(exec(conn, ['SELECT id FROM Fits WHERE `nev file` = "' nevfile '" AND modelID = ' num2str(modelID) ' AND unit = "' unit '"']));
		if ~strcmp(previous.Data{1}, 'No Data')
			display(['Model ' num2str(modelID) ' nevfile ' nevfile ' and unit ' unit ' already analysed. Skipping'])
			continue
		end
	
		%Insert into Fits
		tablename = 'Fits';
		fitcols = {'modelID', '`nev file`', 'unit', 'unitnum', 'ncoeff', 'computer', '`analysis date`', 'commit'};
		sqldata = { modelID, nevfile, unit, unitnum, nC, host, stamp, comm};
		datainsert(conn,tablename,fitcols,sqldata);
		%Get the fit id used
		fitid = fetch(exec(conn, 'SELECT LAST_INSERT_ID()'));
		fitid = fitid.Data{1};
	
		%Insert into FitsMVGC
		tablename = 'FitsMVGC';
		fitcols = {'id', 'alpha', 'units', 'causaldensity'};
		sqldata = { fitid, pval, nUtotal, causaldensity};
		datainsert(conn,tablename,fitcols,sqldata);
	
		%For each unit, save the results 
		tablename = 'GrangerEstimates';
		fitcols = {'id', 'fromnum', 'fromunit', 'score', 'pval', 'significant'};
		nG = length(units);
		for j = (nG+1):(nUtotal+nG)
			%Extract and save regression fiticients
			unit = processed.unitnames{j-nG};
			%Extract deviance
			score = results.pwcgc(i,j);
			p = results.pwcgc_pval(i,j);
			sig = results.pwcgc_sig(i,j);
		
			%Insert into FitsMVGC
			sqldata = {fitid, j-nG, unit, score, p, sig};
			datainsert(conn,tablename,fitcols,sqldata);
		end	
	end
end