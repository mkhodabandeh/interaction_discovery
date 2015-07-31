load(['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data/VIRAT/0401_all.mat']);
img = imread(['/cs/vml2/mkhodaba/data_set/virat/videos/' objm.name(1,:) '/' num2str(objm.tracklet_frames{1}(1)+1) '.jpg']);
ratio = 0.4;
img = imresize(img, ratio);
for i = 1:number_of_tracklets_m
    i
    tracklet_raw_frames = zeros([size(img),length(objm.tracklet_frames{i})]);
    for fr = 1:length(objm.tracklet_frames{i})
        %fr
        tracklet_raw_frames(:,:,:, fr) = imresize(imread(['/cs/vml2/mkhodaba/data_set/virat/videos/' objm.name(i,:) '/' num2str(objm.tracklet_frames{i}(fr)+1) '.jpg']), ratio);
    end
    mkdir(['/cs/vml2/mkhodaba/codes/ECCV 2014/raw_data/tracklet_frames/']);
    save(['/cs/vml2/mkhodaba/codes/ECCV 2014/raw_data/tracklet_frames/' num2str(i) '.mat'], 'tracklet_raw_frames', '-v7.3');
end
           