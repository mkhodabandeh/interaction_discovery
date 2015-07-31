function results = eval_lmmca_with_global_subject1_user_interaction(w, auxdata)
global data latent_data;

dim = size(latent_data, 2);
global_dim = size(data, 2); 
kc = auxdata.kc;
user_interaction = auxdata.user_interaction;

global_w = w(1:global_dim*kc*2); %First part is subject 1 and Second part is subject 2
latent_w = w(global_dim*2*kc+1: end);
[scores, global_latent_var_assignments, latent_var_assignments_subject_1] = ...
    infer_global_latent_variables_subject1(latent_w, global_w, auxdata);
%[ latent_scores, global_scores, latent_var_assignments, global_latent_var_assignments ] = ...
%    infer_global_latent_variables(latent_w, global_w, auxdata);

%scores = latent_scores + global_scores;

ni = size(scores, 1);
auxdata.lsize = auxdata.clsrbalL * (ni / kc);
auxdata.usize = auxdata.clsrbalU * (ni / kc);

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

results.scores = scores;
results.labels = labels;
results.latent_var_assignments_subject_1 = latent_var_assignments_subject_1;
results.global_latent_var_assignments = global_latent_var_assignments;

non_zero_indx = labels ~= 0;
gtlabels = auxdata.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
 results.nmi = measure_nmi(gtlabels, pdlabels);
 results.randindex = measure_randindex(gtlabels, pdlabels);
 