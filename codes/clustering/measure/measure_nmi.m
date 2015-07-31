function NMI = measure_nmi(gtlabels, pdlabels)

unigt = unique(gtlabels);
count_gt = histc(gtlabels, unigt);
nugt = length(unigt);
ngts = length(gtlabels);

unipd = unique(pdlabels);
unipd(unipd == 0) = [];
count_pd = histc(pdlabels, unipd);
nupd = length(unipd);
npds = length(pdlabels);

% intersection
count_int = zeros(nugt, nupd);
for i = 1:nugt
    for j = 1:nupd
        count_int(i, j) = sum((gtlabels == unigt(i)) & (pdlabels == unipd(j)));
    end
end

logterm = repmat(count_gt, [1, nupd]) .* repmat(count_pd', [nugt, 1]);
logterm = ngts .* count_int ./ logterm;
MIs = count_int .* log2(logterm + eps) ./ npds;
MI = sum(MIs(:));

% normalization
prob_gt = count_gt ./ ngts;
Hgt = - sum(prob_gt .* log2(prob_gt));

prob_pd = count_pd ./ npds;
Hpd = - sum(prob_pd .* log2(prob_pd));

NMI = 2 * MI / (Hgt + Hpd);
