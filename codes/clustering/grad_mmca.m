function [fval, grad] = grad_mmca(w, auxdata)

global data perf;

[ni, dim] = size(data);
kc = auxdata.kc;

%lsize = auxdata.clsrbalL * (ni / kc);
%usize = auxdata.clsrbalU * (ni / kc);

scores = data * reshape(w', [dim, kc]);

auxdata.lsize = auxdata.clsrbalL * (ni / kc);
auxdata.usize = auxdata.clsrbalU * (ni / kc);

labels = assign_lpa(scores,  auxdata);

% track performance
perf.iter = perf.iter + 1;
[perf.pa(perf.iter), perf.pp(perf.iter)] = measure_purity(perf.labeltr, labels);
perf.nmi(perf.iter) = measure_nmi(perf.labeltr, labels);
perf.ri(perf.iter) = measure_randindex(perf.labeltr, labels);
save(auxdata.modelfile, 'perf', '-append');

% most violated constraints
fval = 0;
grad = zeros(dim, kc);

n_arash = 0;
for i = 1:ni
    p = labels(i);
    for n = 1:kc
        if n == p , continue; end
        
        if p == 0
            %xip = 1 + scores(i,n) ;
            xip = 0;
        else
            xip = 1 + scores(i, n) - scores(i, p); 
        end
            
        if xip < 0
            continue 
        end
        
        n_arash = n_arash + 1;
        fval = fval + xip;
        currgrad = zeros(dim, kc);
        
        if p == 0
            %currgrad(:, n) = data(i,:)';
        else
            currgrad(:, p) = - data(i, :)';
            currgrad(:, n) = data(i, :)';    
        end
        grad = grad + currgrad;
    end
end
grad = grad(:);
grad = grad';

fval = fval / kc;
grad = grad / kc;
