conn = database('','root','Fairbanks1!','com.mysql.jdbc.Driver', ...
	'jdbc:mysql://fairbanks.amath.washington.edu:3306/spanky_db');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gather data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sqlstr = ['SELECT flin1.dev, flin2.dev, flin3.dev, flin4.dev, flin5.dev, '...
	'Cflin1.dev, Cflin2.dev, Cflin3.dev, Cflin4.dev, Cflin5.dev, '...
	'CVflin1.dev, CVflin2.dev, CVflin3.dev, CVflin4.dev, CVflin5.dev, '...
	'TVflin1.dev, TVflin2.dev, TVflin3.dev, TVflin4.dev, TVflin5.dev FROM '...
'`experiment_tuning` et1 '...
'INNER JOIN `fits` flin1 '...
'ON flin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` fl1 '...
'ON flin1.id = fl1.id '...
'INNER JOIN `fits` flin2 '...
'ON flin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` fl2 '...
'ON flin2.id = fl2.id '...
'INNER JOIN `fits` flin3 '...
'ON flin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` fl3 '...
'ON flin3.id = fl3.id '...
'INNER JOIN `fits` flin4 '...
'ON flin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` fl4 '...
'ON flin4.id = fl4.id '...
'INNER JOIN `fits` flin5 '...
'ON flin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` fl5 '...
'ON flin5.id = fl5.id '...
'INNER JOIN `fits` Cflin1 '...
'ON Cflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` Cfl1 '...
'ON Cflin1.id = Cfl1.id '...
'INNER JOIN `fits` Cflin2 '...
'ON Cflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` Cfl2 '...
'ON Cflin2.id = Cfl2.id '...
'INNER JOIN `fits` Cflin3 '...
'ON Cflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` Cfl3 '...
'ON Cflin3.id = Cfl3.id '...
'INNER JOIN `fits` Cflin4 '...
'ON Cflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` Cfl4 '...
'ON Cflin4.id = Cfl4.id '...
'INNER JOIN `fits` Cflin5 '...
'ON Cflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` Cfl5 '...
'ON Cflin5.id = Cfl5.id '...
'INNER JOIN `fits` CVflin1 '...
'ON CVflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` CVfl1 '...
'ON CVflin1.id = CVfl1.id '...
'INNER JOIN `fits` CVflin2 '...
'ON CVflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` CVfl2 '...
'ON CVflin2.id = CVfl2.id '...
'INNER JOIN `fits` CVflin3 '...
'ON CVflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` CVfl3 '...
'ON CVflin3.id = CVfl3.id '...
'INNER JOIN `fits` CVflin4 '...
'ON CVflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` CVfl4 '...
'ON CVflin4.id = CVfl4.id '...
'INNER JOIN `fits` CVflin5 '...
'ON CVflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` CVfl5 '...
'ON CVflin5.id = CVfl5.id '...
'INNER JOIN `fits` TVflin1 '...
'ON TVflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` TVfl1 '...
'ON TVflin1.id = TVfl1.id '...
'INNER JOIN `fits` TVflin2 '...
'ON TVflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` TVfl2 '...
'ON TVflin2.id = TVfl2.id '...
'INNER JOIN `fits` TVflin3 '...
'ON TVflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` TVfl3 '...
'ON TVflin3.id = TVfl3.id '...
'INNER JOIN `fits` TVflin4 '...
'ON TVflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` TVfl4 '...
'ON TVflin4.id = TVfl4.id '...
'INNER JOIN `fits` TVflin5 '...
'ON TVflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` TVfl5 '...
'ON TVflin5.id = TVfl5.id '];
sqlstr = [sqlstr 'WHERE flin1.modelID = 1 AND flin2.modelID = 1 AND flin3.modelID = 1 AND flin4.modelID = 1 AND flin5.modelID = 1 ' ...
'AND flin1.unit = flin2.unit AND flin2.unit = flin3.unit AND flin2.unit = flin4.unit AND flin2.unit = flin5.unit '...
'AND Cflin1.modelID = 7 AND Cflin2.modelID = 7 AND Cflin3.modelID = 7 AND Cflin4.modelID = 7 AND Cflin5.modelID = 7 ' ...
'AND Cflin1.unit = Cflin2.unit AND Cflin2.unit = Cflin3.unit AND Cflin2.unit = Cflin4.unit AND Cflin2.unit = Cflin5.unit AND flin1.unit = Cflin1.unit '...
'AND CVflin1.modelID = 28 AND CVflin2.modelID = 28 AND CVflin3.modelID = 28 AND CVflin4.modelID = 28 AND CVflin5.modelID = 28 ' ...
'AND CVflin1.unit = CVflin2.unit AND CVflin2.unit = CVflin3.unit AND CVflin2.unit = CVflin4.unit AND CVflin2.unit = CVflin5.unit AND flin1.unit = CVflin1.unit '...
'AND TVflin1.modelID = 30 AND TVflin2.modelID = 30 AND TVflin3.modelID = 30 AND TVflin4.modelID = 30 AND TVflin5.modelID = 30 ' ...
'AND TVflin1.unit = TVflin2.unit AND TVflin2.unit = TVflin3.unit AND TVflin2.unit = TVflin4.unit AND TVflin2.unit = TVflin5.unit AND flin1.unit = TVflin1.unit'];

