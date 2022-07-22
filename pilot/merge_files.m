%save all data in a single table to make analysis easier
clear;

all_files = dir("main/**/*PertrurbExpPilot.mat");
all_response_data = table();
all_audio_data = [];

% extract data from each participant
for i = 1:length(all_files)
    path_to_file = cat(2, all_files(i).folder, '\', all_files(i).name);
    current_data = load(path_to_file);
    current_audio = transpose(current_data.audapter_data); % reverse rows to columns
    current_responses = current_data.whole_data;
    all_response_data = [all_response_data; current_responses];
    all_audio_data = [all_audio_data; current_audio];
end

%merge data types, give pretty names, remove empty columns
all_data = [all_response_data all_audio_data];
all_data = removevars(all_data, {'block', 'confidence_response'});
all_data = renamevars(all_data, ["ID", "Var9", "OST_worked"], ["participant", "audapter_data", "ost_worked"]);

save('main\all_data.mat', "all_data", '-v7.3');
disp('merged all data into a single file');