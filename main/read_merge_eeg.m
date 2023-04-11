%convert data from a participant into a .set file
%neur one stores a .ses file and a folder for each session

%assumes batch processing, if not, add path and participant id manually
path = '/Users/diskuser/analysis/all_data/eeg/S24';
participant_id = 'S24';
cd(path);

%sometimes there are multiple sessions for each participant - these need to be merged
all_files = dir;
all_dir = all_files([all_files(:).isdir]);
num_dir = numel(all_dir);
sessions = num_dir - 2; % exclude folders . and ..

%usually there is only one file - convert, merging not necessary
if sessions == 1
    eeg = readneurone(strcat(pwd,'/'));
    filename = [participant_id '.set'];
    pop_saveset(eeg, 'filename', filename);
else %multiple sessions/blocks
    %convert the neurone file to eeglab file and save, individually for each block
    for i=1:sessions
        eeg = readneurone(strcat(pwd,'/'), i);
        filename = [participant_id '_block' num2str(i) '.set'];
        pop_saveset(eeg, 'filename', filename);
    end
    
    %merge the individual blocks
    sets = dir('*_block*.set');
    for i=1:length(sets)
        eeg = pop_loadset(sets(i).name);
        if i == 1
            all_eeg = eeg;
        else
            all_eeg = pop_mergeset(all_eeg, eeg);
        end
    end
    
    all_eeg = pop_saveset(all_eeg, 'filename', strcat(participant_id,'.set'));
end

disp(['Extracted and merged data for participant ', participant_id]);