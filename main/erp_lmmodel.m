clear;

cd('/Users/diskuser/analysis/eeg_data/main/eeg/')
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

    %average accross electrodes
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
