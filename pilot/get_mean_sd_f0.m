%calculate mean and sd F0 for the part before perturbation
% (used to calculate significant deviations after the pert)
clear;

%load the data
all_data = load("main\all_data.mat");
all_data = all_data.all_data;
f0s = all_data.f0;

%create new columns
all_data.mean_f0_before_pert = nan([height(all_data) 1]);
all_data.stdev_f0_before_pert = nan([height(all_data) 1]);

%fill the new columns
for i = 1:length(f0s)
    all_data(i, :).mean_f0_before_pert = mean(f0s{i});
    all_data(i, :).stdev_f0_before_pert = std(f0s{i});
end

%save the data
save('main\all_data.mat', 'all_data');
