function results = eval_lmmca(w, auxdata)

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

%% Measurements

results.scores = scores;
results.labels = labels;
results.latent_variables = latent_variables;

non_zero_indx = labels ~= 0;
gtlabels = auxdata.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
 results.nmi = measure_nmi(gtlabels, pdlabels);
 results.randindex = measure_randindex(gtlabels, pdlabels);