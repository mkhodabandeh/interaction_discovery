function [fval, grad] = grad_lmmca_with_global_subject1(w, auxdata)

global data latent_data perf;

number_of_global_data = size(data, 1);
new_data_1 = [data(1:number_of_global_data/2, :), data(number_of_global_data/2+1:end, :)];
new_data_2 = [data(number_of_global_data/2+1:end, :), data(1:number_of_global_data/2, :)];
new_data = cat(3, new_data_1, new_data_2);
dim = size(latent_data, 2);
global_dim = size(data, 2); 
kc = auxdata.kc;

global_w = w(1:global_dim*kc*2); %First part is subject 1 and Second part is subject 2
latent_w = w(global_dim*kc*2+1: end);
[scores, global_latent_var_assignments, latent_var_assignments_subject_1] = ...
    infer_global_latent_variables_subject1(latent_w, global_w, auxdata);
%[ latent_scores, global_scores, latent_var_assignments, global_latent_var_assignments ] = ...
%    infer_global_latent_variables(latent_w, global_w, auxdata);
    
%[latent_scores, latent_variables] = infer_latent_variables(latent_w,auxdata);
%global_scores = data_new * reshape(global_w', [global_dim, kc]);

%scores = latent_scores + global_scores;
ni = size(scores, 1);
auxdata.lsize = auxdata.clsrbalL * (ni / kc);
auxdata.usize = auxdata.clsrbalU * (ni / kc);

labels = assign_lpa(scores,  auxdata);

% track performance
non_zero_indx = labels ~= 0;
gtlabels = perf.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

 perf.iter = perf.iter + 1;
 [perf.pa(perf.iter), perf.pp(perf.iter)] = measure_purity(gtlabels, pdlabels);
 perf.nmi(perf.iter) = measure_nmi(gtlabels, pdlabels);
 perf.ri(perf.iter) = measure_randindex(gtlabels, pdlabels);
 save(auxdata.modelfile, 'perf', '-append');

% most violated constraints
fval = 0;
latent_grad_subject_1 = zeros(dim, kc); % left part is for the first subject and right part is for second subject
global_grad = zeros(2*global_dim, kc); % likewise

n_arash = 0;
for i = 1:ni
    p = labels(i);
    for n = 1:kc
        if n == p, continue; end
        
        if p == 0
            %xip =  1 + scores(i,n) ;
            xip = 0;
        else
            xip = 1 + scores(i, n) - scores(i, p);
        end
            
        if xip < 0, continue; end
        
        fval = fval + xip;
        latent_currgrad_subject_1 = zeros(dim, kc);
        latent_currgrad_subject_2 = zeros(dim, kc);
        global_currgrad = zeros(2*global_dim, kc);
        n_arash = n_arash + 1;
        if p == 0
            %currgrad(:, n) = data(latent_variables(i,n), :)';
        else
            if ~isempty(latent_data)
                latent_currgrad_subject_1(:, p) = - latent_data(latent_var_assignments_subject_1(i,p), :)';
                latent_currgrad_subject_1(:, n) = latent_data(latent_var_assignments_subject_1(i,n), :)';    
            end
            global_currgrad(:, p) = - new_data(i, :, global_latent_var_assignments(i,p))';
            global_currgrad(:, n) = new_data(i, :, global_latent_var_assignments(i,n))';    
        end
        latent_grad_subject_1 = latent_grad_subject_1 + latent_currgrad_subject_1;
        global_grad = global_grad + global_currgrad;
    end
end
latent_grad_subject_1 = latent_grad_subject_1(:);
latent_grad_subject_1 = latent_grad_subject_1';
global_grad = global_grad(:);
global_grad = global_grad';

fval = fval / kc;
latent_grad_subject_1 = latent_grad_subject_1 / kc;
global_grad = global_grad / kc;
grad = [global_grad, latent_grad_subject_1];

% n_arash/kc + grad * w'
% fval
