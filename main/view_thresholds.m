%create a table with awareness rating ratios for each participant
clear;

  
responses = load('../../eeg_data/main/response_audio_data.mat');
responses = responses.all_data;
pert_trials = responses(responses.pert_magnitude < 2 & responses.pert_magnitude > 0.0001,:);

pert_trials.aware = pert_trials.awareness >= 1;
[participant, ~, n] = unique(pert_trials.participant);
aware_trial_count = accumarray(n, pert_trials.aware, [], @(x)  sum(x));
total_trial_count = groupcounts(pert_trials.participant);

actual_threshold = aware_trial_count ./ total_trial_count;
attempted_threshold = [50; 75; 75; 75; 75; 65; 65; 65; 65; 65; 65; 65];
result = table(participant, aware_trial_count, total_trial_count, actual_threshold, attempted_threshold);
result
