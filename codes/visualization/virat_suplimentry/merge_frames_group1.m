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
for g=1%:length(labels)
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
    vid = cell(1, num_frames);
    vid{1} = im;
    %im(1,1,1,num_frames) = 0;
    v_sum = 0;
    p_sum = 0;
    o_sum = 0;
    first = 1;
    for i=[5 2 3 4 1]
        %clear im map;
        counter = counter + 1;
        i

        inner = [1 1 -2 -2];
        outer = [-1 -1 2 2];
        num_frames = length(1:length(tracklet_frames{i}));
        startp = 1;
        endp = length(tracklet_frames{i});
        if i == 3
            endp = endp-60;
        end
        for f = startp:endp
            img = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names(i,:) '/' num2str(tracklet_frames{i}(f)+1) '.jpg']);
            bb = [x{i}(f), y{i}(f), w{i}(f), h{i}(f)]*zoom;
            if zoom ~= 1
                img = imresize(img, zoom, 'nearest');
            end
            img = insertShape(img, 'Rectangle', [bb; bb+inner], 'Color', 'green', 'Opacity', 0);
                    
            bb_v = objm.nearest_vehicle_bb{ls(i)}(f,:)*zoom;
            bb_p = objm.nearest_person_bb{ls(i)}(f,:)*zoom;
            img = insertShape(img, 'Rectangle', [bb_p; bb_p+inner], 'Color', 'red', 'Opacity', 0);
            img = insertShape(img, 'Rectangle', [bb_v; bb_v+inner], 'Color', 'yellow', 'Opacity', 0);
            
            img = insertText(img, bb(1:2), i, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'green');
            img = insertText(img, bb_v(1:2), i, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'yellow');
            img = insertText(img, bb_p(1:2), i, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'red');
            
            if i==2
                bb_v_3 = objm.nearest_vehicle_bb{ls(3)}(f,:)*zoom;
                img = insertShape(img, 'Rectangle', [bb_v_3; bb_v_3+inner], 'Color', 'yellow', 'Opacity', 0);
                img = insertText(img, bb_v_3(1:2), 3, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'yellow');
            end
            
            img_size = size(img);
            j = f;%ceil(f/5);
            if i == 3
                j = ceil((f+60));
            end
            if first == 1
                
                vid{j} = img;% rgb2ind(img, map, 'nodither');
                %im(:,:,1,j) = rgb2ind(img, map, 'nodither');
            else
                img1 = img; %rgb2ind(img, map, 'nodither');
                bb_crop = round(bb+outer);
                bb_v_crop = round(bb_v+outer);
                bb_p_crop = round(bb_p+outer);
                bb_crop(bb_crop <= 0) = 1;
                bb_v_crop(bb_v_crop <= 0) = 1;
                bb_p_crop(bb_p_crop <= 0) = 1;
                if i~=4 && i~=3 && sum(bb_v_crop==0) == 0 && (bb_v_crop(1) + bb_v_crop(3))<= img_size(2) && (bb_v_crop(2)+bb_v_crop(4)) <= img_size(1)
                    vid{j}(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), :) = img1(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), :);
                    %im(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), 1, j) = img1(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3));
                else
                    o_sum = o_sum + 1;
                end
                if sum(bb_p_crop==0) == 0 && (bb_p_crop(1) + bb_p_crop(3))<= img_size(2) && (bb_p_crop(2)+bb_p_crop(4)) <= img_size(1)
                    vid{j}(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3), :) = img1(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3), :);
                    %im(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3), 1, j) = img1(bb_p_crop(2):bb_p_crop(2)+bb_p_crop(4), bb_p_crop(1):bb_p_crop(1)+bb_p_crop(3));
                    if i == 4
                        bb_p_crop = bb_p_crop + [-200 -100 400 400];
                        if sum(bb_p_crop <=0) == 0
                            vid{j}(bb_p_crop(2):end, bb_p_crop(1):end, :) = img1(bb_p_crop(2):end, bb_p_crop(1):end, :);
                            %im(bb_p_crop(2):end, bb_p_crop(1):end, 1, j) = img1(bb_p_crop(2):end, bb_p_crop(1):end);
                        end
                    end
                else
                    o_sum = o_sum + 1;
                end
                if sum(bb_crop==0) == 0 && (bb_crop(1) + bb_crop(3))<= img_size(2) && (bb_crop(2)+bb_crop(4)) <= img_size(1)
                    vid{j}(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3), :) = img1(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3), :);
                    %im(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3), 1, j) = img1(bb_crop(2):bb_crop(2)+bb_crop(4), bb_crop(1):bb_crop(1)+bb_crop(3));
                    
                else
                    o_sum = o_sum + 1;
                end
                if i == 2 
                    if f > 120
                        vid{j}(end-300:end, end-800:end, :) = img1(end-300:end, end-800:end, :);
                        %im(end-300:end, end-800:end, 1, j) = img1(end-300:end, end-800:end);
                    end
                    bb_v_crop = round(bb_v_3+outer);
                    vid{j}(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), :) = img1(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), :);
                    %im(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3), 1, j) = img1(bb_v_crop(2):bb_v_crop(2)+bb_v_crop(4), bb_v_crop(1):bb_v_crop(1)+bb_v_crop(3));
                end
                

            end

        end
        first = 0;
    end
    %p_sum
    %v_sum
    o_sum
    %imwrite(im, map, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/merged.gif'], 'DelayTime', 0, 'LoopCount', inf);
    mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/merged_frames/']);  
    for l = 1:num_frames
        imwrite(vid{l}, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/merged_frames/' num2str(l) '.png']);
    end
end
%}