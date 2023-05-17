%extract erps from preprocessed data

%load the data individually
%set_file = '/Users/diskuser/analysis/all_data/eeg/S20/S20_ica.set';
%path = '/Users/diskuser/analysis/all_data/eeg/S20';
%participant_id = 'S20';
%or do batch processin
set_file = [path '/' participant_id '_ica.set'];

EEG = pop_loadset(set_file);
%EEG = pop_resample(EEG, 100); %downsample to 100 Hz for mass univariate analysis

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
locthresh = 3;
globthresh = 3;
events = struct2table(EEG.event);
unaware_trials_n = sum(strcmp(events.type, 'PertOnset_unaware'));
aware1_trials_n = sum(strcmp(events.type, 'PertOnset_aware1'));
aware2_trials_n = sum(strcmp(events.type, 'PertOnset_aware2'));
aware3_trials_n = sum(strcmp(events.type, 'PertOnset_aware3'));

if unaware_trials_n > 1
    erp_data = pop_epoch( EEG, {  'PertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_unaware_crit_eeg.mat'];
    save(savename, "erp_data");
end

if aware1_trials_n > 1
    erp_data = pop_epoch( EEG, {  'PertOnset_aware1'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware1_crit_eeg.mat'];
    save(savename, "erp_data");
end

if aware2_trials_n > 1
    erp_data = pop_epoch( EEG, {  'PertOnset_aware2'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware2_crit_eeg.mat'];
    save(savename, "erp_data");
end

if aware3_trials_n > 1
    erp_data = pop_epoch( EEG, {  'PertOnset_aware3'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware3_crit_eeg.mat'];
    save(savename, "erp_data");
end

%% Also extract awareness ratings for no-pert trials
locthresh = 3;
globthresh = 3;
events = struct2table(EEG.event);
unaware_trials_n = sum(strcmp(events.type, 'NoPertOnset_unaware'));
aware1_trials_n = sum(strcmp(events.type, 'NoPertOnset_aware1'));
aware2_trials_n = sum(strcmp(events.type, 'NoPertOnset_aware2'));
aware3_trials_n = sum(strcmp(events.type, 'NoPertOnset_aware3'));

if unaware_trials_n > 1
    erp_data = pop_epoch( EEG, {  'NoPertOnset_unaware'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_unaware_control_eeg.mat'];
    save(savename, "erp_data");
end

if aware1_trials_n > 1
    erp_data = pop_epoch( EEG, {  'NoPertOnset_aware1'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware1_control_eeg.mat'];
    save(savename, "erp_data");
end

if aware2_trials_n > 1
    erp_data = pop_epoch( EEG, {  'NoPertOnset_aware2'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware2_control_eeg.mat'];
    save(savename, "erp_data");
end

if aware3_trials_n > 1
    erp_data = pop_epoch( EEG, {  'NoPertOnset_aware3'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    erp_data = pop_jointprob(erp_data, 1, [1:32], locthresh, globthresh, 1);
    
    %save the data by participant and trials type
    savename = [path '/' participant_id '_aware3_control_eeg.mat'];
    save(savename, "erp_data");
end
