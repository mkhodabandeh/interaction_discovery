function [ scores, global_latent_var_assignments, latent_var_assignment_subject_1] = infer_global_latent_variables_subject1( latent_w, global_w, auxdata )
%INFER_GLOBAL_LATENT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here

global latent_data data;
number_of_clusters = auxdata.kc;
number_of_global_data = size(data, 1);
dim = size(data, 2);

new_data_1 = [data(1:number_of_global_data/2, :), data(number_of_global_data/2+1:end, :)];
new_data_2 = [data(number_of_global_data/2+1:end, :), data(1:number_of_global_data/2, :)];
global_w = reshape(global_w, [dim * 2, number_of_clusters]);
global_scores_1 = new_data_1 * global_w;
global_scores_2 = new_data_2 * global_w;
%global_w_1 = reshape(global_w, [dim * 2, number_of_clusters]);
%global_w_2 = reshape([global_w(end/2+1:end), global_w(1:end/2)], [dim * 2, number_of_clusters]);
%global_scores_1 = data * global_w_1;
%global_scores_2 = data * global_w_2;

latent_scores_1 = zeros(size(global_scores_1));
latent_scores_2 = zeros(size(global_scores_1));
latent_var_assignment_subject_1 = zeros(size(global_scores_1));


if ~isempty(latent_data)
    auxdata_1 = struct;
    auxdata_1.latent_data = struct;
    auxdata_1.kc = auxdata.kc;
    auxdata_1.latent_data.larger_tracklet = auxdata.latent_data.larger_tracklet(1:end/2); % first part contains subject 1 and second part contains data of subject 2
    auxdata_2 = struct;
    auxdata_2.latent_data = struct;
    auxdata_2.kc = auxdata.kc;
    auxdata_2.latent_data.larger_tracklet = auxdata.latent_data.larger_tracklet(end/2 + 1:end); % first part contains subject 1 and second part contains data of subject 2



    [latent_scores_1, latent_var_assignments_1] = infer_latent_variables_ut(latent_w, auxdata_1);
    [latent_scores_2, latent_var_assignments_2] = infer_latent_variables_ut(latent_w, auxdata_2);
    
    latent_var_assignments_subject_1 = cat(3, latent_var_assignments_1, latent_var_assignments_2); 

end
scores_1 = global_scores_1 + latent_scores_1;
scores_2 = global_scores_2 + latent_scores_2;


[scores, global_latent_var_assignments] = max(cat(3, scores_1, scores_2) ,[] , 3);
%latent_scores = cat(3, latent_scores_1, latent_scores_2);
if ~isempty(latent_data)
    for i = 1:size(global_latent_var_assignments, 1)
        for j = 1:size(global_latent_var_assignments, 2)
            latent_var_assignment_subject_1(i,j) = latent_var_assignments_subject_1(i,j, global_latent_var_assignments(i,j));
        end
    end
end

%{
latent_aux_data = auxdata.latent_data;
[ni, feature_dim] = size(latent_data);
number_of_data = size(latent_aux_data.larger_tracklet, 1);
latent_w = reshape(latent_w, [feature_dim, number_of_clusters]);

clip_scores = latent_data * latent_w;

latent_scores = zeros(size(latent_aux_data.larger_tracklet,1), number_of_clusters);

latent_scores = zeros(size(global_scores));

latent_var_assignments = zeros(size(latent_scores));
if ~isempty(latent_data)
    for i = 1:number_of_data
        [max_score, max_index] = max(clip_scores(latent_aux_data.larger_tracklet{i}(1):latent_aux_data.larger_tracklet{i}(2),:) ,[], 1);
        
        latent_scores(i,:) = max_score;
        latent_var_assignments(i,:) = max_index + latent_aux_data.larger_tracklet{i}(1) - 1;
    end
    
end
%}
