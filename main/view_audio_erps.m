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
results(abs(results.pitch_60_800) > 100, :) = [];

%get different trial types
nopert_trials = results(results.pert_magnitude == 0.0001, :);
bigpert_trials = results(results.pert_magnitude == 2, :);
critical_trials = results(results.pert_magnitude < 2 & results.pert_magnitude > 0.0001, :);
aware_trials = critical_trials(critical_trials.awareness > 0, :);
unaware_trials = critical_trials(critical_trials.awareness == 0, :);

alltrial_cents = horzcat(results.pitch{:})';
nopert_cents = horzcat(nopert_trials.pitch{:})';
bigpert_cents = horzcat(bigpert_trials.pitch{:})';
aware_cents = horzcat(aware_trials.pitch{:})';
unaware_cents = horzcat(unaware_trials.pitch{:})';

%% plot average vocalization timecourse
figure;
%plot(results(1,:).relative_time_points{:} * 1000, mean(alltrial_cents, 'omitnan'), 'LineWidth',3);
%hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(nopert_cents, 'omitnan'), 'LineWidth',3);
hold on;
plot(results(1,:).relative_time_points{:} * 1000, mean(bigpert_cents, 'omitnan'), 'LineWidth',3);
plot(results(1,:).relative_time_points{:} * 1000, mean(aware_cents, 'omitnan'), 'LineWidth',3);
plot(results(1,:).relative_time_points{:} * 1000, mean(unaware_cents, 'omitnan'), 'LineWidth',3);
l = line([0 0],[-10 3]); l.Color = 'b';
l = line([200 200],[-10 3]); l.Color = 'r';
title('Time course of vocal adaptation', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Mean adaptation magnitude (cents)', 'FontSize',30, 'FontWeight','bold')
legend('0-cent trials', '200-cent trials', 'aware threshold tr.', 'unaware threshold tr.')
fontsize(gca, 24, 'points');

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
results = results(:, [1 2 20:23]);

erps_crit = load("/Users/diskuser/analysis/all_data/eeg/awareness_results.mat");
erps_crit = erps_crit.all_results;
erps_crit = renamevars(erps_crit, 'participant_id', 'participant');
erps_crit.erps = []; %fitlme function cannot work with this

%use only valid erp trials
results.key = string([num2str(results.participant), repmat(' ', [height(results) 1]), num2str(results.trial)]);
erps_crit.key = string([num2str(erps_crit.participant), repmat(' ', [height(erps_crit) 1]), num2str(erps_crit.trial)]);
erps_and_adaptations = results(ismember(erps_crit.key, intersect(erps_crit.key, results.key)), :);
erps_and_adaptations = innerjoin(erps_and_adaptations, erps_crit, Keys='key');

%erps_and_adaptations = innerjoin(erps_crit, results);


erps_and_adaptations = erps_and_adaptations(erps_and_adaptations.control == 0, :);

scatter(erps_and_adaptations.mean_aan, erps_and_adaptations.pitch_120_180)

%prepare variables for lme
erps_and_adaptations.mean_aan = double(erps_and_adaptations.mean_aan);
erps_and_adaptations.mean_lp = double(erps_and_adaptations.mean_lp);

%fit linear mixed model
lme = fitlme(erps_and_adaptations, 'pitch_120_180~mean_aan+(1|participant_erps_crit)');
lme

%fit linear mixed model with direction
erps_and_adaptations.pitch_120_180_direction = nan(height(erps_and_adaptations), 1); 
erps_and_adaptations(erps_and_adaptations.pitch_120_180 > 0, :).pitch_120_180_direction = ones(height(erps_and_adaptations(erps_and_adaptations.pitch_120_180 > 0, :)), 1);
erps_and_adaptations(erps_and_adaptations.pitch_120_180 < 0, :).pitch_120_180_direction = zeros(height(erps_and_adaptations(erps_and_adaptations.pitch_120_180 < 0, :)), 1);
erps_and_adaptations.pitch_120_180 = abs(erps_and_adaptations.pitch_120_180);

lme = fitlme(erps_and_adaptations, 'pitch_120_180~mean_aan*pitch_120_180_direction+(1|participant)');
lme

