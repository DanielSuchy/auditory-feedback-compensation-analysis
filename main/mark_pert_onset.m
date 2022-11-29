%load the data individually
%response_sound_data = load('S4_block1_PertrurbExpPilot.mat');
%setfile = '/Users/diskuser/analysis/tutorial/audapter_eeg_sync/S4_renamed.set';
%or do batch processing
set_file = [path '/' participant_id '_matched.set'];
response_sound_data = load(['/Users/diskuser/analysis/eeg_data/main/experiment/' participant_id '/' participant_id '_block1_PertrurbExpPilot_matched.mat']);

responses = response_sound_data.whole_data;
audio = response_sound_data.audapter_data;
EEG = pop_loadset(set_file);
events = struct2table(EEG.event);

%% Perturbation Onset
% go through the trials one-by-one and mark the perturbation onset
current_trial = 0;
n_markers = length(EEG.event);
for i=1:n_markers
    if strcmp(EEG.event(i).type, 'audapterstart')
        current_trial = current_trial + 1;
        trial_audio = audio(current_trial);
        trial_audio = trial_audio{1};

        %load ost status at different time points
        ost_status = trial_audio.ost_stat;
        frame_dur = trial_audio.params.frameLen / trial_audio.params.sr;
        t_axis = 0 : frame_dur : frame_dur * (size(trial_audio.fmts, 1) - 1);

        %sync ost status with audapter start
        sample_length = 1000/EEG.srate; % in ms
        audapterstart = events(i, :).latency;
        audapterstart_sec = audapterstart * sample_length./1000;
        t_axis_offset = t_axis + audapterstart_sec;

        %load the perturbation start    
        ost_pert_flag = 3;
        pert_time_points = t_axis_offset(ost_status == ost_pert_flag); %select time-points with ongoing pert
        if pert_time_points
            pert_start = pert_time_points(1);
            pert_start = pert_start / (sample_length./1000);
        else
            continue
        end

        %get info about trial type
        trial_event = EEG.event(i-1);
        if strcmp(trial_event.type, 'noperttrial') %zero pert control trial
            perturbation_present = 0;
        elseif strcmp(trial_event.type, 'bigperttrial') % big pert control trial
            perturbation_present = 1;
        elseif strcmp(trial_event.type, 'perttrial') % critical trial
            perturbation_present = 2; 
        else
            error('something wrong');
        end

        %mark perturbation start in the eeg signal
        if perturbation_present == 1
            new_event_idx = n_markers+current_trial;
            EEG.event(new_event_idx) = EEG.event(i);
            EEG.event(new_event_idx).type = 'PertOnset';
            EEG.event(new_event_idx).latency = pert_start;
        elseif perturbation_present == 2
            awareness = EEG.event(i+2).type;
            if strcmp(awareness, 'awareness0')
                awareness = 'unaware';
            else
                awareness = 'aware';
            end
            pert_type = ['PertOnset_' awareness];
            new_event_idx = n_markers+current_trial;
            EEG.event(new_event_idx) = EEG.event(i);
            EEG.event(new_event_idx).type = pert_type;
            EEG.event(new_event_idx).latency = pert_start;
        else
            new_event_idx = n_markers+current_trial;
            EEG.event(new_event_idx) = EEG.event(i);
            EEG.event(new_event_idx).type = 'NoPertOnset';
            EEG.event(new_event_idx).latency = pert_start;
        end
    end
end

savename = [path '/' participant_id '_perts.set'];
pop_saveset(EEG, 'filename', savename);