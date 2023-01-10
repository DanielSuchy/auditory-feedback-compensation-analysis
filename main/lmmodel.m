clear;

awareness_results = load("/Users/diskuser/analysis/eeg_data/main/eeg/awareness_results.mat");
awareness_results = awareness_results.all_results;

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
lme_aan
