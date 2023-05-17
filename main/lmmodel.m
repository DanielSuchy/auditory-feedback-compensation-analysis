clear;

awareness_results = load("/Users/diskuser/analysis/all_data/eeg/awareness_results.mat");
awareness_results = awareness_results.all_results;
awareness_results = awareness_results(awareness_results.control == 0, :);
awareness_results.erps = []; 

%% summary
groupsummary(awareness_results, 'participant_id')
groupsummary(awareness_results, 'aware')
trial_types = groupsummary(awareness_results, ["participant_id" "aware"]);

%% auditory awareness negativity
awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_aan = double(awareness_results.mean_aan);
lme_aan = fitlme(awareness_results, 'mean_aan~aware+(1|participant_id)');

lme_aan
plotResiduals(lme_aan, 'caseorder')

%exclude based on residuals
awareness_results(awareness_results.participant_id == 28, :) = [];
lme_aan = fitlme(awareness_results, 'mean_aan~aware+(1|participant_id)');
lme_aan

%% late positivity

awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_lp = double(awareness_results.mean_lp);
lme_lp = fitlme(awareness_results, 'mean_lp~aware+(1|participant_id)');

lme_lp

plotResiduals(lme_lp, 'caseorder')

%% include no-pert control trials in the model
awareness_results = load("/Users/diskuser/analysis/all_data/eeg/awareness_results.mat");
awareness_results = awareness_results.all_results;

awareness_results.has_pert = ~awareness_results.control;
awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_aan = double(awareness_results.mean_aan);
awareness_results.erps = []; 
lme_aan = fitlme(awareness_results, 'mean_aan~aware*has_pert+(1|participant_id)');

lme_aan

awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_lp = double(awareness_results.mean_lp);
lme_lp = fitlme(awareness_results, 'mean_lp~aware*has_pert+(1|participant_id)');

lme_lp


%% control trials - ann
control_results = load("/Users/diskuser/analysis/eeg_data/main/eeg/control_trial_results.mat");
control_results = control_results.all_results;

control_results.has_pert = double(control_results.has_pert);
control_results.mean_aan = double(control_results.mean_aan);
lme_aan = fitlme(control_results, 'mean_aan~has_pert+(1|participant_id)');
lme_aan

%% control trials - lp
control_results.has_pert = double(control_results.has_pert);
control_results.mean_lp = double(control_results.mean_lp);
lme_lp = fitlme(control_results, 'mean_lp~has_pert+(1|participant_id)');
lme_lp