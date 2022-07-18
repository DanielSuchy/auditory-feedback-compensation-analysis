% for f0 data from each trial, mark when the pertrubation starts and ends
clear;

%load the data
f0_data = load("main\S1\S1_F0.mat");
f0_data = f0_data.f0s;
audapter_data = load("main\S1\S1_block1_PertrurbExpPilot.mat");
audapter_data = transpose(audapter_data.audapter_data);
if height(audapter_data) ~= height(f0_data)
    disp('Size of the data does not match!')
    return
end

f0_data_labeled = table();
for trial = 1:height(audapter_data)
    % load ost and the time axis
    % you can tell when the pert begins based on number of recorded data points
    % and the interval between them
    ost_status = audapter_data{trial}.ost_stat; % perturbation status for each time-point in the recording
    ost_pert_flag = 3; % if ost_status == 3, perturbation is ongoing
    frame_dur = audapter_data{trial}.params.frameLen / audapter_data{trial}.params.sr; % time-interval between recorded datapoints
    t_axis = 0 : frame_dur : frame_dur * (size(audapter_data{trial}.fmts, 1) - 1); %time axis for the duration of the vocalization
    if length(t_axis) ~= length(ost_status)
        disp('ost data failed to load')
        return
    end
    
    %calculate perturbation start and end
    pert_time_points = t_axis(ost_status == ost_pert_flag); %select time-points with ongoing pert
    pert_start_time = pert_time_points(1);
    pert_end_time = pert_time_points(end);

    f0 = f0_data(trial);
    f0_data_labeled = [f0_data_labeled; table(f0, pert_start_time, pert_end_time)];
end


