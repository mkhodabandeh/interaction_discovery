function [pa, pp, extra] = measure_purity_multiclass(gtlabels, pdlabels)


unigt = 1:size(gtlabels, 2);
nugt = length(unigt);

unipd = unique(pdlabels);
unipd(unipd == 0) = [];
nupd = length(unipd);
count_pd = histc(pdlabels, unipd);

% intersection
count_int = zeros(nugt, nupd);
for i = 1:nugt
    for j = 1:nupd
        count_int(i, j) = sum((gtlabels(:, unigt(i)) == 1) & (pdlabels == unipd(j)));
    end
end

[nmaxgt, maxgt] = max(count_int, [], 1);
pa = sum(nmaxgt) / sum(count_pd);
pp = mean(nmaxgt' ./ count_pd);

extra.maxgt = unigt(maxgt);
extra.nmaxgt = nmaxgt';
extra.count_pd = count_pd';
