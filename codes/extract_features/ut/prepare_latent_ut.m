%In the name of ALLAH
%scene = '0401';
%scenes = ['0000';'0001'; '0102'; '0502'; '0401'] ;
%scenes = ['0502'] ;
%for scene_counter = 1:size(scenes,1)
data_address = '/cs/vml2/avahdat/data/UT/';
table_address = '/cs/vml2/mkhodaba/data/CVPR2015/UT/';
%vid_name = 'ftr_set2';
file_address = [data_address filesep 'UT' filesep vid_name '.mat'];
load([table_address vid_name '_small_hoghof.mat']);
load([table_address vid_name '_small.mat']);

%    scene = scenes(scene_counter, :);
    
    load(file_address);

%    clip_length = 8;
    %tracklet_clip_ratio = 3; %tracklet = 3*clip/2 => 12
    %{
    clear loaded;
    load_next;
    track_ids = []
    while loaded
        track_ids = unique(obj.track_id);
        for i = 1:length(track_ids)
            id = track_ids(i);
            tracklet_of_track_inds = find(obj.track
        end
    end
    size(track_ids)
    %}
    %gmm_hoghof_data = gmm_fit(hoghof, hog_hof_number_of_centers, 3);
    %save([table_address vid_name '_small_hoghof_gmm_3_' num2str(hog_hof_number_of_centers) '.mat'], 'gmm_hoghof_data');
    %return;
    load([table_address vid_name '_small_hoghof_gmm_2_30.mat']);
    track_counter = 1;
    %t = 1;
    %videos = unique(objm.video_no);
    %objm.larger_tracklet = cell(0,1);
    %for v = 1:length(videos)
        %vid_inds = (objm.video_no == videos(v));
        
        track_ids = unique([obj.track_id obj.subject], 'rows');
        obj.larger_tracklet = cell(length(track_ids),1);
        obj.larger_tracklet_frames = cell(length(track_ids), 1);
        obj.larger_tracklet_track_id = zeros(length(track_ids),1);
        obj.larger_tracklet_subject = zeros(length(track_ids),1);
        obj.larger_tracklet_sequence_no = zeros(length(track_ids),1);
        obj.larger_tracklet_video_name = cell(length(track_ids),1);
        obj.larger_tracklet_interaction_type = zeros(length(track_ids),1);
        obj.larger_tracklet_hoghof_pose_features = cell(length(track_ids),1);
        %obj.larger_tracklet_dist_hist = cell(length(track_ids),1);
        %obj.larger_tracklet_mini_dist_hist = cell(length(track_ids),1);
        %obj.larger_tracklet_velocity_hist = cell(length(track_ids),1);
        %bj.larger_tracklet_mini_dist_hist = cell(length(track_ids),1);
        
        
        for t = 1:length(track_ids)
            table_track_inds = table(:, 1) == track_ids(t,1) & table(:, 8) == track_ids(t,2);
            %table_track_inds = table(1:3:end, 1) == track_ids(t,1) & table(1:3:end, 8) == track_ids(t,2);
            obj.larger_tracklet_hoghof_pose_features{t} = mean(gmm_hoghof_data(table_track_inds, :), 1);
            track_inds = find(obj.track_id==track_ids(t,1) & obj.subject == track_ids(t,2));
            %start_inds = 1:tracklet_clip_ratio:length(track_inds);
            %end_inds = tracklet_clip_ratio:tracklet_clip_ratio:length(track_inds);
            %if length(start_inds) ~= length(end_inds)
            %    end_inds(end+1) = length(track_inds);
            %end
            obj.larger_tracklet{t} = [track_inds(1), track_inds(end)];
            %for i = 1:length(start_inds)
                frames_tmp = cell2mat(obj.tracklet_frames(track_inds(1):track_inds(end)));
                obj.larger_tracklet_frames{t} = unique(frames_tmp(:)');
                obj.larger_tracklet_track_id(t) = track_ids(t, 1);
                obj.larger_tracklet_subject(t) = track_ids(t, 2);
                obj.larger_tracklet_sequence_no(t) = obj.sequence_no(track_inds(1));
                obj.larger_tracklet_video_name{t} = obj.scene(track_inds(1),:);
                obj.larger_tracklet_interaction_type(t) = obj.interaction_type(track_inds(1));

                %t = t + 1;
            %end
            track_counter = track_counter+1;
        end
    %end
    save(file_address, 'obj', 'number_of_tracklets', 'number_of_tracks');
    