all_data = fetch(exec(conn, [sqlstr]));
all_torqPdev = cell2mat(all_data.Data(:,1:5));
all_cursPdev = cell2mat(all_data.Data(:,6:10));
all_cursVdev = cell2mat(all_data.Data(:,11:15));
all_torqVdev = cell2mat(all_data.Data(:,16:20));

all_diffP = all_torqPdev - all_cursPdev;
all_diffV = all_torqVdev - all_cursVdev;

corrsP(1) = corr(all_diffP(:,1), all_diffP(:,2));
corrsP(2) = corr(all_diffP(:,1), all_diffP(:,3));
corrsP(3) = corr(all_diffP(:,3), all_diffP(:,2));
corrsP(4) = corr(all_diffP(:,2), all_diffP(:,4));
corrsP(5) = corr(all_diffP(:,1), all_diffP(:,5));
corrsP(6) = corr(all_diffP(:,2), all_diffP(:,5));

corrsV(1) = corr(all_diffV(:,1), all_diffV(:,2));
corrsV(2) = corr(all_diffV(:,1), all_diffV(:,3));
corrsV(3) = corr(all_diffV(:,3), all_diffV(:,2));
corrsV(4) = corr(all_diffV(:,2), all_diffV(:,4));
corrsV(5) = corr(all_diffV(:,1), all_diffV(:,5));
corrsV(6) = corr(all_diffV(:,2), all_diffV(:,5));

all_torqmax = min(all_torqPdev, all_torqVdev);
all_cursmax = min(all_cursPdev, all_cursVdev);

all_diffmax = all_torqmax - all_cursmax;

%Negative dev differences are 'torque preferring'
all_binarydiffmax = all_diffmax < 0;

%Count those that are 'torque preferring in BC'
TPBC = all_binarydiffmax(:,2) == 1;
TPDC = all_binarydiffmax(:,5) == 1;

