function MAP = measure_map(Labels, Scores)
% Mean Average Precision
% 
% Labels: ground-truth labels;
% Scores: predicted scores;

[~, Sort_Index] = sort(-Scores);
Sort_Label = Labels(Sort_Index);
total_num = length(Labels);
positive_num = length(find(Labels == 1));
Precision = zeros(positive_num, 1);

cumulate_num = 0;
for i = 1:total_num
    if Sort_Label(i) == 1
        cumulate_num = cumulate_num + 1;
        Precision(cumulate_num) = cumulate_num / i;
    end
end

MAP = mean(Precision);
