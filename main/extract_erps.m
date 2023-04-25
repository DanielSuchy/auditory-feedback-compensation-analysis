%extract erps from preprocessed data

%load the data individually
%set_file = '/Users/diskuser/analysis/all_data/eeg/S8/S8_ica_nolowpass.set';
%path = '/Users/diskuser/analysis/all_data/eeg/S8';
%participant_id = 'S8';
%or do batch processing
set_file = [path '/' participant_id '_ica_nolowpass.set'];

EEG = pop_loadset(set_file);

%% Perturbation onset - bigpert vs nopert
% epoch, baseline removal, and artifact rejection
EEG_pert_onset = pop_epoch( EEG, {  'PertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG_nopert_onset = pop_epoch( EEG, {  'NoPertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');

locthresh = 3;
globthresh = 3;
EEG_pert_onset = pop_jointprob(EEG_pert_onset, 1, [1:32], locthresh, globthresh, 1);
EEG_nopert_onset = pop_jointprob(EEG_nopert_onset, 1, [1:32], locthresh, globthresh, 1);

%save the data by participant and trial type
savename = [path '/' participant_id '_pert_onset_eeg.mat'];
save(savename, "EEG_pert_onset");
savename = [path '/' participant_id '_nopert_onset_eeg.mat'];
save(savename, "EEG_nopert_onset");

%% Perturbation onset - aware vs unaware
%see if there are both types of trials, if not, skip this participant
events = struct2table(EEG.event);
unaware_trials_n = sum(strcmp(events.type, 'PertOnset_unaware'));
if unaware_trials_n ~= 0
    EEG_aware_crit = pop_epoch( EEG, {  'PertOnset_aware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    EEG_unaware_crit = pop_epoch( EEG, {  'PertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    
    locthresh = 3;
    globthresh = 3;
    EEG_aware_crit = pop_jointprob(EEG_aware_crit, 1, [1:32], locthresh, globthresh, 1);
    EEG_unaware_crit = pop_jointprob(EEG_unaware_crit, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware_crit_eeg.mat'];
    save(savename, "EEG_aware_crit");
    savename = [path '/' participant_id '_unaware_crit_eeg.mat'];
    save(savename, "EEG_unaware_crit");
end

%% Also extract awareness ratings for no-pert trials
events = struct2table(EEG.event);
false_alarms_n = sum(strcmp(events.type, 'NoPertOnset_aware'));
if ~false_alarms_n %no control trials with aware rating - save an empty file 
    EEG_aware_control = [];
    savename = [path '/' participant_id '_aware_control_eeg.mat'];
    save(savename, "EEG_aware_control");
    return;
end

EEG_aware_control = pop_epoch( EEG, {  'NoPertOnset_aware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG_unaware_control = pop_epoch( EEG, {  'NoPertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');

locthresh = 3;
globthresh = 3;
EEG_aware_control = pop_jointprob(EEG_aware_control, 1, [1:32], locthresh, globthresh, 1);
EEG_unaware_control = pop_jointprob(EEG_unaware_control, 1, [1:32], locthresh, globthresh, 1);

%save the data by participant and trial type
savename = [path '/' participant_id '_aware_control_eeg.mat'];
save(savename, "EEG_aware_control");
savename = [path '/' participant_id '_unaware_control_eeg.mat'];
save(savename, "EEG_unaware_control");
