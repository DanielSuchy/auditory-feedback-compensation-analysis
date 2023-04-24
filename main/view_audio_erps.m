%overlap audio and ERP signal and relate their onsets to see if they correlate
clear;

%load the data
%% load the data
results = load('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat');
results = results.all_data;

%exclude invalid trials (e.g. incorrect vocalization)
results = results(results.ost_worked == 1, :);
results = results(~isnan(results.pert_start_time), :);

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

%% overlap vocalization and ERP timecourse
%load the data
%trials with awareness
cd('/Users/diskuser/analysis/all_data/eeg/')
aware_onset_erps = dir('**/*_aware_crit_erps.mat');
all_aware_onset_erps = [];
for i=1:length(aware_onset_erps)   
    file = [aware_onset_erps(i).folder '/' aware_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_aware_crit;
    all_aware_onset_erps(:,:,i) = erps;
end
aware_onset_erp_mean = mean(all_aware_onset_erps, 3);

aware_onset_eegs = dir('**/*_aware_crit_eeg.mat');
all_aware_onset_eeg_times = [];
for i=1:length(aware_onset_eegs)
    file = [aware_onset_eegs(i).folder '/' aware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_aware_crit;
    eeg_times = eeg.times;
    all_aware_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_aware_onset_times_mean = mean(all_aware_onset_eeg_times, 3);

%trials without awareness
unaware_onset_erps = dir('**/*_unaware_crit_erps.mat');
all_unaware_onset_erps = [];
for i=1:length(unaware_onset_erps)   
    file = [unaware_onset_erps(i).folder '/' unaware_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_unaware_crit;
    all_unaware_onset_erps(:,:,i) = erps;
end
unaware_onset_erp_mean = mean(all_unaware_onset_erps, 3);

unaware_onset_eegs = dir('**/*_unaware_crit_eeg.mat');
all_unaware_onset_eeg_times = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_unaware_crit;
    eeg_times = eeg.times;
    all_unaware_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);

%plot pert erps
plot_channels = [18 24 22 21 23]; %central electrodes
figure;
subplot(2,1,1)
plot(eeg_aware_onset_times_mean, mean(aware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(eeg_unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-1 1])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
fill([100 100.0001 199.9999 200], [-1 1 1 -1], 'y', FaceAlpha=0.2)
fill([300 300.0001 499.9999 500], [-1 1 1 -1], 'y', FaceAlpha=0.2)
legend('aware', 'unaware')
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
