% extract f0 in the manner of Hafke (2008)
% load the data -> filter out high frequencies -> calculate the pitch -> save
% for further procesing
clear;

all_data = load('main\all_data.mat');
all_data = all_data.all_data;
all_data = all_data(1:10, :);
audapter_data = all_data.audapter_data;
audio = transpose({audapter_data(:).signalIn});
filtered_audio = lowpass_filter(audio);
f0 = extract_f0(filtered_audio);
f0 = transpose(f0); % store each observation in new row


all_data = [all_data table(f0)];
save('main\all_data.mat', "all_data");

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
        f0s{i} = pitch(audio{i}, sample_rate, Method="PEF");
    end
end