function EFF = measure_eff(Labels, Scores, S)
% Effectiveness
% 
% Labels: ground-truth labels;
% Scores: predicted scores;
% S: parameter;

relevant_num = length(find(Labels == 1));
retrived_num = S;
[~, Index] = sort(-Scores);
Sort_Label = Labels(Index);
Sort_Label_retrived = Sort_Label(1:S, 1);
retrived_relevant_num = length(find(Sort_Label_retrived == 1));

if S >= relevant_num
    EFF = retrived_relevant_num / relevant_num;
else
    EFF = retrived_relevant_num / retrived_num;
end
