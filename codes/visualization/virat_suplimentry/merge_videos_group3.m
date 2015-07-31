%In the name of God
scene = conf.scene;
dataset = conf.data;
latent = conf.latent;
zoom = 1;
load(['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data/VIRAT/' scene '_all.mat']);
dataset_name = 'VIRAT';
clear labels list others;
%load([model_name{1} '.mat']);
for i = 1:conf.kc
    labels{i} = find(results.labels==i);
    if latent == 1
        list{i} = results.latent_variables(labels{i}, i);
        others{i} = randi(length(objm.tracklet_no), 2*length(ls), 1);
        for j = 1:length(list{i})
            others{i}(others{i}>=list{i}(j)-3 & others{i}<= list{i}(j)+3) = [];
        end
        others{i} = others{i}(1:length(list{i}));
    end
end
%ground_truth_labels = cell(length(labels),1);
%labels{1} = [1 3 5 6];
counter = 0;
number_of_data_per_class = length(labels{1})
for g=3%:length(labels)
    g
    if latent == 1
        ls = results.latent_variables(labels{g}, g);
        
    else
        ls = labels{g};
    end
    
    tracklet_frames = objm.tracklet_frames(ls);

    x = objm.tracklet_bb_x(ls);
    y = objm.tracklet_bb_y(ls);
    w = objm.tracklet_bb_w(ls);
    h = objm.tracklet_bb_h(ls);
    names = objm.name(ls,:);
    dist_to_vehicle = objm.nearest_vehicle_dist_hist(ls);
    
    ten_features = objm.ten_sec_feature(ls);
    two_features = objm.small_tracklet_features(ls);
    dist_to_person = objm.nearest_person_dist_hist(ls);

    frame_address = ['/cs/vml2/mkhodaba/codes/ECCV 2014/raw_data/tracklet_frames/' scene];

    clear img im;
    mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/']);
    img = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names(1,:) '/' num2str(tracklet_frames{1}(1)+1) '.jpg']);
    if zoom ~= 1
        img = imresize(img, zoom, 'nearest');
    end
    [im, map] = rgb2ind(img, 256, 'nodither');
    num_frames = length(1:5:length(tracklet_frames{i}));
    im(1,1,1,num_frames) = 0;
    v_sum = 0;
    p_sum = 0;
    o_sum = 0;
    first = 1;
    for i=[4 3 2 5]
        %clear im map;
        counter = counter + 1;
        i

        inner = [1 1 -2 -2];
        outer = [-1 -1 2 2];
        num_frames = length(1:5:length(tracklet_frames{i}));
        startp = 1;
        endp = length(tracklet_frames{i});

        for f = startp:5:endp
            img = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names(i,:) '/' num2str(tracklet_frames{i}(f)+1) '.jpg']);
            bb = [x{i}(f), y{i}(f), w{i}(f), h{i}(f)]*zoom;
            if zoom ~= 1
                img = imresize(img, zoom, 'nearest');
            end
            img = insertShape(img, 'Rectangle', [bb; bb+inner], 'Color', 'green', 'Opacity', 0);
                    
            bb_v = objm.nearest_vehicle_bb{ls(i)}(f,:)*zoom;
            bb_p = objm.nearest_person_bb{ls(i)}(f,:)*zoom;
            img = insertShape(img, 'Rectangle', [bb_p; bb_p+inner], 'Color', 'red', 'Opacity', 0);
            %img = insertShape(img, 'Rectangle', [bb_v; bb_v+inner], 'Color', 'yellow', 'Opacity', 0);
            
            img = insertText(img, bb(1:2), i, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'green');
            img = insertText(img, bb_p(1:2), i, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'red');
            if i == 3 || i == 4
                img = insertShape(img, 'Rectangle', [bb_v; bb_v+inner], 'Color', 'yellow', 'Opacity', 0);
            end
            if i == 3
                img = insertText(img, bb(1:2)+[0 30], 1, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'green');
                img = insertText(img, bb_v(1:2)+[0 0], 1, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'yellow');
                img = insertText(img, bb_v(1:2)+[20 0], 2, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'yellow');
                img = insertText(img, bb_v(1:2)+[40 0], 3, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'yellow');
                img = insertText(img, bb_v(1:2)+[60 0], 5, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'yellow');
            else
                img = insertText(img, bb_v(1:2), i, 'FontSize', 32, 'BoxOpacity', 0, 'TextColor', 'yellow');
            end
            
            
            
            
            img_size = size(img);
            j = ceil(f/5);

            if first == 1
                

                im(:,:,1,j) = rgb2ind(img, map, 'nodither');
            else
                img1 = rgb2ind(img, map, 'nodither');
                bb_crop = round(bb+outer);
                bb_v_crop = round(bb_v+outer);
                bb_p_crop = round(bb_p+outer);
                bb_crop(bb_crop <= 0) = 1;
                bb_v_crop(bb_v_crop <= 0) = 1;
                bb_p_crop(bb_p_crop <= 0) = 1;
                if (i==4 || i==3) && sum(bb_v_crop==0) == 0 && (bb_v_crop(1) + bb_v_crop(3))<= img_size(2) && (bb_v_crop(2)+bb_v_crop(4)) <= img_size(1)
                    im(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), 1, j) = img1(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3));
                else
                    o_sum = o_sum + 1;
                end
                if sum(bb_p_crop==0) == 0 && (bb_p_crop(1) + bb_p_crop(3))<= img_size(2) && (bb_p_crop(2)+bb_p_crop(4)) <= img_size(1)   
                    im(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3), 1, j) = img1(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3));
                else
                    o_sum = o_sum + 1;
                end
                if sum(bb_crop==0) == 0 && (bb_crop(1) + bb_crop(3))<= img_size(2) && (bb_crop(2)+bb_crop(4)) <= img_size(1)
                    im(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3), 1, j) = img1(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3));
                    
                else
                    o_sum = o_sum + 1;
                end

            end

        end
        first = 0;
    end
    %p_sum
    %v_sum
    o_sum
    imwrite(im, map, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/merged.gif'], 'DelayTime', 0, 'LoopCount', inf);
end
%}