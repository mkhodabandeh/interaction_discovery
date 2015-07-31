%In the name of God
scene = conf.scene;
dataset = conf.data;
latent = conf.latent;

if conf.data == 2
    load(['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data/VIRAT/' scene '_all.mat']);
    dataset_name = 'VIRAT';
else
    load(['/cs/vml3/mkhodaba/codes/ECCV14/data/UT/' scene '.mat']);
    frame_dir = '/cs/vml/users/bog/data/frame/';
    dataset_name = 'UT';
    load(['/cs/vml3/mkhodaba/data/UT/' scene '_small.mat']);
    objm = obj;
end
for i = 1:conf.kc
    labels{i} = find(results.labels==i);
end
ground_truth_labels = cell(length(labels),1);
%labels{1} = [1 3 5 6];

number_of_data_per_class = length(labels{1})
counter = 0;
for g=1:length(labels)
     
    if latent == 1
        ls = results.latent_variables(labels{g}, g);
        
    else
    	ls = labels{g};
    end

    tracklet_frames = objm.tracklet_frames(ls);
    if dataset == 2
        zoom = 0.4;
        x = objm.tracklet_bb_x(ls);
        y = objm.tracklet_bb_y(ls);
        w = objm.tracklet_bb_w(ls);
        h = objm.tracklet_bb_h(ls);
        names = objm.name(ls,:);
        others = randi(length(objm.tracklet_no), 2*length(ls), 1);
        for i = 1:length(ls)
            others(others==ls(i)) = [];
        end
        others = others(1:length(ls));
        dist_to_vehicle = objm.nearest_vehicle_dist_hist(ls);
    else
        %boundingbox = objm.tracklet_bb(ls);
        tarck_ids = objm.track_id(ls);
        zoom = 1;
        %track_ids = objm.track_id(ls)
        %seq_no = objm.sequence_no(ls);
        %subjects = objm.subject(ls);
        
        tracklet_frames = objm.larger_tracklet_frames(labels{g});
        track_ids = objm.larger_tracklet_track_id(labels{g});
        seq_no = objm.larger_tracklet_sequence_no(labels{g});
        subjects = objm.larger_tracklet_subject(labels{g});
        ground_truth_labels{g} = objm.interaction_type(ls);
        for i = 1:length(ls)
            boundingbox{i} = table(table(:, 1) == track_ids(i) & table(:, 8) == subjects(i) &  table(:,9)==seq_no(i), 4:7);
            nearest_person_bb{i} = table(table(:, 1) == track_ids(i) & table(:, 8) == (3-subjects(i)) &  table(:,9)==seq_no(i), 4:7);
        end
    end

%
    ten_features = objm.ten_sec_feature(ls);
    two_features = objm.small_tracklet_features(ls);
    dist_to_person = objm.nearest_person_dist_hist(ls);
    
    
    %figure('visible', 'off');
    %axis tight
    g
    %set(gca,'nextplot','replacechildren','visible','off')
    frame_address = ['/cs/vml2/mkhodaba/codes/ECCV 2014/raw_data/tracklet_frames/' scene];
    %
    try
        rmdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/']);
    catch
    end
    mkdir(['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/']);
    for i=1:length(tracklet_frames)
        counter = counter + 1;
        clear im map;
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
        for f = 1:length(tracklet_frames{i})
            %img = uint8(tracklet_raw_frames(:,:,:,f));
          if dataset == 2
                img = imread(['/cs/vml3/mkhodaba/virat/frames/' scene '/' names(i,:) '/' num2str(tracklet_frames{i}(f)+1) '.jpg']);
           %img = rgb2gray(img);
           %rec = @() rectangle('position',[55 11 114 120]);
           %params = {'linewidth',2,'edgecolor','c'};
           %imgOut = insertInImage(img,rec,params);
                bb = [x{i}(f), y{i}(f), w{i}(f), h{i}(f)]*0.4;
                bb_v = objm.nearest_vehicle_bb{ls(i)}(f,:)*0.4;
                bb_p = objm.nearest_person_bb{ls(i)}(f,:)*zoom;
                img = imresize(img, 0.4, 'nearest');
                
          else
                img = imread(sprintf('%s%s%d%s%.3d%s',frame_dir,'seq',objm.sequence_no(ls(i)),'/frame',tracklet_frames{i}(f),'.png'));
                bb = boundingbox{i}(f,:);
                bb_p = nearest_person_bb{i}(f,:);
          end
           inner = [1 1 -2 -2];
           
           
          
          img = insertShape(img, 'Rectangle', [bb; bb+inner], 'Color', 'green', 'Opacity', 0);
          img = insertShape(img, 'Rectangle', [bb_p; bb_p+inner], 'Color', 'red', 'Opacity', 0);
          %{
          
            %}
          if dataset == 2
              img = insertShape(img, 'FilledRectangle', [10 10 290 200]/2, 'Color', 'white', 'Opacity', 0.4);
              img = insertText(img, [10 10;  10 50;  80  50; 150 50; 220 50]/2, round([ten_features(i), [two_features{i}]]*10)/10, 'FontSize', 12, 'BoxOpacity', 0);
              img = insertText(img, [10 90;  70 90;  130 90]/2, round(dist_to_person{i}*10)/10, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'red');
              img = insertText(img, [10 170]/2, f, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'blue');
              img = insertShape(img, 'Rectangle', [bb_v; bb_v+inner], 'Color', 'yellow', 'Opacity', 0);
              img = insertText(img, [10 130; 70 130; 130 130]/2, round(dist_to_vehicle{i}*10)/10, 'FontSize', 12, 'BoxOpacity', 0, 'TextColor', 'yellow');
              img = insertText(img, [8 130;  68 130; 128 130]/2, round(dist_to_vehicle{i}*10)/10, 'FontSize', 13, 'BoxOpacity', 0, 'TextColor', 'yellow');
          end
          
          %imshow(I);
            %rectangle('Position', [x{i}(f), y{i}(f), w{i}(f), h{i}(f)], 'LineWidth', 2, 'EdgeColor', 'red');
            %
             %     fr = getframe;  
            % imshow(img);
            
            if f == 1
                [im, map] = rgb2ind(img, 256, 'nodither');
                    im(1,1,1,length(tracklet_frames{i})) = 0;
            else
                im(:,:,1,f) = rgb2ind(img, map, 'nodither');
            end

            %sprintf('frame; %d/%d, tracklet: %d/%d',f,length(tracklet_frames{i}), i, length(tracklet_frames))
        end
        
        imwrite(im, map, ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/' num2str(i) '.gif'], 'DelayTime', 0, 'LoopCount', inf);
        
    end
    copyfile('/cs/vml3/mkhodaba/codes/ECCV14/results/group.html', ['/cs/vml3/mkhodaba/codes/ECCV14/results/' dataset_name '/gifs_' scene '/group' num2str(g) '/group' num2str(g) '.html']);
    
    end
%}