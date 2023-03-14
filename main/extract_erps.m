%extract erps from preprocessed data

%load the data individually
%set_file = '/Users/diskuser/analysis/eeg_data/main/eeg/S8-2022-10-31T175508/S8_preprocessed.set';
%path = '/Users/diskuser/analysis/eeg_data/main/eeg/S8-2022-10-31T175508';
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

EEG_aware_onset = pop_epoch( EEG, {  'PertOnset_aware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_aware_onset = pop_rmbase( EEG_aware_onset, [-500 0]);
EEG_unaware_onset = pop_epoch( EEG, {  'PertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
%EEG_unaware_onset = pop_rmbase( EEG_unaware_onset, [-500 0]);

locthresh = 3;
globthresh = 3;
EEG_aware_onset = pop_jointprob(EEG_aware_onset, 1, [1:32], locthresh, globthresh, 1);
EEG_unaware_onset = pop_jointprob(EEG_unaware_onset, 1, [1:32], locthresh, globthresh, 1);

ERP_aware_onset = mean(EEG_aware_onset.data, 3);
ERP_unaware_onset = mean(EEG_unaware_onset.data, 3);

%save the ERPs
savename = [path '/' participant_id '_aware_onset_erps.mat'];
save(savename, "ERP_aware_onset");
savename = [path '/' participant_id '_unaware_onset_erps.mat'];
save(savename, "ERP_unaware_onset");

savename = [path '/' participant_id '_aware_onset_eeg.mat'];
save(savename, "EEG_aware_onset");
savename = [path '/' participant_id '_unaware_onset_eeg.mat'];
save(savename, "EEG_unaware_onset");

