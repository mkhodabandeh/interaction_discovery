function ndcgs = measure_ndcg(scores, rels)

rp = randperm(length(scores));
scores = scores(rp);
rels = rels(rp);

n = length(scores);

[~, sortidx] = sort(scores, 'descend');
prels = rels(sortidx);

gains = prels ./ [1, log2(2:n)]';
dcgs = cumsum(gains);

srels = sort(rels, 'descend');
igains = srels ./ [1, log2(2:n)]';
idcgs = cumsum(igains);

ndcgs = dcgs ./ idcgs;
