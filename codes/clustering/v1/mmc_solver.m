function [ scores, labels ] = mmc_solver( labels, lambda, conf, auxdata)
%MMC_SOLVER Summary of this function goes here
%   iterative solver: svm, label

    max_iter = 200;
    fval_thresh = 0.1;
    
    global data perf;

    %[n, dim] = size(data);
    kc = auxdata.kc;
    
    
    dfval = 1;
    fval = 10^10;
    iter = 0;
    %w = w0;
    while dfval > fval_thresh && iter < max_iter
        scores = find_w(labels, auxdata);
        labels = assign_lpa(scores, auxdata);
        iter = iter+1;
        dfval = compute_fval(scores, labels)-fval;
        fval = fval + dfval;
    end


end

