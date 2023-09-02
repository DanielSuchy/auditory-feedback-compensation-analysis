clear;

%% load the data
results = load('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat');
results = results.all_data;
erp_results = load('/Users/diskuser/analysis/all_data/eeg/awareness_results.mat');
erp_results = erp_results.all_results;
erp_results.erps = []; %lme does not work if this column is in the table
erp_results = renamevars(erp_results,'participant_id','participant'); %keep column names the same for joining tables

%exclude participants

%exclude invalid trials (e.g. incorrect vocalization)
results = results(results.ost_worked == 1, :);
results = results(~isnan(results.pert_start_time), :);
results(cellfun(@isempty,results.pitch), :) = [];

%exclude outliers
%normal_variation = 2*std(abs(results.difference_in_cents), 'omitnan');
%results(abs(results.difference_in_cents) > normal_variation, :) = [];
%results(abs(results.difference_in_cents) > 100, :) = [];
results(abs(results.pitch_tfce) > 100, :) = [];

%distinguish different trial types
control_trials = results(results.pert_magnitude == 2 | results.pert_magnitude == 0.0001, :);
nopert_trials = results(results.pert_magnitude == 0.0001, :);
nobigpert = results(results.pert_magnitude ~= 2, :);
critical_trials = results(results.pert_magnitude ~= 2 & results.pert_magnitude ~= 0.0001, :);
critical_aware = critical_trials(critical_trials.awareness > 0, :);
critical_unaware = critical_trials(critical_trials.awareness == 0, :);
aware_adaptation = critical_aware(critical_aware.meets_2sd_condition == 1, :);
unaware_adaptation = critical_unaware(critical_unaware.meets_2sd_condition == 1, :);
aware_opposing = aware_adaptation(aware_adaptation.difference_in_cents < 0, :);
unaware_opposing = unaware_adaptation(unaware_adaptation.difference_in_cents < 0, :);
aware_following = aware_adaptation(aware_adaptation.difference_in_cents > 0, :);
unaware_following = unaware_adaptation(unaware_adaptation.difference_in_cents > 0, :);

%% run tests

%lme with TFCE-significant time window
tbl3 = results(results.pert_magnitude ~= 2, [1 4 5 20]);
%tbl3(tbl3.pert_magnitude == 0.0001, :) = [];
%tbl3(tbl3.participant == 15 | tbl3.participant == 34, :) = [];
tbl3.has_pert = ones(height(tbl3), 1);
tbl3(tbl3.pert_magnitude == 0.0001, :).has_pert = zeros(height(tbl3(tbl3.pert_magnitude == 0.0001, :)), 1);
%tbl3.direction = nan(height(tbl3), 1);
%tbl3(tbl3.pitch_tfce > 0, :).direction = ones(height(tbl3(tbl3.pitch_tfce > 0, :)), 1);
%tbl3(tbl3.pitch_tfce < 0, :).direction = zeros(height(tbl3(tbl3.pitch_tfce < 0, :)), 1);
%tbl3.pitch_tfce = abs(tbl3.pitch_tfce);
lme3 = fitlme(tbl3, 'pitch_tfce~awareness*has_pert+(1|participant)');
lme3

figure;
plotResiduals(lme3, 'caseorder')

%lme only with trials that are valid for both auditory and erp analysis
results = results(:, [1 2 4 5 19]);
results.key = string([num2str(results.participant), repmat(' ', [height(results) 1]), num2str(results.trial)]);
erp_results.key = string([num2str(erp_results.participant), repmat(' ', [height(erp_results) 1]), num2str(erp_results.trial)]);
valid_results = results(ismember(erp_results.key, intersect(erp_results.key, results.key)), :);

valid_results.direction = nan(height(valid_results), 1);
valid_results(valid_results.pitch_60_800 > 0, :).direction = ones(height(valid_results(valid_results.pitch_60_800 > 0, :)), 1);
valid_results(valid_results.pitch_60_800 < 0, :).direction = zeros(height(valid_results(valid_results.pitch_60_800 < 0, :)), 1);
valid_results.pitch_60_800 = abs(valid_results.pitch_60_800);
valid_results.has_pert = ones(height(valid_results), 1);
valid_results(valid_results.pert_magnitude == 0.0001, :).has_pert = zeros(height(valid_results(valid_results.pert_magnitude == 0.0001, :)), 1);
lme3 = fitlme(valid_results, 'pitch_60_800~has_pert*awareness*direction+(1|participant)');
lme3

%% view the data

