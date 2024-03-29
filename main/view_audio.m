clear;

%% load the data
results = load('/Users/diskuser/analysis/eeg_data/main/experiment/all_data_afterpert.mat');
results = results.all_data;

%exclude invalid trials (e.g. incorrect vocalization)
results = results(results.ost_worked == 1, :);
results = results(~isnan(results.pert_start_time), :);

%exclude outliers
%normal_variation = 2*std(abs(results.difference_in_cents), 'omitnan');
%results(abs(results.difference_in_cents) > normal_variation, :) = [];
results(abs(results.difference_in_cents) > 100, :) = [];

%remove excess columns for better viewing
results.ost_worked = [];
results.audapter_data = [];
results.f0 = [];
results.f0_time_points = [];

%distinguish different trial types
control_trials = results(results.pert_magnitude == 2 | results.pert_magnitude == 0.0001, :);
nopert_trials = results(results.pert_magnitude == 0.0001, :);
results_nobigpert = results(results.pert_magnitude ~= 2, :);
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

%how does awareness affect the chance of adaptive response?
height(aware_adaptation) / height(critical_aware)
height(unaware_adaptation) / height(critical_unaware)

%how does awareness affect the magnitude of adaptive response?
mean(abs(aware_adaptation.difference_in_cents))
mean(abs(unaware_adaptation.difference_in_cents))

%magnitude of adaptive response, depending on direction
%only opposing adaptations
mean(aware_opposing.difference_in_cents)
mean(unaware_opposing.difference_in_cents)

%only following adaptations
mean(aware_following.difference_in_cents)
mean(unaware_following.difference_in_cents)

%test chance of vocal response depending on awareness
%fisher's exact test
%H1 - aware trials are more likely to meet the 2sd condition
%H0 - awareness makes no difference
critical_trials.awareness = critical_trials.awareness > 0;
comparision = table(critical_trials.awareness, critical_trials.meets_2sd_condition);
comparision = renamevars(comparision, {'Var1', 'Var2'}, {'awareness', 'meets_condition'});

%create a contingency table and test
[aware, ~, n] = unique(comparision.awareness);
meets_condition_true = accumarray(n, comparision.meets_condition, [], @(x)  sum(x));
meets_condition_false = [sum(comparision.awareness == 0); sum(comparision.awareness == 1)] - meets_condition_true;
contingency_t = table(aware, meets_condition_true, meets_condition_false);
[h,p,stats] = fishertest(contingency_t(:,2:3));

%compare unaware and control trials
%H1 - unaware trials create a higher magnitude of vocal response compared to trials without
%perturbation
%H0 - there is no such difference
nopert_trials = control_trials(control_trials.pert_magnitude == 0.0001, :);
meets_condition_true = height(nopert_trials(nopert_trials.meets_2sd_condition == 1, :));
meets_condition_false = height(nopert_trials(nopert_trials.meets_2sd_condition == 0, :));
contingency_t = contingency_t(1, 2:3);
contingency_t = [contingency_t; table(meets_condition_true, meets_condition_false)];
[h,p,stats] = fishertest(contingency_t);

%prepare table for mixed effects regression
tbl = critical_trials(:, [1 4 10 12]);
tbl.awareness = tbl.awareness > 0;
tbl.direction = nan(height(tbl), 1);
tbl(tbl.difference_in_cents > 0, :).direction = ones(height(tbl(tbl.difference_in_cents > 0, :)), 1);
tbl(tbl.difference_in_cents < 0, :).direction = zeros(height(tbl(tbl.difference_in_cents < 0, :)), 1);
%tbl(tbl.difference_in_cents < 0, :).direction = -1 * ones (height(tbl(tbl.difference_in_cents < 0, :)), 1);
tbl.difference_in_cents = abs(tbl.difference_in_cents);

%linear mixed effects
lme = fitlme(tbl, 'difference_in_cents~awareness*direction+(1|participant)');
lme

%linear mixed effects with control trials
tbl2 = results(results.pert_magnitude ~= 2, [1 3 4 10 12]);
tbl2.awareness = tbl2.awareness > 0;
tbl2.direction = nan(height(tbl2), 1);
tbl2(tbl2.difference_in_cents > 0, :).direction = ones(height(tbl2(tbl2.difference_in_cents > 0, :)), 1);
tbl2(tbl2.difference_in_cents < 0, :).direction = zeros(height(tbl2(tbl2.difference_in_cents < 0, :)), 1);
tbl2.difference_in_cents = abs(tbl2.difference_in_cents);
tbl2.has_pert = ones(height(tbl2), 1);
tbl2(tbl2.pert_magnitude == 0.0001, :).has_pert = zeros(height(tbl2(tbl2.pert_magnitude == 0.0001, :)), 1);
lme2 = fitlme(tbl2, 'difference_in_cents~has_pert*awareness*direction+(1|participant)');
lme2


%% view the data
histogram(results.difference_in_cents)

%boxplot by participant
figure
bh = boxplot(results.difference_in_cents, results.participant, 'OutlierSize',12);
title('Vocal adaptiation magnitude, divided by the participant', 'FontWeight','bold', 'FontSize',30)
xlabel('Participant ID', 'FontSize', 30, 'FontWeight','bold')
ylabel('Magnitude of pitch shift (cents)', 'FontSize',30, 'FontWeight', 'bold')
set(bh,'LineWidth', 2);
fontsize(gca, 24, 'points')

