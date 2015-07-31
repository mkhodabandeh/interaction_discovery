function randi = measure_randindex_adjust(gtlabels, pdlabels, beta)

unigt = unique(gtlabels);
nugt = length(unigt);

unipd = unique(pdlabels);
unipd(unipd == 0) = [];
count_pd = histc(pdlabels, unipd);
nupd = length(unipd);

count_int = zeros(nugt, nupd);
for i = 1:nugt
    for j = 1:nupd
        count_int(i, j) = sum((gtlabels == unigt(i)) & (pdlabels == unipd(j)));
    end
end

TPFP = count_pd .* (count_pd - 1) / 2;
TPFP = sum(TPFP);

TP = count_int .* (count_int - 1) / 2;
TP = sum(TP(:));

FP = TPFP - TP;

sumcount_int = cumsum(count_int, 2);
FN = sumcount_int(:, 1:end - 1) .* count_int(:, 2:end);
FN = sum(FN(:));

% TN = 0;
% for i = 1:size(count_int, 1)
%     for j = 1:size(count_int, 2)
%         tmp = count_int;
%         tmp(i, :) = 0;
%         tmp(:, j) = 0;
%         TN = TN + count_int(i, j) * sum(tmp(:));
%     end
% end
% TN = TN / 2;

P = TP / (TP + FP);
R = TP / (TP + FN);

randi = ((beta * beta + 1) * P * R) / (beta * beta * P + R);

% TPFPTNFN = sum(count_pd) * (sum(count_pd) - 1) / 2;
% randi = 1 - ((FP + FN) / TPFPTNFN);
