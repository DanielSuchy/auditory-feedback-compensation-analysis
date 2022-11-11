clear all;

%load the data
voice_onset_erp = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_voice_onset_erps.mat');
voice_onset_erp = voice_onset_erp.ERP_voice_onset;
voice_onset_eeg = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_voice_onset_eeg.mat');
voice_onset_eeg = voice_onset_eeg.EEG_voice_onset;




%plot voice onset erps
plot_channels = [5 6 18 21 22 23 24];
figure;
plot(voice_onset_eeg.times, mean(voice_onset_erp(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
%hold on
%plot(EEG_nopert_onset.times, mean(ERP_nopert_onset(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
%legend('Perturbation', 'No perturbation')
title('Voice onset ERP')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';

pert_onset_erp = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_pert_onset_erps.mat');
nopert_onset_erp = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_nopert_onset_erps.mat');
pert_onset_eeg = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_pert_onset_eeg.mat');
nopert_onset_eeg = load('../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_nopert_onset_eeg.mat');

pert_onset_erp = pert_onset_erp.ERP_pert_onset;
nopert_onset_erp = nopert_onset_erp.ERP_nopert_onset;
pert_onset_eeg = pert_onset_eeg.EEG_pert_onset;
nopert_onset_eeg = nopert_onset_eeg.EEG_nopert_onset;

%plot pert erps
plot_channels = [5 6 18 21 22 23 24];
figure;
plot(pert_onset_eeg.times, mean(pert_onset_erp(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
hold on
plot(nopert_onset_eeg.times, mean(nopert_onset_erp(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
xlim([-200 800])
ylim([-3 3])
legend('Perturbation', 'No perturbation')
title('Voice onset ERP')
xlabel('Time (ms)')
ylabel('Amplitude')
l = line([0 0],[-5 5]); l.Color = 'k';
l = line([-500 1000],[0 0]); l.Color = 'k';