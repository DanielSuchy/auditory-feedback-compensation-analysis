clear;

%% load the data
behavior_data = [];
cd 'F:/materialy/thesis/analysis/pilot/';
files = dir('staircase/**/*.mat');
for i = 1:length(files)
    current_file = files(i);
    current_file = cat(2, current_file.folder, '\', current_file.name);
    current_data = load(current_file);
    behavior_data = [behavior_data; current_data.whole_data];
end

%% plot the staircase
p1 = behavior_data(behavior_data.ID == 1 & behavior_data.pert_type == 1, :);
p2 = behavior_data(behavior_data.ID == 2 & behavior_data.pert_type == 1, :);
p3 = behavior_data(behavior_data.ID == 3 & behavior_data.pert_type == 1, :);
p1n = behavior_data(behavior_data.ID == 1 & behavior_data.pert_type == -1, :);
p2n = behavior_data(behavior_data.ID == 2 & behavior_data.pert_type == -1, :);
p3n = behavior_data(behavior_data.ID == 3 & behavior_data.pert_type == -1, :);

figure;
subplot(2,1,1)
plot(p1.trial, p1.pert_magnitude, '-o')
hold on
plot(p2.trial, p2.pert_magnitude, '-o')
plot(p3.trial, p3.pert_magnitude, '-o')
hold off
title('Upward perturbation staircase by participant')
xlabel('trial')
ylabel('pert. magnitude')
set(gca,'FontSize',16)

subplot(2,1,2)
plot(p1n.trial, p1n.pert_magnitude, '-o')
hold on
plot(p2n.trial, p2n.pert_magnitude, '-o')
plot(p3n.trial, p3n.pert_magnitude, '-o')
hold off
title('Downward perturbation staircase by participant')
xlabel('trial')
ylabel('pert. magnitude')
set(gca,'FontSize',16)

%% count the reversals
positive_trials = behavior_data(behavior_data.pert_type == 1, :);
negative_trials = behavior_data(behavior_data.pert_type == -1, :);
participants = unique(behavior_data.ID);

% for positive perts
for i = 1:length(participants)
    ID = participants(i);
    ID_results = positive_trials(positive_trials.ID == ID, :);
    reversals = 0;
    % go from 2 to length-1, bc. first and last trials are not reversals
    for j = 2:height(ID_results)-1
        current_pert = table2array(ID_results(j,"pert_magnitude"));
        previous_pert = table2array(ID_results(j-1, "pert_magnitude"));
        next_pert = table2array(ID_results(j+1, "pert_magnitude"));
    
        if (current_pert > previous_pert && current_pert > next_pert)
            reversals = reversals + 1;
        elseif (current_pert < previous_pert && current_pert < next_pert)
            reversals = reversals + 1;
        end
    end
    disp(cat(2, ID, reversals))
end

% for negative perts
for i = 1:length(participants)
    ID = participants(i);
    ID_results = negative_trials(negative_trials.ID == ID, :);
    reversals = 0;
    % go from 2 to length-1, bc. first and last trials are not reversals
    for j = 2:height(ID_results)-1
        current_pert = table2array(ID_results(j,"pert_magnitude"));
        previous_pert = table2array(ID_results(j-1, "pert_magnitude"));
        next_pert = table2array(ID_results(j+1, "pert_magnitude"));
    
        if (current_pert > previous_pert && current_pert > next_pert)
            reversals = reversals + 1;
        elseif (current_pert < previous_pert && current_pert < next_pert)
            reversals = reversals + 1;
        end
    end
    disp(cat(2, ID, reversals))
end

%% calculate the threshold
%keep only the later trials
behavior_data = behavior_data(behavior_data.trial > 15, :);
positive_trials = behavior_data(behavior_data.pert_type == 1, :);
negative_trials = behavior_data(behavior_data.pert_type == -1, :);

%mean 50 percent threshold per participant and pert. direction
threshold_positive = accumarray(positive_trials.ID, positive_trials.pert_magnitude, [], @(x)  mean(x));
threshold_negative = accumarray(negative_trials.ID, negative_trials.pert_magnitude, [], @(x)  mean(x));
threshold = table(participants, threshold_positive, threshold_negative);