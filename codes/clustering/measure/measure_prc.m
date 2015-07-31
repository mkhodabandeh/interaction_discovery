function [Precisions, Recalls] = measure_prc(Label, Scores, NumPR)
% Precision-Recall Curve
% 
% Labels: ground-truth labels;
% Scores: predicted scores;
% NumPR: number of pr-curve samples;

[~, Sort_Index] = sort(-Scores);
Sort_Label = Label(Sort_Index);
total_num = length(Label);
positive_num = length(find(Label == 1));
Precisions_All = zeros(positive_num, 1);

cumulate_num = 0;
for i = 1:total_num
    if Sort_Label(i) == 1
        cumulate_num = cumulate_num + 1;
        Precisions_All(cumulate_num) = cumulate_num / i;
    end
end

Recalls = (0:(1 / NumPR):1)';
Recalls(1) = 1 / positive_num;
temp = round(positive_num .* Recalls);
Precisions = Precisions_All(temp);
