function ndcgs = measure_ndcg_exp(scores, rels)

rp = randperm(length(scores));
scores = scores(rp);
rels = rels(rp);

n = length(scores);

[~, sortidx] = sort(scores, 'descend');
prels = rels(sortidx);

gains = ((2 .^ prels) - 1) ./ log2(2:(n + 1))';
dcgs = cumsum(gains);

srels = sort(rels, 'descend');
igains = ((2 .^ srels) - 1) ./ log2(2:(n + 1))';
idcgs = cumsum(igains);

ndcgs = dcgs ./ idcgs;
