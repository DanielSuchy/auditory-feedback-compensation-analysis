clear;

%% aware vs unaware
cd('/Users/diskuser/analysis/all_data/eeg/')
all_data = dir('**/*aware_onset_eeg.mat');
all_results = table();
for i = 1:height(all_data)
    filename = [all_data(i).folder '/' all_data(i).name];
    aware = isempty(strfind(filename, 'unaware'));
    participant_id = strsplit(all_data(i).name, '_');
    participant_id = {participant_id{1}};

    %load the data
    data = load(filename);
    if aware
       data = data.EEG_aware_onset;
    else
       data = data.EEG_unaware_onset;
    end
    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    erps = erps(select_channels, :, :);
    erps = mean(erps);
    erps = squeeze(erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; erps];
    aan = times_erps(:,times_erps(1,:) >= 50 & times_erps(1,:) <= 150);
    lp = times_erps(:,times_erps(1,:) >= 300 & times_erps(1,:) <= 500);

    %remove times from data structure
    aan = aan(2:end, :);
    lp = lp(2:end, :);

    %get a mean amplitude during time window for each trial
    mean_aan = mean(aan, 2);
    mean_lp = mean(lp, 2);

    %create a table for regression
    l = length(mean_aan);
    participant_id = repmat(participant_id, [l 1]);
    aware = repmat(aware, [l 1]);
    trial = (1:l)';
    results = table(participant_id, trial, aware, mean_aan, mean_lp);
    all_results = [all_results; results];
end

save("awareness_results.mat", "all_results");

%% include no-pert control trials in the model
critical_trial_results = all_results;
critical_trial_results.has_pert = ones(height(critical_trial_results), 1);
control_data = dir('**/*nopert_onset_eeg.mat');
control_results = table();
for i=1:height(control_data)
    filename = [control_data(i).folder '/' control_data(i).name];
    participant_id = strsplit(control_data(i).name, '_');
    participant_id = {participant_id{1}};

    %load the data
    data = load(filename);
    data = data.EEG_nopert_onset;
    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    erps = erps(select_channels, :, :);
    erps = mean(erps);
    erps = squeeze(erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; erps];
    aan = times_erps(:,times_erps(1,:) >= 50 & times_erps(1,:) <= 150);
    lp = times_erps(:,times_erps(1,:) >= 300 & times_erps(1,:) <= 500);

    %remove times from data structure
    aan = aan(2:end, :);
    lp = lp(2:end, :);

    %get a mean amplitude during time window for each trial
    mean_aan = mean(aan, 2);
    mean_lp = mean(lp, 2);

    %create a table for regression
    l = length(mean_aan);
    participant_id = repmat(participant_id, [l 1]);
    has_pert = ones(l, 1);
    aware = nan(l, 1);
    has_pert = zeros(l, 1);
    trial = (1:l)';
    results = table(participant_id, trial, aware, mean_aan, mean_lp, has_pert);
    control_results = [control_results; results];
end

all_results = [critical_trial_results; control_results];
save("awareness_control_results.mat", "all_results");

%% control trials
cd('/Users/diskuser/analysis/eeg_data/main/eeg/')
all_data = dir('**/*pert_onset_eeg.mat');
all_results = table();

for i = 1:height(all_data)
    filename = [all_data(i).folder '/' all_data(i).name];
    has_pert = isempty(strfind(filename, 'nopert'));
    participant_id = strsplit(all_data(i).name, '_');
    participant_id = {participant_id{1}};
    t = [filename ' ' participant_id ' ' has_pert];

    %load the data
    data = load(filename);
    if has_pert
       data = data.EEG_pert_onset;
    else
       data = data.EEG_nopert_onset;
    end
    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    erps = erps(select_channels, :, :);
    erps = mean(erps);
    erps = squeeze(erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; erps];
    aan = times_erps(:,times_erps(1,:) >= 150 & times_erps(1,:) <= 250);
    lp = times_erps(:,times_erps(1,:) >= 300 & times_erps(1,:) <= 500);

    %remove times from data structure
    aan = aan(2:end, :);
    lp = lp(2:end, :);

    %get a mean amplitude during time window for each trial
    mean_aan = mean(aan, 2);
    mean_lp = mean(lp, 2);
    
    %create a table for regression
    l = length(mean_aan);
    participant_id = repmat(participant_id, [l 1]);
    has_pert = repmat(has_pert, [l 1]);
    trial = (1:l)';
    results = table(participant_id, trial, has_pert, mean_aan, mean_lp);
    all_results = [all_results; results];
end

save("control_trial_results.mat", "all_results");
