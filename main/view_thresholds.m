%create a table with awareness rating ratios for each participant
clear;
  
responses = load('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat');
responses = responses.all_data;
responses = responses(:, [1 2 4 5 19:22]);
pert_trials = responses(responses.pert_magnitude < 2, :); %& responses.pert_magnitude > 0.0001,:);

%ratio of aware to unaware trials
pert_trials.aware = pert_trials.awareness >= 1;
[participant, ~, n] = unique(pert_trials.participant);
aware_trial_count = accumarray(n, pert_trials.aware, [], @(x)  sum(x));
total_trial_count = groupcounts(pert_trials.participant);
[aware_trial_count total_trial_count]
mean_percentage_aware = mean(aware_trial_count ./ total_trial_count)


actual_threshold = aware_trial_count ./ total_trial_count;
attempted_threshold = [50 75 75 75 repmat(65, [1 30-4])]';
magnitudes = unique(pert_trials.pert_magnitude, 'stable');
result = table(participant, aware_trial_count, total_trial_count, actual_threshold, attempted_threshold, magnitudes);
result

disp(['actual threshold: ', num2str(mean(result.actual_threshold)) ...
    ' attempted threshold: ' num2str(mean(result.attempted_threshold)) ...
    ' mean perturbation: ' num2str(mean(result.magnitudes))]);

false_alarms = responses(responses.pert_magnitude == 0.0001 & responses.awareness > 0, :);
height(false_alarms) / height(responses)

%% calculate d prime
pert_trials.has_stimulus = pert_trials.pert_magnitude > 0.0001;
pert_trials.hit = (pert_trials.has_stimulus == 1 & pert_trials.awareness >= 1);
pert_trials.fa = (pert_trials.has_stimulus == 0 & pert_trials.awareness >= 1);

participants_count = 35;
sd_table = table();
pert_trials.hit = double(pert_trials.hit); %change to double for d prime adjustment
pert_trials.fa = double(pert_trials.fa);
for participant_id=1:participants_count
    participant = pert_trials(pert_trials.participant == participant_id, :);
    if height(participant) == 0; continue; end %this participant has been excluded
    %adjust d prime to avoid inf (all hits) and 0 (no false alarms)
    %gives a numerical value to every participant while not chaning results too much
    for j=1:height(participant)
        if participant(j, :).hit == 1
            participant(j, :).hit = 1 - 1/(2*height(participant));
        else
            participant(j, :).hit = 1/(2*height(participant));
        end
        if participant(j, :).fa == 1
            participant(j, :).fa = 1 - 1/(2*height(participant));
        else
            participant(j, :).fa = 1/(2*height(participant));
        end
    end
    phit = sum(participant.hit) / sum(participant.has_stimulus);
    pfa = sum(participant.fa) / sum(participant.has_stimulus == 0);
    dprime = norminv(phit) - norminv(pfa);
    criterion = norminv(pfa);


     participant(participant.pert_magnitude == 0.0001, :) = [];
     unaware = participant(participant.awareness == 0, :);
     pitch_100_200 = mean(participant.pitch_100_200);
     pitch_300_500 = mean(participant.pitch_300_500);
     pitch_tfce = mean(participant.pitch_tfce);

    pertsize = participant.pert_magnitude(1);
    sd_table = [sd_table; table(participant_id, pertsize, dprime, criterion, pitch_100_200, ...
        pitch_300_500, pitch_tfce)];
end

sd_table(sd_table.participant_id == 23, :) = [];

%does pertsize correlate with sdt measures?
%early time window
lm1 = fitlm(sd_table, 'pitch_100_200 ~ dprime');
lm1
lm2 = fitlm(sd_table, 'pitch_100_200 ~ criterion');
lm2

%late time window
lm3 = fitlm(sd_table, 'pitch_300_500 ~ dprime');
lm3
lm4 = fitlm(sd_table, 'pitch_300_500 ~ criterion');
lm4

%tfce time window
lm5 = fitlm(sd_table, 'pitch_tfce ~ dprime');
lm5
lm6 = fitlm(sd_table, 'pitch_tfce ~ criterion');
lm6

% plot all regressions in a grid
figure;
subplot(2,2,1);
plot(lm3);
subplot(2,2,2);
plot(lm4);
subplot(2,2,3);
plot(lm5);
subplot(2,2,4);
plot(lm6);


