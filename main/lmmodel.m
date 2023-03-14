clear;

awareness_results = load("/Users/diskuser/analysis/eeg_data/main/eeg/awareness_results.mat");
awareness_results = awareness_results.all_results;

%% summary
groupsummary(awareness_results, 'participant_id')
groupsummary(awareness_results, 'aware')
trial_types = groupsummary(awareness_results, ["participant_id" "aware"]);

%% auditory awareness negativity
histogram(awareness_results.mean_aan);
boxplot(awareness_results.mean_aan, awareness_results.aware);

figure;
scatter(awareness_results.aware, awareness_results.mean_aan);
xlim([-0.2 1.2])

figure;
gscatter(double(awareness_results.aware), awareness_results.mean_aan, awareness_results.participant_id, [],[],30);
xlim([-0.2 1.2])

participant_id = 'S7';
data_by_participant = awareness_results(strcmp(awareness_results.participant_id, participant_id), :);
figure;
scatter(data_by_participant.aware, data_by_participant.mean_aan);
xlim([-0.5 1.5])

awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_aan = double(awareness_results.mean_aan);
lme_aan = fitlme(awareness_results, 'mean_aan~aware+(1|participant_id)');

lme_aan
figure;
scatter(awareness_results.aware, awareness_results.mean_aan);
refline(-0.013,-0.00074)
xlim([-0.2 1.2])

plotResiduals(lme_aan, 'caseorder')

%% late positivity
histogram(awareness_results.mean_lp);
boxplot(awareness_results.mean_lp, awareness_results.aware);

figure;
scatter(awareness_results.aware, awareness_results.mean_lp);
xlim([-0.2 1.2])

awareness_results.aware = double(awareness_results.aware);
awareness_results.mean_lp = double(awareness_results.mean_lp);
lme_lp = fitlme(awareness_results, 'mean_lp~aware+(1|participant_id)');

lme_lp

plotResiduals(lme_lp, 'caseorder')
to_exclude = find(residuals(lme_lp) > 6 | residuals(lme_lp) < -6);
lme_lp = fitlme(awareness_results, 'mean_lp~aware+(1|participant_id)', Exclude=to_exclude);
lme_lp

%% control trials - ann
control_results = load("/Users/diskuser/analysis/eeg_data/main/eeg/control_trial_results.mat");
control_results = control_results.all_results;

histogram(control_results.mean_aan);
boxplot(control_results.mean_aan, control_results.has_pert);

figure;
scatter(control_results.has_pert, control_results.mean_aan);
xlim([-0.2 1.2])

control_results.has_pert = double(control_results.has_pert);
control_results.mean_aan = double(control_results.mean_aan);
lme_aan = fitlme(control_results, 'mean_aan~has_pert+(1|participant_id)');
lme_aan

%% control trials - lp
histogram(control_results.mean_lp);
boxplot(control_results.mean_lp, control_results.has_pert);

figure;
scatter(control_results.has_pert, control_results.mean_aan);
xlim([-0.2 1.2])

control_results.has_pert = double(control_results.has_pert);
control_results.mean_lp = double(control_results.mean_lp);
lme_lp = fitlme(control_results, 'mean_lp~has_pert+(1|participant_id)');
lme_lp
