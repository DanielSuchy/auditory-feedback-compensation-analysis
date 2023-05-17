%% t-values table for mass univariate analysis
clear;

all_results = load('/Users/diskuser/analysis/all_data/eeg/awareness_results.mat');
all_results = all_results.all_results;
t_values = nan(32, 150);
for electrode_i=1:32
    parfor sample_i=1:150
        voltage = [];
        for trial_i=1:height(all_results)
            erp = squeeze(all_results(trial_i, :).erps);
            erp_cell = erp(electrode_i, sample_i);
            voltage = [voltage; erp_cell];
        end
        % Create a copy of all_results for each iteration
        all_results_copy = all_results;
        all_results_copy.voltage = double(voltage); %has to be double for lme
        all_results_copy.erps = [];
        lme = fitlme(all_results_copy, 'voltage~aware+(1|participant_id)');
        t_value = lme.Coefficients(2, 4).tStat;
        t_values(electrode_i, sample_i) = t_value;
        disp(['electrode:' num2str(electrode_i) ' sample: ' num2str(sample_i)])
    end
end

for i = 50:150; figure; f = topoplot(t_values(:,i), EEG.chanlocs); pause(1); close all; end
figure; imagesc(times, 1:32, t_values)

EEG = pop_loadset('/Users/diskuser/analysis/all_data/eeg/S17/S17_ica.set');
[neighbours,channeighbstructmat] = limo_get_channeighbstructmat(EEG, 60);
tfce_out = limo_tfce(2, t_values, channeighbstructmat);
figure; imagesc(times, 1:32, tfce_out)


save("tvalues_real_data.mat", "t_values");
save("tfce_real_data.mat", "tfce_out");

%scalp maps of t-values for aan
aan_ts = t_values(1:32,63:69); %120 - 180 ms
mean_aan = mean(aan_ts, 2);
topoplot(mean_aan, EEG.chanlocs);

%scalp maps of t-values for LP
lp_ts = t_values(1:32, 81:101);
mean_lp = mean(lp_ts, 2);
topoplot(mean_lp, EEG.chanlocs);

%% Permutations for TFCE analysis

all_results = load('/Users/diskuser/analysis/all_data/eeg/awareness_results.mat');
all_results = all_results.all_results;
all_results(all_results.control == 1, :) = [];
rand_tfces = [];
all_t_scores = [];

all_results.aware = double(all_results.aware);
all_results.participant_id = single(all_results.participant_id);
all_results.trial = [];
all_results.control = [];
all_results.mean_aan = [];
all_results.mean_lp = [];

EEG = pop_loadset('/Users/diskuser/analysis/all_data/eeg/S17/S17_ica.set');
[neighbours,channeighbstructmat] = limo_get_channeighbstructmat(EEG, 60);

permutations = 2;
for perm_i=1:permutations

    % Shuffle the aware variable
    rand_aware = randsample(all_results.aware, length(all_results.aware));
    all_results.aware = rand_aware;

    t_values = nan(32, 150);
    for electrode_i=1:32
        parfor sample_i=1:150
            voltage = [];
            for trial_i=1:height(all_results)
                erp = squeeze(all_results(trial_i, :).erps);
                erp_cell = erp(electrode_i, sample_i);
                voltage = [voltage; erp_cell];
            end
            % Create a copy of all_results for each iteration
            all_results_copy = all_results;
            all_results_copy.voltage = double(voltage); %has to be double for lme
            all_results_copy.erps = []
            lme = fitlme(all_results_copy, 'voltage~aware+(1|participant_id)');
            t_value = lme.Coefficients(2, 4).tStat;
            t_values(electrode_i, sample_i) = t_value;
            disp(['permutation:' num2str(perm_i) ' electrode:' num2str(electrode_i)])
        end
    end
    tfce_out = limo_tfce(2, t_values, channeighbstructmat);
    all_t_scores(:, :, perm_i) = t_values;
    rand_tfces(:, :, perm_i) = tfce_out;
end

save("tfce_perms2", "rand_tfces");

hist(all_t_scores)
prctile(all_t_scores, 95, 'all')

%% mass univariate analysis of vocal data
all_data = load('/Users/diskuser/analysis/all_data/experiment/all_data_final.mat');
all_data = all_data.all_data;
all_data = all_data(all_data.pert_magnitude < 2 & all_data.pert_magnitude > 0.0001, :);
all_data(all_data.pitch_60_800 == 0, :) = [];
mu_data = all_data(:, [1 5 18]); %data relevant for mass univariate analysis

for sample_i=1:100
    cents = [];
    for trial_i=1:height(mu_data)
        pitch = cell2mat(mu_data(trial_i, :).pitch);
        pitch_cell = pitch(sample_i);
        cents = [cents; pitch_cell];
    end
    % Create a copy of all_results for each iteration
    mu_data_copy = mu_data;
    mu_data_copy.cents = double(cents); %has to be double for lme
    lme = fitlme(mu_data_copy, 'cents~awareness+(1|participant)');
    t_value = lme.Coefficients(2, 4).tStat;
    t_values(sample_i) = t_value;
    disp(['sample: ' num2str(sample_i)])
end
real_t_values = t_values;

permutations = 1000;
fake_t_values = nan(1000, 100);
for perm_i=1:permutations

    % Shuffle the aware variable
    rand_aware = randsample(mu_data.awareness, length(mu_data.awareness));
    mu_data.awareness = rand_aware;

    parfor sample_i=1:100
        cents = [];
        for trial_i=1:height(mu_data)
            pitch = cell2mat(mu_data(trial_i, :).pitch);
            pitch_cell = pitch(sample_i);
            cents = [cents; pitch_cell];
        end
        % Create a copy of all_results for each iteration
        mu_data_copy = mu_data;
        mu_data_copy.cents = double(cents); %has to be double for lme
        lme = fitlme(mu_data_copy, 'cents~awareness+(1|participant)');
        t_value = lme.Coefficients(2, 4).tStat;
        t_values(sample_i) = t_value;
    end
    disp(['permutation: ' num2str(perm_i)])
    fake_t_values(perm_i, :) = t_values;
end

save("real_tvalues.mat", "real_t_values");
save("fake_tvalues.mat", "fake_t_values");

tmax = max(fake_t_values, [], 2);
tmax = abs(tmax);
cutoff = prctile(tmax, 95);
real_t_values = abs(real_t_values);
real_t_values(real_t_values > cutoff)

plot(real_t_values);
hold on;
plot((real_t_values > cutoff) * 3 );