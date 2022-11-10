%convert data from a participant into a .set file
%neur one stores a .ses file and a folder for each session (one in our case)
clear;

%this folder contains all collected eeg data (same structure as in the eeg computer)
data_path = '/Users/diskuser/analysis/eeg_data/main/eeg/';
%try processing only a single participant for now
participant_id = 'S6';
participant_folder = dir([participant_id '-2022*']);
participant_path = [data_path participant_folder.name];
cd(participant_path);

%convert the neurone file to eeglab file and save
%readneurone function is weird, just rerun the code if it crashes with the XMLSession bug
eeg = readneurone(strcat(pwd,'/'));
filename = [participant_id '.set'];
pop_saveset(eeg, 'filename', filename);