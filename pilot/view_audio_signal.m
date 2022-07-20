%look at pitch accross time of any audio signal, to see if its ready
%for analysis
clear;

data = load('main\all_data.mat');
data = data.all_data;
f0 = data.f0(800); % select trial number here
f0 = f0{1};

time_points = 1:length(f0);

figure;
plot(time_points, f0)