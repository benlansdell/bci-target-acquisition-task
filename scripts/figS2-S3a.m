%conn = database('',databaseuser,databasepwd,'com.mysql.jdbc.Driver', ...
%	databaseurl);
%
%%Tuning angles, BCI units (velocity)
%bci_data = fetch(exec(conn, ['SELECT fl1.dir, fl2.dir, fl3.dir, fl5.dir, et1.`tuning_type`, rec1.`successrate`, rec2.`successrate`, '...
%' IF(EXISTS (SELECT * FROM `bci_units` bci WHERE bci.`ID` = et1.`1DBCrecording` AND bci.unit = flin1.unit), '...
%' 1, 0), flin1.`nev file` FROM '...
%'`experiment_tuning` et1 '...
%'INNER JOIN `fits` flin1 '...
%'ON flin1.`nev file` = et1.`manualrecording`'...
%'INNER JOIN `fits_linear` fl1 '...
%'ON flin1.id = fl1.id '...
%'INNER JOIN `fits` flin2 '...
%'ON flin2.`nev file` = et1.`1DBCrecording`'...
%'INNER JOIN `fits_linear` fl2 '...
%'ON flin2.id = fl2.id '...
%'INNER JOIN `fits` flin3 '...
%'ON flin3.`nev file` = et1.`manualrecordingafter`'...
%'INNER JOIN `fits_linear` fl3 '...
%'ON flin3.id = fl3.id '...
%'INNER JOIN `fits` flin5 '...
%'ON flin5.`nev file` = et1.`dualrecording`'...
%'INNER JOIN `fits_linear` fl5 '...
%'ON flin5.id = fl5.id '...
%'INNER JOIN `recordings` rec1 '...
%'ON rec1.`nev file` = et1.`1DBCrecording` '...
%'INNER JOIN `recordings` rec2 '...
%'ON rec2.`nev file` = et1.`dualrecording` '...
%'WHERE flin1.modelID = 30 AND flin2.modelID = 30 AND flin3.modelID = 30 AND flin5.modelID = 30 ' ...
%'AND flin1.unit = flin2.unit AND flin2.unit = flin3.unit AND flin2.unit = flin5.unit '...
%'AND fl1.r2 > .01 AND fl3.r2 > .01']));
%
%save('./scripts/figS2-S3a.mat')
load('./scripts/figS2-S3a.mat')

all_r2 = cell2mat(bci_data.Data(:,1:4));
bcituningtype = cell2mat(bci_data.Data(:,5));
bciperformance = 50*cell2mat(bci_data.Data(:,6:7))+10;
bciunit = cell2mat(bci_data.Data(:,8));
nevfiles = bci_data.Data(:,9);

unrot = (bcituningtype == 5);
bci = (bciunit == 1) & unrot;
nonbci = (bciunit == 0) & unrot;

dof_bci = sum(bci)-1;
dof_nonbci = sum(nonbci)-1;

%1 = mc1 
%2 = bc
%3 = mc2 
%4 = dc 

mc1bc_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,2)));
mc1mc2_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,3)));
mc2bc_difftheta = abs(center_angles(all_r2(unrot,3), all_r2(unrot,2)));
mcdc_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,4)));
bcdc_difftheta = abs(center_angles(all_r2(unrot,2), all_r2(unrot,4)));

bci_mc1bc_difftheta = abs(center_angles(all_r2(bci,1), all_r2(bci,2)));
bci_mc1mc2_difftheta = abs(center_angles(all_r2(bci,1), all_r2(bci,3)));
bci_mc2bc_difftheta = abs(center_angles(all_r2(bci,3), all_r2(bci,2)));
bci_mcdc_difftheta = abs(center_angles(all_r2(bci,1), all_r2(bci,4)));
bci_bcdc_difftheta = abs(center_angles(all_r2(bci,2), all_r2(bci,4)));

