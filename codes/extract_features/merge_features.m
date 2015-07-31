%data_path = ['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data/VIRAT/'];

%scenes = ['0502'] ;
for scene_counter = 1:size(scenes,1)
    scene = scenes(scene_counter, :);
    data_path = [data_address 'VIRAT/' scene '/'];
    a = dir(data_path);
    load([data_path a(3).name]);
    names = fieldnames(obj);
    number_of_tracklets_m = number_of_tracklets;
    number_of_tracks_m = number_of_tracks;
    objm = obj;
    for i = 4:length(a)
        load([data_path a(i).name]);
        if number_of_tracklets == 0
            continue;
        end
        for f = 1:numel(names)
            objm.(names{f}) = cat(1, objm.(names{f}), obj.(names{f}));
        end
        number_of_tracklets_m = number_of_tracklets + number_of_tracklets_m;
        number_of_tracks_m = number_of_tracks + number_of_tracks_m;
    end
    save([data_address 'VIRAT/' scene '_all.mat'], 'objm', 'number_of_tracklets_m', 'number_of_tracks_m');
end