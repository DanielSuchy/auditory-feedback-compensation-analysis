%remove last 200 ms from the F0 signal, these tend to be faulty
clear;

all_data = load('main\all_data.mat');
all_data = all_data.all_data;
sample_rate = 16000;
trim_by = 0.300; % 200 ms

for i = 1:height(all_data)
    f0 = all_data.f0{i};
    time_points = all_data.f0_time_points{i};
    time_pitch = (time_points - 1)/sample_rate;

    total_length = time_pitch(end);
    goal_length = total_length - trim_by;
    time_pitch_result = time_pitch(time_pitch<goal_length);
    time_points_result = time_points(1:length(time_pitch_result));
    f0_result = f0(1:length(time_pitch_result));

    all_data.f0{i} = f0_result;
    all_data.f0_time_points{i} = time_points_result;
end

save('main\all_data.mat', 'all_data', '-v7.3');
disp('Trimmed F0 signal');