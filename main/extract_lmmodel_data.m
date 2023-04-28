clear;

%% aware vs unaware
cd('/Users/diskuser/analysis/all_data/eeg/')
all_data = dir('**/*aware*eeg.mat');
all_results = table();
for i = 1:height(all_data)
    filename = [all_data(i).folder '/' all_data(i).name];
    aware = ~contains(filename, 'unaware');
    control = contains(filename, 'control');
    participant_id = strsplit(all_data(i).name, '_');
    participant_id = {participant_id{1}};
    participant_id = str2double(extract(participant_id, digitsPattern));

    %load the data
    data = load(filename);

    if aware && control
       data = data.EEG_aware_control;
       if height(data) == 0 %the participant does not have any trials of this type, e.g. false alarms, this is ok
        continue; 
       end
    elseif aware && ~control
       data = data.EEG_aware_crit;
    elseif ~aware && control
       data = data.EEG_unaware_control;
    elseif ~aware && ~control
       data = data.EEG_unaware_crit;
    end
    times = data.times;
    erps = data.data; %electrodes x voltage at time points x trials
    events = struct2table(data.event);
    trial = events(contains(events.type, {'Trial'}),:);
    trial = str2double(extractAfter(trial.type, '_'));

    %average accross electrodes, use central electrodes only (Cz, FC1, FC2, CP1, CP2)
    select_channels = [18 21 22 23 24];
    erps = erps(select_channels, :, :);
    erps = mean(erps);
    erps = squeeze(erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; erps];
    aan = times_erps(:,times_erps(1,:) >= 100 & times_erps(1,:) <= 160);
    lp = times_erps(:,times_erps(1,:) >= 250 & times_erps(1,:) <= 460);

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
    results = table(participant_id, trial, control, aware, mean_aan, mean_lp);
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
    erps = erps(select_channels, :, :);
    erps = mean(erps);
    erps = squeeze(erps)'; %makes it trials x average voltage at time points

    %select relevant time windows
    times_erps = [times; erps];
    aan = times_erps(:,times_erps(1,:) >= 100 & times_erps(1,:) <= 160);
    lp = times_erps(:,times_erps(1,:) >= 250 & times_erps(1,:) <= 460);

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
