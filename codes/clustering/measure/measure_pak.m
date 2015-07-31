function PAK = measure_pak(Labels, Scores)
% Precision at top-k ranked instances
% 
% Labels: ground-truth labels;
% Scores: predicted scores;

[~, Index] = sort(-Scores);
Sort_Label = Labels(Index);
PAK = cumsum(Sort_Label) ./ (1:length(Sort_Label))';
