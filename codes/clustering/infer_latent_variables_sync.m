function [ scores, latent_var_assignments_1, latent_var_assignments_2 ] = infer_latent_variables_sync( w1, w2, auxdata )
%INFER_LATENT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here
global latent_data;
number_of_clusters = auxdata.kc;
latent_aux_data = auxdata.latent_data;
[~, feature_dim] = size(latent_data);
number_of_data = size(latent_aux_data.larger_tracklet_1, 1);
w1 = reshape(w1, [feature_dim, number_of_clusters]);
w2 = reshape(w2, [feature_dim, number_of_clusters]);

clip_scores_1 = latent_data * w1;
clip_scores_2 = latent_data * w2;


scores = zeros(number_of_data, number_of_clusters);
latent_var_assignments_1 = zeros(size(scores));
latent_var_assignments_2 = zeros(size(scores));
if ~isempty(latent_data)
    for i = 1:number_of_data
        inds1 = latent_aux_data.larger_tracklet_1{i}(1):latent_aux_data.larger_tracklet_1{i}(2);
        inds2 = latent_aux_data.larger_tracklet_2{i}(1):latent_aux_data.larger_tracklet_2{i}(2);
        if length(inds1)>6
            [max_score, max_index] = max(clip_scores_1(inds1(2:end),:)+clip_scores_2(inds2(2:end),:) ,[], 1);
            latent_var_assignments_1(i,:) = max_index + latent_aux_data.larger_tracklet_1{i}(1)+1 - 1;
            latent_var_assignments_2(i,:) = max_index + latent_aux_data.larger_tracklet_2{i}(1)+1 - 1;
        else
            inds1 = latent_aux_data.larger_tracklet_1{i}(1):latent_aux_data.larger_tracklet_1{i}(2);
            inds2 = latent_aux_data.larger_tracklet_2{i}(1):latent_aux_data.larger_tracklet_2{i}(2);
            [max_score, max_index] = max(clip_scores_1(inds1,:)+clip_scores_2(inds2,:) ,[], 1);
            latent_var_assignments_1(i,:) = max_index + latent_aux_data.larger_tracklet_1{i}(1) - 1;
            latent_var_assignments_2(i,:) = max_index + latent_aux_data.larger_tracklet_2{i}(1) - 1;
        end
        
        scores(i,:) = max_score;
        
    end

end

