%overlap audio and ERP signal and relate their onsets to see if they correlate
clear;

%load the data
%% load the data
results = load('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat');
results = results.all_data;

%exclude invalid trials (e.g. incorrect vocalization)
results = results(results.ost_worked == 1, :);
results = results(~isnan(results.pert_start_time), :);
results(cellfun(@isempty,results.pitch), :) = [];

%exclude outliers
results(abs(results.pitch_tfce) > 100, :) = [];

aware = results(results.pert_magnitude > 0.0001 & results.pert_magnitude < 2 & results.awareness >= 1, :);
unaware = results(results.pert_magnitude > 0.0001 & results.pert_magnitude < 2 & results.awareness == 0, :);
bigpert = results(results.pert_magnitude == 2, :);
nopert = results(results.pert_magnitude == 0.0001, :);
nopert_aware = results(results.pert_magnitude == 0.0001 & results.awareness >= 1, :);
nopert_unaware = results(results.pert_magnitude == 0.0001 & results.awareness == 0, :);


%calculate mean pitch for each participant and each type of trial
[participant, ~, ~] = unique(aware.participant);
all_pitch_participant = [];
mean_aware = [];
for i=1:length(participant)
    pitch_participant = participant(i);
    pitch_participant = aware(aware.participant == pitch_participant, :).pitch;
    for j=1:length(pitch_participant)
        pitch_trial = cell2mat(pitch_participant(j))';
        all_pitch_participant = [all_pitch_participant; pitch_trial];
    end
    mean_aware = [mean_aware; mean(all_pitch_participant)];
    all_pitch_participant = [];
end

[participant, ~, ~] = unique(unaware.participant);
all_pitch_participant = [];
mean_unaware = [];
for i=1:length(participant)
    pitch_participant = participant(i);
    pitch_participant = unaware(unaware.participant == pitch_participant, :).pitch;
    for j=1:length(pitch_participant)
        pitch_trial = cell2mat(pitch_participant(j))';
        all_pitch_participant = [all_pitch_participant; pitch_trial];
    end
    mean_unaware = [mean_unaware; mean(all_pitch_participant)];
    all_pitch_participant = [];
end

%calculate mean pitch for each participant and each type of trial
[participant, ~, ~] = unique(bigpert.participant);
all_pitch_participant = [];
mean_bigpert = [];
for i=1:length(participant)
    pitch_participant = participant(i);
    pitch_participant = bigpert(bigpert.participant == pitch_participant, :).pitch;
    for j=1:length(pitch_participant)
        pitch_trial = cell2mat(pitch_participant(j))';
        all_pitch_participant = [all_pitch_participant; pitch_trial];
    end
    mean_bigpert = [mean_bigpert; mean(all_pitch_participant)];
    all_pitch_participant = [];
end

%calculate mean pitch for each participant and each type of trial
[participant, ~, ~] = unique(nopert.participant);
all_pitch_participant = [];
mean_nopert = [];
for i=1:length(participant)
    pitch_participant = participant(i);
    pitch_participant = nopert(nopert.participant == pitch_participant, :).pitch;
    for j=1:length(pitch_participant)
        pitch_trial = cell2mat(pitch_participant(j))';
        all_pitch_participant = [all_pitch_participant; pitch_trial];
    end
    mean_nopert = [mean_nopert; mean(all_pitch_participant)];
    all_pitch_participant = [];
end


