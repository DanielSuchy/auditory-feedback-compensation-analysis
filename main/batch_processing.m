%for all participants:
%create .set files, merge them, add audio markers, preprocess, create ERPs for analysis
clear all;
close all;

%this folder contains files for all participants
root_path = '/Users/diskuser/analysis/all_data/eeg/';
cd(root_path);

%load participants individually
files = dir('S*');
participant_folders = files([files.isdir]);

%run the pipeline
for participant = 1:length(participant_folders)
    path = [participant_folders(participant).folder '/' participant_folders(participant).name];
    participant_id = participant_folders(participant).name;
    if strcmp(participant_id, 'S2') || strcmp(participant_id, 'S20') || strcmp(participant_id, 'S22') ...
            || strcmp(participant_id, 'S25') ||  strcmp(participant_id, 'S28')
        continue %skip this participant for now (EEG trigger codes were different)
    end
    cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    %read_merge_eeg;
    %rename_triggers;
    %insert_responses %participants 1 and 2 only
    %match_audapter_to_eeg;
    %mark_pert_onset;
    %preprocess;
    extract_erps;
end