%look at pitch accross time of any audio signal, to see if its ready
%for analysis
clear;

data = load('main\all_data.mat');
data = data.all_data;
data = data.f0(5); % select trial number here
data = data{1};

time_points = 1:length(data);

figure;
plot(time_points, data)