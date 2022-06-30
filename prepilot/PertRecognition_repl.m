clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARTICIPANT FOLDER    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subject number and where to save files
cd('C:\speechres\PertRecognition_repl')

% specify participant sex
fprintf('\n')
sex = [];
while isempty(sex)
    sex = input('Type participant sex (1 = male, 2 = female): ');
end
fprintf('\n')

%typing a number is easy, but audapter needs it in this format
if sex == 1
    sex = 'male';
elseif sex == 2 
    sex = 'female';
end

subjectID = [];
while isempty(subjectID)
    subjectID = input('Type participant ID number: ');
end
fprintf('\n')

% session/block number
session = [];
while isempty(session)
    session = input('Type session/block number: ');
end
fprintf('\n')

savefolder = strcat('S', num2str(subjectID)); % where to save data (folder)
savefilename = sprintf('S%i_block%i_PertrurbExpPilot.mat', subjectID, session); % save data to this file

% check if the paticipant's folder exists
folder = exist(savefolder, 'dir');
if folder ~= 7
    mkdir(savefolder);
end
cd(savefolder);

% check if same filename exists in the folder
file = exist(savefilename, 'file');
if file == 2
    cont = input('Found a file with the same name - overwrite? [0 = no / 1 = yes / else = end experiment here] ');
    if cont == 1
        disp('Overwriting previous data...')
    else
        disp('Experiment terminated.')
        return
    end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUDAPTER PARAMETERS    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd('C:\speechres')

% add path to Audapter
addpath(genpath('C:\commonmcode-master'))
addpath(genpath('C:\audapter_matlab-master'))

% Audapter config
audioInterfaceName = 'MOTU MicroBook';
downFact = 3;
sRate = 16000; % Hardware sampling rate = 48000 (before downsampling)
frameLen = 32; % 96 before downsampling

Audapter('deviceName', audioInterfaceName);
Audapter('setParam', 'downFact', downFact, 1);
Audapter('setParam', 'sRate', sRate / downFact, 1);
Audapter('setParam', 'frameLen', frameLen / downFact, 1);

% online status tracking (OST)
% this file specifies the delay and duration of the perturbation
ostFN = 'C:\speechres\PertRecognition_repl\delayed_perturbation.ost';
Audapter('ost', ostFN, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSYCHTOOLBOX SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL; % Make sure this is running on OpenGL Psychtoolbox

PsychDefaultSetup(2);
[seed,whichGen] = ClockRandSeed; % Seed the random number generator
screenNumber = max(Screen('Screens'));

% Numer of frames to wait before re-drawing
waitframes = 1; % 1 = flip every frame

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% define keys
escapeKey = KbName('ESCAPE');
zeroKey = KbName('0');
oneKey = KbName('1');
twoKey = KbName('2');
threeKey = KbName('3');

%open the psytoolbox window
[window, wRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,[], [],  kPsychNeed32BPCFloat);
Screen('Flip', window);
ifi = Screen('GetFlipInterval', window);

%the text will look like this in the experiment
textsize = 25; 
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, textsize);
Screen('TextStyle', window, 0); % 0=normal, 1=bold, 2=italic, 4=underlined, 8=outline

