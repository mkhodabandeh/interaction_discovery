%In the name of Allah
%scene = '0401';

%scenes = ['0502'] ;



for scene_counter = 1:size(scenes,1)
    scene = scenes(scene_counter, :);
    
    objects = dir(fullfile(raw_data_address, 'annotations',scene,'*objects*'));
    homography = dlmread(fullfile(raw_data_address, 'homographies', ...
                        ['VIRAT_' scene '_homography_img2world.txt']));
    
    %loop on all videos of a certain scene
    datapath = ['/cs/vml2/mkhodaba/codes/ECCV14extension/codes/data/VIRAT/' scene '/auto_tracks/'];
    names = dir([datapath 'VIRAT*']);
    counter = 0;
    c2 = 0;
    short = 0;
    long = 0;
    jeddi = 0;
    nababa = 0;
    for o = 1:length(objects)
        o
        load([datapath names(o).name]);
        object = objects(o).name;
        try
            %table = dlmread(fullfile(raw_data_address,'annotations', scene, object));
            table = convert_ysstracks(254+o);
        catch e
            table = zeros(0, 8);
        end
        %table = table(table(:,8)==1,:);
        all_vehicle_inds = (table(:,8)==2 | table(:,8)==3);
        all_people_inds = (table(:,8)==1);
        homo_table = zeros(size(table,1),2);
        homo_table(all_vehicle_inds,:) = [table(all_vehicle_inds,4)+table(all_vehicle_inds,6)./2 , table(all_vehicle_inds,5)+table(all_vehicle_inds,7)./2]; %center of bounding box
        homo_table(all_people_inds,:) = [table(all_people_inds,4)+table(all_people_inds,6)./2 , table(all_people_inds,5)]; % top middle of bounding box
        %homo_table(all_people_inds,:) = [table(all_people_inds,4) , table(all_people_inds,5)]; % top middle of bounding box
        %homo_table(:,:) = [table(:,4)+table(:,6)./2 , table(:,5)+table(:,7)./2]; %center of bounding box
        homo_table = homography * [homo_table ones(size(table,1),1)]';
        homo_table = homo_table';
        homo_table = homo_table(:,1:2) ./ repmat(homo_table(:,3), 1,2);
        ids = unique(table(:,1));
        %vehicle_proximity = cell(number_of_tracklets, 1);
        %human_proximity = cell(number_of_tracklets, 1);
        nearest_person_id = cell(number_of_tracklets, 1);
        nearest_person_bb = cell(number_of_tracklets, 1);
        nearest_person_dist = cell(number_of_tracklets,1);
        nearest_vehicle_id = cell(number_of_tracklets, 1);
        nearest_vehicle_bb = cell(number_of_tracklets, 1);
        nearest_vehicle_dist = cell(number_of_tracklets,1);

        for i = 1: number_of_tracklets

            nearest_person_bb{i} = zeros(tracklet_length,4);
            nearest_person_dist{i} = inf(tracklet_length,1);
            nearest_vehicle_bb{i} = zeros(tracklet_length,4);
            nearest_vehicle_dist{i} = inf(tracklet_length,1);

            %all objects in the scene that have overlap with this tracklet
            frames_inds = find(table(:,3) >= obj.tracklet_frames{i}(1) & table(:,3)<= obj.tracklet_frames{i}(end) & table(:,1)==obj.track_id(i));
            person_inds = find(table(:,3) >= obj.tracklet_frames{i}(1) & table(:,3)<= obj.tracklet_frames{i}(end) & table(:,8)==1 & table(:,1)~=obj.track_id(i));
            vehicle_inds = find(table(:,3) >= obj.tracklet_frames{i}(1) & table(:,3)<= obj.tracklet_frames{i}(end) & (table(:,8)==2 | table(:,8)==3));
            person_ids = unique(table(person_inds,1));
            vehicle_ids = unique(table(vehicle_inds,1));
            ids = table(person_inds,1);

            inds_dist_to_first_frame = table(frames_inds,3)-obj.tracklet_frames{i}(1)+1;
            map_frame_to_ind = zeros(max(inds_dist_to_first_frame),1);
            if size(map_frame_to_ind,1) > tracklet_length
                counter = counter + 1;
                k(counter,1)=o;
                k(counter,2)=i;
            end
            for c = 1:length(inds_dist_to_first_frame)
                map_frame_to_ind(inds_dist_to_first_frame(c)) = c;
            end
            map_non_zero_inds = map_frame_to_ind~=0;
            map_frame_to_ind(map_frame_to_ind==0) = round(median(map_frame_to_ind(map_frame_to_ind~=0)));
            %{
            human_proximity{i} = zeros(length(obj.tracklet_frames{i}),1);
            vehicle_proximity{i} = zeros(length(obj.tracklet_frames{i}),1);
            nearest_human_id{i} = zeros(length(obj.tracklet_frames{i}),1);
            nearest_vehicle_id{i} = zeros(length(obj.tracklet_frames{i}),1);
            nearest_human_bb{i} = zeros(length(obj.tracklet_frames{i}), 4);
            nearest_vehicle_bb{i} = zeros(length(obj.tracklet_frames{i}), 4);
            %}

            if ~isempty(person_inds)
                start_frame = obj.tracklet_frames{i}(1);
                try
                    inds = table(person_inds,3) - start_frame + 1;
                    dists = sum((homo_table(person_inds,:) - homo_table(frames_inds(map_frame_to_ind(inds)),:)).^2, 2);
                catch e
                    sprintf('shoot')
                end
                %{
                dists = zeros(size(person_inds));
                for p = 1:length(person_inds)
                    try
                        object_inds = (table(:,3)==table(person_inds(p),3))&(table(:,1)==obj.track_id(i));
                        dists(p) = sum((homo_table(person_inds(p),:)-homo_table(object_inds,:)).^2);
                        %object_ind = find(table(frames_inds));
                    catch e
                        %p
                    end
                end
                %}
                sum_dists = zeros(size(person_ids));
                kachal = zeros(size(person_ids));
                for x = 1:length(person_ids)
                    %sum_dists(x) = sum(dists(table(person_inds,1)==person_ids(x)))/sum(table(person_inds,1)==person_ids(x));
                    try
                        sum_dists(x) = median(dists(table(person_inds,1)==person_ids(x)));
                    catch e
                        x
                    end
                    if sum(table(person_inds,1)==person_ids(x))<=45
                        sum_dists(x) = Inf;
                        %kachal(x) = 1;
                        short = short + 1;
                    else
                        long = long + 1;
                    end

                end
                [min_dist, person_with_min_dist] = min(sum_dists);
                %{
                if kachal(person_with_min_dist) == 1
                    jeddi = jeddi+1;
                else
                    nababa = nababa+1;
                end
                %}
                nearest_person_inds1 = table(person_inds,1)==person_ids(person_with_min_dist);
                nearest_person_inds = person_inds(nearest_person_inds1);
                offset = table(nearest_person_inds(1),3) - start_frame+1;
                tah = offset+length(nearest_person_inds)-1;%table(nearest_person_inds(end),3) - start_frame+1; 
                if tah-offset >tracklet_length-1
                    c2 = c2+1;
                end
                n_p_bb = zeros(length(map_frame_to_ind), 4);
                try
                    n_p_bb(offset:tah,:) = table(nearest_person_inds,4:7);
                catch e
                    e %frame ha moshkel darand! yekishoon ja oftade!
                end
                distsss = inf(length(map_frame_to_ind),1);
                distsss(offset:tah,:) = dists(nearest_person_inds1);
                nearest_person_bb{i} = n_p_bb(map_non_zero_inds,:);
                %nearest_person_dist{i}(offset:offset+length(nearest_person_inds)-1) = dists(nearest_person_inds1);
                nearest_person_dist{i} = distsss(map_non_zero_inds);
                if length(nearest_person_bb{i})>tracklet_length
                    max(inds)
                end

            end

            if ~isempty(vehicle_inds)
                start_frame = obj.tracklet_frames{i}(1);
                try
                    inds = table(vehicle_inds,3) - start_frame + 1;
                    dists = sum((homo_table(vehicle_inds,:) - homo_table(frames_inds(map_frame_to_ind(inds)),:)).^2, 2);
                catch e
                    sprintf('shoot')
                end

                %{
                dists = zeros(size(vehicle_inds));
                for p = 1:length(vehicle_inds)
                    try
                        object_inds = (table(:,3)==table(vehicle_inds(p),3))&(table(:,1)==obj.track_id(i));
                        dists(p) = sum((homo_table(vehicle_inds(p),:)-homo_table(object_inds,:)).^2);
                    catch
                        %p
                    end
                end
                %}
                sum_dists = zeros(size(vehicle_ids));
                for x = 1:length(vehicle_ids)
                    %sum_dists(x) = sum(dists(table(vehicle_inds,1)==vehicle_ids(x)));
                    try
                        sum_dists(x) = median(dists(table(vehicle_inds,1)==vehicle_ids(x)));
                    catch
                        sprintf('shoot')
                    end
                    if sum(table(vehicle_inds,1)==vehicle_ids(x))<=45
                        sum_dists(x) = Inf;
                        %kachal(x) = 1;
                        short = short + 1;
                    else
                        long = long + 1;
                    end

                end
                [min_dist, vehicle_with_min_dist] = min(sum_dists);
                nearest_vehicle_inds1 = table(vehicle_inds,1)==vehicle_ids(vehicle_with_min_dist);
                nearest_vehicle_inds = vehicle_inds(nearest_vehicle_inds1);
                offset = table(nearest_vehicle_inds(1),3) - start_frame+1;
                tah = offset+length(nearest_vehicle_inds)-1;
                n_v_bb = zeros(length(map_frame_to_ind), 4);
                try
                    n_v_bb(offset:tah,:) = table(nearest_vehicle_inds,4:7);
                catch e
                    e %frame ha moshkel darand! yekishoon ja oftade!
                end
                distsss = inf(length(map_frame_to_ind),1);
                distsss(offset:tah,:) = dists(nearest_vehicle_inds1);
                nearest_vehicle_bb{i} = n_v_bb(map_non_zero_inds,:);
                %nearest_person_dist{i}(offset:offset+length(nearest_person_inds)-1) = dists(nearest_person_inds1);
                nearest_vehicle_dist{i} = distsss(map_non_zero_inds);
                %nearest_vehicle_bb{i}(offset:offset+length(nearest_vehicle_inds)-1,:) = table(nearest_vehicle_inds,4:7);
                %nearest_vehicle_dist{i}(offset:offset+length(nearest_vehicle_inds)-1) = dists(nearest_vehicle_inds1);
            end
            %{
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
            %}
        end
        obj.nearest_person_id = nearest_person_id;
        obj.nearest_person_bb = nearest_person_bb;
        obj.nearest_person_dist = nearest_person_dist;
        obj.nearest_vehicle_id = nearest_vehicle_id;
        obj.nearest_vehicle_bb = nearest_vehicle_bb;
        obj.nearest_vehicle_dist = nearest_vehicle_dist;
        save([datapath names(o).name], 'obj', 'number_of_tracklets', 'number_of_tracks');
    end
end