function [ table ] = convert_ysstracks( vid_num )
%CONVERT_YSSTRACKS Summary of this function goes here
%   This function converts YSS tracks to virat standard
    yss_track_path = '/cs/vml2/ysefidga/Human-vehicle interaction datasets/VIRAT/Public Projects/VIRAT/Public Dataset/VIRAT Video Dataset Release 2.0/VIRAT Ground Dataset/YSSMILtracks/detm2/';
    vid_name = sprintf('video%03d', vid_num);
    track_path = [yss_track_path vid_name filesep 'v' sprintf('%03d', vid_num) 't%06d_%06d.mat'];
    list = dir([yss_track_path vid_name]);
    list = list(3:end);
    track_id = 0;
    table = zeros(16000*80, 8);
    table_temp = zeros(80, 8);
    last_i = 1;
    for i = 1:length(list)
        track_path = [yss_track_path vid_name filesep list(i).name];
        clear tracks;
        load(track_path);
        for tr = 1:size(tracks, 1)
            track_id = track_id + 1;
            temp = tracks{tr, 1};
            if isempty(temp)
                continue;
            end
            l = length(temp);
            table_temp(1:l,:) = cat(2, temp, ones(l, 1)*track_id, ones(l,1)*l, ones(l,1));
            table_temp(:, 3:4) = abs(table_temp(:, 3:4)-table_temp(:, 1:2));
            table_temp = table_temp(:,[6 7 5 1 2 3 4 8]);
            table(last_i:last_i+l-1,:) = table_temp(1:l, :);
            last_i = last_i+l;
        end
        
    end
    
end

