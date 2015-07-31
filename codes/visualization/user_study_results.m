%In the name of God
scene = conf.scene;
dataset = conf.data;
latent = conf.latent;
show_others = 0;
same_group = 0;
do_it = 1;
details = 1;
zoom = 0.4;
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
for g=1:length(labels)
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
    
    if show_others == 1
        tracklet_frames_others = objm.tracklet_frames(others{g});
        x_others = objm.tracklet_bb_x(others{g});
        y_others = objm.tracklet_bb_y(others{g});
        w_others = objm.tracklet_bb_w(others{g});
        h_others = objm.tracklet_bb_h(others{g});
        names_others = objm.name(others{g},:);
    end
    
    
    
    ten_features = objm.ten_sec_feature(ls);
    two_features = objm.small_tracklet_features(ls);
    dist_to_person = objm.nearest_person_dist_hist(ls);

    frame_address = ['/cs/vml2/mkhodaba/codes/ECCV 2014/raw_data/tracklet_frames/' scene];
    if do_it == 1
        try
            rmdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/']);
        catch
        end
        mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/']);
        mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/same_group' num2str(g) '/']);
        
    end
    if show_others == 1
        try
            rmdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/not_in_group' num2str(g) '/']);
        catch
        end
        mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/not_in_group' num2str(g) '/']);
        
    end
    for i=1:length(tracklet_frames)
        clear im map;
        counter = counter + 1;
        i
        %load([frame_address num2str(ls(i)) '.mat']);
        if dataset == 3 & latent == 1
            %frame_inds = table(:,1)==track_ids(i) & table(:,9) == seq_no(i) & table(:,8) == subjects(i);
            %tracklet_frames{i} = table(frame_inds, 3);
            %boundingbox{i} = table(frame_inds, 4:7);
            %frame_inds = table(:,1)==track_ids(i) & table(:,9) == seq_no(i) & table(:,8) == (3-subjects(i));
            %objm.nearest_person_bb{ls(i)} = table(frame_inds, 4:7);
        end
        
        %sprintf('group: %d, tracklet: %d', g, i);
        inner = [1 1 -2 -2];
        
        num_frames = length(1:5:length(tracklet_frames{i}));
        for i=1:length(tracklet_frames)
            %img = uint8(tracklet_raw_frames(:,:,:,f));
            
            if do_it == 1
                img = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names(i,:) '/' num2str(tracklet_frames{i}(f)+1) '.jpg']);
                bb = [x{i}(f), y{i}(f), w{i}(f), h{i}(f)]*zoom;
                if zoom ~= 1
                    img = imresize(img, zoom, 'nearest');
                end
                img = insertShape(img, 'Rectangle', [bb; bb+inner], 'Color', 'green', 'Opacity', 0);
                
                if details == 1
                    bb_v = objm.nearest_vehicle_bb{ls(i)}(f,:)*zoom;
                    bb_p = objm.nearest_person_bb{ls(i)}(f,:)*zoom;
                     img = insertShape(img, 'Rectangle', [bb_p; bb_p+inner], 'Color', 'red', 'Opacity', 0);
                     img = insertShape(img, 'Rectangle', [bb_v; bb_v+inner], 'Color', 'yellow', 'Opacity', 0);
                    %{
                   
                    img = insertShape(img, 'FilledRectangle', [10 10 290 200]/2, 'Color', 'white', 'Opacity', 0.4);
                    img = insertText(img, [10 10;  10 50;  80  50; 150 50; 220 50]/2, round([ten_features(i), [two_features{i}]]*10)/10, 'FontSize', 12, 'BoxOpacity', 0);
                    img = insertText(img, [10 90;  70 90;  130 90]/2, round(dist_to_person{i}*10)/10, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'red');
                    img = insertText(img, [10 170]/2, f, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'blue');
                    
                    img = insertText(img, [10 130; 70 130; 130 130]/2, round(dist_to_vehicle{i}*10)/10, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'yellow');
                    img = insertText(img, [8 130;  68 130; 128 130]/2, round(dist_to_vehicle{i}*10)/10, 'FontSize', 13, 'BoxOpacity', 0, 'TextColor', 'yellow');
                    img = insertText(img, [size(img,2) 10]/2, counter, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'yellow');
                    %}
                else
                    img = insertShape(img, 'FilledRectangle', [6 6 250 80]/2, 'Color', 'white', 'Opacity', 0.4);
                    img = insertText(img, [10 10]/2, f, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'red');
                    img = insertText(img, [100 10]/2, '/', 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'blue');
                    img = insertText(img, [130 10]/2, length(tracklet_frames{i}), 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'blue');
                    if same_group == 0
                        img = insertText(img, [size(img,2) 10]/2, counter, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'yellow');
                    end
                    
                end
                if f == 1
                    [im, map] = rgb2ind(img, 256, 'nodither');
                    im(1,1,1,num_frames) = 0;
                else
                    j = ceil(f/5);
                    im(:,:,1,j) = rgb2ind(img, map, 'nodither');
                end
            end
            
            if show_others == 1
                img_other = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names_others(i,:) '/' num2str(tracklet_frames_others{i}(f)+1) '.jpg']);
                bb_other = [x_others{i}(f), y_others{i}(f), w_others{i}(f), h_others{i}(f)]*0.4;
                img_other = imresize(img_other, 0.4, 'nearest');
                %img_other = insertShape(img_other, 'Rectangle', [bb_other; bb_other+inner], 'Color', 'green', 'Opacity', 0);
                img_other = insertShape(img_other, 'Rectangle', [bb_other], 'Color', 'green', 'Opacity', 0);
                img_other = insertShape(img_other, 'FilledRectangle', [6 6 250 80]/2, 'Color', 'white', 'Opacity', 0.4);
                img_other = insertText(img_other, [10 10]/2, f, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'red');
                img_other = insertText(img_other, [100 10]/2, '/', 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'blue');
                img_other = insertText(img_other, [130 10]/2, length(tracklet_frames{i}), 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'blue');
                %img_other = insertText(img_other, [size(img_other,2) 10]/2, counter, 'FontSize', 24, 'BoxOpacity', 0, 'TextColor', 'yellow');
                
                if f == 1
                    [im_other, map_other] = rgb2ind(img_other, 256, 'nodither');
                    im_other(1,1,1,length(tracklet_frames{i})) = 0;
                else
                    im_other(:,:,1,f) = rgb2ind(img_other, map_other, 'nodither');
                end
            end
            
            %sprintf('frame; %d/%d, tracklet: %d/%d',f,length(tracklet_frames{i}), i, length(tracklet_frames))
        end
        if show_others == 1
            imwrite(im_other, map_other, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/not_in_group' num2str(g) '/' num2str(i) '.gif'], 'DelayTime', 0, 'LoopCount', inf);
        end
        if do_it == 1
            if same_group == 0
                imwrite(im, map, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/' num2str(i) '.gif'], 'DelayTime', 0, 'LoopCount', inf);
            else
                imwrite(im, map, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/same_group' num2str(g) '/' num2str(i) '.gif'], 'DelayTime', 0, 'LoopCount', inf);
            end
        end
        
    end
    if do_it == 1
        copyfile('/cs/vml3/mkhodaba/codes/ECCV14/results/group.html', ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/group.html']);
        copyfile('/cs/vml3/mkhodaba/codes/ECCV14/results/group.html', ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/same_group' num2str(g) '/group.html']);
    end
    if show_others == 1
        copyfile('/cs/vml3/mkhodaba/codes/ECCV14/results/group.html', ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/not_in_group' num2str(g) '/group.html']);
    end
    
end
%}