%find center of the screen
[xCenter, yCenter] = RectCenter(wRect);
[winWidth, winHeight] = WindowSize(window);
topPriorityLevel = MaxPriority(window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% present grey screen
DrawFormattedText(window, ' ', 'center', 'center', white);
vbl = Screen('Flip', window);
HideCursor()

%present instructions
image = imread('C:\speechres\PertRecognition_repl\instructions.jpg');
our_texture = Screen('MakeTexture', window, image);
Screen('DrawTexture', window, our_texture, [], [400 25 1500 1000]);

%wait for participant to press any button
vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
KbStrokeWait;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERTURBATION SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd 'C:\speechres\PertRecognition_repl'
perts_rep = 1; %how many times should each perturbation be repeated (originally 30)
ntrials = 1; %should be 9 * perts rep

% Specify perturbation magnitudes
% Pitch shift is given in semitones, 1 semitone = 100 cents
pitch_shifts = [];
for i = [-1,-0.5,-0.19,-0.09,0,0.09,0.19,0.50,1]
    current_row = repmat(i, [1 perts_rep]);
    pitch_shifts = [pitch_shifts current_row];
end
pitch_shifts = repmat(2, [1 ntrials]); % same on every trial (for testing), 2 = large, easily noticeable perturbation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT LOOP   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for trial = 1:ntrials
    
    % select random pitch shift
    pitch_shift_index = randi(length(pitch_shifts));
    pitch_shift_magnitude = pitch_shifts(pitch_shift_index);
    
    %delete chosen pitch shift to prevent repeating
    pitch_shifts(pitch_shift_index) = [];

    % select pitch shifts in order
    %pitch_shift_magnitude = pitch_shifts(trial);
    
    % update Perturbation Configuration File to change perturbation magnitude
    fileID = fopen('delayed_pitch_shift.pcf', 'w')
    fprintf(fileID, '# Section 1 (Time warping): tBegin, rate1, dur1, durHold, rate2\n');
    fprintf(fileID, '0\n');
    fprintf(fileID, '\n');
    fprintf(fileID, '# Section 2: stat pitchShift(st) gainShift(dB) fmtPertAmp fmtPertPhi(rad)\n');
    fprintf(fileID, '6\n');
    fprintf(fileID, '0, 0, 0, 0, 0\n');
    fprintf(fileID, '1, 0, 0, 0, 0\n');
    fprintf(fileID, '2, 0, 0, 0, 0\n');
    fprintf(fileID, '3, %i, 0, 0, 0\n', pitch_shift_magnitude);
    fprintf(fileID, '4, 0, 0, 0, 0\n');
    fprintf(fileID, '5, 0, 0, 0, 0\n');
    fclose(fileID);
    
    pcfFN = 'C:\speechres\PertRecognition_repl\delayed_pitch_shift.pcf';
    Audapter('pcf', pcfFN, 1);
    
    params = getAudapterDefaultParams(sex);
    params.bPitchShift = 1;
    params.pBypassFmt = 0;
    params.bDetect = 1;
    params.rmsThresh = 0.03;
    params.bShift = 0;
    params.bRatioShift = 1;

    
    %-----------mix voice with noise-------------------
    params.fb = 3; % fb = feedback type, 3 = voice + noise
    noiseWavFN = 'audiocheck.net_pinknoise.wav'; % pink noise file
    maxPBSize = Audapter('getMaxPBLen');

    check_file(noiseWavFN);
    [w, fs] = read_audio(noiseWavFN);

    if fs ~= params.sr * params.downFact
        w = resample(w, params.sr * params.downFact, fs);              
    end
    if length(w) > maxPBSize
        w = w(1 : maxPBSize);
    end
    Audapter('setParam', 'datapb', w, 1);
    params.fb3Gain = 0.01; %set noise intensity
    
    AudapterIO('init', params);
    
    % take a break every 50 trials
    if ismember(trial, [51 101 151 201 251])
        text  = 'Feel free to take a break now.\n\nPress any button to continue.';
        DrawFormattedText(window, text, 'center', 'center', black);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 
        KbWait;
    end
    
    %show trial number at the start of every trial
    text  = ['trial ', num2str(trial), '/', num2str(ntrials)];
    DrawFormattedText(window, text, 'center', 'center', black);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(0.5);
    
    % start the countdown
    DrawFormattedText(window, '4', 'center', 'center', black);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(0.5);
        DrawFormattedText(window, '3', 'center', 'center', black);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        WaitSecs(0.5);
            DrawFormattedText(window, '2', 'center', 'center', black);
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            WaitSecs(0.5);
                DrawFormattedText(window, '1', 'center', 'center', black);
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                WaitSecs(0.5);
            
    %audapter starts recording and creating the perturbation
    Audapter('reset');
    Audapter('start');
    
    %go = strcat('go!', '_magnitude:_', num2str(pitch_shift_magnitude));
    DrawFormattedText(window, 'go!', 'center', 'center', black);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(4.5);
    
    DrawFormattedText(window, 'STOP', 'center', 'center', black);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    WaitSecs(0.6);
    Audapter('stop');
    
    %% Collect responses
    ask_confidence = false;
    
    % RESPONSE 1 - Objective discrimination ------------------------------
    Screen('TextSize', window, textsize);
    text = 'Was the pitch modified up or down? \n\n 1 = UP \n\n 0 = DOWN';
    DrawFormattedText(window, text, 'center', 'center', black);
    Screen('Flip', window);
    
    % wait for a response for 2.5 secs (Esc = exit)
    respToBeMade = true;
    while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(zeroKey)
            updown = 0; % down
            respToBeMade = false;
        elseif keyCode(oneKey)
            updown = 1; % up
            respToBeMade = false; 
        end
    end
    
    WaitSecs(0.2); % this needs to be there to separate screens, otherwise timing does not work 
    
    % RESPONSE 2 - subjective discrimination -----------------------------
    Screen('TextSize', window, textsize);
    DrawFormattedText(window, 'How noticeable was the change in pitch? \n\n [0-3]', 'center', 'center', black);
    Screen('Flip', window);


    % wait for a response for 2.5 secs (Esc = exit)
    respToBeMade = true;
    while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(zeroKey)
            how_noticeable = 0; % no detection
            respToBeMade = false;
        elseif keyCode(oneKey)
            how_noticeable = 1; % detection without direction
            respToBeMade = false; 
        elseif keyCode(twoKey)
            how_noticeable = 2; % detection with direction
            respToBeMade = false; 
        elseif keyCode(threeKey)
            how_noticeable = 3; % confident detection with direction
            respToBeMade = false; 
        end

    end
    
    WaitSecs(0.2); % this needs to be there to separate screens, otherwise timing does not work 
    
    % RESPONSE 3 -----------------------------------------
    if (ask_confidence == true)
        Screen('TextSize', window, textsize);
        DrawFormattedText(window, 'How confident are you? [0-3]', 'center', 'center', black);
        Screen('Flip', window);

        %wait for a response (Esc = exit)
        respToBeMade = true;
        while respToBeMade
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(zeroKey)
                confidence = 0;
                respToBeMade = false;
            elseif keyCode(oneKey)
                confidence = 1;
                respToBeMade = false;
            elseif keyCode(twoKey)
                confidence = 2;
                respToBeMade = false;
            elseif keyCode(threeKey)
                confidence = 3;
                respToBeMade = false;
            end
        end
    else % response to the firt question not provided - do not ask this one
        confidence = nan;
    end

    %% Save the data 
    updown_data(trial,1) = updown;
    updown = [];
    
    noticeable_data(trial,1) = how_noticeable;
    how_noticeable = [];
    
    confidence_data(trial,1) = confidence;
    confidence = [];
   
    magnitude_data(trial,1) = pitch_shift_magnitude;
    
    audapter_data{trial} = AudapterIO('getData');
    
    ost = audapter_data{trial}.ost_stat; % this trial's Audapter Online Status Tracking
    if sum(ost) == 0; ost_worked(trial,1) = 0; fprintf('ost does not work'); else ost_worked(trial,1) = 1; end
    ost = [];
    
    %% at end of experimental loop
    if trial == ntrials
        DrawFormattedText(window, ...
            'Thank you!' ,...
            'center', 'center', black);
        Screen('Flip', window);
        KbWait;
    end
end

% collect participant's whole data to a table
id_data = repmat(subjectID, ntrials, 1);
session_data = repmat(session, ntrials, 1);
trial_data = [1:ntrials]';
whole_data = cat(2, id_data, session_data, trial_data, ost_worked, magnitude_data, updown_data, noticeable_data, confidence_data);
whole_data = array2table(whole_data,'VariableNames', {'ID' 'block' 'trial' 'OST_worked' 'pert_magnitude' 'updown_response', 'how_noticeable_response' 'confidence_response'});

% save the table
cd('C:\speechres\PertRecognition_repl')
cd(savefolder)
save(savefilename, 'whole_data', 'audapter_data');

%close the experiment
Screen('Close');
Screen('CloseAll');
ShowCursor;

whole_data
%return

%% check pitch-shift

trial_to_display = 1;

frameDur = audapter_data{trial_to_display}.params.frameLen / audapter_data{trial_to_display}.params.sr;
tAxis = 0 : frameDur : frameDur * (size(audapter_data{trial_to_display}.fmts, 1) - 1);

ostMult = 250; % multiply OSF by ... for better visualization

pitch_shift_OST = 3; % specify here at which OSF the perturbation takes place
ost = audapter_data{trial_to_display}.ost_stat;

% check that online status tracking worked
if sum(ost) == 0; error('Cannot plot - OSF failed on this trial'); end 

ost_time_points = tAxis(ost == pitch_shift_OST);

input = audapter_data{trial_to_display}.signalIn;
output = audapter_data{trial_to_display}.signalOut;
fs = audapter_data{trial_to_display}.params.sr;

figure;
subplot(2,2,1)
    [s, f, t]=spectrogram(input, 256, 192, 1024, fs);
    imagesc(t, f, 10 * log10(abs(s))); hold on;
    axis xy;
    hold on;
    set(gca, 'YLim', [f(1), f(end)]);
    ost_t = zeros(1, size(t, 2));
    osf_t(t > ost_time_points(1) & t < ost_time_points(end)) = 1; 
    plot(t, (ost_t*ostMult), 'k');
    title('input')
    xlabel('time (s)')
    ylabel('frequency (hz)')
    legend('perturbation')

subplot(2,2,2)
    [s, f, t]=spectrogram(output, 256, 192, 1024, fs);
    imagesc(t, f, 10 * log10(abs(s))); hold on;
    axis xy;
    hold on;
    set(gca, 'YLim', [f(1), f(end)]);
    osf_t = zeros(1, size(t, 2));
    ost_t(t > ost_time_points(1) & t < ost_time_points(end)) = 1; 
    plot(t, (ost_t*ostMult), 'k');
    title('output')
    xlabel('time (s)')
    ylabel('frequency (hz)')
    legend('perturbation')
    
[s, f, t]=spectrogram(input, 256, 192, 1024, fs);
input_spectrum = 10 * log10(abs(s));
input_spectrum(input_spectrum == -Inf) = NaN;
input_spectrum(input_spectrum == Inf) = NaN;
input_spectrum = input_spectrum .* repmat(ost_t, [513 1]);
input_spectrum(input_spectrum == 0) = NaN;
mean_input_spectrum = nanmean(input_spectrum, 2);

[s, f, t]=spectrogram(output, 256, 192, 1024, fs);
shifted_spectrum = 10 * log10(abs(s));
shifted_spectrum(shifted_spectrum == -Inf) = NaN;
shifted_spectrum(shifted_spectrum == Inf) = NaN;
shifted_spectrum = shifted_spectrum .* repmat(ost_t, [513 1]);
shifted_spectrum(shifted_spectrum == 0) = NaN;
mean_shifted_spectrum = nanmean(shifted_spectrum, 2);

subplot(2,1,2)
    plot(f, mean_input_spectrum, 'b')
    hold on
    plot(f, mean_shifted_spectrum, 'r')
    legend('input', 'output')
    title('perturbation time-window')
    xlabel('frequency (hz)')
    ylabel('mean log10 power');
    
    
    
    
    
    
 