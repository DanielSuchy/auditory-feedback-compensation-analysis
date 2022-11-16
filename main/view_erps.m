clear all;

%% voice onset
%load the data
%individually
%voice_onset_erp = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_voice_onset_erps.mat');
%voice_onset_erp = voice_onset_erp.ERP_voice_onset;
%voice_onset_eeg = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_voice_onset_eeg.mat');
%voice_onset_eeg = voice_onset_eeg.EEG_voice_onset;
%or for the whole batch
cd('../../eeg_data/main/eeg/');
voice_onset_erps = dir('**/*voice_onset_erps.mat');
all_erps = [];
for i=1:length(voice_onset_erps)   
    file = [voice_onset_erps(i).folder '/' voice_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_voice_onset;
    all_erps(:,:,i) = erps;
end
voice_onset_erp_mean = mean(all_erps, 3);

voice_onset_eegs = dir('**/*voice_onset_eeg.mat');
all_eeg_times = [];
for i=1:length(voice_onset_eegs)
    file = [voice_onset_eegs(i).folder '/' voice_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_voice_onset;
    eeg_times = eeg.times;
    all_eeg_times(:, :, i) = eeg_times;
end
eeg_times_mean = mean(all_eeg_times, 3);

%plot voice onset erps
plot_channels = [5 6 18 21 22 23 24];
figure;
plot(eeg_times_mean, mean(voice_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
%hold on
%plot(EEG_nopert_onset.times, mean(ERP_nopert_onset(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
%legend('Perturbation', 'No perturbation')
title('Voice onset ERP')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';


%% perturbation onset - bigpert vs nopert
%load the data
%trials with pert onset
pert_onset_erps = dir('**/*_pert_onset_erps.mat');
all_pert_onset_erps = [];
for i=1:length(pert_onset_erps)   
    file = [pert_onset_erps(i).folder '/' pert_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_pert_onset;
    all_pert_onset_erps(:,:,i) = erps;
end
pert_onset_erp_mean = mean(all_pert_onset_erps, 3);

pert_onset_eegs = dir('**/*_pert_onset_eeg.mat');
all_pert_onset_eeg_times = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_pert_onset;
    eeg_times = eeg.times;
    all_pert_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_pert_onset_times_mean = mean(all_pert_onset_eeg_times, 3);

%trials without pert onset
nopert_onset_erps = dir('**/*_nopert_onset_erps.mat');
all_nopert_onset_erps = [];
for i=1:length(nopert_onset_erps)   
    file = [nopert_onset_erps(i).folder '/' nopert_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_nopert_onset;
    all_nopert_onset_erps(:,:,i) = erps;
end
nopert_onset_erp_mean = mean(all_nopert_onset_erps, 3);

nopert_onset_eegs = dir('**/*_nopert_onset_eeg.mat');
all_nopert_onset_eeg_times = [];
for i=1:length(nopert_onset_eegs)
    file = [nopert_onset_eegs(i).folder '/' nopert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_nopert_onset;
    eeg_times = eeg.times;
    all_nopert_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_nopert_onset_times_mean = mean(all_nopert_onset_eeg_times, 3);

%plot pert erps
%plot_channels = [5 6 18 21 22 23 24]; %central electrodes
plot_channels = [30 16 8 19 7 27 29 15 9 20 10]; % right hemisphere electrodes
figure;
plot(eeg_pert_onset_times_mean, mean(pert_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(eeg_nopert_onset_times_mean, mean(nopert_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
legend('Perturbation', 'No perturbation')
title('Perturbation onset ERPs')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';

%% pertrubation onset - aware vs unaware
%load the data
%trials with awareness
aware_onset_erps = dir('**/*_aware_onset_erps.mat');
all_aware_onset_erps = [];
for i=1:length(aware_onset_erps)   
    file = [aware_onset_erps(i).folder '/' aware_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_aware_onset;
    all_aware_onset_erps(:,:,i) = erps;
end
aware_onset_erp_mean = mean(all_aware_onset_erps, 3);

aware_onset_eegs = dir('**/*_aware_onset_eeg.mat');
all_aware_onset_eeg_times = [];
for i=1:length(aware_onset_eegs)
    file = [aware_onset_eegs(i).folder '/' aware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_aware_onset;
    eeg_times = eeg.times;
    all_aware_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_aware_onset_times_mean = mean(all_aware_onset_eeg_times, 3);

%trials without awareness
unaware_onset_erps = dir('**/*_unaware_onset_erps.mat');
all_unaware_onset_erps = [];
for i=1:length(unaware_onset_erps)   
    file = [unaware_onset_erps(i).folder '/' unaware_onset_erps(i).name];
    erps = load(file);
    erps = erps.ERP_unaware_onset;
    all_unaware_onset_erps(:,:,i) = erps;
end
unaware_onset_erp_mean = mean(all_unaware_onset_erps, 3);

unaware_onset_eegs = dir('**/*_unaware_onset_eeg.mat');
all_unaware_onset_eeg_times = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_unaware_onset;
    eeg_times = eeg.times;
    all_unaware_onset_eeg_times(:, :, i) = eeg_times;
end
eeg_unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);

%plot pert erps
plot_channels = [5 6 18 21 22 23 24]; %central electrodes
%plot_channels = [30 16 8 19 7 27 29 15 9 20 10]; % right hemisphere electrodes
figure;
plot(eeg_aware_onset_times_mean, mean(aware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(eeg_unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
legend('aware', 'unaware')
title('Perturbation onset ERPs (critical trial awareness)')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';