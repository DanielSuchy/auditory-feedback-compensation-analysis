%convert data from a participant into a .set file
%neur one stores a .ses file and a folder for each session (one session in our case)

%assumes batch processing, if not, add path and participant id manually
cd(path);

%convert the neurone file to eeglab file and save
%readneurone function is weird, just rerun the code if it crashes with the XMLSession bug
eeg = readneurone(strcat(pwd,'/'));
filename = [participant_id '.set'];
pop_saveset(eeg, 'filename', filename);