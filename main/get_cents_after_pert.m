%calculate the magnitude of vocal adaptation at all timepoints after pert
clear;

%load the data
all_data = load('/Users/diskuser/analysis/all_data/experiment/all_data_afterpert.mat');
all_data = all_data.all_data;

%calculate:
%deviation from the pre-perturbation mean for every time point after pert
%deviation from pre-pert mean for every time point in a pre-selected time-window
%the mean value of this deviation
reaction_time = 0.060; %60 miliseconds, based on Hafke's paper
max_duration = 0.800; % the end of each vocalization is usually unstable
all_data.mean_cents_trimmed = nan([height(all_data), 1]);
for i = 1:height(all_data)
    trial = all_data(i, :);
    sample_rate = trial.audapter_data.params.sr;
    time_points = trial.f0_time_points{1};
    time_pitch = (time_points - 1)/sample_rate;
    time_pitch = [time_pitch trial.f0{1}]; %f0 values and their timings
    %deviations in cents after pert
    tp_after_pert = time_pitch(time_pitch(:, 1) >= trial.pert_start_time, :);
    cents = 100 * ((10 * log(tp_after_pert(:, 2) / trial.mean_f0_before_pert)) / log(2));
    all_data.cents_after_pert{i} = cents;

    %deviation during a pre-selected time window
    %remove outliers (adaptation > 100 cents)
    if cents & sum(abs(cents) > 100) == 0
        cents_after_pert = [tp_after_pert(:,1) cents];
        %relative timing to pert start
        cents_after_pert(:, 1) = cents_after_pert(:, 1) - cents_after_pert(1,1);
        cents_after_pert = cents_after_pert(cents_after_pert(:, 1) > reaction_time & ...
            cents_after_pert(:, 1) < max_duration, :);
        all_data.cents_after_pert_trimmed{i} = cents_after_pert(:,2);
        all_data.mean_cents_trimmed(i) = mean(cents_after_pert(:,2));
    end
end

%save the data
save('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat', "all_data", '-v7.3');
disp("calculated vocal reactions timecourse");