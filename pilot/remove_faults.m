%remove faulty trials
clear;

all_data = load('main\all_data.mat');
all_data = all_data.all_data;

all_data(all_data.ost_worked == 0, :) = [];
all_data(isnan(all_data.pert_start_time), :) = [];


save('main\all_data.mat', 'all_data');
disp('Removed faulty trials');