clear;

all_data = load('main\all_data.mat');
all_data = all_data.all_data;
all_data.mean_f0_after_pert = nan([height(all_data), 1]);
all_data.meets_2sd_condition = zeros([height(all_data), 1]);
all_data.mean_f0_during_condition = nan([height(all_data), 1]);
all_data.difference_in_cents = nan([height(all_data), 1]);

%all_data = all_data(796, :);
for trial_id = 1:height(all_data)
    %load required variables from the table
    trial = all_data(trial_id, :);
    sample_rate = trial.audapter_data.params.sr;
    time_points = trial.f0_time_points{1};
    time_pitch = (time_points - 1)/sample_rate;
    f0 = trial.f0{1};
    pert_start = trial.pert_start_time;
    reaction_time = 0.060; %60 miliseconds, based on Hafke's paper 
    
    %get F0 values after the pert start + latency
    time_pitch(time_pitch < pert_start + reaction_time) = [];
    f0_after_pert = f0(length(f0) - length(time_pitch) + 1:end);
    mean_f0_after_pert = mean(f0_after_pert);
    all_data(trial_id, :).mean_f0_after_pert = mean_f0_after_pert;
    
    %cut the part 800 miliseconds after pert start
    time_limit = time_pitch(1) + 0.800;
    time_pitch(time_pitch > time_limit) = [];
    relevant_f0 = f0_after_pert(1:length(time_pitch));
    
    %for every time point in F0, specify if it is greater than mean + 2sd
    meets_condition1 = relevant_f0 < trial.mean_f0_before_pert - 2*trial.stdev_f0_before_pert;
    meets_condition2 = relevant_f0 > trial.mean_f0_before_pert + 2*trial.stdev_f0_before_pert;
    meets_condition = meets_condition1 + meets_condition2; % one or the other
    meets_condition_table = [relevant_f0 time_pitch meets_condition];

    %check if the 2sd condition lasts at least 120 ms
    for i = 1:length(meets_condition_table)
        meets_condition = meets_condition_table(i, 3);
        if meets_condition == 1
            x = meets_condition;
            j = i;
            while x ~= 0 && j <= height(meets_condition_table) %find when the condition stops
                x = meets_condition_table(j, 3);
                j = j + 1;
            end
            j = j - 2;
            condition_start_end = meets_condition_table(i:j,:);
            % check is stop -> end interval is at least 120 ms
            if height(condition_start_end) > 1 && (condition_start_end(end,2) - condition_start_end(1,2) > 0.120)
                all_data(trial_id, :).mean_f0_during_condition = mean(condition_start_end(:,1));
                all_data(trial_id, :).meets_2sd_condition = true;
                all_data(trial_id, :).difference_in_cents = 100 * ((10 * log(mean(condition_start_end(:, 1)) / all_data.mean_f0_before_pert(trial_id, :))) / log(2));
                break;
            end
        end
    end
end

save("main\all_data.mat", "all_data", '-v7.3');
disp("calculated F0 after pert");