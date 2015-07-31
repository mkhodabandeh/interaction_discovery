function [ scores, latent_var_assignments ] = infer_latent_variables_ut( w, auxdata )
%INFER_LATENT_VARIABLES Summary of this function goes here
%   Detailed explanation goes here
global latent_data;
number_of_clusters = auxdata.kc;
latent_aux_data = auxdata.latent_data;
[~, feature_dim] = size(latent_data);
number_of_data = size(latent_aux_data.larger_tracklet, 1);
w = reshape(w, [feature_dim, number_of_clusters]);

clip_scores = latent_data * w;

scores = zeros(size(latent_aux_data.larger_tracklet,1), number_of_clusters);
latent_var_assignments = zeros(size(scores));
if ~isempty(latent_data)
    for i = 1:number_of_data
        %{
        if latent_aux_data.larger_tracklet{i}(2) - latent_aux_data.larger_tracklet{i}(1) > 10
            [max_score, max_index] = max(clip_scores(latent_aux_data.larger_tracklet{i}(1)+1:latent_aux_data.larger_tracklet{i}(2)-1,:) ,[], 1);
            latent_var_assignments(i,:) = max_index + latent_aux_data.larger_tracklet{i}(1)+1 - 1;
        
        else
            %}
        if latent_aux_data.larger_tracklet{i}(2) - latent_aux_data.larger_tracklet{i}(1) > 4
            [max_score, max_index] = max(clip_scores(latent_aux_data.larger_tracklet{i}(1)+1:latent_aux_data.larger_tracklet{i}(2),:) ,[], 1);
            latent_var_assignments(i,:) = max_index + latent_aux_data.larger_tracklet{i}(1)+1 - 1;
        else
            [max_score, max_index] = max(clip_scores(latent_aux_data.larger_tracklet{i}(1):latent_aux_data.larger_tracklet{i}(2),:) ,[], 1);
            latent_var_assignments(i,:) = max_index + latent_aux_data.larger_tracklet{i}(1) - 1;
        end
        

        scores(i,:) = max_score;
        
    end

end

