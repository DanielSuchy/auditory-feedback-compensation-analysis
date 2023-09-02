clear;

%% control trials
%bigpert trials
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
    all_pert_onset_erps(:,:,i) = erps;
end
pert_onset_erp_mean = mean(all_pert_onset_erps, 3);

%trials without pert onset
nopert_onset_eegs = dir('**/*_nopert_onset_eeg.mat');
all_nopert_onset_eeg_times = [];
all_nopert_onset_erps = [];
for i=1:length(nopert_onset_eegs)
    file = [nopert_onset_eegs(i).folder '/' nopert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_nopert_onset;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_nopert_onset_erps(:,:,i) = erps;
end
nopert_onset_erp_mean = mean(all_nopert_onset_erps, 3);

%select data for aan and lp
bigpert_lp = all_pert_onset_erps(:,401:501,:);
nopert_lp = all_nopert_onset_erps(:, 401:501,:);
%eeglab2loreta(EEG.chanlocs, bigpert_lp, 'exporterp', 'on');

%export data into txt files for loreta
cd('/Users/diskuser/analysis/all_data/eeg/source_localization/')
for participant=1:30
    m = bigpert_lp(:,:,participant)';
    name = ['bigpert_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['bigpert_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end
for participant=1:30
    m = nopert_lp(:,:,participant)';
    name = ['nopert_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['nopert_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end

%% critical trials
%load ERPs rated as aware
cd('/Users/diskuser/analysis/all_data/eeg/')
aware_files = dir('**/*_aware*_crit_eeg.mat');
all_aware_erps = [];
for participant_id=1:35
    pattern =  ['S' num2str(participant_id) '_'];
    if strcmp(pattern, 'S8_')
        continue;
    end
    erps_part = [];
    for i=1:length(aware_files)
        if contains(aware_files(i).name, pattern)
            file = [aware_files(i).folder '/' aware_files(i).name];
            eeg = load(file);
            eeg = eeg.erp_data;
            erp = eeg.data;
            erps_part = cat(3,erps_part, erp);
        end
    end
    erps_part = mean(erps_part, 3); %mean ERP for this participant accross all aware trials, regardless of specific awareness rating
    all_aware_erps = cat(3, all_aware_erps, erps_part);
end

%load ERPs rated as unaware
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

%select data for aan and lp
aware_lp = all_aware_erps(:,401:501,:);
unaware_lp = all_unaware_onset_erps(:, 401:501,:);
aware_aan = all_aware_erps(:,301:351,:);
unaware_aan = all_unaware_onset_erps(:, 301:351,:);


%export data into txt files for loreta
cd('/Users/diskuser/analysis/all_data/eeg/source_localization_lp/')
for participant=1:29
    m = aware_lp(:,:,participant)';
    name = ['aware_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['aware_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end
for participant=1:29
    m = unaware_lp(:,:,participant)';
    name = ['unaware_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['unaware_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end

cd('/Users/diskuser/analysis/all_data/eeg/source_localization_aan/')
for participant=1:29
    m = aware_aan(:,:,participant)';
    name = ['aware_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['aware_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end
for participant=1:29
    m = unaware_aan(:,:,participant)';
    name = ['unaware_participant' num2str(participant) '.xls'];
    writematrix(m, name);
    name = ['unaware_participant' num2str(participant) '.txt'];
    writematrix(m, name, 'Delimiter','tab');
end