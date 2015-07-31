%In the name of Allah
scene = '0401';
objects = dir(fullfile(raw_data_address, 'annotations',scene,'*objects*'));
homography = dlmread(fullfile(raw_data_address, 'homographies', ...
                    ['VIRAT_' scene '_homography_img2world.txt']));
tracklet_length = 8*30
bins = 2;
small_parts = 4;
%loop on all videos of a certain scene
datapah = [data_address scene '/'];
%datapath = ['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data/VIRAT/0401/'];
names = dir([datapath 'VIRAT*']);

for o = 1%:length(objects)
    o
    load([datapath names(o).name]);
    object = objects(o).name;
    table = dlmread(fullfile(raw_data_address,'annotations', scene, object));
    table = table(table(:,8)==1,:);
    homo_table = homography * [table(:,4:5) ones(size(table,1),1)]';
    homo_table = homo_table';
    homo_table = homo_table(:,1:2) ./ repmat(homo_table(:,3), 1,2);
    ids = unique(table(:,1));
    vehicle_proximity = cell(number_of_tracklets, 1);
    human_proximity = cell(number_of_tracklets, 1);
    nearest_human_id = cell(number_of_tracklets, 1);
    nearest_vehicle_id = cell(number_of_tracklets, 1);
    nearest_human_bb = cell(number_of_tracklets, 1);
    nearest_vehicle_bb = cell(number_of_tracklets, 1);
    
    for i = 1: number_of_tracklets
        i
        %inds = find(table(:,3) >= obj.tracklet_frames{i}(1) & table(:,3)<= obj.tracklet_frames{i}(end));
        %vehicle_same_interval_inds = find(table(inds,8)==2 | table(inds,8)==3);
        %person_same_interval_inds = find(table(inds,8)==1 & table(inds,1)~=obj.track_id{i}(1));
        human_proximity{i} = zeros(length(obj.tracklet_frames{i}),1);
        vehicle_proximity{i} = zeros(length(obj.tracklet_frames{i}),1);
        nearest_human_id{i} = zeros(length(obj.tracklet_frames{i}),1);
        nearest_vehicle_id{i} = zeros(length(obj.tracklet_frames{i}),1);
        nearest_human_bb{i} = zeros(length(obj.tracklet_frames{i}), 4);
        nearest_vehicle_bb{i} = zeros(length(obj.tracklet_frames{i}), 4);
        for j = 1:length(obj.tracklet_frames{i})
            % in the same frame
            veh_inds = find(table(:,3) == obj.tracklet_frames{i}(j) & (table(:,8) ==3 | table(:,8)==2));
            human_inds = find(table(:,3) == obj.tracklet_frames{i}(j) & table(:,1) ~= obj.track_id(i) & table(:,8) ==1);
            main_object_ind = find(table(:,1)==obj.track_id(i) & table(:,3)==obj.tracklet_frames{i}(j));
            if ~isempty(veh_inds)
                [dist_veh, i_veh] = min(sum((bsxfun(@minus, homo_table(veh_inds,:), homo_table(main_object_ind,:))).^2));
                vehicle_proximity{i}(j) = dist_veh;
                nearest_vehicle_bb{i}(j,:) = table(veh_inds(i_veh), 4:7);
                nearest_vehicle_id{i}(j) = table(veh_inds(i_veh), 1);
            else
                vehicle_proximity{i}(j) = inf;
            end
            if ~isempty(human_inds)
                [dist_human, i_human] = min(sum((bsxfun(@minus, homo_table(human_inds,:), homo_table(main_object_ind,:))).^2));
                human_proximity{i}(j) = dist_human;
                nearest_human_bb{i}(j,:) = table(human_inds(i_human), 4:7);
                nearest_human_id{i}(j) = table(human_inds(i_human), 1);
            else
                human_proximity{i}(j) = inf;
            end
        end
    end
end
