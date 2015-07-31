function [rec, prec, ap] = measure_vocmap(gt, out, draw)

[~, si] = sort(-out);
tp = gt(si) > 0;
fp = gt(si) < 0;

fp = cumsum(fp);
tp = cumsum(tp);
rec = tp / sum(gt > 0);
prec = tp ./ (fp + tp);

ap = VOCap(rec, prec);

if draw
    % plot precision/recall
    plot(rec, prec, '-');
    grid;
    xlabel('recall');
    ylabel('precision');
    title(sprintf('AP = %.3f', ap));
end
