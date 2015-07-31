function NMI = measure_nmi_multiclass(gtlabels, pdlabels)

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
count_gt = sum(count_int, 2);

ngts = sum(gtlabels(:));
npds = length(pdlabels);

logterm = repmat(count_gt, [1, nupd]) .* repmat(count_pd', [nugt, 1]);
logterm = npds .* count_int ./ logterm;
MIs = count_int .* log2(logterm + eps) ./ ngts;
MI = sum(MIs(:));

% normalization
prob_gt = count_gt ./ ngts;
Hgt = - sum(prob_gt .* log2(prob_gt));

prob_pd = count_pd ./ npds;
Hpd = - sum(prob_pd .* log2(prob_pd));

NMI = 2 * MI / (Hgt + Hpd);
