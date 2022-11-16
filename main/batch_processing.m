%for all participants:
%create .set files, merge them, add audio markers, preprocess, create ERPs for analysis
clear all;
close all;

%this folder contains files for all participants
root_path = '/Users/diskuser/analysis/eeg_data/main/eeg/';
cd(root_path);

%load participants individually
files = dir('*2022*');
participant_folders = files([files.isdir]);

%run the pipeline
for participant = 1:length(participant_folders)
    path = [participant_folders(participant).folder '/' participant_folders(participant).name];
    participant_id = extractBefore(participant_folders(participant).name, '-');
    if strcmp(participant_id, 'S1') || strcmp(participant_id, 'S3') || strcmp(participant_id, 'S5')
        continue %skip this participant for now (EEG trigger codes were different)
    end
    %cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    %read_merge_eeg;
    %cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    %rename_triggers;
    %cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    %mark_vocal_onset;
    %cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    %preprocess;
    cd('/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/')
    extract_erps;
end