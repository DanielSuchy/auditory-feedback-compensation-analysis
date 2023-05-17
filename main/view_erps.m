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
cd('/Users/diskuser/analysis/all_data/eeg/')
pert_onset_eegs = dir('**/*_aware1*.mat');
all_aware1_times = [];
all_aware1_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware1_times(:, :, i) = eeg_times;
    all_aware1_erps(:,:,i) = erps;
end
aware1_mean = mean(all_aware1_erps, 3);
aware1_times_mean = mean(all_aware1_times, 3);

pert_onset_eegs = dir('**/*_aware2*.mat');
all_aware2_times = [];
all_aware2_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware2_times(:, :, i) = eeg_times;
    all_aware2_erps(:,:,i) = erps;
end
aware2_mean = mean(all_aware2_erps, 3);
aware2_times_mean = mean(all_aware2_times, 3);

pert_onset_eegs = dir('**/*_aware3*.mat');
all_aware3_times = [];
all_aware3_erps = [];
for i=1:length(pert_onset_eegs)
    file = [pert_onset_eegs(i).folder '/' pert_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
    erps = eeg.data;
    erps = mean(erps, 3);
    eeg_times = eeg.times;
    all_aware3_times(:, :, i) = eeg_times;
    all_aware3_erps(:,:,i) = erps;
end
aware3_mean = mean(all_aware3_erps, 3);
aware3_times_mean = mean(all_aware3_times, 3);

%trials without awareness
unaware_onset_eegs = dir('**/*_unaware_crit_eeg.mat');
all_unaware_onset_eeg_times = [];
all_unaware_onset_erps = [];
for i=1:length(unaware_onset_eegs)
    file = [unaware_onset_eegs(i).folder '/' unaware_onset_eegs(i).name];
    eeg = load(file);
    eeg = eeg.erp_data;
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
plot(aware1_times_mean, mean(aware1_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(aware2_times_mean, mean(aware2_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(aware3_times_mean, mean(aware3_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(unaware_onset_times_mean, mean(unaware_onset_erp_mean(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-2 2])
title('Perturbation onset ERPs (critical trial awareness)', 'FontSize',30, 'FontWeight','bold')
xlabel('Time (ms)', 'FontSize',30, 'FontWeight','bold')
ylabel('Voltage (µV)', 'FontSize',30, 'FontWeight','bold')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';
%legend('aware', 'unaware')
fontsize(gca, 24, 'points');