nonbci_mc1bc_difftheta = abs(center_angles(all_r2(nonbci,1), all_r2(nonbci,2)));
nonbci_mc1mc2_difftheta = abs(center_angles(all_r2(nonbci,1), all_r2(nonbci,3)));
nonbci_mc2bc_difftheta = abs(center_angles(all_r2(nonbci,3), all_r2(nonbci,2)));
nonbci_mcdc_difftheta = abs(center_angles(all_r2(nonbci,1), all_r2(nonbci,4)));
nonbci_bcdc_difftheta = abs(center_angles(all_r2(nonbci,2), all_r2(nonbci,4)));

mu_mc1bc_difftheta = mean(mc1bc_difftheta);
mu_mc1mc2_difftheta = mean(mc1mc2_difftheta);
mu_mc2bc_difftheta = mean(mc2bc_difftheta);
mu_mcdc_difftheta = mean(mcdc_difftheta);
mu_bcdc_difftheta = mean(bcdc_difftheta);

std_mc1bc_difftheta = std(mc1bc_difftheta);
std_mc1mc2_difftheta = std(mc1mc2_difftheta);
std_mc2bc_difftheta = std(mc2bc_difftheta);
std_mcdc_difftheta = std(mcdc_difftheta);
std_bcdc_difftheta = std(bcdc_difftheta);

mu_bci_mc1bc_difftheta = mean(bci_mc1bc_difftheta);
mu_bci_mc1mc2_difftheta = mean(bci_mc1mc2_difftheta);
mu_bci_mc2bc_difftheta = mean(bci_mc2bc_difftheta);
mu_bci_mcdc_difftheta = mean(bci_mcdc_difftheta);
mu_bci_bcdc_difftheta = mean(bci_bcdc_difftheta);

std_bci_mc1bc_difftheta = std(bci_mc1bc_difftheta);
std_bci_mc1mc2_difftheta = std(bci_mc1mc2_difftheta);
std_bci_mc2bc_difftheta = std(bci_mc2bc_difftheta);
std_bci_mcdc_difftheta = std(bci_mcdc_difftheta);
std_bci_bcdc_difftheta = std(bci_bcdc_difftheta);

mu_nonbci_mc1bc_difftheta  = mean(nonbci_mc1bc_difftheta);
mu_nonbci_mc1mc2_difftheta = mean(nonbci_mc1mc2_difftheta);
mu_nonbci_mc2bc_difftheta  = mean(nonbci_mc2bc_difftheta);
mu_nonbci_mcdc_difftheta = mean(nonbci_mcdc_difftheta);
mu_nonbci_bcdc_difftheta = mean(nonbci_bcdc_difftheta);

std_nonbci_mc1bc_difftheta = std(nonbci_mc1bc_difftheta);
std_nonbci_mc1mc2_difftheta = std(nonbci_mc1mc2_difftheta);
std_nonbci_mc2bc_difftheta = std(nonbci_mc2bc_difftheta);
std_nonbci_mcdc_difftheta = std(nonbci_mcdc_difftheta);
std_nonbci_bcdc_difftheta = std(nonbci_bcdc_difftheta);

[h_mc1bc, p_mc1bc] = ttest2(bci_mc1bc_difftheta, nonbci_mc1bc_difftheta, 0.05)
[h_mc1mc2, p_mc1mc2] = ttest2(bci_mc1mc2_difftheta, nonbci_mc1mc2_difftheta, 0.05)
[h_mc2bc, p_mc2bc] = ttest2(bci_mc2bc_difftheta, nonbci_mc2bc_difftheta, 0.05)
[h_mcdc, p_mcdc] = ttest2(bci_mcdc_difftheta, nonbci_mcdc_difftheta, 0.05)
[h_bcdc, p_bcdc] = ttest2(bci_bcdc_difftheta, nonbci_bcdc_difftheta, 0.05)

[h_mc1bc, p_mc1bc] = ttest2(mc1mc2_difftheta, mc1bc_difftheta, 0.05)
[h_mc2bc, p_mc2bc] = ttest2(mc1mc2_difftheta, mc2bc_difftheta, 0.05)
[h_mcdc, p_mcdc] = ttest2(mc1mc2_difftheta, mcdc_difftheta, 0.05)
[h_bcdc, p_bcdc] = ttest2(mc1mc2_difftheta, bcdc_difftheta, 0.05)

