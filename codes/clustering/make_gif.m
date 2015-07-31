x = obj.tracklet_bb_x{i};
y = obj.tracklet_bb_y{i};
w = obj.tracklet_bb_w{i};
h = obj.tracklet_bb_h{i};
bbs = nearest_person_bb{i};
for f = 1:length(obj.tracklet_frames{i})
    img = imread(['/cs/vml2/mkhodaba/data_set/virat/videos/' names(o).name(1:end-4) '/' num2str(obj.tracklet_frames{i}(f)+1) '.jpg']);
    img = insertShape(img, 'Rectangle', [[x(f), y(f), w(f), h(f)]; [x(f)+1, y(f)+1, w(f)-2, h(f)-2]], 'Color', 'green', 'Opacity', 0);
    img = insertShape(img, 'Rectangle', [bbs(f,:); bbs(f,:)+[1 1 -2 -2]], 'Color', 'red', 'Opacity', 0);
    img = imresize(img,0.3);
    if f == 1
        [im, map] = rgb2ind(img, 256, 'nodither');
        im(1,1,1,240) = 0;
    else
        im(:,:,1,f) = rgb2ind(img, map, 'nodither');
    end
end
imwrite(im, map, ['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/results/gifs/test.gif'], 'DelayTime', 0, 'LoopCount', inf);
