%In the name of ALLAH
%scene = '0401';

%scenes = ['0502'] ;
for scene_counter = 1:size(scenes,1)
    scene = scenes(scene_counter, :);
    data_path = [data_address 'VIRAT/' scene '_all.mat'];
    load(data_path);

    
    
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
    track_counter = 1;
    large_tracklet_counter = 1;
    videos = unique(objm.video_no);
    objm.larger_tracklet = cell(0,1);
    for v = 1:length(videos)
        vid_inds = (objm.video_no == videos(v));
        track_ids = unique(objm.track_id(vid_inds));
        for t = 1:length(track_ids)
            track_inds = find(vid_inds & objm.track_id==track_ids(t));
            start_inds = 1:tracklet_clip_ratio:length(track_inds);
            end_inds = tracklet_clip_ratio:tracklet_clip_ratio:length(track_inds);
            if length(start_inds) ~= length(end_inds)
                end_inds(end+1) = length(track_inds);
            end
            objm.larger_tracklet = cat(1, objm.larger_tracklet, ...
                mat2cell([track_inds(start_inds)'; ...
                            track_inds(end_inds)']', ones(length(start_inds),1)));
            for i = 1:length(start_inds)
                frames_tmp = cell2mat(objm.tracklet_frames(track_inds(start_inds(i)):track_inds(end_inds(i))));
                objm.larger_tracklet_frames{large_tracklet_counter} = unique(frames_tmp(:)');
                objm.larger_tracklet_track_id(large_tracklet_counter) = track_ids(t);
                objm.larger_tracklet_video_no(large_tracklet_counter) = videos(v);

                large_tracklet_counter = large_tracklet_counter + 1;
            end
            track_counter = track_counter+1;
        end
    end
    objm.larger_tracklet_track_id = objm.larger_tracklet_track_id';
    objm.larger_tracklet_video_no = objm.larger_tracklet_video_no';
    objm.larger_tracklet_frames = objm.larger_tracklet_frames';
    save(data_path, 'objm', 'number_of_tracklets_m', 'number_of_tracks_m');
    
end