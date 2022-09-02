%see how many trials meet the 2sd condition, filter them out and
%assign the type of reaction (following, opposing) to them
clear;

all_data = load('main\all_data.mat');
all_data = all_data.all_data;

%what percentage of trials meets Hafke's condition
valid_data = all_data(all_data.meets_2sd_condition == true, :);
100 * (height(valid_data) / height(all_data))

%separate control trials from trials with pert
valid_data = all_data(all_data.pert_magnitude ~= 0, :);
control_trials = all_data(all_data.pert_magnitude == 0, :);

%what percentage of control trials meets Hafke's condition
control_tr_with_react = control_trials(control_trials.meets_2sd_condition == true, :);
100 * (height(control_tr_with_react) / height(control_trials))

%what percentage of pert trials meet Hafke's condition
valid_data_with_react = valid_data(valid_data.meets_2sd_condition == true, :);
100 * (height(valid_data_with_react) / height(valid_data))

%can we test the difference between control and pert trials?
%H1 = pert trials are more likely to meet the 2sd condition
%H0 = there is no such difference
comparision = table(all_data.pert_magnitude, all_data.meets_2sd_condition);
comparision = renamevars(comparision, {'Var1', 'Var2'}, {'trial_type', 'meets_condition'});
comparision.trial_type(comparision.trial_type ~= 0, :) = 1;

%fisher's exact test 
[trial_types, ~, n] = unique(comparision.trial_type);
meets_condition_true = accumarray(n, comparision.meets_condition, [], @(x)  sum(x));
meets_condition_false = [sum(comparision.trial_type == 0); sum(comparision.trial_type == 1)] - meets_condition_true;
contingency_t = table(trial_types, meets_condition_true, meets_condition_false);
[h,p,stats] = fishertest(contingency_t(:,2:3));

%classify data as aware/unaware
%how many aware vs. unaware trials meet the 2sd condition
valid_data.aware = valid_data.how_noticeable_response > 0;
aware_data = valid_data(valid_data.aware == 1, :);
unaware_data = valid_data(valid_data.aware == 0, :);
aware_meets_condition = aware_data(aware_data.meets_2sd_condition == 1, :);
unaware_meets_condition = unaware_data(unaware_data.meets_2sd_condition == 1, :);
100*(height(aware_meets_condition) / height(aware_data))
100*(height(unaware_meets_condition) / height(unaware_data))

%assign type of response to each trial with reaction
valid_data = valid_data_with_react;
valid_data.reaction_type = strings([height(valid_data), 1]);
for i = 1:height(valid_data)
    trial = valid_data(i, :);
    if (trial.pert_magnitude > 0 && trial.difference_in_cents > 0)
        valid_data.reaction_type(i, :) = 'following';
    elseif (trial.pert_magnitude < 0 && trial.difference_in_cents < 0)
        valid_data.reaction_type(i, :) = 'following';
    elseif (trial.pert_magnitude > 0 && trial.difference_in_cents < 0)
        valid_data(i, :).reaction_type = 'opposing';
    elseif (trial.pert_magnitude < 0 && trial.difference_in_cents > 0)
        valid_data(i, :).reaction_type = 'opposing';
    end
end

%percentages of opposing and following
opposing = valid_data(valid_data.reaction_type == 'opposing', :);
following = valid_data(valid_data.reaction_type == 'following', :);
100*(height(opposing) / height(valid_data))
100*(height(following) / height(valid_data))

save('main\valid_data.mat', 'valid_data');