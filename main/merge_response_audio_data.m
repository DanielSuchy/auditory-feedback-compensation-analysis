%save all response and audio data in a single table to make analysis easier
clear;

%make a list of indivudal data files (one per participant)
all_files = dir("../../eeg_data/main/experiment/**/*.mat");
all_response_data = table();
all_audio_data = [];

% extract data from each participant
for i = 1:length(all_files)
    path_to_file = cat(2, all_files(i).folder, '/', all_files(i).name);
    current_data = load(path_to_file);
    current_audio = transpose(current_data.audapter_data); % reverse rows to columns
    current_responses = current_data.whole_data;
    all_response_data = [all_response_data; current_responses];
    all_audio_data = [all_audio_data; current_audio];
end

%merge data types, give pretty names, remove empty columns
all_data = [all_response_data all_audio_data];
all_data = removevars(all_data, {'block', 'confidence_response', 'updown_response'});
all_data = renamevars(all_data, ["ID", "Var9", "OST_worked", 'how_noticeable_response'], ["participant", "audapter_data", "ost_worked", 'awareness']);

save('../../eeg_data/main/response_audio_data.mat', "all_data", '-v7.3');
disp('merged all data into a single file');