figure;
histogram(unaware_adaptation.pitch_tfce, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
hold on;
histogram(aware_adaptation.pitch_tfce, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
%histogram(nopert_trials.pitch_tfce, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
legend('aware', 'unaware', 'control (no pert.)', 'FontSize', 36)
title('Vocal adaptiation magnitude, divided by awareness ratings', 'FontWeight','bold', 'FontSize',42)
xlabel('adaptation magnitude (cents)', 'FontSize', 36, 'FontWeight','bold')
ylabel('Probability', 'FontSize',36, 'FontWeight', 'bold')
fontsize(gca, 30, 'points')

%errorbar with vocal results
nu = tbl3(tbl3.pert_magnitude == 0.0001 & tbl3.awareness == 0, :);
na = tbl3(tbl3.pert_magnitude == 0.0001 & tbl3.awareness >= 1, :);
pu = tbl3(tbl3.pert_magnitude > 0.0001 & tbl3.awareness == 0, :);
pa = tbl3(tbl3.pert_magnitude > 0.0001 & tbl3.awareness >= 1, :);

[b, ~, n] = unique(nu.participant);
nu_mean = accumarray(n, nu.pitch_tfce, [], @(x) mean(x));

[b, ~, n] = unique(na.participant);
na_mean = accumarray(n, na.pitch_tfce, [], @(x) mean(x));

[b, ~, n] = unique(pu.participant);
pu_mean = accumarray(n, pu.pitch_tfce, [], @(x) mean(x));

[b, ~, n] = unique(pa.participant);
pa_mean = accumarray(n, pa.pitch_tfce, [], @(x) mean(x));

%exclude outliers
%na_mean(26) = []; %participant 34
%na_mean(14) = []; %participant 15

figure;
subplot(2,1,1);
errorbar(1, mean(nu_mean), std(nu.pitch_tfce) / sqrt(length(nu_mean)), 'LineWidth', 5, 'Color','r');
hold on;
errorbar(2, mean(na_mean), std(na.pitch_tfce) / sqrt(length(na_mean)), 'LineWidth', 5, 'Color','b');
scatter(1, mean(nu_mean), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(2, mean(na_mean), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
yline(mean(nu_mean), '--', 'Color', 'black', 'LineWidth', 1);
yline(mean(na_mean), '--', 'Color', 'black', 'LineWidth', 1);
xlim([0.5 2.5]);
ylim([-8 3]);
xticks([1 2]);
ylabel('Adaptation magnitude (cents)');
xticklabels({'unaware', 'aware'});
title('No perturbation');
fontsize(gca, 30, 'points');

subplot(2,1,2);
errorbar(1, mean(pu_mean), std(pu.pitch_tfce)  / sqrt(length(pu_mean)), 'LineWidth', 5, 'Color','r');
hold on;
errorbar(2, mean(pa_mean), std(pa.pitch_tfce) / sqrt(length(pa_mean)), 'LineWidth', 5, 'Color','b');
scatter(1, mean(pu_mean), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(2, mean(pa_mean), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
yline(mean(pu_mean), '--', 'Color', 'black', 'LineWidth', 1);
yline(mean(pa_mean), '--', 'Color', 'black', 'LineWidth', 1);
xlim([0.5 2.5]);
ylim([-8 3]);
xticks([1 2]);
xticklabels({'unaware', 'aware'});
title('Perturbation');
fontsize(gca, 30, 'points');

% subplot(2,2,3);
% errorbar(1, mean(pfu.pitch_tfce), std(pfu.pitch_tfce), 'LineWidth', 5, 'Color','r');
% hold on;
% errorbar(2, mean(pfa.pitch_tfce), std(pfa.pitch_tfce), 'LineWidth', 5, 'Color','b');
% scatter(1, mean(pfu.pitch_tfce), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
% scatter(2, mean(pfa.pitch_tfce), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
% yline(mean(pfu.pitch_tfce), '--', 'Color', 'black', 'LineWidth', 1);
% yline(mean(pfa.pitch_tfce), '--', 'Color', 'black', 'LineWidth', 1);
% xlim([0.5 2.5]);
% ylim([-3 28]);
% xticks([1 2]);
% ylabel('Adaptation magnitude (cents)');
% xticklabels({'unaware', 'aware'});
% title('With perturbation - following');
% fontsize(gca, 30, 'points');
% 
% subplot(2,2,4);
% errorbar(1, mean(pou.pitch_tfce), std(pou.pitch_tfce), 'LineWidth', 5, 'Color','r');
% hold on;
% errorbar(2, mean(poa.pitch_tfce), std(poa.pitch_tfce), 'LineWidth', 5, 'Color','b');
% scatter(1, mean(pou.pitch_tfce), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
% scatter(2, mean(poa.pitch_tfce), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
% yline(mean(pou.pitch_tfce), '--', 'Color', 'black', 'LineWidth', 1);
% yline(mean(poa.pitch_tfce), '--', 'Color', 'black', 'LineWidth', 1);
% xlim([0.5 2.5]);
% ylim([-3 28]);
% xticks([1 2]);
% xticklabels({'unaware', 'aware'});
% title('With perturbation - opposing');
% fontsize(gca, 30, 'points');


plot(pa_mean)
hold on;
plot(pu_mean)
