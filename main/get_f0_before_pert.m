%calculate mean and sd F0 for the part before perturbation
% (used to calculate significant deviations after the pert)
clear;

%load the data
all_data = load('../../eeg_data/main/experiment/all_data_pertstart.mat');
all_data = all_data.all_data;

%create new columns
all_data.mean_f0_before_pert = nan([height(all_data) 1]);
all_data.stdev_f0_before_pert = nan([height(all_data) 1]);

%fill the new columns
for i = 1:height(all_data)
    current_trial = all_data(i, :);

    %skip trials with incorrect vocalization
    if isnan(current_trial.pert_start_time)
        continue;
    end

    sample_rate = current_trial.audapter_data.params.sr;
    time_points = current_trial.f0_time_points{1};
    f0 = current_trial.f0{1};

    time = (time_points - 1)/sample_rate; % transform time points (in n. of samples) to seconds
    time(time >= current_trial.pert_start_time) = []; %remove time points after pert
    f0_before_pert = f0(1:length(time)); % F0 is estimated for each timepoint

    %get f0 one second before the pertrubation
    goal_time = time(end) - 1;
    time(time < goal_time) = [];
    f0_before_pert = f0_before_pert(length(f0_before_pert) - length(time) + 1: end);

    all_data(i, :).mean_f0_before_pert = mean(f0_before_pert);
    all_data(i, :).stdev_f0_before_pert = std(f0_before_pert);
end

%save the data
save('../../eeg_data/main/experiment/all_data_meanf0.mat', 'all_data', '-v7.3');
disp('calculated mean and stdev of F0 before the pert')
