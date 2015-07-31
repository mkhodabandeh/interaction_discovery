function BEP = measure_bep(Labels, Scores)
% Break-Event-Point
% 
% Labels: groundtruth labels;
% Scores: predicted scores;

[~, Sort_Index] = sort(-Scores);
Sort_Label = Labels(Sort_Index);
total_num = length(Labels);
positive_num = length(find(Labels == 1));
Recall = zeros(positive_num, 1);
Precision = zeros(positive_num, 1);

cumulate_num = 0;
for i = 1:total_num
    if Sort_Label(i) == 1
        cumulate_num = cumulate_num + 1;
        Recall(cumulate_num) = cumulate_num;
        Precision(cumulate_num) = cumulate_num / i;
    end
end
Recall = Recall / positive_num;
PRdiff = abs(Precision - Recall);
[~, min_index] = min(PRdiff);

BEP = (Precision(min_index) + Recall(min_index)) / 2;
