clear;

data = load('main\all_data.mat');
data = data.all_data;

data.aware = data.how_noticeable_response > 0;
[pert_magnitude, ~, n] = unique(data.pert_magnitude);
aware = accumarray(n, data.aware, [], @(x)  sum(x));
pert_magnitude_count = sum(data.pert_magnitude == [transpose(pert_magnitude)]);
total = transpose(pert_magnitude_count);
percentage = 100 * (aware ./ total);
curve_data = table(pert_magnitude, aware, total, percentage);

positives = curve_data(curve_data.pert_magnitude > 0, :);
negatives = curve_data(curve_data.pert_magnitude <0, :);
targets = [0.25, 0.5, 0.75]; % 25%, 50% and 75% performance
weights = repmat(1, [1,length(positives.pert_magnitude)]); % No weighting


[coeffsPositives, curvePositives, thresholdPositives] = ...
    fitPsycheCurveLogit(positives.pert_magnitude, positives.percentage, weights, targets);
[coeffsNegatives, curveNegatives, thresholdNegatives] = ...
    fitPsycheCurveLogit(negatives.pert_magnitude, negatives.percentage, weights, targets);

figure();
hold on
scatter(positives.pert_magnitude, positives.percentage/100);
plot(curvePositives(:,1), curvePositives(:,2), 'LineStyle', '--');
hold off


figure();
hold on
scatter(negatives.pert_magnitude, negatives.percentage/100);
plot(curveNegatives(:,1), curveNegatives(:,2), 'LineStyle', '--');
hold off
