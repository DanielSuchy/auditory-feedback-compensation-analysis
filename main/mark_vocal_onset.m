%mark where the vocalization and the perturbations starts in each epoch

%load the data individually
set_file = '/Users/diskuser/analysis/eeg_data/main/eeg/S6-2022-10-24T183712/S6_renamed.set';
participant_id = 'S6';
%or do batch processing
%set_file = [path '/' participant_id '_renamed.set'];

EEG = pop_loadset(set_file);

%certain participants have audio issues
%scan these using the figure below
%and remove them using the following code
if strcmp(participant_id, 'S5')
    EEG = pop_select( EEG, 'time',[800 EEG.xmax] );
end

%extract the audio
EEG_audio = pop_select( EEG ,'channel',{'audio'});
original_markers_n = length(EEG.event);

%% plot trigger markers and audiodata
set(0,'defaultAxesFontSize',16)
sample_length = 1000/EEG.srate; % in ms
time_seconds = linspace(1, (size(EEG_audio.data, 2)*(sample_length)./1000), size(EEG_audio.data, 2));
figure;
plot(time_seconds, abs(EEG_audio.data), 'k','LineWidth', 1)
for e = 1:length(EEG.event)
    if strcmp(EEG.event(e).type, 'noperttrial')
        line([EEG.event(e).latency*sample_length./1000 EEG.event(e).latency*sample_length./1000], [2000 -2000], 'Color', 'green', 'LineWidth', 3)
    elseif strcmp(EEG.event(e).type,'bigperttrial') || strcmp(EEG.event(e).type,'2')
        line([EEG.event(e).latency*sample_length./1000 EEG.event(e).latency*sample_length./1000], [2000 -2000], 'Color', 'blue', 'LineWidth', 3)
    elseif strcmp(EEG.event(e).type,'perttrial') || strcmp(EEG.event(e).type,'3')
        line([EEG.event(e).latency*sample_length./1000 EEG.event(e).latency*sample_length./1000], [2000 -2000], 'Color', 'red', 'LineWidth', 3)
    end
end
xlabel 'time (sec)'
clear 'e'

%% Add markers to the onset of vocalization
threshold = 150;
userdecides = 0;
set(0,'DefaultFigureWindowStyle','docked');
audiodata = abs(EEG_audio.data);
audiodata_bin = audiodata;
audiodata_bin(audiodata >= threshold) = 1;
audiodata_bin(audiodata <= threshold) = 0;

trial_start = 500; % visualize audiodata N samples before the threshold is crossed
trial_end = 3000; % visualize audiodata N samples before the threshold is crossed
timeaxis = linspace(-trial_start*2, trial_end*2, (trial_start+trial_end+1));

prompt = 'Include [Enter] or exclude [n] marker?';
i = 1;
count = 0;
onsetsdetected = 1;

figure
set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultAxesFontSize',20)

nevents = length(EEG.event);

while i < length(audiodata_bin) % loop over each sample
    
    % end while loop when at the end of data
    if i+trial_end > length(audiodata)
        break
    end
    
    if audiodata_bin(i) == 1 && sum(audiodata_bin(1,i:i+300)) > 100 && sum(audiodata_bin(1,i-300:i)) < 50
        count = count + 1;
        
        % plot each phoneme
        if userdecides
            try
                plot(timeaxis, audiodata(1,(i-trial_start):(i+trial_end)), 'k', 'LineWidth', 2);
            catch
                plot(timeaxis, audiodata(1, 1:(1+length(timeaxis)-1)), 'k', 'LineWidth', 2);
            end
            
            xlim([-trial_start, trial_end]);
            xlabel('time (ms)'); ylabel('amplitude')
            pl = line([-trial_start*2 trial_end*2], [threshold threshold]); % threshold
            pl.LineWidth = 3;
            ylim([-50 2000])

            try
                pl = line([0 0], [0 max(audiodata(1,(i-trial_start):(i+trial_end)))]); % threshold crossed at time
            catch
                pl = line([0 0], [0 max(audiodata(1,1:(1+length(timeaxis)-1)))]); % threshold crossed at time
            end
            
            pl.LineWidth = 3;
            
            str = input(prompt, 's');
            if strcmp(str, '')
                % save time sample
                speechonsets(onsetsdetected) = i;
                onsetsdetected = onsetsdetected + 1;
                
                EEG.event(nevents+1).type = 'voice_onset';
                EEG.event(nevents+1).latency = i;
                EEG.event(nevents+1).duration = 1;
                nevents = nevents +1;
            end
            
        else
            % save time sample
            speechonsets(onsetsdetected) = i;
            onsetsdetected = onsetsdetected+1;
            
            EEG.event(nevents+1).type = 'voice_onset';
            EEG.event(nevents+1).latency = i;
            EEG.event(nevents+1).duration = 1;
            
            nevents = nevents +1;
        end
        
        i = i+500; % skip time points (towards next speech onset)
        
    else
        i = i+1;
    end
