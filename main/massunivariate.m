%% t-values table for mass univariate analysis
clear;

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

EEG = pop_loadset('/Users/diskuser/analysis/all_data/eeg/S17/S17_ica_nolowpass.set');
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

hist(all_t_scores)
prctile(all_t_scores, 95, 'all')

% 
% save("tvalues.mat", "t_values");
% 
% %run TFCE for t-values
% EEG = pop_loadset('/Users/diskuser/analysis/all_data/eeg/S17/S17_ica_nolowpass.set');
% [neighbours,channeighbstructmat] = limo_get_channeighbstructmat(EEG, 60);
% tfce_out = limo_tfce(2, t_values, channeighbstructmat);
% figure; imagesc(times, 1:32, tfce_out)
% 
% 
% t_values_row = reshape(t_values, 1, []);
% nperm = 1000;
% permutations = [];
% for i=1:nperm
%     row = randsample(t_values_row, length(t_values_row));
%     permutations = [permutations; row];
% end
% permutations = unique(permutations, 'rows');
% 
% t_perms = [];
% for i=1:height(permutations)
%     row = permutations(i, :);
%     t_perms(:, :, i) = reshape(row, 32, 150);
% end

%for i = 50:150; figure; f = topoplot(t_values(:,i), EEG.chanlocs); pause(1); close all; end
%figure; imagesc(times, 1:32, t_values)
