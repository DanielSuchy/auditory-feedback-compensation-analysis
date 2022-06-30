clear 
clear 

%include both participants, right?
cd 'F:/materialy/thesis/analysis/prepilot/';
s0 = load('S0/S0_block1_PertrurbExpPilot.mat');
s1 = load('S1/S1_block1_PertrurbExpPilot.mat');
whole_data = [s0.whole_data; s1.whole_data];
audapter_data = [s0.audapter_data s1.audapter_data];


%% Behavioral data
% discard bad trials
whole_data(:,whole_data.OST_worked == 0) = [];

% make a binary "is_aware of perturbation" variable
whole_data.aware = zeros(size(whole_data, 1), 1);
whole_data.aware(whole_data.how_noticeable_response > 0) = 1;

% make accuracy variable (correct discrimination)
% shouldn't zeros be processed separately?
% why not use percentages rather than means for binary values (accuracy, awareness)
% whole_data.accuracy = zeros(size(whole_data, 1), 1);
% whole_data.accuracy(whole_data.pert_magnitude < 0 & whole_data.updown_response == 0) = 1;
% whole_data.accuracy(whole_data.pert_magnitude > 0 & whole_data.updown_response == 1) = 1;

whole_data.accuracy = nan(size(whole_data, 1), 1);
whole_data.accuracy(whole_data.pert_magnitude < 0 & whole_data.updown_response == 0) = 1;
whole_data.accuracy(whole_data.pert_magnitude > 0 & whole_data.updown_response == 1) = 1;
whole_data.accuracy(whole_data.pert_magnitude < 0 & whole_data.updown_response == 1) = 0;
whole_data.accuracy(whole_data.pert_magnitude > 0 & whole_data.updown_response == 0) = 0;

% aggregate data
% unique: 
%   first argument = unique values, 
%   second argument = indeces of unique values in the original data, 
%   third argument = indeces of unique values in the first argument
[unique_perts, ~, n] = unique(whole_data.pert_magnitude); %assign index for each perturbation, e.g. -.9 always equals 4
mean_accuracy  = accumarray(n, whole_data.accuracy, [], @(x)  mean(x));
mean_ratings  = accumarray(n, whole_data.how_noticeable_response, [], @(x)  mean(x));
mean_aware  = accumarray(n, whole_data.aware, [], @(x)  mean(x));
mean_up  = accumarray(n, whole_data.updown_response, [], @(x)  mean(x));

perturbations = unique(whole_data.pert_magnitude); % list perturbations

figure
subplot(1,3,1)
plot(perturbations, mean_accuracy, 'o-')
xlabel('perturbation size')
ylabel('mean accuracy')
set(gca,'FontSize',16)

subplot(1,3,2)
plot(perturbations, mean_ratings, 'o-')
xlabel('perturbation size')
ylabel('mean rating')
set(gca,'FontSize',16)

subplot(1,3,3)
plot(perturbations, mean_aware, 'o-')
xlabel('perturbation size')
ylabel('proportion aware')
set(gca,'FontSize',16)

%compare data accross participants
[participants, ~, n] = unique(whole_data.ID);
mean_accuracy = accumarray(n, whole_data.accuracy, [], @(x)  mean(x, 'omitnan'));
mean_aware = accumarray(n, whole_data.aware, [], @(x)  mean(x, 'omitnan'));
mean_rating = accumarray(n, whole_data.how_noticeable_response, [], @(x)  mean(x, 'omitnan'));
participants_agg = table(participants, mean_accuracy, mean_aware, mean_rating);

%asign response type to each trial
%(hit, false-alarm, miss, correct-rejection)
whole_data.response_type = strings(size(whole_data, 1), 1);
whole_data.response_type(whole_data.how_noticeable_response > 0 & whole_data.pert_magnitude ~= 0) = 'hit';
whole_data.response_type(whole_data.how_noticeable_response > 0 & whole_data.pert_magnitude == 0) = 'false_alarm';
whole_data.response_type(whole_data.how_noticeable_response == 0 & whole_data.pert_magnitude == 0) = 'correct_rejection';
whole_data.response_type(whole_data.how_noticeable_response == 0 & whole_data.pert_magnitude ~= 0) = 'miss';

%create contingency table with response types
participants_agg.hits = zeros(size(participants_agg, 1), 1);
participants_agg.false_alarms = zeros(size(participants_agg, 1), 1);
participants_agg.misses = zeros(size(participants_agg, 1), 1);
participants_agg.correct_rejections = zeros(size(participants_agg, 1), 1);

%fill the contingency table for each participant
for trial_n = 1:size(whole_data)
    trial = whole_data(trial_n, :);
    response_type = trial.response_type;
    row_id = trial.ID + 1;

    if strcmp(response_type, 'hit')
        participants_agg(row_id, :).hits = participants_agg(row_id, :).hits + 1;
    elseif strcmp(response_type, 'false_alarm')
        participants_agg(row_id, :).false_alarms = participants_agg(row_id, :).false_alarms + 1;
    elseif strcmp(response_type, 'miss')
        participants_agg(row_id, :).misses = participants_agg(row_id, :).misses + 1;
    elseif strcmp(response_type, 'correct_rejection')
        participants_agg(row_id, :).correct_rejections = participants_agg(row_id, :).correct_rejections + 1;
    end
end

