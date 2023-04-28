%calculate the magnitude of vocal adaptation at all timepoints after pert
clear;

%load the data
all_data = load('/Users/diskuser/analysis/all_data/experiment/all_data_afterpert.mat');
all_data = all_data.all_data;

%trimmed pitch cointains data within these latencies after pert onset
reaction_time = 0.060; %60 miliseconds, based on Hafke's paper
max_duration = 0.800; %the end of each vocalization is usually unstable

%calculate:
%deviation from the pre-perturbation mean for every time point
%deviation from pre-pert mean for every time point in a pre-selected time-window
%the mean value of this deviation
for i = 1:height(all_data)
    %load variables for this trial
    trial = all_data(i, :);
    sample_rate = trial.audapter_data.params.sr;
    time_points = trial.f0_time_points{1};
    time_pitch = (time_points - 1)/sample_rate;
    time_pitch = [time_pitch trial.f0{1}]; %f0 values and their timings

    %exclude faulty trials
    if isnan(trial.pert_start_time)
        continue;
    end

    %deviations in cents relative to pert onset
    cents = 100 * ((10 * log(time_pitch(:, 2) / trial.mean_f0_before_pert)) / log(2));
    time_pitch(:, 2) = cents;
    time_pitch(:, 1) = time_pitch(:, 1) - trial.pert_start_time;

    if length(time_pitch) < 379
        nan_padding = 379 - length(time_pitch);
        time_pitch = [time_pitch; repmat([nan nan], nan_padding, 1)];
    end

    %include only pitch around pert start
    time_pitch = time_pitch(time_pitch(:,1) > -0.2 & time_pitch(:,1) < max_duration, :);
 
    if length(time_pitch(:, 2)) < 97 | sum(abs(time_pitch(:,2)) > 100) > 0 %if vocalization too short or cointains outliers, skip
        disp('outlier')
        continue;
    elseif length(time_pitch) < 99   % some trials have one less sample point in the same interval, depends on e.g. audapter start time (this is ok)
        nan_padding = 100 - length(time_pitch);
        time_pitch = [time_pitch; repmat([nan nan], nan_padding, 1)];
    end

    %create new variables
    all_data.relative_time_points{i} = time_pitch(:, 1);
    all_data.pitch{i} = time_pitch(:, 2);
    pitch_60_800 = time_pitch(time_pitch(:,1) > 0.06, :);
    all_data.pitch_60_800(i) = mean(pitch_60_800(:, 2), 'omitnan');
    pitch_100_160 = time_pitch(time_pitch(:,1) > 0.1 & time_pitch(:,1) < 0.160, :);
    all_data.pitch_100_160(i) = mean(pitch_100_160(:, 2), 'omitnan');
    pitch_250_460 = time_pitch(time_pitch(:,1) > 0.250 & time_pitch(:,1) < 0.460, :);
    all_data.pitch_250_460(i) = mean(pitch_250_460(:, 2), 'omitnan');
end

%save the data
save('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat', "all_data", '-v7.3');
disp("calculated vocal reactions timecourse");