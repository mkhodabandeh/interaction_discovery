
data_address = '/cs/vml3/mkhodaba/codes/ECCV14/data';
table_address = '/cs/vml3/mkhodaba/data/UT/';
%vid_name = 'ftr_set2';
file_address = [data_address filesep 'UT' filesep vid_name '.mat'];
load([table_address vid_name '_small_hoghof.mat']);
load([table_address vid_name '_small.mat']);
load([table_address vid_name '_small_hoghof_gmm_' num2str(hog_hof_number_of_centers) '.mat']);

%centroids = run_kmeans(double(hoghof), 100, 500);
%centroids = run_kmeans([1 2 3 4 5  100 102 105 107]', 2, 100)
obj.larger_tracklet_hog_hof_k_means = cell(length(obj.larger_tracklet_frames), 1);
obj.larger_tracklet_hog_hof_gmm = cell(length(obj.larger_tracklet_frames), 1);
for i = 1:length(obj.larger_tracklet_frames)
    % compute 'triangle' activation function
%     inds = (table(:,3) >= obj.larger_tracklet_frames{i}(1)) ...
%         & (table(:,3) <= obj.larger_tracklet_frames{i}(end)) ...
%         & (table(:,8) == obj.larger_tracklet_subject(i)) ...
%         & (table(:,1) == obj.larger_tracklet_track_id(i));
%     patches = hoghof(inds, :);
%     xx = sum(patches.^2, 2);
%     cc = sum(centroids.^2, 2)';
%     xc = patches * centroids';
% 
%     z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) ); % distances
%     [v,inds] = min(z,[],2);
%     mu = mean(z, 2); % average distance to centroids for each patch
%     patches = max(bsxfun(@minus, mu, z), 0);
%     obj.larger_tracklet_hog_hof_k_means{i} = mean(patches, 1);
    
    inds = (table(:,8) == obj.larger_tracklet_subject(i)) ...
        & (table(:,1) == obj.larger_tracklet_track_id(i));
    obj.larger_tracklet_hog_hof_gmm{i} = mean(gmm_hoghof_data(inds,:), 1);
    
    
    % patches is now the data matrix of activations for each patch
end

obj.hog_hof_k_means = cell(length(obj.tracklet_frames), 1);
for i = 1:length(obj.tracklet_frames)
    % compute 'triangle' activation function
%     inds = (table(:,3) >= obj.tracklet_frames{i}(1)) ...
%         & (table(:,3) <= obj.tracklet_frames{i}(end)) ...
%         & (table(:,8) == obj.subject(i)) ...
%         & (table(:,1) == obj.track_id(i));
%     patches = hoghof(inds, :);
%     xx = sum(patches.^2, 2);
%     cc = sum(centroids.^2, 2)';
%     xc = patches * centroids';
% 
%     z = sqrt( bsxfun(@plus, cc, bsxfun(@minus, xx, 2*xc)) ); % distances
%     [v,inds] = min(z,[],2);
%     mu = mean(z, 2); % average distance to centroids for each patch
%     patches = max(bsxfun(@minus, mu, z), 0);
%     obj.hog_hof_k_means{i} = mean(patches, 1);
    % patches is now the data matrix of activations for each patch
end

save(file_address, 'obj', 'number_of_tracklets', 'number_of_tracks');