% calculate sensitivity, specificity and criterion
participants_agg.sensitivity = participants_agg.hits / (participants_agg.hits + participants_agg.correct_rejections);
participants_agg.sensitivity = participants_agg.sensitivity(:,2);
participants_agg.dprime = zscore(participants_agg.hits) - zscore(participants_agg.correct_rejections);
participants_agg.criterion = -0.5 * (zscore(participants_agg.hits) + zscore(participants_agg.false_alarms));


%% Audapter data
fs = 16000;

data_1 = nan(405,1);
data_min1 = nan(405,1);
data_05 = nan(405,1);
data_min05 = nan(405,1);
data_019 = nan(405,1);
data_min019 = nan(405,1);
data_009 = nan(405,1);
data_min009 = nan(405,1);
all_pert_data = table();

% how do you approach auditory data from different participants?
% merge them? -> but different voices have different properties
% normalize them? -> but is averaging around zero enough?
% look for this in papers

for trial = 1:size(whole_data,1)

    % plot only unconscious perturbations
    if whole_data.aware(trial) > 0; continue; end
    
    audio = audapter_data{trial}.signalOut;
    
    % discard first and last x seconds of data
    audio(1:8000) = [];
    audio((end-8000):end) = [];
    
    % get f0
    [f0, idx] = pitch(audio,fs);
    
    % shift baseline to 0 (baseline correct to the first 50 samples)
    f0 = f0 - mean(f0(1:100));
    
    if size(f0,1) ~= 405; continue; end
    
    time = (0:length(audio)-1)/fs;
    time_pitch = (idx - 1)/fs;
    
    % find out when the perturbation starts
    ost_pert_flag = 3;
    ost = audapter_data{trial}.ost_stat;
    frameDur = audapter_data{trial}.params.frameLen / audapter_data{trial}.params.sr;
    tAxis = 0 : frameDur : frameDur * (size(audapter_data{trial}.fmts, 1) - 1);
    ost_time_points = tAxis(ost == ost_pert_flag);
    pert_start_time = ost_time_points(1);
    
    %cut the part before perturbation
    time_after_pert = time_pitch(time_pitch > pert_start_time);
    pert_start_index = find(time_pitch == time_after_pert(1), 1);
    f0(1:pert_start_index-1) = nan; % ignore everything before pert
    
    
    %compare pert. direction to voice adaptation direction
    mean_f0_after_pert = mean(f0, 'omitnan');
    if (whole_data(trial,:).pert_magnitude > 0)
        pert_direction = {'positive'};
    else
        pert_direction = {'negative'};
    end
    if (mean_f0_after_pert > 0)
        voice_direction = {'positive'};
    else
        voice_direction = {'negative'};
    end

    %create a table with perturbations and their frequencies
    new_row = table(whole_data(trial, :).ID, whole_data(trial, :).pert_magnitude, ...
        whole_data(trial, :).aware, mean_f0_after_pert, pert_direction, voice_direction, ...
        'VariableNames',{'participant', 'pert_magnitude', 'aware', 'mean_f0_after_pert', 'pert_direction', 'voice_direction'});
    all_pert_data = [all_pert_data; new_row];

    switch whole_data.pert_magnitude(trial)
       case -1
            if isnan(data_min1); data_min1 = f0;
            else; data_min1 = cat(2, data_min1, f0); end
       case 1
            if isnan(data_1); data_1 = f0;
            else; data_1 = cat(2,data_1, f0); end
       
       case -0.5
            if isnan(data_min05); data_min05 = f0;
            else; data_min05 = cat(2, data_min05, f0); end
       case 0.5
            if isnan(data_05); data_05 = f0;
            else; data_05 = cat(2,data_05, f0); end
      
       case -0.19
            if isnan(data_min019); data_min019 = f0;
            else; data_min019 = cat(2, data_min019, f0); end
       case 0.19
            if isnan(data_019); data_019 = f0;
            else; data_019 = cat(2,data_019, f0); end
    
       case -0.09
            if isnan(data_min009); data_min009 = f0;
            else; data_min009 = cat(2, data_min009, f0); end
       case 0.09
            if isnan(data_009); data_009 = f0;
            else; data_009 = cat(2,data_009, f0); end
    end
end

figure;
% upward perturbations
subplot(2,4,1)
plot(time_pitch, data_1, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('+1 perturbation')

subplot(2,4,2)
plot(time_pitch, data_05, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('+0.5 perturbation')

subplot(2,4,3)
plot(time_pitch, data_019, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('+0.19 perturbation')

subplot(2,4,4)
plot(time_pitch, data_009, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('+0.09 perturbation')


% downward perturbations
subplot(2,4,5)
plot(time_pitch, data_min1, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('-1 perturbation')

subplot(2,4,6)
plot(time_pitch, data_min05, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('-0.5 perturbation')

subplot(2,4,7)
plot(time_pitch, data_min019, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('-0.19 perturbation')

subplot(2,4,8)
plot(time_pitch, data_min009, 'Color', [.7 .7 .7 .5])
line([0 4], [0 0], 'Color', [0 0 0])
ylim([-10 10])
title('-0.09 perturbation')

% voice x pert direction asignment
all_pert_data.react_type = strings(size(all_pert_data, 1), 1);
all_pert_data.react_type(strcmp(all_pert_data.pert_direction, all_pert_data.voice_direction), :) = "adaptation";
all_pert_data.react_type(~strcmp(all_pert_data.pert_direction, all_pert_data.voice_direction), :) = "compensation";

[react_type, ~, n] = unique(all_pert_data.react_type);
react_types_sum = accumarray(n, all_pert_data.react_type(1), [], @(x)  sum(x));
