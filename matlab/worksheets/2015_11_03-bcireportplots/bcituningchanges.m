conn = database('','root','Fairbanks1!','com.mysql.jdbc.Driver', ...
	'jdbc:mysql://fairbanks.amath.washington.edu:3306/spanky_db');

%List of files
files = fetch(exec(conn, ['SELECT et.`manualrecording` FROM experiment_tuning et']));
files = files.Data;

%Torque tuning angle (velocity)
deltaBCI = [];
deltacotuned = [];
deltaother = [];

for idx = 1:length(files)
	mcfile = files{idx}
	all_data = fetch(exec(conn, ['SELECT fl1.dir, fl2.dir, fl5.dir, et1.`tuning_type` FROM '...
	'`experiment_tuning` et1 '...
	'INNER JOIN `fits` flin1 '...
	'ON flin1.`nev file` = et1.`manualrecording`'...
	'INNER JOIN `fits_linear` fl1 '...
	'ON flin1.id = fl1.id '...
	'INNER JOIN `fits` flin2 '...
	'ON flin2.`nev file` = et1.`1DBCrecording`'...
	'INNER JOIN `fits_linear` fl2 '...
	'ON flin2.id = fl2.id '...
	'INNER JOIN `fits` flin5 '...
	'ON flin5.`nev file` = et1.`dualrecording`'...
	'INNER JOIN `fits_linear` fl5 '...
	'ON flin5.id = fl5.id '...
	'WHERE flin1.modelID = 30 AND flin2.modelID = 30 AND flin5.modelID = 30 ' ...
	'AND flin1.unit = flin2.unit AND flin2.unit = flin5.unit ' ...
	'AND fl1.r2 > 0.01 '...
	'AND NOT EXISTS (SELECT * FROM `bci_units` bci WHERE bci.`ID` = et1.`1DBCrecording` AND bci.unit = flin1.unit) '...
	'AND et1.`manualrecording` = "' mcfile '" '...
	'AND et1.`tuning_type` = 5']));
	if strcmp(all_data.Data, 'No Data')
		continue 
	end
	if size(all_data.Data, 1) < 4 
		continue 
	end
	all_theta = cell2mat(all_data.Data(:,1:3));
	tuningtype = cell2mat(all_data.Data(:,4));
	
	%BCI unit
	all_data = fetch(exec(conn, ['SELECT fl1.dir, fl2.dir, fl5.dir FROM '...
	'`experiment_tuning` et1 '...
	'INNER JOIN `fits` flin1 '...
	'ON flin1.`nev file` = et1.`manualrecording`'...
	'INNER JOIN `fits_linear` fl1 '...
	'ON flin1.id = fl1.id '...
	'INNER JOIN `fits` flin2 '...
	'ON flin2.`nev file` = et1.`1DBCrecording`'...
	'INNER JOIN `fits_linear` fl2 '...
	'ON flin2.id = fl2.id '...
	'INNER JOIN `fits` flin5 '...
	'ON flin5.`nev file` = et1.`dualrecording`'...
	'INNER JOIN `fits_linear` fl5 '...
	'ON flin5.id = fl5.id '...
	'WHERE flin1.modelID = 30 AND flin2.modelID = 30 AND flin5.modelID = 30 ' ...
	'AND flin1.unit = flin2.unit AND flin2.unit = flin5.unit ' ...
	'AND EXISTS (SELECT * FROM `bci_units` bci WHERE bci.`ID` = et1.`1DBCrecording` AND bci.unit = flin1.unit) '...
	'AND et1.`manualrecording` = "' mcfile '" '...
	'AND et1.`tuning_type` = 5 '...
	'LIMIT 1']));
	bci_theta = cell2mat(all_data.Data(:,1:3));
	nU = size(all_theta,1);
	
	%Pick cotuned units to BCI units in MC
	diff_MC_theta = cos(bci_theta(1) - all_theta(:,1));
	
	%Pick top two
	[l, cotunedidx] = sort(diff_MC_theta, 'descend'); 
	cotunedidx = cotunedidx(1:2);
	bcicotuned = diff_MC_theta(cotunedidx);
	
	%Pick random two 
	otherunits = randsample(setdiff(1:nU, cotunedidx), 2);
	
	deltathetaBCIMCDC = (bci_theta(3)-bci_theta(1))*180/pi
	deltathetacotunedMCDC = (all_theta(cotunedidx,3) - all_theta(cotunedidx,1))*180/pi
	deltathetaotherMCDC = (all_theta(otherunits,3) - all_theta(otherunits,1))*180/pi

	deltaBCI = [deltaBCI(:); deltathetaBCIMCDC; deltathetaBCIMCDC];
	deltacotuned = [deltacotuned(:); deltathetacotunedMCDC];
	deltaother = [deltaother(:); deltathetaotherMCDC];	
	%pause 
end

deltaBCI = mod(deltaBCI, 2*pi);
deltacotuned = mod(deltacotuned, 2*pi);
deltaother = mod(deltaother, 2*pi);

subplot(2,1,1)
plot(deltaBCI, deltacotuned, '.')
xlabel('Change in tuning. BC unit')
ylabel('Change in tuning. Cotuned unit')
subplot(2,1,2)
plot(deltaBCI, deltaother, '.')
xlabel('Change in tuning. BC unit')
ylabel('Change in tuning. Other unit')