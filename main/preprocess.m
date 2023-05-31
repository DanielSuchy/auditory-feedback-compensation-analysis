%load the data individually
%set_file = '/Users/diskuser/analysis/eeg_data/main/eeg/S11-2022-11-07T162012/S11_perts.set';
%path = '/Users/diskuser/analysis/eeg_data/main/eeg/S11-2022-11-07T162012/';
%participant_id = 'S11';
%or do batch processing
set_file = [path '/' participant_id '_perts.set'];

%decide if we have to to run the ICA
run_ica = 1;

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
%EEG = pop_eegfiltnew(EEG, 0, 40); %low-pass

%remove line noise
figure; subplot(1,2,1); pop_spectopo(EEG, 1, [0  EEG.times(end)], 'EEG' , 'percent', 15, 'freq', [6 10 50], 'freqrange',[1 80],'electrodes','off');
% ZapLine
FLINE=50/EEG.srate; % line frequency
NREMOVE=3; % number of components to remove
[clean_EEG, noise] = nt_zapline_plus(EEG.data',FLINE,NREMOVE);
EEG.data = clean_EEG';  
subplot(1,2,2); pop_spectopo(EEG, 1, [0  EEG.times(end)], 'EEG' , 'percent', 15, 'freq', [6 10 50], 'freqrange',[1 80],'electrodes','off');

% interpolate channels
EEG = pop_interp(EEG, orign_chanlocs, 'spherical');

% average reference
EEG = pop_reref(EEG, []);
%linked mastoids
%EEG = pop_reref( EEG, [27 28] );
%EEG = pop_interp(EEG, orign_chanlocs, 'spherical');

%save
savename = [path '/' participant_id '_preprocessed.set'];
EEG = pop_saveset(EEG, 'filename',savename);

if run_ica == 1
    % Discard channels to make the data full ranked
    datarank = 32 - removed;
    channelSubset = loc_subsets(EEG.chanlocs, datarank);
    EEG = pop_select( EEG,'channel', channelSubset{1});
    EEG = pop_chanedit(EEG, 'eval','chans = pop_chancenter( chans, [],[]);');

    %epoch and remove baseline
    EEG = pop_epoch(EEG, {'NoPertOnset' 'PertOnset' 'PertOnset_aware1' ...
        'PertOnset_aware2' 'PertOnset_aware3' 'PertOnset_unaware'  }, [-0.5  1], 'epochinfo', 'yes');
    EEG = pop_rmbase( EEG, [-500 0] ,[]);

    % run ICA
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
    %EEG.etc.ic_classification.ICLabel.classifications = EEG.etc.ic_classification.ICLabel.classifications(brainIdx,:); % update IC label info
    % if using DIPFIT, this can be something like:
        % rvList    = [EEG.dipfit.model.rv]; % residual variances
        % goodRvIdx = find(rvList < 0.15); % find components with residual variance < x
        % goodIcIdx = intersect(brainIdx, goodRvIdx); % these are the components we keep
        % EEG = pop_subcomp(EEG, goodIcIdx, 0, 1); % remove components
        %EEG.etc.ic_classification.ICLabel.classifications = EEG.etc.ic_classification.ICLabel.classifications(goodIcIdx,:); % update IC label info

    
    EEG = pop_interp(EEG, orign_chanlocs, 'spherical');

    savename = [path '/' participant_id '_ica.set'];
    EEG = pop_saveset(EEG, 'filename',savename);
end