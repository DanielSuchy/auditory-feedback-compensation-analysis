clear;

%% control trials
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_pert_onset_eeg.mat');
all_pert_onset_eeg_times = [];
all_pert_onset_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_pert_onset;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_pert_onset_eeg_times(:, :, i) = eeg_times;
    all_pert_onset_erps(:,:,i) = erps;
end
pert_onset_erp_mean = mean(all_pert_onset_erps, 3);
pert_onset_times_mean = mean(all_pert_onset_eeg_times, 3);

bigpert_mean = pert_onset_erp_mean(:,251:351); %300-500 ms
eeglab2loreta(EEG.chanlocs, bigpert_mean, 'exporterp', 'on');

%% critical trials
%load mean ERP with awareness rating 1
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_aware1_crit*.mat');
all_aware1_times = [];
all_aware1_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    times = eeg.times;
    all_aware1_times(:, :, i) = times;
    all_aware1_erps(:,:,i) = erps;
end
aware1_mean = mean(all_aware1_erps, 3);
aware1_times_mean = mean(all_aware1_times, 3);

%load mean ERP with awareness rating 2
pert_onset_eegs = dir('**/*_aware2_crit*.mat');
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

%load mean ERP with awareness rating 3
pert_onset_eegs = dir('**/*_aware3_crit*.mat');
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
unaware_mean = mean(all_unaware_onset_erps, 3);
unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);



%mean erp of all participants, 300-500ms, all electrodes
aware1_mean = aware1_mean(:,251:351); %300-500 ms
aware2_mean = aware2_mean(:,251:351); 
aware3_mean = aware3_mean(:,251:351);
unaware_mean = unaware_mean(:,251:351); 
aware_mean = cat(3, aware1_mean, aware2_mean, aware3_mean);
aware_mean = mean(aware_mean, 3);
difference = aware_mean - unaware_mean;
eeglab2loreta(eeg.chanlocs, difference, 'exporterp', 'on');