%scene = '0401';

%scenes = ['0502'] ;
for scene_counter = 1:size(scenes,1)
    scene = scenes(scene_counter, :);
    clear loaded;
    
    load_next;
    while loaded
        if number_of_tracklets == 0
            load_next;
            continue;
        end
        obj.nearest_person_dist_hist = cell(number_of_tracklets, 1);
        obj.nearest_person_small_dist_hist = cell(number_of_tracklets, 1);
        obj.nearest_vehicle_dist_hist = cell(number_of_tracklets, 1);
        obj.nearest_vehicle_small_dist_hist = cell(number_of_tracklets, 1);
        file_address
        interval_length = (length(obj.nearest_person_dist{1})/number_of_small_parts);
        for i = 1:number_of_tracklets
            obj.nearest_person_dist_hist{i} = [ sum(obj.nearest_person_dist{i}<=person_very_close_threshold), ...
                                                 sum(obj.nearest_person_dist{i}>person_very_close_threshold & obj.nearest_person_dist{i}<=person_near_threshold), ...
                                                 sum(obj.nearest_person_dist{i}>person_near_threshold)]/length(obj.nearest_person_dist{i});

            obj.nearest_vehicle_dist_hist{i} = [ sum(obj.nearest_vehicle_dist{i}<=vehicle_very_close_threshold), ...
                                                 sum(obj.nearest_vehicle_dist{i}>vehicle_very_close_threshold & obj.nearest_vehicle_dist{i}<=vehicle_near_threshold), ...
                                                 sum(obj.nearest_vehicle_dist{i}>vehicle_near_threshold)]/length(obj.nearest_vehicle_dist{i});
            obj.nearest_person_small_dist_hist{i} = zeros(1, 3*number_of_small_parts);
            obj.nearest_vehicle_small_dist_hist{i} = zeros(1, 3*number_of_small_parts);
            for j = 1:number_of_small_parts
                interval1 = (j-1)*interval_length+1:j*interval_length;
                interval2=(j-1)*3+1:j*3;
                obj.nearest_person_small_dist_hist{i}(interval2) = [ sum(obj.nearest_person_dist{i}(interval1)<=person_very_close_threshold), ...
                                                 sum(obj.nearest_person_dist{i}(interval1)>person_very_close_threshold & obj.nearest_person_dist{i}(interval1)<=person_near_threshold), ...
                                                 sum(obj.nearest_person_dist{i}(interval1)>person_near_threshold)]/length(interval1);

                obj.nearest_vehicle_small_dist_hist{i}(interval2) = [ sum(obj.nearest_vehicle_dist{i}(interval1)<=vehicle_very_close_threshold), ...
                                                 sum(obj.nearest_vehicle_dist{i}(interval1)>vehicle_very_close_threshold & obj.nearest_vehicle_dist{i}(interval1)<=vehicle_near_threshold), ...
                                                 sum(obj.nearest_vehicle_dist{i}(interval1)>vehicle_near_threshold)]/length(interval1);
            end
        end

        save(file_address, 'obj', 'number_of_tracklets', 'number_of_tracks');
        load_next;
    end
end