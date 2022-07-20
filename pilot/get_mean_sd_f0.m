%calculate mean and sd F0 for the part before perturbation
% (used to calculate significant deviations after the pert)
clear;

%load the data
all_data = load("main\all_data.mat");
all_data = all_data.all_data;

%create new columns
all_data.mean_f0_before_pert = nan([height(all_data) 1]);
all_data.stdev_f0_before_pert = nan([height(all_data) 1]);

%fill the new columns
for i = 1:height(all_data)
    current_trial = all_data(i, :);
    sample_rate = current_trial.audapter_data.params.sr;
    time_points = current_trial.f0_time_points{1};
    f0 = current_trial.f0{1};


    time = (time_points - 1)/sample_rate; % transform time points to seconds
    time(time >= current_trial.pert_start_time) = []; %remove time points after pert
    f0_before_pert = f0(1:length(time)); % F0 is estimated for each timepoint

    all_data(i, :).mean_f0_before_pert = mean(f0_before_pert);
    all_data(i, :).stdev_f0_before_pert = std(f0_before_pert);
end

%save the data
save('main\all_data.mat', 'all_data');
disp('calculated mean and stdev of F0 before the pert')
