%In the name of Allah
data_address = '/cs/vml2/mkhodaba/codes/ECCV14extension/codes/data';
%scenes = ['0000';'0001'; '0102'; '0502'] ;
for scene_counter = 1:size(scenes,1)
    scene = scenes(scene_counter, :)
    objects = dir(fullfile(raw_data_address, 'annotations',scene,'*objects*'));
    homography = dlmread(fullfile(raw_data_address, 'homographies', ...
                        ['VIRAT_' scene '_homography_img2world.txt']));
    
    %bins = 2;
    
    %loop on all videos of a certain scene

    for o = 1:length(objects)
        o
        obj = objects(o).name;
        try
            table = convert_ysstracks(254+o);
            %table = dlmread(fullfile(raw_data_address,'annotations', scene, obj));
        catch e
            table = zeros(0, 8);
        end
        table = table(table(:,8)==1,:);
        homo_table = homography * [table(:,4:5) ones(size(table,1),1)]';
        homo_table = homo_table';
        homo_table = homo_table(:,1:2) ./ repmat(homo_table(:,3), 1,2);
        ids = unique(table(:,1));
        velocity_features = cell(1, length(ids));
        t_length = tracklet_length;
        %iterate over all human trajectories in a video
        trajectories = cell(1,length(ids));
        small_velocity_features = cell(1,length(ids));
        start_frames = cell(1,length(ids));
        end_frames = cell(1,length(ids));
        bounding_box = cell(1,length(ids)); % x, y, width, height
        tracklet_no = cell(1,length(ids));
        frames = cell(1,length(ids));
        id = cell(1,length(ids));
        tracklet_frames = cell(1,length(ids));
        tracklet_bb_x  = cell(1,length(ids));
        tracklet_bb_y  = cell(1,length(ids));
        tracklet_bb_w  = cell(1,length(ids));
        tracklet_bb_h  = cell(1,length(ids));
        k = 0;
        for j = 1:length(ids)

            %frame numbers of a certain trajectory
            inds = find(table(:,1)==ids(j));
            trajectories{j} = struct;
            if length(inds) <= tracklet_length
                continue;
                k = k + 1;
                t_length = length(inds);
                start_position      = homo_table(inds(1),:);
                end_position        = homo_table(inds(end), :);
                small_t_length = floor(t_length/small_parts);
                tracklet_no{j}      = 1;
                small_start_position = homo_table(inds(1:small_t_length: end-small_t_length+1),:);
                small_end_position = homo_table(inds(small_t_length:small_t_length: end),:);
                small_velocity_features{j} = small_parts * reshape(sqrt(sum((small_end_position-small_start_position).^2,2)), [1 small_parts]);
                velocity_features{j} = sqrt(sum((end_position-start_position).^2,2)); 
                start_frames{j}     = table(inds(1),3)';
                end_frames{j}       = table(inds(end),3)';
                bounding_box{j}     = table(inds,4:7)'; % x, y, width, height

                frames{j}           = table(inds, 3)';
                id{j}               = ids(j);
                tracklet_frames{j}  = table(inds,3)';
                tracklet_bb_x{j}    = table(inds,4)';
                tracklet_bb_y{j}    = table(inds,5)';
                tracklet_bb_w{j}    = table(inds,6)';
                tracklet_bb_h{j}    = table(inds,7)';
            else
                t_length = tracklet_length;
                small_t_length = floor(t_length/small_parts);
                 % [x,y] position of the starting point of tracklets of length 10 sec
                start_position = homo_table(inds(1:floor(t_length/2):end-t_length+1),:);
                 % [x,y] position of the ending point of tracklets of length 10 sec
                end_position = homo_table(inds(t_length:floor(t_length/2):end), :);
                velocity_features{j} = sqrt(sum((end_position-start_position).^2,2)); 
                tracklet_no{j}      = 1:length(velocity_features{j});

                last_frame = floor(length(inds)/floor(t_length/2))*floor(t_length/2);
                small_start_position = homo_table(inds(1:small_t_length: last_frame-1),:);
                small_end_position = homo_table(inds(small_t_length:small_t_length: last_frame),:);

                small_tracklet_inds = zeros(small_parts * length(velocity_features{j}),1);
                s = 1;
                for i = 0:length(velocity_features{j})-1
                    small_tracklet_inds(s:s+small_parts-1) = i*(small_parts/2)+1:i*(small_parts/2)+small_parts;
                    s = s+small_parts;
                end

                small_part_features = sqrt(sum((small_end_position-small_start_position).^2,2));
                small_velocity_features{j} = small_parts * reshape(small_part_features(small_tracklet_inds), [small_parts length(velocity_features{j})])';

                used_frames = inds(1: last_frame);
                k_size = [t_length size(start_position,1)];


                tracklet_inds = zeros(prod(k_size),1);
                s = 1;
                for i = 1:floor(t_length/2):length(inds)-t_length+1
                    tracklet_inds(s:s+t_length-1) = i:i+t_length-1;
                    s = s+t_length;
                end
                
                %%%%INJA TAGHIR KARD
                %start_frames{j}     = table(inds(1:floor(t_length/2):end-t_length),3)';
                %end_frames{j}       = table(inds(t_length+1:floor(t_length/2):end),3)';
                start_frames{j}     = table(inds(1:floor(t_length/2):end-t_length+1),3)';
                end_frames{j}       = table(inds(t_length:floor(t_length/2):end),3)';
                bounding_box{j}     = table(inds,4:7)'; % x, y, width, height
                id{j}               = ids(j)*ones(1,length(velocity_features{j}));
                frames{j}           = table(used_frames, 3)';
                tracklet_frames{j}  = reshape(table(used_frames(tracklet_inds),3), k_size)';
                tracklet_bb_x{j}    = reshape(table(used_frames(tracklet_inds),4), k_size)';
                tracklet_bb_y{j}    = reshape(table(used_frames(tracklet_inds),5), k_size)';
                tracklet_bb_w{j}    = reshape(table(used_frames(tracklet_inds),6), k_size)';
                tracklet_bb_h{j}    = reshape(table(used_frames(tracklet_inds),7), k_size)';
            end
        end
        %{
        x = ;
        [~, centers] = kmeans(x, bins);
        velocity_hist_features = cell(1,length(ids));
        l = length(ids);
        for i = 1:l
            for j=1:4
                a = velocity_features{j}(1+floor(l*(i-1)/4):floor(l*i/4));

                % hala fasele az markaz haro min migiri va hist ro misazi
            end
        end
        %}
        obj = struct;
        obj.ten_sec_feature = cell2mat(velocity_features');
        obj.small_tracklet_features = {};
        for i = 1:length(small_velocity_features)
           obj.small_tracklet_features = cat(1, obj.small_tracklet_features, mat2cell(small_velocity_features{i},ones(1, size(small_velocity_features{i},1)), size(small_velocity_features{i},2)));
        end
        obj.track_id        = cell2mat(id)'; %object id
        obj.start_frames    = cell2mat(start_frames)';
        obj.end_frames      = cell2mat(end_frames)';
        obj.bounding_box    = cell2mat(bounding_box)';
        obj.frames          = cell2mat(frames)';
        obj.tracklet_no     = cell2mat(tracklet_no)';
        obj.tracklet_frames = {};
        for i = 1:length(ids)
           obj.tracklet_frames = cat(1, obj.tracklet_frames, mat2cell(tracklet_frames{i},ones(1, size(tracklet_frames{i},1)), size(tracklet_frames{i},2)));
        end
        obj.tracklet_bb_x = {};
        for i = 1:length(ids)
           obj.tracklet_bb_x = cat(1, obj.tracklet_bb_x, mat2cell(tracklet_bb_x{i},ones(1, size(tracklet_bb_x{i},1)), size(tracklet_bb_x{i},2)));
        end
        obj.tracklet_bb_y = {};
        for i = 1:length(ids)
           obj.tracklet_bb_y = cat(1, obj.tracklet_bb_y, mat2cell(tracklet_bb_y{i},ones(1, size(tracklet_bb_y{i},1)), size(tracklet_bb_y{i},2)));
        end
        obj.tracklet_bb_w = {};
        for i = 1:length(ids)
           obj.tracklet_bb_w = cat(1, obj.tracklet_bb_w, mat2cell(tracklet_bb_w{i},ones(1, size(tracklet_bb_w{i},1)), size(tracklet_bb_w{i},2)));
        end
        obj.tracklet_bb_h = {};
        for i = 1:length(ids)
           obj.tracklet_bb_h = cat(1, obj.tracklet_bb_h, mat2cell(tracklet_bb_h{i},ones(1, size(tracklet_bb_h{i},1)), size(tracklet_bb_h{i},2)));
        end
        number_of_tracklets = length(obj.tracklet_frames);
        number_of_tracks = length(unique(obj.track_id));
        obj.scene = repmat(scene, [number_of_tracklets 1]);
        obj.video_no = o*ones(number_of_tracklets, 1);
        obj.name = repmat(objects(o).name(1:end-length(['.viratdata.objects.txt'])), [number_of_tracklets 1]);
        mkdir([data_address filesep 'VIRAT' filesep 'auto_tracks' filesep scene filesep]);
        save([data_address filesep 'VIRAT' filesep 'auto_tracks' filesep scene filesep objects(o).name(1:end-length(['.viratdata.objects.txt'])) '.mat'], 'obj', 'number_of_tracklets', 'number_of_tracks');
    end
end