sum(TPBC & TPDC)
sum(TPBC & ~TPDC)
sum(~TPBC & TPDC)
sum(~TPBC & ~TPDC)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do the same with R2 instead of dev%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sqlstr = ['SELECT fl1.r2, fl2.r2, fl3.r2, fl4.r2, fl5.r2, '...
	'Cfl1.r2, Cfl2.r2, Cfl3.r2, Cfl4.r2, Cfl5.r2, '...
	'CVfl1.r2, CVfl2.r2, CVfl3.r2, CVfl4.r2, CVfl5.r2, '...
	'TVfl1.r2, TVfl2.r2, TVfl3.r2, TVfl4.r2, TVfl5.r2 FROM '...
'`experiment_tuning` et1 '...
'INNER JOIN `fits` flin1 '...
'ON flin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` fl1 '...
'ON flin1.id = fl1.id '...
'INNER JOIN `fits` flin2 '...
'ON flin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` fl2 '...
'ON flin2.id = fl2.id '...
'INNER JOIN `fits` flin3 '...
'ON flin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` fl3 '...
'ON flin3.id = fl3.id '...
'INNER JOIN `fits` flin4 '...
'ON flin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` fl4 '...
'ON flin4.id = fl4.id '...
'INNER JOIN `fits` flin5 '...
'ON flin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` fl5 '...
'ON flin5.id = fl5.id '...
'INNER JOIN `fits` Cflin1 '...
'ON Cflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` Cfl1 '...
'ON Cflin1.id = Cfl1.id '...
'INNER JOIN `fits` Cflin2 '...
'ON Cflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` Cfl2 '...
'ON Cflin2.id = Cfl2.id '...
'INNER JOIN `fits` Cflin3 '...
'ON Cflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` Cfl3 '...
'ON Cflin3.id = Cfl3.id '...
'INNER JOIN `fits` Cflin4 '...
'ON Cflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` Cfl4 '...
'ON Cflin4.id = Cfl4.id '...
'INNER JOIN `fits` Cflin5 '...
'ON Cflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` Cfl5 '...
'ON Cflin5.id = Cfl5.id '...
'INNER JOIN `fits` CVflin1 '...
'ON CVflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` CVfl1 '...
'ON CVflin1.id = CVfl1.id '...
'INNER JOIN `fits` CVflin2 '...
'ON CVflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` CVfl2 '...
'ON CVflin2.id = CVfl2.id '...
'INNER JOIN `fits` CVflin3 '...
'ON CVflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` CVfl3 '...
'ON CVflin3.id = CVfl3.id '...
'INNER JOIN `fits` CVflin4 '...
'ON CVflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` CVfl4 '...
'ON CVflin4.id = CVfl4.id '...
'INNER JOIN `fits` CVflin5 '...
'ON CVflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` CVfl5 '...
'ON CVflin5.id = CVfl5.id '...
'INNER JOIN `fits` TVflin1 '...
'ON TVflin1.`nev file` = et1.`manualrecording`'...
'INNER JOIN `fits_linear` TVfl1 '...
'ON TVflin1.id = TVfl1.id '...
'INNER JOIN `fits` TVflin2 '...
'ON TVflin2.`nev file` = et1.`1DBCrecording`'...
'INNER JOIN `fits_linear` TVfl2 '...
'ON TVflin2.id = TVfl2.id '...
'INNER JOIN `fits` TVflin3 '...
'ON TVflin3.`nev file` = et1.`manualrecordingafter`'...
'INNER JOIN `fits_linear` TVfl3 '...
'ON TVflin3.id = TVfl3.id '...
'INNER JOIN `fits` TVflin4 '...
'ON TVflin4.`nev file` = et1.`1DBCrecordingafter`'...
'INNER JOIN `fits_linear` TVfl4 '...
'ON TVflin4.id = TVfl4.id '...
'INNER JOIN `fits` TVflin5 '...
'ON TVflin5.`nev file` = et1.`dualrecording`'...
'INNER JOIN `fits_linear` TVfl5 '...
'ON TVflin5.id = TVfl5.id '];
sqlstr = [sqlstr 'WHERE flin1.modelID = 1 AND flin2.modelID = 1 AND flin3.modelID = 1 AND flin4.modelID = 1 AND flin5.modelID = 1 ' ...
'AND flin1.unit = flin2.unit AND flin2.unit = flin3.unit AND flin2.unit = flin4.unit AND flin2.unit = flin5.unit '...
'AND Cflin1.modelID = 7 AND Cflin2.modelID = 7 AND Cflin3.modelID = 7 AND Cflin4.modelID = 7 AND Cflin5.modelID = 7 ' ...
'AND Cflin1.unit = Cflin2.unit AND Cflin2.unit = Cflin3.unit AND Cflin2.unit = Cflin4.unit AND Cflin2.unit = Cflin5.unit AND flin1.unit = Cflin1.unit '...
'AND CVflin1.modelID = 28 AND CVflin2.modelID = 28 AND CVflin3.modelID = 28 AND CVflin4.modelID = 28 AND CVflin5.modelID = 28 ' ...
'AND CVflin1.unit = CVflin2.unit AND CVflin2.unit = CVflin3.unit AND CVflin2.unit = CVflin4.unit AND CVflin2.unit = CVflin5.unit AND flin1.unit = CVflin1.unit '...
'AND TVflin1.modelID = 30 AND TVflin2.modelID = 30 AND TVflin3.modelID = 30 AND TVflin4.modelID = 30 AND TVflin5.modelID = 30 ' ...
'AND TVflin1.unit = TVflin2.unit AND TVflin2.unit = TVflin3.unit AND TVflin2.unit = TVflin4.unit AND TVflin2.unit = TVflin5.unit AND flin1.unit = TVflin1.unit'];

all_data = fetch(exec(conn, [sqlstr]));
all_torqPdev = cell2mat(all_data.Data(:,1:5));
all_cursPdev = cell2mat(all_data.Data(:,6:10));
all_cursVdev = cell2mat(all_data.Data(:,11:15));
all_torqVdev = cell2mat(all_data.Data(:,16:20));

all_diffP = all_torqPdev - all_cursPdev;
all_diffV = all_torqVdev - all_cursVdev;

corrsP(1) = corr(all_diffP(:,1), all_diffP(:,2));
corrsP(2) = corr(all_diffP(:,1), all_diffP(:,3));
corrsP(3) = corr(all_diffP(:,3), all_diffP(:,2));
corrsP(4) = corr(all_diffP(:,2), all_diffP(:,4));
corrsP(5) = corr(all_diffP(:,1), all_diffP(:,5));
corrsP(6) = corr(all_diffP(:,2), all_diffP(:,5));

corrsV(1) = corr(all_diffV(:,1), all_diffV(:,2));
corrsV(2) = corr(all_diffV(:,1), all_diffV(:,3));
corrsV(3) = corr(all_diffV(:,3), all_diffV(:,2));
corrsV(4) = corr(all_diffV(:,2), all_diffV(:,4));
corrsV(5) = corr(all_diffV(:,1), all_diffV(:,5));
corrsV(6) = corr(all_diffV(:,2), all_diffV(:,5));

all_torqmax = max(all_torqPdev, all_torqVdev);
all_cursmax = max(all_cursPdev, all_cursVdev);

all_diffmax = -all_torqmax + all_cursmax;

%Negative dev differences are 'torque preferring'
all_binarydiffmax = all_diffmax < 0;

%Count those that are 'torque preferring in BC'
TPBC = all_binarydiffmax(:,2) == 1;
TPDC = all_binarydiffmax(:,5) == 1;

sum(TPBC & TPDC)
sum(TPBC & ~TPDC)
sum(~TPBC & TPDC)
sum(~TPBC & ~TPDC)
%See the same thing as using the deviance... (surpsingly)