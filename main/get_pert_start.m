% for f0 data from each trial, mark when the pertrubation starts and ends
clear;

%load the data
all_data = load('/Users/diskuser/analysis/all_data/experiment/all_data_trimmed.mat');
all_data = all_data.all_data;
f0_data = all_data.f0;
audapter_data = all_data.audapter_data;
if height(audapter_data) ~= height(f0_data)
    disp('Size of the data does not match!')
    return
end

f0_data_labeled = table();
for trial = 1:height(audapter_data)
    % load ost and the time axis
    % you can tell when the pert begins based on number of recorded data points
    % and the interval between them
    ost_status = audapter_data(trial).ost_stat; % perturbation status for each time-point in the recording
    ost_pert_flag = 3; % if ost_status == 3, perturbation is ongoing
    frame_dur = audapter_data(trial).params.frameLen / audapter_data(trial).params.sr; % time-interval between recorded datapoints (in seconds)
    t_axis = 0 : frame_dur : frame_dur * (size(audapter_data(trial).fmts, 1) - 1); %time axis for the duration of the vocalization
    if length(t_axis) ~= length(ost_status)
        disp('ost data failed to load')
        %return
    end
    
    %calculate perturbation start and end
    pert_time_points = t_axis(ost_status == ost_pert_flag); %select time-points with ongoing pert
    if length(pert_time_points) > 1
        pert_start_time = pert_time_points(1);
        pert_end_time = pert_time_points(end);
    else % no vocalization during this trial or ost failed
        pert_start_time = nan;
        pert_end_time = nan;
    end

    %the perturbation needs to last at least 850 ms, otherwise the trial is
    %not valid (800ms for pert calculation, 50 ms for phonation ending)
    if pert_end_time - pert_start_time < 0.850
        pert_start_time = nan;
        pert_end_time = nan;
    end

    f0 = f0_data(trial);
    f0_data_labeled = [f0_data_labeled; table(pert_start_time, pert_end_time)];
end

%save the file
all_data = [all_data, f0_data_labeled];
save('/Users/diskuser/analysis/all_data/experiment/all_data_pertstart.mat', "all_data", '-v7.3');
disp("calculated pert start and end");

