function [costs, ids, weights] = get_costs(scores, groups)

[n, k] = size(scores);
scores = double(scores);
ids = [];
weights = [];



%objective function coeficionts
temp_costs = zeros(n, k);
for i = 1:k
    xi = scores + 1 - repmat(scores(:, i), [1, k]);
    xi(:, i) = 0;
    xi(xi < 0) = 0;
    temp_costs(:, i) = sum(xi, 2);
end

if nargin == 1
    costs = scores;
else
    g = cellfun(@transpose, groups, 'UniformOutput', false);
    groupsidx = [g{:}]';
    regular_ids = removerows([1:n]', groupsidx);

    groups_costs = cell2mat(cellfun(@(x) sum(temp_costs(x, :), 1), groups, 'UniformOutput', false)');
    groups_sizes = cell2mat(cellfun(@length, groups, 'UniformOutput', false)');
    
    costs = [temp_costs(regular_ids, :); groups_costs];
    weights = [ones(length(regular_ids), 1); groups_sizes];

    ids = zeros(n, 1);
    ids(regular_ids) = [1:length(regular_ids)];
    for i = 1:length(groups_sizes)
        ids(groups{i}) = ones(length(groups{i}), 1) * (i+length(regular_ids));
    end
end
