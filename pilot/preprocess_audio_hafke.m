% preprocess audio in the manner of Hafke (2008)
% load the data -> filter out high frequencies -> calculate the pitch -> save
% for further procesing
clear;

%do the same thing for every participant
all_files = dir("main/**/*PertrurbExpPilot.mat");
for i = 1:length(all_files)
    participant_filename = cat(2, all_files(i).folder, '\', all_files(i).name);
    audio = load_audio(participant_filename);
    filtered_audio = lowpass_filter(audio);
    f0s = extract_f0(filtered_audio);
    
    name = cat(2, all_files(i).folder, '\', all_files(i).name(1:2), '_f0.mat');
    save(name, 'f0s');
end

%load vocalizations from every trial into one variable
function audio = load_audio(filename)
    all_data = load(filename);
    audapter_data = all_data.audapter_data;
    audio = [];
    for i = 1:length(audapter_data)
        current_trial = audapter_data(i);
        current_sound = current_trial{1}.signalIn;
        audio{i} = current_sound;
    end
end

%lowpass-filter audio at 500Hz
function filtered_audio = lowpass_filter(audio)
    frequency_cutoff = 500; %Hz
    sample_rate = 16000;
    for i = 1:length(audio)
        filtered_audio{i} = lowpass(audio{i}, frequency_cutoff, sample_rate);
    end
end

%extract the fundamental frequency
function f0s = extract_f0(audio)
    sample_rate = 16000;
    for i = 1:length(audio)
        f0s{i} = pitch(audio{i}, sample_rate);
    end
end