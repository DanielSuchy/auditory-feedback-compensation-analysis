%create 'bins' in every file
%bins are special markers in the EEG signal required by the mass univariate toolbox
%also downsample the data to get more power for mass univariate analysis
ica_file = [path '/' participant_id '_ica_nolowpass.set'];
bins_file = [path '/' participant_id '_bins.set'];
instructions = '/Users/diskuser/analysis/auditory-feedback-compensation-analysis/main/bins.txt';

EEG = pop_loadset(ica_file);
EEG.subject = participant_id;
EEG = pop_resample(EEG, 250);
pop_saveset(EEG, 'filename', bins_file);
bin_info2EEG(bins_file, instructions, bins_file);