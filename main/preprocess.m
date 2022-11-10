clear all;
close all;

%load the data
set_file = '../../eeg_data/main/eeg/S6-2022-10-24T183712/S6_perts.set';
EEG = pop_loadset(set_file);

% remove audio channels
EEG = pop_select( EEG,'nochannel',{'audio'}); 

% add channel locations
EEG=pop_chanedit(EEG, 'lookup','/Users/diskuser/matlab_tools/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
orign_chanlocs = EEG.chanlocs;

% check for bad channels
EEG = pop_rejchan(EEG, 'elec', [1:size(EEG.data, 1)] ,'threshold',3,'norm','on','measure','kurt');
removed = 32 - size(EEG.data, 1);
EEG = pop_rejchan(EEG, 'elec', [1:size(EEG.data, 1)] ,'threshold',3,'norm','on','measure','prob');
removed = removed + (32 - size(EEG.data, 1));

%filter
EEG = pop_eegfiltnew(EEG, 1, 0); %high-pass
EEG = pop_eegfiltnew(EEG, 0, 40); %low-pass

% interpolate channels
EEG = pop_interp(EEG, orign_chanlocs, 'spherical');

% average reference
EEG = pop_reref(EEG, []);

% Discard channels to make the data full ranked, and run ICA
datarank = 32 - removed;
channelSubset = loc_subsets(EEG.chanlocs, datarank);
EEG = pop_select( EEG,'channel', channelSubset{1});
EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');
EEG = pop_runica(EEG, 'extended',1,'interupt','on');    

% interpolate channels
EEG = pop_interp(EEG, orign_chanlocs, 'spherical');

% DIPFIT (fit dipoles to components)
% EEG = pop_dipfit_settings( EEG, 'hdmfile','/run/media/hmrail/My Book Duo/eeglab14_1_1b/plugins/dipfit3.7/standard_BEM/standard_vol.mat','coordformat','MNI','mrifile','/home/hmrail/eeglab14_1_1b/plugins/dipfit3.7/standard_BEM/elec/standard_1005.elc','chanfile','/run/media/hmrail/My Book Duo/eeglab14_1_1b/plugins/dipfit3.7/standard_BEM/elec/standard_1005.elc','coord_transform',[0.83215 -15.6287 2.4114 0.081214 0.00093739 -1.5732 1.1742 1.0601 1.1485] ,'chansel',[1:EEG.nbchan] );
% EEG = pop_multifit(EEG, [1:size(EEG.icaact, 1)], 'dipoles', 2, 'threshold', 100);

% IC label
EEG = pop_iclabel(EEG, 'default');
brainIdx  = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) >= 0.7); % find which components are classified as brain-based with this probability
EEG = pop_subcomp(EEG, brainIdx, 0, 1);
EEG.etc.ic_classification.ICLabel.classifications = EEG.etc.ic_classification.ICLabel.classifications(brainIdx,:); % update IC label info
% if using DIPFIT, this can be something like:
    % rvList    = [EEG.dipfit.model.rv]; % residual variances
    % goodRvIdx = find(rvList < 0.15); % find components with residual variance < x
    % goodIcIdx = intersect(brainIdx, goodRvIdx); % these are the components we keep
    % EEG = pop_subcomp(EEG, goodIcIdx, 0, 1); % remove components
    %EEG.etc.ic_classification.ICLabel.classifications = EEG.etc.ic_classification.ICLabel.classifications(goodIcIdx,:); % update IC label info

%% Voice onset
% epoch, baseline removal, and artifact rejection
EEG_voice_onset = pop_epoch( EEG, {  'voice_onset'  }, [-0.5 3], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG_voice_onset = pop_rmbase( EEG_voice_onset, [-500 0]);

    locthresh = 3;
    globthresh = 3;
    EEG_voice_onset = pop_jointprob(EEG_voice_onset, 1, [1:32], locthresh, globthresh, 1);
    
    
    ERP_voice_onset = mean(EEG_voice_onset.data, 3);
    
    figure;
    pop_timtopo(EEG_voice_onset, [-200  598], [-100 150  250  400], 'test', 'maplimits', [-4 4]);
   
    
    figure;
    plot_channels = [5 6 18 21 22 23 24];
    plot(EEG_voice_onset.times, mean(ERP_voice_onset(plot_channels, :))', 'LineWidth', 3) 
    xlim([-200 300])
    title('Voice onset ERP')
    xlabel('Time (ms)')
    ylabel('Amplitude')
    l = line([0 0],[-5 5]); l.Color = 'k';
    l = line([1500 1500],[-5 5]); l.Color = 'k'; l.LineStyle  =':'
    l = line([-500 3000],[0 0]); l.Color = 'k';

%% Perturbation onset
% epoch, baseline removal, and artifact rejection
EEG_pert_onset = pop_epoch( EEG, {  'PertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG_pert_onset = pop_rmbase( EEG_pert_onset, [-500 0]);
EEG_nopert_onset = pop_epoch( EEG, {  'NoPertOnset'  }, [-0.5 1], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG_nopert_onset = pop_rmbase( EEG_nopert_onset, [-500 0]);

    locthresh = 3;
    globthresh = 3;
    EEG_pert_onset = pop_jointprob(EEG_pert_onset, 1, [1:32], locthresh, globthresh, 1);
    EEG_nopert_onset = pop_jointprob(EEG_nopert_onset, 1, [1:32], locthresh, globthresh, 1);

    ERP_pert_onset = mean(EEG_pert_onset.data, 3);
    ERP_nopert_onset = mean(EEG_nopert_onset.data, 3);

    figure;
    plot_channels = 1:10;
    plot(EEG_pert_onset.times, mean(ERP_pert_onset(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
    hold on
    plot(EEG_nopert_onset.times, mean(ERP_nopert_onset(plot_channels, :))', 'LineWidth', 3) % 18 = Cz
    xlim([-200 800])
    ylim([-3 3])
    legend('Perturbation', 'No perturbation')
    title('Voice onset ERP')
    xlabel('Time (ms)')
    ylabel('Amplitude')
    l = line([0 0],[-5 5]); l.Color = 'k';
    l = line([-500 1000],[0 0]); l.Color = 'k';
