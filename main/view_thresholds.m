%create a table with awareness rating ratios for each participant
clear;
  
responses = load('/Users/diskuser/analysis/eeg_data/main/experiment/response_audio_data.mat');
responses = responses.all_data;
pert_trials = responses(responses.pert_magnitude < 2 & responses.pert_magnitude > 0.0001,:);

pert_trials.aware = pert_trials.awareness >= 1;
[participant, ~, n] = unique(pert_trials.participant);
aware_trial_count = accumarray(n, pert_trials.aware, [], @(x)  sum(x));
total_trial_count = groupcounts(pert_trials.participant);

actual_threshold = aware_trial_count ./ total_trial_count;
attempted_threshold = [50; 75; 75; 75; 75; 65; 65; 65; 65; 65; 65; 65];
magnitudes = unique(pert_trials.pert_magnitude, 'stable');
result = table(participant, aware_trial_count, total_trial_count, actual_threshold, attempted_threshold, magnitudes);
result

false_alarms = responses(responses.pert_magnitude == 0.0001 & responses.awareness > 0, :);
height(false_alarms) / height(responses)