[h_bcdc2, p_bcdc2] = ttest2(mc1bc_difftheta, mcdc_difftheta, 0.05);

[h_mc1bc_bci, p_mc1bc_bci] = ttest2(bci_mc1mc2_difftheta, bci_mc1bc_difftheta, 0.05)
[h_mc2bc_bci, p_mc2bc_bci] = ttest2(bci_mc1mc2_difftheta, bci_mc2bc_difftheta, 0.05)
[h_mcdc_bci, p_mcdc_bci] = ttest2(bci_mc1mc2_difftheta, bci_mcdc_difftheta, 0.05)
[h_bcdc_bci, p_bcdc_bci] = ttest2(bci_mc1mc2_difftheta, bci_bcdc_difftheta, 0.05)

[h_mc1bc_nonbci, p_mc1bc_nonbci] = ttest2(nonbci_mc1mc2_difftheta, nonbci_mc1bc_difftheta, 0.05);
[h_mc2bc_nonbci, p_mc2bc_nonbci] = ttest2(nonbci_mc1mc2_difftheta, nonbci_mc2bc_difftheta, 0.05);
[h_mcdc_nonbci, p_mcdc_nonbci] = ttest2(nonbci_mc1mc2_difftheta, nonbci_mcdc_difftheta, 0.05);
[h_bcdc_nonbci, p_bcdc_nonbci] = ttest2(nonbci_mc1mc2_difftheta, nonbci_bcdc_difftheta, 0.05);

figure 
bar(180*[mean(mc1mc2_difftheta), mean(mc1bc_difftheta), mean(mcdc_difftheta)]/pi)
hold on 
errorbar(180*[mean(mc1mc2_difftheta), mean(mc1bc_difftheta), mean(mcdc_difftheta)]/pi, ...
	180*[std(mc1mc2_difftheta), std(mc1bc_difftheta), std(mcdc_difftheta)]/pi)
ylabel('|\Delta \theta|')
ylim([0 120])
saveplot(gcf, './figures/tuningangle-conditions-bargraph-unrotated.eps')

corrsdir(1) = corr(all_r2(unrot,1), translate_angles(all_r2(unrot,1), all_r2(unrot,2)));
corrsdir(2) = corr(all_r2(unrot,1), translate_angles(all_r2(unrot,1), all_r2(unrot,3)));
corrsdir(3) = corr(all_r2(unrot,3), translate_angles(all_r2(unrot,3), all_r2(unrot,2)));
corrsdir(4) = corr(all_r2(unrot,1), translate_angles(all_r2(unrot,1), all_r2(unrot,4)));
corrsdir(5) = corr(all_r2(unrot,2), translate_angles(all_r2(unrot,2), all_r2(unrot,4)));

corrsbci(1) = corr(all_r2(bci,1), translate_angles(all_r2(bci,1), all_r2(bci,2)));
corrsbci(2) = corr(all_r2(bci,1), translate_angles(all_r2(bci,1), all_r2(bci,3)));
corrsbci(3) = corr(all_r2(bci,3), translate_angles(all_r2(bci,3), all_r2(bci,2)));
corrsbci(4) = corr(all_r2(bci,1), translate_angles(all_r2(bci,1), all_r2(bci,4)));
corrsbci(5) = corr(all_r2(bci,2), translate_angles(all_r2(bci,2), all_r2(bci,4)));

corrsnonbci(1) = corr(all_r2(nonbci,1), translate_angles(all_r2(nonbci,1), all_r2(nonbci,2)));
corrsnonbci(2) = corr(all_r2(nonbci,1), translate_angles(all_r2(nonbci,1), all_r2(nonbci,3)));
corrsnonbci(3) = corr(all_r2(nonbci,3), translate_angles(all_r2(nonbci,3), all_r2(nonbci,2)));
corrsnonbci(4) = corr(all_r2(nonbci,1), translate_angles(all_r2(nonbci,1), all_r2(nonbci,4)));
corrsnonbci(5) = corr(all_r2(nonbci,2), translate_angles(all_r2(nonbci,2), all_r2(nonbci,4)));

