function [pa, extra] = measure_purity_unbalance(gtlabels, pdlabels)

unigt = unique(gtlabels);
nugt = length(unigt);

unipd = unique(pdlabels);
unipd(unipd == 0) = [];
nupd = length(unipd);

% intersection
count_int = zeros(nugt, nupd);
for i = 1:nugt
    for j = 1:nupd
        count_int(i, j) = sum((gtlabels == unigt(i)) & (pdlabels == unipd(j)));
    end
end
count_gt = sum(count_int, 2);
prob_int = count_int ./ repmat(count_gt, [1, nupd]);

[pmaxgt, maxgt] = max(prob_int, [], 1);
pa = mean(pmaxgt);

extra.maxgt = unigt(maxgt);
extra.pmaxgt = pmaxgt';
