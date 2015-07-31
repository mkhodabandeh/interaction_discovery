function [fval, grad] = grad_lmmca_with_global_group_activity_user_interaction(w, auxdata)

global latent_data data perf

num_data = auxdata.num_data;
num_latent = auxdata.num_latent;
feature_size = auxdata.feature_size;
num_clusters = auxdata.kc;
user_interaction = auxdata.user_interaction;

%% Extract w0 w1 w2
w0_vec = w(1:(feature_size+1)*num_clusters);
w1_vec = w((feature_size+1)*num_clusters+1: (feature_size+1)*num_clusters+num_latent*feature_size);
w2_vec = w(feature_size*(num_clusters+num_latent)+num_clusters+1:feature_size*(num_clusters+num_latent)+num_clusters+num_clusters*num_latent);


w0 = reshape(w0_vec, feature_size+1, num_clusters)'; % K by F
w1 = reshape(w1_vec, feature_size, num_latent)'; % H by F
w2 = reshape(w2_vec, num_clusters, num_latent)'; % H by K
%% Infer latent variables
% max over possible hidden variables
[scores, latent_variable_assignments] = infer_global_latent_variables_group_activity(w0, w1, w2, auxdata);

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
    for r = 1:num_clusters
        if r == p, continue; end
        
        if p == 0
            %xip =  1 + scores(i,n) ;
            xip = 0;
        else
            xip = 1 + scores(i, r) - scores(i, p);
            a = a +1 ;
            %xip = scores(i, r) - scores(i, p);
        end
            
        if xip < 0, continue; end
        
        fval = fval + xip;

        w0_grad = zeros(size(w0));
        w1_grad = zeros(size(w1));
        w2_grad = zeros(size(w2));

        if p == 0
            %currgrad(:, n) = data(latent_variables(i,n), :)';
            
        else
            
            w0_grad(r, :) = data(:,i)';
            w0_grad(p, :) = -data(:,i)';

            for j = 1:size(latent_data{i}, 2)
                w1_grad(latent_variable_assignments{i, r}(j), :) = w1_grad(latent_variable_assignments{i, r}(j), :) + latent_data{i}(:, j)';
                w1_grad(latent_variable_assignments{i, p}(j), :) = w1_grad(latent_variable_assignments{i, p}(j), :) - latent_data{i}(:, j)';
                w2_grad(latent_variable_assignments{i, r}(j), r) = w2_grad(latent_variable_assignments{i, r}(j), r) + 1;
                w2_grad(latent_variable_assignments{i, p}(j), p) = w2_grad(latent_variable_assignments{i, p}(j), p) - 1;
                %w1_grad(latent_variable_assignments{i, r}(j), :) = latent_data{i}(:, j)';
                %w1_grad(latent_variable_assignments{i, p}(j), :) = -latent_data{i}(:, j)';
                %w2_grad(latent_variable_assignments{i, r}(j), r) = 1;
                %w2_grad(latent_variable_assignments{i, p}(j), p) = -1;
            end
       end
        w0_grad_transpose = w0_grad';
        w1_grad_transpose = w1_grad';
        w2_grad_transpose = w2_grad';
        grad = grad + [w0_grad_transpose(:); w1_grad_transpose(:); w2_grad_transpose(:)]';
        
    end
end

%grad = grad';
fval = fval / num_clusters;
grad = grad / num_clusters;
