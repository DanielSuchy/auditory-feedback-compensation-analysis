clear;

%load the data
results = load('../../eeg_data/main/experiment/all_data_afterpert.mat');
results = results.all_data;

%exclude invalid trials (e.g. incorrect vocalization)
results = results(results.ost_worked == 1, :);
results = results(~isnan(results.pert_start_time), :);

%exclude outliers
normal_variation = 2*std(abs(results.difference_in_cents), 'omitnan');
results(abs(results.difference_in_cents) > normal_variation, :) = [];
results(abs(results.difference_in_cents) > 100, :) = [];

%view the data
histogram(results.difference_in_cents)

%remove excess columns for better viewing
results.ost_worked = [];
results.audapter_data = [];
results.f0 = [];
results.f0_time_points = [];

%distinguish different trial types
control_trials = results(results.pert_magnitude == 2 | results.pert_magnitude == 0.0001, :);
critical_trials = results(results.pert_magnitude ~= 2 & results.pert_magnitude ~= 0.0001, :);
critical_aware = critical_trials(critical_trials.awareness > 0, :);
critical_unaware = critical_trials(critical_trials.awareness == 0, :);

%how does awareness affect the chance of adaptive response?
aware_adaptation = critical_aware(critical_aware.meets_2sd_condition == 1, :);
height(aware_adaptation) / height(critical_aware)

unaware_adaptation = critical_unaware(critical_unaware.meets_2sd_condition == 1, :);
height(unaware_adaptation) / height(critical_unaware)

%how does direction differ?
figure
histogram(aware_adaptation.difference_in_cents, 'Normalization','probability');
hold on;
histogram(unaware_adaptation.difference_in_cents, 'Normalization','probability');
legend('aware', 'unaware')
title('Vocal adaptiation magnitude, divide by awareness')
xlabel('adaptation magnitude (cents)')
ylabel('Probability')

%how does awareness affect the magnitude of adaptive response?
mean(abs(aware_adaptation.difference_in_cents))
mean(abs(unaware_adaptation.difference_in_cents))

figure;
histogram(abs(aware_adaptation.difference_in_cents), 'Normalization','probability');
hold on;
histogram(abs(unaware_adaptation.difference_in_cents), 'Normalization', 'probability');
legend('aware', 'unaware')
title('Vocal adaptiation magnitude, divide by awareness, absolute values')
xlabel('adaptation magnitude (cents)')
ylabel('Probability')

%only opposing adaptations
aware_opposing = aware_adaptation(aware_adaptation.difference_in_cents < 0, :);
unaware_opposing = unaware_adaptation(unaware_adaptation.difference_in_cents < 0, :);

mean(aware_opposing.difference_in_cents)
mean(unaware_opposing.difference_in_cents)

%only following
aware_following = aware_adaptation(aware_adaptation.difference_in_cents > 0, :);
unaware_following = unaware_adaptation(unaware_adaptation.difference_in_cents > 0, :);

mean(aware_following.difference_in_cents)
mean(unaware_following.difference_in_cents)