figure 
clf
cc = ones(size(bciunit));
cc(bciunit == 1) = 2;
colors = [1 0 0; 0 0 1];
c = [];
for idx = 1:size(cc, 1);
	c(idx,1:3) = colors(cc(idx),:);
end
colormap(colors)
subplot(2,3,1)
scatter(180/pi*all_r2(unrot,1), 180/pi*translate_angles(all_r2(unrot,1), all_r2(unrot,2)), [], cc(unrot), '.')
xlabel('\theta MC1')
ylabel('\theta BC1')
title(['corr bci: ' num2str(corrsbci(1)) ' corr nonbci: ' num2str(corrsnonbci(1))])
subplot(2,3,2)
scatter(180/pi*all_r2(unrot,1), 180/pi*translate_angles(all_r2(unrot,1), all_r2(unrot,3)), [], cc(unrot), '.')
xlabel('\theta MC1')
ylabel('\theta MC2')
title(['corr bci: ' num2str(corrsbci(2)) ' corr nonbci: ' num2str(corrsnonbci(2))])
subplot(2,3,3)
scatter(180/pi*all_r2(unrot,3), 180/pi*translate_angles(all_r2(unrot,3), all_r2(unrot,2)), [], cc(unrot), '.')
ylabel('\theta BC1')
xlabel('\theta MC2')
title(['corr bci: ' num2str(corrsbci(3)) ' corr nonbci: ' num2str(corrsnonbci(3))])
subplot(2,3,5)
scatter(180/pi*all_r2(unrot,1), 180/pi*translate_angles(all_r2(unrot,1), all_r2(unrot,4)), [], cc(unrot), '.')
xlabel('\theta MC1')
ylabel('\theta DC')
title(['corr bci: ' num2str(corrsbci(4)) ' corr nonbci: ' num2str(corrsnonbci(4))])
subplot(2,3,6)
scatter(180/pi*all_r2(unrot,2), 180/pi*translate_angles(all_r2(unrot,2), all_r2(unrot,4)), [], cc(unrot), '.')
xlabel('\theta BC1')
ylabel('\theta DC')
title(['corr bci: ' num2str(corrsbci(5)) ' corr nonbci: ' num2str(corrsnonbci(5))])
saveplot(gcf, './figures/tuningangle-bciVnonbci-unrotated.eps', 'eps', [10 6])


%Perform stats tests...
%mc1bc_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,2)));
%mc1mc2_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,3)));
%mc2bc_difftheta = abs(center_angles(all_r2(unrot,3), all_r2(unrot,2)));
%mcdc_difftheta = abs(center_angles(all_r2(unrot,1), all_r2(unrot,4)));
%bcdc_difftheta = abs(center_angles(all_r2(unrot,2), all_r2(unrot,4)));

%Proportion of brain control units whose absolute change in angle is above 
%2 standard deviations compared to the absolute changes observed in MC-MC2
sum(mc1bc_difftheta > mu_mc1mc2_difftheta + 2*std_mc1mc2_difftheta)

100*sum(bci_mc1bc_difftheta > mu_bci_mc1mc2_difftheta + 2*std_bci_mc1mc2_difftheta)/size(bci_mc1bc_difftheta,1)
100*sum(nonbci_mc1bc_difftheta > mu_nonbci_mc1mc2_difftheta + 2*std_nonbci_mc1mc2_difftheta)/size(nonbci_mc1bc_difftheta,1)

%Proportion of dual control units whose absolute change in angle is above 
%2 standard deviations compared to the absolute changes observed in MC-MC2
sum(mcdc_difftheta > mu_mc1mc2_difftheta + 2*std_mc1mc2_difftheta)

100*sum(bci_mcdc_difftheta > mu_bci_mc1mc2_difftheta + 2*std_bci_mc1mc2_difftheta)/size(bci_mcdc_difftheta,1)
100*sum(nonbci_mcdc_difftheta > mu_nonbci_mc1mc2_difftheta + 2*std_nonbci_mc1mc2_difftheta)/size(nonbci_mcdc_difftheta,1)





