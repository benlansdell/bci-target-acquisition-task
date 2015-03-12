matfile_in = './expts/2dmanualpos_1day.mat';
settings = setupExperiment('sprc_relpos_target_lv_def');
exptname = '2dmanualpos_sprc_relpos_target_lv_def';
expts = runExperiment(matfile_in, settings, exptname);
save(['./expts/' exptname '.mat'], 'expts');