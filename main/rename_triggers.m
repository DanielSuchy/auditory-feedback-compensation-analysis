%rename eeg trigger codes to human-redable names to make preprocessing & analysis easier

%load the data individually
%set_file = '/Users/diskuser/analysis/all_data/eeg/S6-2022-10-24T183712/S6.set';
%or do batch processing
set_file = [path '/' participant_id '.set'];


EEG = pop_loadset(set_file);

%rename
events = EEG.event;
for i = 1:length(events)
    old_name = events(i).type;
    if strcmp(old_name, '1')
        new_name = 'noperttrial';
    elseif strcmp(old_name, '2')
        new_name = 'bigperttrial';
    elseif strcmp(old_name, '3')
        new_name = 'perttrial';
    elseif strcmp(old_name, '21')
        new_name = 'audapterstart';
    elseif strcmp(old_name, '22')
        new_name = 'audapterend';
    elseif strcmp(old_name, '30')
        new_name = 'awareness0';
    elseif strcmp(old_name, '31')
        new_name = 'awareness1';
    elseif strcmp(old_name, '32')
        new_name = 'awareness2';
    elseif strcmp(old_name, '33')
        new_name = 'awareness3';
    else
        new_name = 'undefined';
    end

    events(i).type = new_name;
end

%save
EEG.event = events;
savename = [path '/' participant_id '_renamed.set'];
EEG = pop_saveset(EEG, 'filename',savename);
disp('Renamed triggers to human-readable format')