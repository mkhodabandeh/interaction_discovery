function [fval, grad] = grad_lmmca(w, auxdata)

global data latent_data perf;

dim = size(data, 2);
kc = auxdata.kc;
num_data = auxdata.num_data;
num_latent = auxdata.num_latent;
global_feature_size = auxdata.global_feature_size;
latent_feature_size = auxdata.latent_feature_size;
num_clusters = auxdata.kc;
user_interaction = auxdata.user_interaction;

%% Extract weight vectors
w0_vec = w(1:(global_feature_size+1)*num_clusters);
w1_vec = w((global_feature_size+1)*num_clusters+1:...
    (global_feature_size+1)*num_clusters + latent_feature_size * num_clusters);

w0 = reshape(w0_vec, global_feature_size+1, num_clusters); % Fg by K
w1 = reshape(w1_vec, latent_feature_size, num_clusters); %Fl by K

[scores, latent_variables] = infer_latent_variables(w0, w1, auxdata);


%% Choose best labeling using Linear Programming
ni = size(scores, 1);
auxdata.lsize = auxdata.clsrbalL * (ni / num_clusters);
auxdata.usize = auxdata.clsrbalU * (ni / num_clusters);


if auxdata.training == 0
    if user_interaction == 1
        pairs = auxdata.pairs;
        groups = auxdata.groups;
        [costs, merged_to_reg_ids, weights] = get_costs(scores, groups);
        new_pairs = merged_to_reg_ids(pairs);
        temp_labels = assign_lpa_user_interaction(costs, auxdata, new_pairs, weights);
        labels = temp_labels(merged_to_reg_ids);
    else
        [costs, ~, ~] = get_costs(scores);
        labels = assign_lpa(costs, auxdata);
    end
else
    labels = auxdata.training_labels;
end


%% track performance
non_zero_indx = labels ~= 0;
gtlabels = perf.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

 perf.iter = perf.iter + 1;
 [perf.pa(perf.iter), perf.pp(perf.iter)] = measure_purity(gtlabels, pdlabels);
 perf.nmi(perf.iter) = measure_nmi(gtlabels, pdlabels);
 perf.ri(perf.iter) = measure_randindex(gtlabels, pdlabels);
 save(auxdata.modelfile, 'perf', '-append');

%% most violated constraints
fval = 0;
grad = zeros(size(w));

a = 0;
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
        a = a+1;
        fval = fval + xip;
        w0_grad = zeros(size(w0));
        w1_grad = zeros(size(w1));
        
        if p == 0
            %currgrad(:, n) = data(latent_variables(i,n), :)';
        else
            w1_grad(:, p) = w1_grad(:, p) - latent_data(latent_variables(i,p), :)';
            w1_grad(:, n) = w1_grad(:, n) + latent_data(latent_variables(i,n), :)';    
            w0_grad(:, p) = w0_grad(:, p) - data(i, :)';
            w0_grad(:, n) = w0_grad(:, n) + data(i, :)';    
            
        end
        grad = grad + [w0_grad(:);w1_grad(:)]';
    end
end
%grad = grad(:);
%grad = grad';

fval = fval / kc;
grad = grad / kc;
