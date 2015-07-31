i%In the name of Allah
data_address = '/cs/vml2/mkhodaba/codes/ECCV14/data';

    

        %
        vid_name = 'ftr_set2';
        load(['/cs/vml2/avahdat/data/UT/' vid_name '.mat']);
        z = 0.9;
        table = tr_data(:, 3043:3054);
        table_inds = abs(table(:, 9) - z) < 1e-3 & table(:,12) == 5;
        table = table(table_inds, [8 1 3 4 5 6 7 10 2]);
        table(:,[4:7]) = table(:,[4:7]); %TODO
        hoghof = tr_data(table_inds,1:3042);
        %
        mkdir('/cs/vml2/mkhodaba/data/UT/');
        save(['/cs/vml2/mkhodaba/data/UT/' vid_name '_small.mat'], 'table');
        save(['/cs/vml2/mkhodaba/data/UT/' vid_name '_small_hoghof.mat'], 'hoghof');
        %}
        load(['/cs/vml2/mkhodaba/data/UT/' vid_name '_small.mat']);
        load(['/cs/vml2/mkhodaba/data/UT/' vid_name '_small_hoghof.mat']);
        %load(['/cs/vml3/mkhodaba/data/UT/' vid_name '_small_hoghof_gmm_' num2str(hog_hof_number_of_centers) '.mat']);
        
        %table = table(table(:,8)==1,:);
        %homo_table = homography * [table(:,4:5) ones(size(table,1),1)]';
        %homo_table = homo_table';
        %homo_table = homo_table(:,1:2) ./ repmat(homo_table(:,3), 1,2);
        homo_table = table(:,4:5);
        ids = unique(table(:,[1 8]), 'rows');
        velocity_features = cell(1, length(ids));
        t_length = tracklet_length;
        %iterate over all human trajectories in a video
        trajectories = cell(1,length(ids));
        small_velocity_features = cell(1,length(ids));
        small_part_hog_hof_gmm = cell(1,length(ids));
        start_frames = cell(1,length(ids));
        end_frames = cell(1,length(ids));
        bounding_box = cell(1,length(ids)); % x, y, width, height
        tracklet_no = cell(1,length(ids));
        frames = cell(1,length(ids));
        id = cell(1,length(ids));
        subject = cell(1,length(ids));
        tracklet_frames = cell(1,length(ids));
        hog_hof = cell(1,length(ids));
        hog_hof_gmm = cell(1,length(ids));
        tracklet_bb  = cell(1,length(ids));
        interaction_type = cell(1,length(ids));
        sequence_no = cell(1,length(ids));
        %tracklet_bb_x  = cell(1,length(ids));
        %tracklet_bb_y  = cell(1,length(ids));
        %tracklet_bb_w  = cell(1,length(ids));
        %tracklet_bb_h  = cell(1,length(ids));
        k = 0;
        for j = 1:length(ids)

            %frame numbers of a certain trajectory
            inds = find(table(:,1)==ids(j,1) & table(:,8) == ids(j,2));
            % The above line is important, we extract features for both
            % subjects of each interaction
            
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
                small_velocity_features{j} = small_parts * reshape(sqrt(sum((small_end_position-small_start_position).^2,2))*tracklet_length/t_length, [1 small_parts]);
                velocity_features{j} = sqrt(sum((end_position-start_position).^2,2))*tracklet_length/t_length; 
                start_frames{j}     = table(inds(1),3)';
                end_frames{j}       = table(inds(end),3)';
                bounding_box{j}     = table(inds,4:7)'; % x, y, width, height

                frames{j}           = table(inds, 3)';
                id{j}               = ids(j);
                tracklet_frames{j}  = table(inds,3)';
                tracklet_bb{j}      = table(inds,[4:7])';
                %tracklet_bb_x{j}    = table(inds,4)';
                %tracklet_bb_y{j}    = table(inds,5)';
                %racklet_bb_w{j}    = table(inds,6)';
                %racklet_bb_h{j}    = table(inds,7)';
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

                start_frames{j}     = table(inds(1:floor(t_length/2):end-t_length+1),3)';
                end_frames{j}       = table(inds(t_length:floor(t_length/2):end),3)';
                bounding_box{j}     = table(inds,4:7)'; % x, y, width, height
                id{j}               = ids(j,1)*ones(1,length(velocity_features{j}));
                frames{j}           = table(used_frames, 3)';
                tracklet_frames{j}  = reshape(table(used_frames(tracklet_inds),3), k_size)';
                
                small_part_hog_hof_gmm{j} = zeros(small_parts, size(gmm_hoghof_data,2)); %for each part a 1x50 row
                for s = 1:length(used_frames)/small_t_length % for a 90 frame tracklet we have 9 small 10 sec clips (where tracklet_length = 20)
                    sp_inds = [1+(s-1)*small_t_length: s*small_t_length];
                    small_part_hog_hof_gmm{j}(s,:) = mean( gmm_hoghof_data(used_frames(sp_inds),:) ,1);
                end
                small_part_hog_hof_gmm{j} = small_part_hog_hof_gmm{j}(small_tracklet_inds,:);
                hog_hof_gmm{j} = permute( reshape( gmm_hoghof_data(used_frames(tracklet_inds),:)', [size(gmm_hoghof_data,2) k_size]), [2 1 3]); % size = 3042 40 3
                hog_hof_gmm{j} = reshape(mean(hog_hof_gmm{j}, 1), size(hog_hof_gmm{j}, 2), size(hog_hof_gmm{j},3))';
                
                hog_hof{j} = permute( reshape( hoghof(used_frames(tracklet_inds),:)', [size(hoghof,2) k_size]), [2 1 3]); % size = 3042 40 3
                hog_hof{j} = reshape(mean(hog_hof{j}, 1), size(hog_hof{j}, 2), size(hog_hof{j},3))';
                tracklet_bb{j}      = table(used_frames(tracklet_inds),4:7);
                %bb tracklet bayad dorost beshe TODO
                
                interaction_type{j} = table(inds(1:floor(t_length/2):end-t_length+1),2)';
                sequence_no{j} = table(inds(1:floor(t_length/2):end-t_length+1),9)';
                %tracklet_bb_x{j}    = reshape(table(used_frames(tracklet_inds),4), k_size)';
                %tracklet_bb_y{j}    = reshape(table(used_frames(tracklet_inds),5), k_size)';
                %tracklet_bb_w{j}    = reshape(table(used_frames(tracklet_inds),6), k_size)';
                %tracklet_bb_h{j}    = reshape(table(used_frames(tracklet_inds),7), k_size)';
                subject{j} = ids(j,2)*ones(1,length(velocity_features{j}));
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
        non_empty = logical(~cellfun(@isempty, velocity_features));
        non_empty_inds = find(non_empty);
        obj = struct;
        obj.ten_sec_feature = cell2mat(velocity_features(non_empty)');
        obj.small_tracklet_features = {};
        for j = 1:length(non_empty_inds)
            i = non_empty_inds(j);
           obj.small_tracklet_features = cat(1, obj.small_tracklet_features, mat2cell(small_velocity_features{i},ones(1, size(small_velocity_features{i},1)), size(small_velocity_features{i},2)));
        end
        obj.track_id         = cell2mat(id(non_empty))'; %object id
        obj.subject          = cell2mat(subject(non_empty))'; %Is object, the subject number 1 or the subject number 2
        obj.interaction_type = cell2mat(interaction_type(non_empty))'; 
        obj.start_frames     = cell2mat(start_frames(non_empty))';
        obj.end_frames       = cell2mat(end_frames(non_empty))';
        obj.bounding_box     = cell2mat(bounding_box(non_empty))';
        obj.frames           = cell2mat(frames(non_empty))';
        obj.tracklet_no      = cell2mat(tracklet_no(non_empty))';
        obj.sequence_no      = cell2mat(sequence_no(non_empty))';
        obj.small_part_hog_hof_gmm = cat(1, small_part_hog_hof_gmm{:});
        obj.tracklet_frames  = {};
        for j = 1:length(non_empty_inds)
            i = non_empty_inds(j);
           obj.tracklet_frames = cat(1, obj.tracklet_frames, mat2cell(tracklet_frames{i},ones(1, size(tracklet_frames{i},1)), size(tracklet_frames{i},2)));
        end
        obj.hog_hof_gmm = {};
        for j = 1:length(non_empty_inds)
            i = non_empty_inds(j);
           obj.hog_hof_gmm = cat(1, obj.hog_hof_gmm, mat2cell(hog_hof_gmm{i},ones(1, size(hog_hof_gmm{i},1)), size(hog_hof_gmm{i},2)));
        end
        obj.hog_hof = {};
        for j = 1:length(non_empty_inds)
            i = non_empty_inds(j);
           obj.hog_hof = cat(1, obj.hog_hof, mat2cell(hog_hof{i},ones(1, size(hog_hof{i},1)), size(hog_hof{i},2)));
        end
        obj.tracklet_bb = {};
        for j = 1:length(non_empty_inds)
            i = non_empty_inds(j);
           obj.tracklet_bb = cat(1, obj.tracklet_bb, mat2cell(tracklet_bb{i}, tracklet_length * ones(1, size(tracklet_bb{i},1)/tracklet_length), size(tracklet_bb{i},2)));
        end
        %{
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
        %}
        number_of_tracklets = length(obj.tracklet_frames);
        number_of_tracks = length(ids);
        obj.scene = repmat(vid_name, [number_of_tracklets 1]);
        %obj.video_no = o*ones(number_of_tracklets, 1);
        %obj.name = repmat(vid_name, [number_of_tracklets 1]);
        mkdir([data_address ]);
        
        save([data_address  vid_name '.mat'], 'obj', 'number_of_tracklets', 'number_of_tracks');
  %  end
%end