%% plot average vocalization timecourse
figure;
plot(results(1,:).relative_time_points{:} * 1000, mean(mean_nopert, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(mean_bigpert, 'omitnan'), 'LineWidth',3);
plot(results(1,:).relative_time_points{:} * 1000, mean(mean_aware, 'omitnan'), 'LineWidth',3);
plot(results(1,:).relative_time_points{:} * 1000, mean(mean_unaware, 'omitnan'), 'LineWidth',3);
l = line([0 0],[-10 10]); l.Color='k';
title('Time course of vocal adaptation', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Mean adaptation magnitude (cents)', 'FontSize',30, 'FontWeight','bold')
legend('0-cent trials', '200-cent trials', 'aware threshold tr.', 'unaware threshold tr.')
fontsize(gca, 24, 'points');
yline(0);
ylim([-8 6]);

%% overlap vocalization and ERP timecourse
%load the data
%trials with pert onset
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_aware1*.mat');
all_aware1_times = [];
all_aware1_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware1_times(:, :, i) = eeg_times;
    all_aware1_erps(:,:,i) = erps;
end
aware1_mean = mean(all_aware1_erps, 3);
aware1_times_mean = mean(all_aware1_times, 3);

pert_onset_eegs = dir('**/*_aware2*.mat');
all_aware2_times = [];
all_aware2_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware2_times(:, :, i) = eeg_times;
    all_aware2_erps(:,:,i) = erps;
end
aware2_mean = mean(all_aware2_erps, 3);
aware2_times_mean = mean(all_aware2_times, 3);

pert_onset_eegs = dir('**/*_aware3*.mat');
all_aware3_times = [];
all_aware3_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware3_times(:, :, i) = eeg_times;
    all_aware3_erps(:,:,i) = erps;
end
aware3_mean = mean(all_aware3_erps, 3);
aware3_times_mean = mean(all_aware3_times, 3);

%trials without awareness
unaware_onset_eegs = dir('**/*_unaware_crit_eeg.mat');
all_unaware_onset_eeg_times = [];
all_unaware_onset_erps = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_unaware_onset_erps(:,:,i) = erps;
    all_unaware_onset_eeg_times(:, :, i) = eeg_times;
end
unaware_onset_erp_mean = mean(all_unaware_onset_erps, 3);
unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);

%plot pert erps
plot_channels = [18 24 22 21 23]; %central electrodes
figure;
subplot(2,1,1)
plot(aware1_times_mean, mean(aware1_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(aware2_times_mean, mean(aware2_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(aware3_times_mean, mean(aware3_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
%legend('aware', 'unaware')
fontsize(gca, 24, 'points');

subplot(2,1,2)
plot(results(1,:).relative_time_points{:} * 1000, mean(alltrial_cents, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(nopert_cents, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(bigpert_cents, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(aware_cents, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(unaware_cents, 'omitnan'), 'LineWidth',3);
l = line([0 0],[-10 2]); l.Color = 'b';
l = line([200 200],[-10 2]); l.Color = 'r';
title('Time course of vocal adaptation', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Mean adaptation magnitude (cents)', 'FontSize',30, 'FontWeight','bold')
legend('all valid trials', '0-cent trials', '200-cent trials', 'aware threshold tr.', 'unaware threshold tr.')
fontsize(gca, 24, 'points');

%% correlate vocal adaptations with ERPs
results = results(:, [1 2 20:22]);

erps_crit = load("/Users/diskuser/analysis/all_data/eeg/awareness_results.mat");
erps_crit = erps_crit.all_results;
erps_crit = renamevars(erps_crit, 'participant_id', 'participant');
erps_crit.erps = []; %fitlme function cannot work with this

%use only valid erp trials
erps_and_adaptations = innerjoin(erps_crit, results);


erps_and_adaptations = erps_and_adaptations(erps_and_adaptations.control == 0, :);

%prepare variables for lme
erps_and_adaptations.mean_aan = double(erps_and_adaptations.mean_aan);
erps_and_adaptations.mean_lp = double(erps_and_adaptations.mean_lp);

%fit linear mixed model
lme = fitlme(erps_and_adaptations, 'pitch_100_200~mean_aan+(1|participant)');
lme
lme = fitlme(erps_and_adaptations, 'pitch_300_500~mean_aan+(1|participant)');
lme
lme = fitlme(erps_and_adaptations, 'pitch_tfce~mean_aan+(1|participant)');
lme
lme = fitlme(erps_and_adaptations, 'pitch_300_500~mean_lp+(1|participant)');
lme
lme = fitlme(erps_and_adaptations, 'pitch_tfce~mean_lp+(1|participant)');
lme


%fit linear mixed model with direction
erps_and_adaptations.pitch_489_738_direction = nan(height(erps_and_adaptations), 1); 
erps_and_adaptations(erps_and_adaptations.pitch_489_738 > 0, :).pitch_489_738_direction = ones(height(erps_and_adaptations(erps_and_adaptations.pitch_489_738 > 0, :)), 1);
erps_and_adaptations(erps_and_adaptations.pitch_489_738 < 0, :).pitch_489_738_direction = zeros(height(erps_and_adaptations(erps_and_adaptations.pitch_489_738 < 0, :)), 1);
erps_and_adaptations.pitch_489_738 = abs(erps_and_adaptations.pitch_489_738);

lme = fitlme(erps_and_adaptations, 'pitch_489_738~mean_aan*pitch_489_738_direction+(1|participant)');
lme


lme = fitlme(erps_and_adaptations, 'pitch_489_738~mean_lp*pitch_489_738_direction+(1|participant)');
lme

