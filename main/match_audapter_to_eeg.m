%make sure that the recorded audapter signal matches the recorded eeg signal
%sometimes some trials at the start were not recorded in the eeg signal
%these need to be excluded if audapter ost if used to detect the perturbation
clear all;

%load data individualy
response_sound_data = load('/Users/diskuser/analysis/all_data/experiment/S21/S21_block1_PertrurbExpPilot.mat');
eegfile = '/Users/diskuser/analysis/all_data/eeg/S21/S21_renamed.set';
participant_id = '/S21';
%or do batch processing
%eegfile = [path '/' participant_id '_renamed.set'];
%response_sound_data = load(['/Users/diskuser/analysis/all_data/experiment/' participant_id '/' participant_id '_block1_PertrurbExpPilot.mat']);

%extract audio data and eeg events from all data
responses = response_sound_data.whole_data;
audio = response_sound_data.audapter_data;
EEG = pop_loadset(eegfile);
events = struct2table(EEG.event);
%events(strcmp(events.type, 'undefined'), :).type = {'audapterstart'}
eeg_trial_starts = events(strcmp(events.type, 'audapterstart'), :);

disp([participant_id, ' eeg trials: ' num2str(height(events(strcmp(events.type,'audapterstart'), :))) ' audio trials: ' num2str(length(audio))]);

%remove part of the EEG signal from the start
EEG = pop_select(EEG, 'time', [1920 EEG.xmax]);
%add trial type at the start
latency = 1;
type = {'noperttrial'};
event = table(latency, type);
events = [event; events];
EEG.event = table2struct(events);
%remove response
responses(responses.trial==1,:) = [];

%find out how many trials were not recorded at the start in the eeg
%and remove these from other data sources as well
if length(audio) > height(eeg_trial_starts)
    to_remove = length(audio) - height(eeg_trial_starts);
    audio = audio(to_remove+1:end);
    responses = responses(to_remove+1:end,:);
elseif length(audio) < height(eeg_trial_starts)
    disp(['trim data manually for participant' participant_id])
    return;
else
    to_remove = 0;
end

%verify that the trial types and responses match
trial_types = ["perttrial", "bigperttrial", "noperttrial"];
trial_types = events(matches(events.type, trial_types), :);
trial_types.pert_magnitude = responses.pert_magnitude;
if height(trial_types(trial_types.pert_magnitude == 2 & ~strcmp(trial_types.type,'bigperttrial'), :)) > 0
    error('Error comparing eeg to audapter signal - trial types');
elseif height(trial_types(trial_types.pert_magnitude == 0.0001 & ~strcmp(trial_types.type,'noperttrial'), :)) > 0
    error('Error comparing eeg to audapter signal - trial types');
end

% for i=1:height(trial_types)
%     trial_type = awareness_ratings(i, :).type;
%     eeg_rating_latency = awareness_ratings(i, :).latency;
%     audapter_rating = responses(i, :).how_noticeable_response;
%     disp([eeg_rating audapter_rating  eeg_rating_latency i]);
%     %if strcmp(eeg_rating, 'awareness1') && audapter_rating == 3
%     %    disp(eeg_rating_latency);
%     %    break;
%     %end
% end


%verify that the awareness ratings match
awareness_ratings = ["awareness0", "awareness1", "awareness2", "awareness3"];
awareness_ratings = events(matches(events.type, awareness_ratings), :);
%responses(responses.trial==271,:) = [];
awareness_ratings.response = responses.how_noticeable_response;
if height(awareness_ratings(awareness_ratings.response == 0 & ~strcmp(awareness_ratings.type, 'awareness0'), :)) > 0
    error('Error comparing eeg to audapter signal - responses');
elseif height(awareness_ratings(awareness_ratings.response == 1 & ~strcmp(awareness_ratings.type, 'awareness1'), :)) > 0
    error('Error comparing eeg to audapter signal - responses');
elseif height(awareness_ratings(awareness_ratings.response == 2 & ~strcmp(awareness_ratings.type, 'awareness2'), :)) > 0
    error('Error comparing eeg to audapter signal - responses');
elseif height(awareness_ratings(awareness_ratings.response == 3 & ~strcmp(awareness_ratings.type, 'awareness3'), :)) > 0
    error('Error comparing eeg to audapter signal - responses');
end

for i=1:height(awareness_ratings)
    eeg_rating = awareness_ratings(i, :).type;
    eeg_rating_latency = awareness_ratings(i, :).latency;
    audapter_rating = responses(i, :).how_noticeable_response;
    disp([eeg_rating audapter_rating  eeg_rating_latency i]);
    if strcmp(eeg_rating, 'awareness1') && audapter_rating == 3
      disp(eeg_rating_latency);
      break;
    end
end

%save the structure in the original format
whole_data = responses;
audapter_data = audio;
save('/Users/diskuser/analysis/all_data/experiment/S21/S21_block1_PertrurbExpPilot_matched.mat', 'whole_data', 'audapter_data');
pop_saveset(EEG,'filename', '/Users/diskuser/analysis/all_data/eeg/S21/S21_matched.set');