%extract erps from preprocessed data

%load the data individually
%set_file = '/Users/diskuser/analysis/all_data/eeg/S8/S8_ica.set';
%path = '/Users/diskuser/analysis/all_data/eeg/S8';
%participant_id = 'S8';
%or do batch processing
set_file = [path '/' participant_id '_ica.set'];

EEG = pop_loadset(set_file);

%% Voice onset
%see if the voice onset tool works for this participant, if not, skip
% events = struct2table(EEG.event);
% onsets = sum(strcmp(events.type, 'voice_onset'));
% if onsets > 0
%     % epoch, baseline removal, and artifact rejection
%     EEG_voice_onset = pop_epoch( EEG, {  'voice_onset'  }, [-0.5 3], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%     EEG_voice_onset = pop_rmbase( EEG_voice_onset, [-500 0]);
%     
%     locthresh = 3;
%     globthresh = 3;
%     EEG_voice_onset = pop_jointprob(EEG_voice_onset, 1, [1:32], locthresh, globthresh, 1);
%     ERP_voice_onset = mean(EEG_voice_onset.data, 3);
%     
%     %save the ERPs
%     savename = [path '/' participant_id '_voice_onset_erps.mat'];
%     save(savename, "ERP_voice_onset");
%     savename = [path '/' participant_id '_voice_onset_eeg.mat'];
%     save(savename, "EEG_voice_onset");
% end

%% Perturbation onset - bigpert vs nopert
% epoch, baseline removal, and artifact rejection
EEG_pert_onset = pop_epoch( EEG, {  'PertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_pert_onset = pop_rmbase( EEG_pert_onset, [-500 0]);
EEG_nopert_onset = pop_epoch( EEG, {  'NoPertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_nopert_onset = pop_rmbase( EEG_nopert_onset, [-500 0]);

locthresh = 3;
globthresh = 3;
EEG_pert_onset = pop_jointprob(EEG_pert_onset, 1, [1:32], locthresh, globthresh, 1);
EEG_nopert_onset = pop_jointprob(EEG_nopert_onset, 1, [1:32], locthresh, globthresh, 1);

ERP_pert_onset = mean(EEG_pert_onset.data, 3);
ERP_nopert_onset = mean(EEG_nopert_onset.data, 3);

%save the ERPs
savename = [path '/' participant_id '_pert_onset_erps.mat'];
save(savename, "ERP_pert_onset");
savename = [path '/' participant_id '_nopert_onset_erps.mat'];
save(savename, "ERP_nopert_onset");

savename = [path '/' participant_id '_pert_onset_eeg.mat'];
save(savename, "EEG_pert_onset");
savename = [path '/' participant_id '_nopert_onset_eeg.mat'];
save(savename, "EEG_nopert_onset");

%% Perturbation onset - aware vs unaware
%see if there are both types of trials, if not, skip this participant
events = struct2table(EEG.event);
unaware_trials_n = sum(strcmp(events.type, 'PertOnset_unaware'));
if unaware_trials_n == 0
    return;
end

EEG_aware_crit = pop_epoch( EEG, {  'PertOnset_aware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_aware_onset = pop_rmbase( EEG_aware_onset, [-500 0]);
EEG_unaware_crit = pop_epoch( EEG, {  'PertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_unaware_onset = pop_rmbase( EEG_unaware_onset, [-500 0]);

locthresh = 3;
globthresh = 3;
EEG_aware_crit = pop_jointprob(EEG_aware_crit, 1, [1:32], locthresh, globthresh, 1);
EEG_unaware_crit = pop_jointprob(EEG_unaware_crit, 1, [1:32], locthresh, globthresh, 1);

ERP_aware_crit = mean(EEG_aware_crit.data, 3);
ERP_unaware_crit = mean(EEG_unaware_crit.data, 3);

%save the ERPs
savename = [path '/' participant_id '_aware_crit_erps.mat'];
save(savename, "ERP_aware_crit");
savename = [path '/' participant_id '_unaware_crit_erps.mat'];
save(savename, "ERP_unaware_crit");

savename = [path '/' participant_id '_aware_crit_eeg.mat'];
save(savename, "EEG_aware_crit");
savename = [path '/' participant_id '_unaware_crit_eeg.mat'];
save(savename, "EEG_unaware_crit");

%% Also extract awareness ratings for no-pert trials
events = struct2table(EEG.event);
false_alarms_n = sum(strcmp(events.type, 'NoPertOnset_aware'));
if ~false_alarms_n %no control trials with aware rating - save an empty file 
    EEG_aware_control = [];
    ERP_aware_control = [];
    savename = [path '/' participant_id '_aware_control_erps.mat'];
    save(savename, "ERP_aware_control");
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

ERP_aware_control = mean(EEG_aware_control.data, 3);
ERP_unaware_control = mean(EEG_unaware_control.data, 3);

%save the ERPs
savename = [path '/' participant_id '_aware_control_erps.mat'];
save(savename, "ERP_aware_control");
savename = [path '/' participant_id '_unaware_control_erps.mat'];
save(savename, "ERP_unaware_control");

savename = [path '/' participant_id '_aware_control_eeg.mat'];
save(savename, "EEG_aware_control");
savename = [path '/' participant_id '_unaware_control_eeg.mat'];
save(savename, "EEG_unaware_control");