%scatterplot by participant
results.awareness_bin = results.awareness > 0;
h = gscatter(results.participant, results.difference_in_cents, results.awareness_bin);
set(h(1), 'Marker','o', 'MarkerSize',15, 'MarkerEdgeColor','none', 'MarkerFaceColor','r');
set(h(2), 'Marker','o', 'MarkerSize',15, 'MarkerEdgeColor','none', 'MarkerFaceColor','b');
drawnow
set(h(1).MarkerHandle, 'FaceColorType','truecoloralpha', 'FaceColorData',uint8([200;0;0;300]));
set(h(2).MarkerHandle, 'FaceColorType','truecoloralpha', 'FaceColorData',uint8([0;0;200;50]));
drawnow


c = linspace(1,12,length(results.participant));
scatter(results.participant, results.difference_in_cents, 150, c, 'filled', 'MarkerEdgeColor',[0 .5 .5], 'LineWidth',1.5);
xlim([0, 13])
set(gca, 'xtick', 1:12);

%scatterplot and boxplot
figure
h = gscatter(results.participant, results.difference_in_cents, results.awareness_bin);
set(h(1), 'Marker','o', 'MarkerSize',15, 'MarkerEdgeColor','none', 'MarkerFaceColor','r');
set(h(2), 'Marker','o', 'MarkerSize',15, 'MarkerEdgeColor','none', 'MarkerFaceColor','b');
drawnow
set(h(1).MarkerHandle, 'FaceColorType','truecoloralpha', 'FaceColorData',uint8([200;0;0;30]));
set(h(2).MarkerHandle, 'FaceColorType','truecoloralpha', 'FaceColorData',uint8([0;0;200;30]));
drawnow
hold on;
bh = boxplot(results.difference_in_cents, results.participant, 'Symbol','');
title('Vocal adaptiation magnitude, divided by the participant', 'FontWeight','bold', 'FontSize',30)
xlabel('Participant ID', 'FontSize', 30, 'FontWeight','bold')
ylabel('Magnitude of pitch shift (cents)', 'FontSize',30, 'FontWeight', 'bold')
%legend('unaware', 'aware')
set(bh,'LineWidth', 2);
fontsize(gca, 24, 'points')
hold off;

%raincloud plot
cb = [0.5 0.8 0.9; 1 1 0.7; 0.7 0.8 0.9; 0.8 0.5 0.4; 0.5 0.7 0.8; 1 0.8 0.5; 0.7 1 0.4; 1 0.7 1; 0.6 0.6 0.6; 0.7 0.5 0.7; 0.8 0.9 0.8; 1 1 0.4];
fontsize(gca, 30, 'points')
for i=1:12
    sp = subplot(12, 1, i);
    h1 = raincloud_plot(results(results_nobigpert.participant == i, :).difference_in_cents, 'band_width', 2);
    set(gca,'ytick',[])
    %title(['Participant ' num2str(i)], FontSize=30);
    set(gca, 'XLim', [-80 80]);
    set(h1{1}, 'FaceColor', cb(i, :));
    sp.Position = sp.Position + [0 0 0.08 0];
    fontsize(gca, 15, 'points')
    box off
end

%histogram by participant
figure;
lgnd = [];
for i = 1:12
    participant = results(results.participant == i, :);
    histogram(participant.difference_in_cents);
    current_lgnd = ['participant=' num2str(1)];
    hold on;
end
legend(lgnd)
hold off;

%histogram, divided by awareness and direction, real values
figure
histogram(unaware_adaptation.difference_in_cents, 'Normalization','probability', FaceAlpha=0.3, BinWidth=3);
hold on;
histogram(aware_adaptation.difference_in_cents, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
legend('aware', 'unaware', 'FontSize', 36)
title('Vocal adaptiation magnitude, divided by awareness ratings', 'FontWeight','bold', 'FontSize',42)
xlabel('adaptation magnitude (cents)', 'FontSize', 36, 'FontWeight','bold')
ylabel('Probability', 'FontSize',36, 'FontWeight', 'bold')
fontsize(gca, 30, 'points')

%histogram, divided by awareness and direction, real values, including control trials
figure
histogram(unaware_adaptation.difference_in_cents, 'Normalization','probability', FaceAlpha=0.3, BinWidth=3);
hold on;
histogram(aware_adaptation.difference_in_cents, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
histogram(nopert_trials.difference_in_cents, 'Normalization','probability', FaceAlpha=0.6, BinWidth=3);
legend('aware', 'unaware', 'control (no pert.)', 'FontSize', 36)
title('Vocal adaptiation magnitude, divided by awareness ratings', 'FontWeight','bold', 'FontSize',42)
xlabel('adaptation magnitude (cents)', 'FontSize', 36, 'FontWeight','bold')
ylabel('Probability', 'FontSize',36, 'FontWeight', 'bold')
fontsize(gca, 30, 'points')

%histogram, divided by awareness and direction, absolute values
figure;
histogram(abs(aware_adaptation.difference_in_cents), 'Normalization','probability');
hold on;
histogram(abs(unaware_adaptation.difference_in_cents), 'Normalization', 'probability');
legend('aware', 'unaware')
title('Vocal adaptiation magnitude, divide by awareness, absolute values')
xlabel('adaptation magnitude (cents)')
ylabel('Probability')

%plot lme residuals
plotResiduals(lme2, 'caseorder')

%plot lme - new model
%unaware oposing -> aware oposing
figure
scatter(tbl.awareness, tbl.difference_in_cents)
hold on
refline(-1.31, 21.626) 
xlim([-1 2])

%unaware oposing -> unaware following
figure
scatter(tbl.direction, tbl.difference_in_cents)
hold on
refline(1.68, 21.626) 
xlim([-1 2])

%display F0 time course;
for i=1:height(results)
    trial = results(i, :);
    time = (trial.f0_time_points{1} - 1)/16000; % transform time points (in n. of samples) to seconds
    plot(time, trial.f0{1});
    xline(trial.pert_start_time)
    hold on;
end

