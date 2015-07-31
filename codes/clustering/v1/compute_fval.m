function [ fval ] = compute_fval( scores, labels )
%COMPUTE_FVAL Summary of this function goes here
%   Detailed explanation goes here

    [n, k] = size(scores);
    fval = 0;
    for i = 1:n
        p = labels(i);
        if p == 0, continue; end
        xip = 1 + max(scores(i, :) - repmat(scores(i, p), [1, k]));
        if xip < 0, continue; end
        fval = fval + xip;
    end


end