end
fprintf('added markers/trials: %i/%i', onsetsdetected-1, count)
fprintf('\n')

set(0,'DefaultFigureWindowStyle','normal')
set(0,'defaultAxesFontSize',12)

%% Correct trials where the voice onset happens before audapter start
%find out what event follows each voice onset
events = struct2table(EEG.event);
events = sortrows(events, 'latency');
next_events = events(2:end, 1:2);
type = 0;
latency = 0;
next_events = [next_events; table(type, latency)];
events.next_event = next_events.type;
events.next_latency = next_events.latency + 1;

%voice_onset should be followed by audapterstart (see below) or audapter end (usually); if not it needs to be excluded
latencies_to_delete = events(strcmp(events.type, 'voice_onset') & ~(strcmp(events.next_event, 'audapterstart') | strcmp(events.next_event, 'audapterend')), :).latency;
%sometimes, the participant starts phonation sooner that audapter starts (voice_onset -> audapterstart)
%but the perturbation cannot start sooner than the minimal preset limit (1.5s) after audapterstart
%in this case voice onset should be moved to audapter start in order to correctly assign pert start
%remove this option when viewing voice onset ERPs
latencies_to_change = events(strcmp(events.type, 'voice_onset') & strcmp(events.next_event, 'audapterstart'), [1 5]);

new_events = struct2table(EEG.event);
new_events(ismember(new_events.latency, latencies_to_delete), :) = [];
new_events(ismember(new_events.latency, latencies_to_change.latency), :).latency = latencies_to_change.next_latency;
EEG.event = table2struct(new_events);

%% Mark perturbation onset for each trial/condition... 
perturbation_delay = 1500; % in milliseconds
perturbation_delay = perturbation_delay ./ sample_length; % in samples

counter = 0;
n_markers = length(EEG.event);
for e = 1:original_markers_n % loop over original markers
    if sum(strcmp(EEG.event(e).type, {'noperttrial' 'bigperttrial', 'perttrial'})) % find no_perturbation (1, 2) or perturbation (3) trials
        trial_start_latency = EEG.event(e).latency; % 
        response_latency = EEG.event(e+2).latency; % latency of button press (i.e., after vocalization)
        response = EEG.event(e+3).type; % what they responded
        trial_type = EEG.event(e).type;
        
        % was perturbation present or not?
        if strcmp(EEG.event(e).type, 'noperttrial') %zero pert control trial
            perturbation_present = 0;
        elseif strcmp(EEG.event(e).type, 'bigperttrial') % big pert control trial
            perturbation_present = 1;
        elseif strcmp(EEG.event(e).type, 'perttrial') % critical trial
            perturbation_present = 2;     
        else
            error('something wrong')
        end
        
        % find corresponding voice onset marker and add marker to
        % perturbation onset (and info about condition)
        for i = original_markers_n:n_markers % loop over newly added voice-onset markers
            if (EEG.event(i).latency > trial_start_latency) && (EEG.event(i).latency < response_latency)
                counter = counter + 1;
                if perturbation_present == 1
                    new_event_idx = n_markers+counter;
                    EEG.event(new_event_idx) = EEG.event(i);
                    EEG.event(new_event_idx).type = 'PertOnset'; 
                    EEG.event(new_event_idx).latency = EEG.event(i).latency + perturbation_delay;
                elseif perturbation_present == 2
                    awareness = EEG.event(e+3).type;
                    if strcmp(awareness, 'awareness0')
                        awareness = 'unaware';
                    else
                        awareness = 'aware';
                    end
                    pert_type = ['PertOnset_' awareness];
                    new_event_idx = n_markers+counter;
                    EEG.event(new_event_idx) = EEG.event(i);
                    EEG.event(new_event_idx).type = pert_type; 
                    EEG.event(new_event_idx).latency = EEG.event(i).latency + perturbation_delay;
                else
                    new_event_idx = n_markers+counter;
                    EEG.event(new_event_idx) = EEG.event(i);
                    EEG.event(new_event_idx).type = 'NoPertOnset'; 
                    EEG.event(new_event_idx).latency = EEG.event(i).latency + perturbation_delay; 
                end
            end
        end
    end
end
fprintf('number of modified marker names: %i', counter)
fprintf('\n')

savename = [path '/' participant_id '_perts.set'];
EEG = pop_saveset(EEG, 'filename',savename);
disp('added perturbation onset to set files')
