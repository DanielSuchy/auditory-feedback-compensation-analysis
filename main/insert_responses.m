clear all;

%load EEG signal and keyboard responses
responses = load('/Users/diskuser/analysis/all_data/experiment/S2/S2_block1_PertrurbExpPilot.mat');
responses = responses.whole_data;
EEG = pop_loadset('/Users/diskuser/analysis/all_data/eeg/S2/S2_renamed.set');

%see if we have all trials in both responses and eeg
eeg_events = struct2table(EEG.event);
eeg_trials_n = sum(strcmp(eeg_events.type, 'audapterstart'));

%eeg signal does not contain the first two trials for participant 1
%responses = responses(3:end, :);
responses_n = height(responses);

if eeg_trials_n ~= responses_n
    disp('eeg signal does not match keyboard signal');
    return;
end

% %go through all eeg events one-by-one
% %if end of perturbation is found, insert a new event just behind it
% %this event contains participant's answer for this trial
% i = 1; %event count
% trial_count = 1; % there are multiple events per trial
% while i < height(eeg_events) + 1
%     current_event = table2array(eeg_events(i, "type")); % e.g. 'audapterend'
%     current_event_latency = table2array(eeg_events(i, "latency")); %when it happened
%     if strcmp(current_event, 'audapterend') && i ~= 1  %insert response at the end of every  fully recorded trial
%         latency = current_event_latency + 50; %introduce a slight delay for better visualization
%         type = {['awareness' num2str(table2array(responses(trial_count, 'how_noticeable_response')))]}; %extract participant's response
%         trial_count = trial_count + 1;
% 
%         %insert a new row into the table
%         events1 = eeg_events(1:i, :);
%         events2 = eeg_events(i+1:end, :);
%         new_row = table(latency, type);
%         eeg_events = [events1; new_row; events2];
%     end
%     i = i + 1;
% end

 

%save the result
EEG.event = table2struct(eeg_events);
savename = '/Users/diskuser/analysis/all_data/eeg/S2/S2_renamed.set';
EEG = pop_saveset(EEG, 'filename',savename);