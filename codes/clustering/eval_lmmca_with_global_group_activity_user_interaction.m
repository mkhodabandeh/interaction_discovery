function results = eval_lmmca_with_global_group_activity_user_interaction(w, auxdata)

global data

num_data = auxdata.num_data;% N
num_latent = auxdata.num_latent;% H
feature_size = auxdata.feature_size;% F
num_clusters = auxdata.kc;% K
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
[scores, latent_variable_assignments] = ...
    infer_global_latent_variables_group_activity(w0, w1, w2, auxdata);

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

%% Measurements
results.scores = scores;
results.labels = labels;
results.latent_var_assignments = latent_variable_assignments;

non_zero_indx = labels ~= 0;
gtlabels = auxdata.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
 results.nmi = measure_nmi(gtlabels, pdlabels);
 results.randindex = measure_randindex(gtlabels, pdlabels);