%look at pitch accross time of any audio signal, to see if its ready
%for analysis
clear;

data = load('F:\materialy\thesis\analysis\pilot\main\S1\S1_F0.mat');
data = data.f0s(4); % select trial number here
data = data{1};

time_points = 1:length(data);

figure;
plot(time_points, data)