function [ scores, latent_var_assignments] = infer_global_latent_variables_group_activity( w0, w1, w2, auxdata )
% 	[ scores, latent_var_assignments] = infer_global_latent_variables_group_activity( w0, w1, w2, auxdata )
%   Detailed explanation goes here

global latent_data data
num_data = auxdata.num_data;% N
num_latent = auxdata.num_latent;% H
feature_size = auxdata.feature_size;% F
num_clusters = auxdata.kc;% K
%number_of_people = cellfun(@(x) size(x,1), data);



latent_var_assignments = cell(num_data, num_clusters);
% for each data point
scores = (w0 * data)';


%w1_scores_all = w1 * cell2mat(latent_data');
%latent_sizes = [1; cellfun(@(x) size(x, 2), latent_data)];
%latent_sizes_acc = cumsum(latent_sizes);
%w1_scores_all2 = mat2cell(w1_scores_all, num_latent, cellfun(@(x) size(x, 2), latent_data));
for i = 1:num_data
    % for each possible label
    %for y = 1:num_clusters
        
        w1_scores = w1 * latent_data{i}; %H by J
        %w1_scores = w1_scores_all2{i}; %H by J
        %w1_scores = w1_scores_all(:, latent_sizes_acc(i):(latent_sizes_acc(i+1)-1));
        w2_scores = w2; % H by K
        w1_scores = repmat(w1_scores, 1, 1, num_clusters); % H by J by K
        w2_scores = repmat(w2_scores, 1, 1, size(latent_data{i}, 2)); % H by K by J
        w2_scores = permute(w2_scores, [1 3 2]); % H by J by K
        
        w1_w2_scores = w1_scores + w2_scores; % H by J by K
        [max_w1_w2_scores, latent_var] = max(w1_w2_scores, [], 1); % 1 by J by K
        for r = 1:num_clusters
            latent_var_assignments{i, r} = latent_var(1, :, r);
            %scores(i, r) = scores(i, r) + sum(max_w1_w2_scores(1, :, r));
        end
        scores(i, :) = scores(i, :) + reshape(sum(max_w1_w2_scores(1, :, :), 2), 1, num_clusters);
    %end
end


