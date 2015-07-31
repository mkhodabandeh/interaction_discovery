function [ scores, latent_var_assignments ] = infer_latent_variables( w0, w1 , auxdata )
%INFER_LATENT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here
global latent_data data;
number_of_clusters = auxdata.kc;
%latetn_feature_size = auxdata.latent_feature_size;

global_scores = data * w0;

latent_aux_data = auxdata.latent_data;
clip_scores = latent_data * w1;
number_of_data = size(latent_aux_data.larger_tracklet,1);
scores = zeros(number_of_data, number_of_clusters);
latent_var_assignments = zeros(size(scores));

for i = 1:number_of_data

    [max_score, max_index] = max(clip_scores(latent_aux_data.larger_tracklet{i}(1):latent_aux_data.larger_tracklet{i}(2),:) ,[], 1);
    latent_var_assignments(i,:) = max_index + latent_aux_data.larger_tracklet{i}(1) - 1;

    scores(i,:) = max_score;

end

scores = scores + global_scores;


