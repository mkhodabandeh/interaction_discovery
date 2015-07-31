global perf;
l1 = res{1}.labels;
l2 = res{2}.labels;
l3 = res{3}.labels;
gt = perf.labeltr;

l1(pairs_history{1})
l2(pairs_history{2})
l3(pairs_history{1})


l = [l1;l2;l3];
%arrayfun(@(d) [arrayfun(@(x) sum(l(d,:) == x), 1:5);arrayfun(@(x) sum(gt(l(d,:)==x) == mode(gt(l(d,:)==x))), 1:5)], [1:2]', 'UniformOutput')

d = l2;
k = 5;
cluster_sizes = arrayfun(@(x) sum(d == x), 1:k)
cluster_most_frequent_item_size = arrayfun(@(x) sum(gt(d==x) == mode(gt(d==x))), 1:k)
cluster_most_frequent_item = arrayfun(@(x) mode(gt(d==x)), 1:k)
[vs, ids] = sort(cluster_most_frequent_item);
most_frequent_item = cluster_most_frequent_item(ids)
most_frequent_item_size = cluster_most_frequent_item_size(ids)
cluster_sizes = cluster_sizes(ids)

ground_truth_sizes = arrayfun(@(x) sum(gt == x), 1:k)


