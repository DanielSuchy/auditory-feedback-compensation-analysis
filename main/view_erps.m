clear all;

%% perturbation onset - bigpert vs nopert
%load the data
%trials with pert onset
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_pert_onset_eeg.mat');
all_pert_onset_eeg_times = [];
all_pert_onset_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_pert_onset;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_pert_onset_eeg_times(:, :, i) = eeg_times;
    all_pert_onset_erps(:,:,i) = erps;
end
pert_onset_erp_mean = mean(all_pert_onset_erps, 3);
pert_onset_times_mean = mean(all_pert_onset_eeg_times, 3);

%trials without pert onset
nopert_onset_eegs = dir('**/*_nopert_onset_eeg.mat');
all_nopert_onset_eeg_times = [];
all_nopert_onset_erps = [];
for i=1:length(nopert_onset_eegs)
    file = [nopert_onset_eegs(i).folder '/' nopert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_nopert_onset;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_nopert_onset_eeg_times(:, :, i) = eeg_times;
    all_nopert_onset_erps(:,:,i) = erps;
end
nopert_onset_erp_mean = mean(all_nopert_onset_erps, 3);
nopert_onset_times_mean = mean(all_nopert_onset_eeg_times, 3);

%plot pert erps
plot_channels = [5 6 18 21 22 23 24]; %central electrodes
figure;
plot(pert_onset_times_mean, mean(pert_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on;
plot(nopert_onset_times_mean, mean(nopert_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
title('Perturbation onset ERPs', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize', 30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
legend({'Perturbation (+200 cents)', 'No perturbation'})
fontsize(gca, 24, 'points')

%plot pert erps including individual data
figure;
plot(pert_onset_times_mean, mean(pert_onset_erp_mean(plot_channels, :))', 'LineWidth', 5) % 18 = Cz
hold on;
plot(nopert_onset_times_mean, mean(nopert_onset_erp_mean(plot_channels, :))', 'LineWidth', 5) % 18 = Cz
hold on;
for i=1:size(all_nopert_onset_erps, 3)
    plot(nopert_onset_times_mean, mean(all_nopert_onset_erps(plot_channels, :, i))', 'LineWidth', 1, 'Color','Red', 'LineStyle','--');
    hold on;
end
for i=1:size(all_nopert_onset_erps, 3)
    plot(pert_onset_times_mean, mean(all_pert_onset_erps(plot_channels, :, i))', 'LineWidth', 1, 'Color','Blue', 'LineStyle','--');
    hold on;
end
xlim([-200 800])
ylim([-7 7])
legend('Perturbation', 'No perturbation')
title('Perturbation onset ERPs')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';

%% pertrubation onset - aware vs unaware
%load the data
%trials with awareness
aware_onset_eegs = dir('**/*_aware_crit_eeg.mat');
all_aware_onset_eeg_times = [];
all_aware_onset_erps = [];
for i=1:length(aware_onset_eegs)
    file = [aware_onset_eegs(i).folder '/' aware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_aware_crit;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware_onset_eeg_times(:, :, i) = eeg_times;
    all_aware_onset_erps(:,:,i) = erps;
end
aware_onset_erp_mean = mean(all_aware_onset_erps, 3);
aware_onset_times_mean = mean(all_aware_onset_eeg_times, 3);

%trials without awareness
unaware_onset_eegs = dir('**/*_unaware_crit_eeg.mat');
all_unaware_onset_eeg_times = [];
all_unaware_onset_erps = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.EEG_unaware_crit;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_unaware_onset_erps(:,:,i) = erps;
    all_unaware_onset_eeg_times(:, :, i) = eeg_times;
end
unaware_onset_erp_mean = mean(all_unaware_onset_erps, 3);
unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);

%plot pert erps
plot_channels = [18 24 22 21 23]; %central electrodes
figure;
plot(aware_onset_times_mean, mean(aware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-1 1])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
legend('aware', 'unaware')
fontsize(gca, 24, 'points');

%plot including control data
plot_channels = [18 24 22 21 23]; %central electrodes
figure;
plot(aware_onset_times_mean, mean(aware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3)
hold on
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3)
hold on
plot(nopert_onset_times_mean, mean(nopert_onset_erp_mean(plot_channels, :))', 'LineWidth', 3)
xlim([-200 800])
ylim([-1 1])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
legend('aware', 'unaware', 'control')
fontsize(gca, 24, 'points');

%plot pert erps including individual data
figure;
plot(aware_onset_times_mean, mean(aware_onset_erp_mean(plot_channels, :))', 'LineWidth', 5) % 18 = Cz
hold on;
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 5) % 18 = Cz
hold on;
for i=1:size(all_unaware_onset_erps, 3)
    plot(unaware_onset_times_mean, mean(all_unaware_onset_erps(plot_channels, :, i))', 'LineWidth', 1, 'Color','Red', 'LineStyle','--');
    hold on;
end
for i=1:size(all_aware_onset_erps, 3)
    plot(aware_onset_times_mean, mean(all_aware_onset_erps(plot_channels, :, i))', 'LineWidth', 1, 'Color','Blue', 'LineStyle','--');
    hold on;
end
xlim([-200 800])
ylim([-10 10])
legend('aware', 'unaware')
title('Perturbation onset ERPs (critical trial awareness)')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';

%which channel locations have the biggest differences?
difference = aware_onset_erp_mean - unaware_onset_erp_mean;
%consruct scalp maps for aware/unaware and their difference
%at relevant times: 150 200 250 ms
index150 = find(aware_onset_times_mean == 0);
index200 = find(aware_onset_times_mean == 200);
index250 = find(aware_onset_times_mean == 250);
figure;
subplot(3, 3, 1);
topoplot(difference(:, index150), eeg.chanlocs)
subplot(3, 3, 2);
topoplot(difference(:, index200), eeg.chanlocs)
subplot(3, 3, 3);
topoplot(difference(:, index250), eeg.chanlocs)

index = [find(eeg.times == 100) find(eeg.times == 200) find(eeg.times == 300) find(eeg.times == 400) find(eeg.times == 500)];
all_electrodes = 1:32;
central_electrodes = [18 21 22 23 24];
noncentral_electrodes = all_electrodes(~ismember(all_electrodes, central_electrodes));
for i = 1:length(index)
    set(0,'defaultAxesFontSize', 15)
    subplot(3,5,i)
    topoplot(aware_onset_erp_mean(1:32,index(i),:), eeg.chanlocs(1,1:32), 'maplimits', [-2 2], 'emarker2', {noncentral_electrodes,'.','w'}, 'emarkersize', 14)
    title([num2str(eeg.times(index(i))), ' ms'],'FontWeight','Normal')
    colormap(redblue);

    set(0,'defaultAxesFontSize', 15)
    subplot(3,5,i + 5)
    topoplot(unaware_onset_erp_mean(1:32,index(i),:), eeg.chanlocs(1,1:32), 'maplimits', [-2 2], 'emarker2', {noncentral_electrodes,'.','w'}, 'emarkersize', 14)
    title([num2str(eeg.times(index(i))), ' ms'],'FontWeight','Normal')
    colormap(redblue);

    set(0,'defaultAxesFontSize', 15)
    subplot(3,5,i+10)
    topoplot(difference(1:32,index(i),:), eeg.chanlocs(1,1:32), 'maplimits', [-2 2], 'emarker2', {noncentral_electrodes,'.','w'}, 'emarkersize', 14)
    title([num2str(eeg.times(index(i))), ' ms'],'FontWeight','Normal')
    colormap(redblue);
end

%% aware vs unaware: [0-3] ratings
%load the data
%trials with pert onset
plot_channels = [18 24 22 21 23]; %central electrodes
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_aware1_crit*.mat');
all_aware1_times = [];
all_aware1_erps = [];
aans1 = [];
lps1 = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    times = eeg.times;
    all_aware1_times(:, :, i) = times;
    all_aware1_erps(:,:,i) = erps;
    erps = mean(erps(plot_channels, :));
    erps_times = [erps; times];
    aan = erps_times(1, erps_times(2,:) > 120 & erps_times(2,:) < 180);
    aan = mean(aan);
    aans1 = [aans1; aan];
    lp = erps_times(1, erps_times(2,:) > 300 & erps_times(2,:) < 500);
    lp = mean(lp);
    lps1 = [lps1; lp];
end
aware1_mean = mean(all_aware1_erps, 3);
aware1_times_mean = mean(all_aware1_times, 3);

pert_onset_eegs = dir('**/*_aware2_crit*.mat');
all_aware2_times = [];
all_aware2_erps = [];
aans2 = [];
lps2 = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware2_times(:, :, i) = eeg_times;
    all_aware2_erps(:,:,i) = erps;
    erps = mean(erps(plot_channels, :));
    erps_times = [erps; times];
    aan = erps_times(1, erps_times(2,:) > 120 & erps_times(2,:) < 180);
    aan = mean(aan);
    aans2 = [aans2; aan];
    lp = erps_times(1, erps_times(2,:) > 300 & erps_times(2,:) < 500);
    lp = mean(lp);
    lps2 = [lps2; lp];
end
aware2_mean = mean(all_aware2_erps, 3);
aware2_times_mean = mean(all_aware2_times, 3);

pert_onset_eegs = dir('**/*_aware3_crit*.mat');
all_aware3_times = [];
all_aware3_erps = [];
aans3 = [];
lps3 = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware3_times(:, :, i) = eeg_times;
    all_aware3_erps(:,:,i) = erps;
    erps = mean(erps(plot_channels, :));
    erps_times = [erps; times];
    aan = erps_times(1, erps_times(2,:) > 120 & erps_times(2,:) < 180);
    aan = mean(aan);
    aans3 = [aans3; aan];
    lp = erps_times(1, erps_times(2,:) > 300 & erps_times(2,:) < 500);
    lp = mean(lp);
    lps3 = [lps3; lp];
end
aware3_mean = mean(all_aware3_erps, 3);
aware3_times_mean = mean(all_aware3_times, 3);

%trials without awareness
unaware_onset_eegs = dir('**/*_unaware_crit_eeg.mat');
all_unaware_onset_eeg_times = [];
all_unaware_onset_erps = [];
aans_una = [];
lps_una = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_unaware_onset_erps(:,:,i) = erps;
    all_unaware_onset_eeg_times(:, :, i) = eeg_times;
    erps = mean(erps(plot_channels, :));
    erps_times = [erps; times];
    aan = erps_times(1, erps_times(2,:) > 120 & erps_times(2,:) < 180);
    aan = mean(aan);
    aans_una = [aans_una; aan];
    lp = erps_times(1, erps_times(2,:) > 300 & erps_times(2,:) < 500);
    lp = mean(lp);
    lps_una = [lps_una; lp];
end
unaware_onset_erp_mean = mean(all_unaware_onset_erps, 3);
unaware_onset_times_mean = mean(all_unaware_onset_eeg_times, 3);

aware_erps = cat(3, all_aware1_erps, all_aware2_erps, all_aware3_erps);
aware_mean = mean(aware_erps, 3);

%plot pert erps
figure;
erp_plot = subplot(2,3,[1 4]);
plot_channels = [18 24 22 21 23]; %central electrodes
plot(aware1_times_mean, mean(aware_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-1.5 1.5])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
area([100 200], [2 2], BaseValue=-2, FaceColor='blue', FaceAlpha=0.1)
area([300 500], [2 2], BaseValue=-2, FaceColor='red', FaceAlpha=0.1)
legend('aware', 'unaware')
fontsize(gca, 18, 'points');

aanmean_plot = subplot(2,3,2);
e1 = errorbar(1, mean(aans_una), std(aans_una) / sqrt(length(aans_una)), 'LineWidth', 5, 'MarkerFaceColor', 'r');
hold on
e2 = errorbar(2, mean(aans1), std(aans1) / sqrt(length(aans1)), 'LineWidth', 5);
e3 = errorbar(3, mean(aans2), std(aans2) / sqrt(length(aans2)), 'LineWidth', 5);
e4 = errorbar(4, mean(aans3), std(aans3) / sqrt(length(aans3)), 'LineWidth', 5);
scatter(1, mean(aans_una), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(2, mean(aans1), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(3, mean(aans2), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(4, mean(aans3), 300, 'd','filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
e1.Color = 'red';
e2.Color = [0.5, 0.5, 1];
e3.Color = [0.3, 0.3, 1];
e4.Color = [0.1, 0.1, 1];
xlabel('Awareness rating');
ylabel('Voltage 120-180 ms after perturbation');
title('Auditory awareness negativity - mean value');
xlim([0.5 4.5]);
xticks([0 1 2 3]);
grid on;
grid minor;
xticks([1 2 3 4]);
xticklabels({'unaware', 'aware 1', 'aware 2', 'aware3'});
fontsize(gca, 18, 'points');

lpmean_plot = subplot(2,3,5);
e1 = errorbar(1, mean(lps_una), std(lps_una) / sqrt(length(lps_una)), 'LineWidth', 5, 'MarkerFaceColor', 'r');
hold on
e2 = errorbar(2, mean(lps1), std(lps1) / sqrt(length(lps1)), 'LineWidth', 5);
e3 = errorbar(3, mean(lps2), std(lps2) / sqrt(length(lps2)), 'LineWidth', 5);
e4 = errorbar(4, mean(lps3), std(lps3) / sqrt(length(lps3)), 'LineWidth', 5);
scatter(1, mean(lps_una), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(2, mean(lps1), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(3, mean(lps2), 300, 'd', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
scatter(4, mean(lps3), 300, 'd','filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 5);
e1.Color = 'red';
e2.Color = [0.5, 0.5, 1];
e3.Color = [0.3, 0.3, 1];
e4.Color = [0.1, 0.1, 1];
xlabel('Awareness rating');
ylabel('Voltage 300-500 ms after perturbation');
title('Late positivity - mean value');
xlim([0.5 4.5]);
xticks([0 1 2 3]);
grid on;
grid minor;
xticks([1 2 3 4]);
xticklabels({'unaware', 'aware 1', 'aware 2', 'aware3'});
fontsize(gca, 18, 'points');

tvalues = load('/Users/diskuser/analysis/all_data/eeg/tvalues_real_data.mat');
tvalues = tvalues.t_values;
%scalp maps of t-values for aan
aan_ts = tvalues(1:32,63:69); %120 - 180 ms
mean_aan = mean(aan_ts, 2);
aan_scalp = subplot(2,3,3);
topoplot(mean_aan, eeg.chanlocs, 'whitebk', 'on');
title('AAN - tscores');
fontsize(gca, 18, 'points');
colorbar;

%scalp maps of t-values for LP
lp_ts = tvalues(1:32, 81:101);
mean_lp = mean(lp_ts, 2);
lp_scalp = subplot(2,3,6);
topoplot(mean_lp, eeg.chanlocs, 'whitebk', 'on');
title('LP - tscores');
fontsize(gca, 18, 'points');
colorbar;

%adjust positions of the subplots
erp_plot.Position = erp_plot.Position + [-0.05 0 0.15 0];
aanmean_plot.Position = aanmean_plot.Position + [0.1 0 0 0];
lpmean_plot.Position = lpmean_plot.Position + [0.1 0 0 0];
aan_scalp.Position = aan_scalp.Position + [0.05 0 0 0];
lp_scalp.Position = lp_scalp.Position + [0.05 0 0 0];

%% perturbation onset - ratings for no-pert trials

%trials without awareness
cd('/Users/diskuser/analysis/all_data/eeg/')
unaware_eegs = dir('**/*_unaware_control_eeg.mat');
all_unaware_erps = [];
for i=1:length(unaware_eegs)
    file = [unaware_eegs(i).folder '/' unaware_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_unaware_erps(:,:,i) = erps;
end
unaware_erp_mean = mean(all_unaware_erps, 3);


%trials with awareness
cd('/Users/diskuser/analysis/all_data/eeg/')
aware_eegs = dir('**/*_aware*_control_eeg.mat');
all_aware_erps = [];
for i=1:length(aware_eegs)
    file = [aware_eegs(i).folder '/' aware_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware_erps(:,:,i) = erps;
end
aware_erp_mean = mean(all_aware_erps, 3);

%plot pert erps
figure;
plot_channels = [18 22 4 12 26 6 24]; %central electrodes
plot(eeg_times, mean(aware_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(eeg_times, mean(unaware_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-1.5 1.5])
title('No pert. trials - effect of awareness', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
area([100 200], [2 2], BaseValue=-2, FaceColor='blue', FaceAlpha=0.1)
area([300 500], [2 2], BaseValue=-2, FaceColor='red', FaceAlpha=0.1)
legend('aware', 'unaware')
fontsize(gca, 24, 'points');