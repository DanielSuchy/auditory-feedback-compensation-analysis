clear;

data = load('main/valid_data.mat');
data = data.valid_data;

%draw response intensity based on magnitude of pitch shift
[pitch_shift, ~, n] = unique(data.pert_magnitude);
mean_response = accumarray(n, data.difference_in_cents, [], @(x)  mean(x));
stdev_response = accumarray(n, data.difference_in_cents, [], @(x)  std(x));
[pitch_shift mean_response stdev_response]

pitch_shift = categorical(pitch_shift);
figure
errorbar(pitch_shift, mean_response, stdev_response)

%draw correct detections of pitch shift based on pert magnitude
data.aware = data.how_noticeable_response > 0;
mean_aware = accumarray(n, data.aware, [], @(x)  mean(x));
stdev_aware = accumarray(n, data.aware, [], @(x)  std(x));

figure
errorbar(pitch_shift, mean_aware, stdev_aware)

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

    subplot(6,2,figure_position)
    errorbar(pitch_shift, mean_response, stdev_response)
    figure_position = figure_position + 1;

    subplot(6,2,figure_position)
    errorbar(pitch_shift, mean_aware, stdev_aware)
    figure_position = figure_position + 1;
end