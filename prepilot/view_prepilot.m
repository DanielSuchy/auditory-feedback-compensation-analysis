s0 = load('S0\S0_block1_PertrurbExpPilot.mat');
s1 = load('S1\S1_block1_PertrurbExpPilot.mat');

% tabular data only, not auditory
responses = [s0.whole_data; s1.whole_data];

% do we have the correct amount of data
height(responses)
height(responses(responses.ID == 1, :)) % participant 1
height(responses(responses.ID == 0, :)) % participant 0

% did the ost work?
height(responses(responses.OST_worked == 1, :))

% create a column that says if the response is correct or not
responses.correct = nan([height(responses) 1]);

idCorrect = find(responses.pert_magnitude > 0 & responses.updown_response == 1);
responses.correct(idCorrect) = true;

idCorrect = find(responses.pert_magnitude < 0 & responses.updown_response == 0);
responses.correct(idCorrect) = true;

idIncorrect = find(responses.pert_magnitude < 0 & responses.updown_response == 1);
responses.correct(idIncorrect) = false;

idIncorrect = find(responses.pert_magnitude > 0 & responses.updown_response == 0);
responses.correct(idIncorrect) = false;

% are the participants correct?
height(responses(responses.correct == 1, :))
height(responses(responses.correct == 0, :))

% correct responses by perturbation magnitude
perts = unique(responses.pert_magnitude);
perttype_agg = [];
for i = 1:length(perts)
    pert = perts(i);
    if (pert == 0)
        continue;
    end

    ids = find(responses.correct == 1 & responses.pert_magnitude == pert);
    perttype_agg = [perttype_agg; [pert length(ids)]];
end

% display correct reponses by pert. magnitude in bar plot
bar(perttype_agg(:, 1), perttype_agg(:, 2))



