clear;

%% aware vs unaware
cd('/Users/diskuser/analysis/all_data/eeg/')
all_data = dir('**/*aware*eeg.mat');
all_results = table();
for i = 1:height(all_data)
    filename = [all_data(i).folder '/' all_data(i).name];
    control = contains(filename, 'control');

    if contains(filename, 'aware3')
        aware = 3;
    elseif contains(filename, 'aware2')
        aware = 2;
    elseif contains(filename, 'aware1')
        aware = 1;
    else
        aware = 0;
    end

    participant_id = strsplit(all_data(i).name, '_');
    participant_id = {participant_id{1}};
    participant_id = str2double(extract(participant_id, digitsPattern));

    %load the data
    data = load(filename);
    data = data.erp_data;

    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials
    events = struct2table(data.event);
    trial = events(contains(events.type, {'Trial'}),:);
    trial = str2double(extractAfter(trial.type, '_'));

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    mean_erps = erps(select_channels, :, :);
    mean_erps = mean(mean_erps);
    mean_erps = squeeze(mean_erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; mean_erps];
    aan = times_erps(:,times_erps(1,:) >= 100 & times_erps(1,:) <= 200);
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
    control = repmat(control, [l 1]);
    erps = permute(erps, [3 1 2]);
    results = table(participant_id, trial, control, aware, mean_aan, mean_lp, erps);
    all_results = [all_results; results];
end

save("awareness_results.mat", "all_results");

%% control trials
cd('/Users/diskuser/analysis/all_data/eeg/')
all_data = dir('**/*pert_onset_eeg.mat');
all_results = table();

for i = 1:height(all_data)
    filename = [all_data(i).folder '/' all_data(i).name];
    has_pert = isempty(strfind(filename, 'nopert'));
    participant_id = strsplit(all_data(i).name, '_');
    participant_id = {participant_id{1}};
    t = [filename ' ' participant_id ' ' has_pert];
    participant_id = str2double(extract(participant_id, digitsPattern));

    %load the data
    data = load(filename);
    if has_pert
       data = data.EEG_pert_onset;
    else
       data = data.EEG_nopert_onset;
    end
    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials
    events = struct2table(data.event);
    trial = events(contains(events.type, {'Trial'}),:);
    trial = str2double(extractAfter(trial.type, '_'));

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    mean_erps = erps(select_channels, :, :);
    mean_erps = mean(mean_erps);
    mean_erps = squeeze(mean_erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; mean_erps];
    aan = times_erps(:,times_erps(1,:) >= 100 & times_erps(1,:) <= 200);
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
    results = table(participant_id, trial, has_pert, mean_aan, mean_lp);
    all_results = [all_results; results];
end

save("control_trial_results.mat", "all_results");
