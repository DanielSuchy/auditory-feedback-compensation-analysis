clear;

data = load('main/valid_data.mat');
data = data.valid_data;

%remove the outlier
data(data.participant == 7 & data.trial == 132, :) = [];

%draw response intensity based on magnitude of pitch shift
[pitch_shift, ~, n] = unique(data.pert_magnitude);
mean_response = accumarray(n, data.difference_in_cents, [], @(x)  mean(x));
stdev_response = accumarray(n, data.difference_in_cents, [], @(x)  std(x));
[pitch_shift mean_response stdev_response]

%line plot as in Hafke
pitch_shift = pitch_shift * 100;
pitch_shift = categorical(pitch_shift);
figure
errorbar(pitch_shift, mean_response, stdev_response, 'LineWidth', 4)
yline(0)
fontsize(gca, 30, 'points')
title(['Mean magnitude of vocal adaptation to different magnitudes of artificial pitch shift' newline], ...
    'FontSize', 40, 'FontWeight','bold');
xlabel("Magnitude of pitch shift (cents)", 'FontSize', 40, 'FontWeight','bold')
ylabel("Magnitude of vocal adaptation (cents)", 'FontSize',40, 'FontWeight','bold')



%draw correct detections of pitch shift based on pert magnitude
data.aware = data.how_noticeable_response > 0;
mean_aware = accumarray(n, data.aware, [], @(x)  mean(x));
stdev_aware = accumarray(n, data.aware, [], @(x)  std(x));

figure
scatter(pitch_shift, mean_aware, 'LineWidth', 3)
ylim([0 1.5])
yline(0.75)
xlabel("Magnitude of pitch shift (cents)", 'FontSize', 17)
ylabel("Probability of detection", 'FontSize', 17)

return
%draw results for each participant
figure();
figure_position = 1;
for i = 1:length(unique(data.participant))
    participant = data(data.participant == i, :);
    
    [pitch_shift, ~, n] = unique(participant.pert_magnitude);
    mean_response = accumarray(n, participant.difference_in_cents, [], @(x)  mean(x));
    stdev_response = accumarray(n, participant.difference_in_cents, [], @(x)  std(x));
    mean_aware = accumarray(n, participant.aware, [], @(x)  mean(x));
    stdev_aware = accumarray(n, participant.aware, [], @(x)  std(x));
    pitch_shift = categorical(pitch_shift);

    subplot(7,2,figure_position)
    errorbar(pitch_shift, mean_response, stdev_response)
    figure_position = figure_position + 1;

    subplot(7,2,figure_position)
    errorbar(pitch_shift, mean_aware, stdev_aware)
    figure_position = figure_position + 1;
end

%compare unaware and aware reactions
aware_positive = data(data.aware == 1 & data.difference_in_cents > 0, :);
unware_positive = data(data.aware == 0 & data.difference_in_cents > 0, :);
mean(aware_positive.difference_in_cents)
mean(unware_positive.difference_in_cents)

aware_negative = data(data.aware == 1 & data.difference_in_cents < 0, :);
unaware_negative = data(data.aware == 0 & data.difference_in_cents < 0, :);
mean(aware_negative.difference_in_cents)
mean(unaware_negative.difference_in_cents)

%data.difference_in_cents = abs(data.difference_in_cents);
aware = data(data.aware == 1 & data.pert_magnitude == 0.19, :);
unaware = data(data.aware == 0  & data.pert_magnitude == 0.19, :);
aware.difference_in_cents = abs(aware.difference_in_cents);
unaware.difference_in_cents = abs(unaware.difference_in_cents);
mean(aware.difference_in_cents)
mean(unaware.difference_in_cents)