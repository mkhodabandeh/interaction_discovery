function [global_data, latent_data, labeltr, w_init, latent_aux_data] = read_data(conf)
%global data;
latent_aux_data = struct;
latent_data = [];
coeff_hog = 1;
switch conf.data
    case 1 % synthetic data
        load([conf.datapath filesep 'synthetic_data/synthetic_data.mat']);
        conf.respath = [conf.datapath '/synthetic_data/'];
        %{
        load_vl_feat
        synthetic_data_expanded = vl_homkermap(synthetic_data', 10, 'KINTERS');
        synthetic_data_expanded = transpose(synthetic_data_expanded);
        unload_vl_feat
        data = single(synthetic_data_expanded);
        %}
        %
        %data = prep_data(data, 3, 'KINTERS');
        gmm_bins = 3;
        myData = prep_data( synthetic_data, 'KINTERS', 3, gmm_bins );
        global_data = single(myData);
        %}
        % data = zscore(data, 0, 1);
        
        labeltr = zeros(size(global_data,1), max(synthetic_data_labels));
        b = cumsum([1;size(labeltr,2)*ones(size(global_data,1)-1,1)]);
        labeltr = labeltr';
        labeltr(b+(synthetic_data_labels-1)) = 1;
        labeltr = labeltr';
        w_init = initialize_w([myData ones(size(synthetic_data,1),1)], conf.kc);
        %w = initialize_w([synthetic_data_expanded ones(size(synthetic_data_expanded,1),1)], conf.kc);
        %%w = initialize_w([data ones(size(data,1),1)], conf.kc);
        %clear synthetic_data_expanded
        clear synthetic_data synthetic_data_labels;
        %
    case 2 % trecvid
        %negs = 20;
        %scene = '002';
        scene = conf.scene;
        %conf.scene = scene;
        %conf.respath = [conf.datapath '/VIRAT/' scene '/'];
        conf.respath = ['/cs/vml2/mkhodbaa/resluts/CVPR2015/VIRAT/'];
        [latent_aux_data, labeltr, w_init, global_data, latent_data ] = loadVIRAT(conf);
        labeltr;
    case 3 % UT
        clear obj objm number_of_tracklets number_of_tracklets_m number_of_tracks number_of_tracks_m data my_data;
        scene = conf.scene;
        %conf.datapath = '/cs/vml2/mkhodaba/data/CVPR2015/UT/';
        conf.datapath= '/cs/vml3/exports/vml/mkhodaba/results/ECCV14/data/UT/'
        %conf.datapath = '/cs/grad1/mkhodaba/Documents/codes/ECCV14/';
        %conf.respath = [conf.datapath '/UT/' scene '/'];
        
        %configurations
        gmm_bins = 3;
        kernel_expansion_n = 3;
        
        
        %THIS ONE
        %load([conf.datapath  scene '.mat']);
        
        %{
       
        ten_sec_tracklets = gmm_fit(obj.ten_sec_feature, gmm_bins, 1);
        myData = cell2mat(obj.small_tracklet_features)';
        number_of_mini_tracklets = size(myData,1);
        mini_tracklets = gmm_fit(myData(:), gmm_bins, 1);
        mini_tracklets = reshape( mini_tracklets', [(gmm_bins)*number_of_mini_tracklets number_of_tracklets])';
        myData = [mini_tracklets, ten_sec_tracklets];
        myData1 = [cell2mat(obj.nearest_person_dist_hist), cell2mat(obj.nearest_person_small_dist_hist)];
        myData = [myData, myData1];
        
        mini_tracklets_hoghof = gmm_fit(obj.small_part_hog_hof_gmm, gmm_bins, 1);
        mini_tracklets_hoghof = reshape( mini_tracklets_hoghof', [(gmm_bins)*number_of_mini_tracklets number_of_tracklets])';
        
        
        %save([conf.datapath '/data/UT/' scene '_20_2_4_' num2str(conf.alpha) '.mat'], 'myData', 'obj');
        
        %}
        %THIS ONE
        %CVPR SET1
        alpha = 2
        load([conf.datapath scene '_20_2_4_' num2str(10^alpha) '.mat'], 'myData', 'obj');
        
        %%%%%%%%%%%%%%%%%% Last results on scene 1
        %alpha = 2
        %load([conf.datapath scene '_20_2_3_' num2str(conf.alpha) '.mat'], 'myData', 'obj'); %thresholds: 162 215
        
        
        %alpha = 3;
        %load([conf.datapath '/data/UT/' scene '_20_2_2_' num2str(10 ^alpha) '.mat'], 'myData', 'obj'); %thresholds: 165 215
        
        
        %CVPR SET2
        %alpha = 4
        %load([conf.datapath scene '_20_2_1_' num2str(10 ^ alpha) '.mat'], 'myData', 'obj');
        
        
        
        %%%%%%%%%%%%%%%%% Sheet 3 & latent_region -> only dist + v or do
        %%%%%%%%%%%%%%%%% the below settings
        %load([conf.datapath '/data/UT/' scene '_20_2_1_1000.mat'], 'myData', 'mini_tracklets_hoghof', 'obj');
        %latent_coeff_hog = 0.4;
        %load([conf.datapath '/data/UT/' scene 'mini_tracklets_hoghof.mat'], 'mini_tracklets_hoghof');
        %%%%%%%%%%%%%%%%% Sheet 4
        %THIS ONE
        %CVPR SET2
        %load([conf.datapath scene '_20_2_5_10000.mat'], 'myData', 'mini_tracklets_hoghof', 'obj');
        
        %mini_tracklets_hoghof = gmm_fit(obj.small_part_hog_hof_gmm, gmm_bins, 1);
        %mini_tracklets_hoghof = reshape( mini_tracklets_hoghof', [(gmm_bins)*2 number_of_tracklets])';
        %save([conf.datapath '/data/UT/' scene '_20_2_2_' num2str(10 ^ conf.alpha) '_mini_tracklets_hoghof.mat'], 'mini_tracklets_hoghof');
        
        %alpha = 3;
        %load([conf.datapath scene '_20_2_2_' num2str(10 ^ alpha) '_mini_tracklets_hoghof.mat'], 'mini_tracklets_hoghof');
        
        
        %%%%%%%% last results of mini_tracklets %%%% on scene 1
        % SET1
        alpha = 4;
        load([conf.datapath scene '_20_2_1_' num2str(10 ^ alpha) '_mini_tracklets_hoghof.mat'], 'mini_tracklets_hoghof');
        
        
        
        %load([conf.datapath '/data/UT/' scene '_40_4_1_10000.mat'], 'myData', 'mini_tracklets_hoghof', 'obj');
        %{
obj.larger_tracklet_hog_hof_gmm = cat(1, obj.larger_tracklet_hog_hof_gmm(1:82), obj.larger_tracklet_hog_hof_gmm(85:120));
obj.larger_tracklet_subject = cat(1, obj.larger_tracklet_subject(1:82), obj.larger_tracklet_subject(85:end));
obj.larger_tracklet_interaction_type = cat(1, obj.larger_tracklet_interaction_type(1:82), obj.larger_tracklet_interaction_type(85:end));
obj.larger_tracklet_track_id = cat(1, obj.larger_tracklet_track_id(1:82), obj.larger_tracklet_track_id(85:end));
number_of_tracks = 118;
        %}
        
        %load([conf.datapath '/data/UT/' scene '_20_2_1_10000.mat'], 'myData', 'obj');
        % For experiments where: tracklet_length=20 parts=2 -- it worked
        % best with alpha=2
        %load([conf.datapath '/data/UT/' scene '_20_2_1000.mat'], 'myData', 'obj');
        
        
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm8_100.mat'], 'myData', 'obj');
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm6_10000.mat'], 'myData', 'obj'); %44 length with 4 parts 81% purity
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm7_1000.mat'], 'myData', 'obj');
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm2_10000.mat'], 'myData');
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm.mat']);
        %load('/cs/vml3/mkhodaba/codes/ECCV14//data/UT/ftr_set2_ten_mini_gmm_1000.mat')
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm3_10000.mat'], 'myData', 'obj');
        %if conf.feature_number ~= 2
        %load([conf.datapath '/data/UT/' scene '_ten_mini_gmm4_1000.mat'], 'myData', 'obj');
        
        %load([conf.datapath '/data/UT/' scene '_hog20_dist44.mat']);
        %myData = dist_v_myData;
        
        %end
        if conf.latent == 1
            
            %myData = gmm_fit(myData, gmm_bins);
            hog_hof_features = cell2mat(obj.hog_hof_gmm);
            hog_hof_features = [hog_hof_features, mini_tracklets_hoghof];
            %%%% Specify latent features %%%%
            switch conf.feature_number
                case 1 %velocity+distance features
                    latent_data = [myData];
                case 2 %hog+hof features
                    latent_data = [hog_hof_features];
                case 3 %hof+hof+velocity+distance features
                    latent_data = [myData, hog_hof_features];
            end
            
            %
            %latent_data = [myData];
            %latent_data = [hog_hof_features];
            
            if conf.latent_region == 0
                latent_data = [];
            end
            
            latent_data = prep_data(latent_data, 'KINTERS', kernel_expansion_n);
            latent_data = single(latent_data);
            latent_data = zscore(latent_data, 0, 1);
            
            sorted_index = [1:size(unique([obj.track_id obj.subject], 'rows'), 1)];
            have_global_features = 1
            if have_global_features == 1
                [track_ids, sorted_index] = sortrows(unique([obj.track_id obj.subject], 'rows'), 2);
                %labeltr = zeros(length(sorted_index)/2, 1);
                %track_ids = unique([obj.track_id obj.subject], 'rows');
                global_velocity_dist_features = zeros(length(track_ids), size(myData, 2));
                for i = 1:length(track_ids)
                    track_inds = obj.track_id == track_ids(i,1) & obj.subject == track_ids(i,2);
                    global_velocity_dist_features(i, :) = mean(myData(track_inds,:),1);
                    
                end
                
                
                
                %%%% specify global features %%%%
                %
                %
                
                switch conf.feature_number
                    case 1 %velocity+distance features
                        myData = global_velocity_dist_features;
                    case 2 %hog+hof features
                        myData = cell2mat(obj.larger_tracklet_hoghof_pose_features);
                        %myData = cell2mat(obj.larger_tracklet_hog_hof_k_means);
                        %myData = cell2mat(obj.larger_tracklet_hog_hof_gmm);
                        myData = myData(sorted_index, :);
                        %save([conf.datapath '/data/UT/' scene '_global_hog_hof_latent.mat'], 'myData');
                        %load([conf.datapath '/data/UT/' scene '_global_hog_hof_latent.mat'], 'myData');
                        %myData = myData([[2:60], [62:120]], :);
                    case 3 %hof+hof+velocity+distance features
                        myData = cell2mat(obj.larger_tracklet_hoghof_pose_features);
                        %myData = cell2mat(obj.larger_tracklet_hog_hof_gmm);
                        myData = myData(sorted_index, :);
                        %load([conf.datapath '/data/UT/' scene '_global_hog_hof_latent.mat'], 'myData');
                        %myData = myData([[2:60], [62:120]], :);
                        myData = [myData, coeff_hog .* global_velocity_dist_features];
                end
            end
            
            
            
            latent_aux_data = struct;
            latent_aux_data.larger_tracklet = obj.larger_tracklet(sorted_index);
            latent_aux_data.larger_tracklet_frames = obj.larger_tracklet_frames(sorted_index);
            latent_aux_data.larger_tracklet_track_id = obj.larger_tracklet_track_id(sorted_index);
            latent_aux_data.larger_tracklet_video_name = obj.larger_tracklet_video_name(sorted_index,:);
            latent_aux_data.larger_tracklet_subject = obj.larger_tracklet_subject(sorted_index);
            
            %hog_hof_features = cell2mat(obj.hog_hof);
            %table_address = '/cs/vml3/mkhodaba/data/UT/';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NEXT LINE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% !!!!!
            %myData = [hog_hof_features];
            
            
            %labeltr = [labels, ones(1, negs)*(max(labels)+1)]';
            %myData = [ n_pInteractionHists(:,1:16); interactionHists(1:negs,1:16)];
            %labels2 = [labels(327:621) labels(1:236)];
            %labeltr = labels2(1:size(myData,1))';
            labeltr = obj.larger_tracklet_interaction_type;
            if have_global_features == 1
                labeltr = obj.larger_tracklet_interaction_type(sorted_index);
            end
            %labeltr = full( sparse((1:length(labeltr))', labeltr, ones(length(labeltr), 1)) );
            %save([conf.datapath, '/VIRAT/virat.mat'], 'myData','labeltr');
            %save([conf.datapath '/VIRAT/0401_all.mat'], 'objm', 'number_of_tracklets_m', 'number_of_tracks_m');
        else
            %[track_ids, sorted_index] = sortrows(unique([obj.track_id obj.subject], 'rows'), 2);
            track_ids = unique(obj.track_id);
            global_velocity_dist_features = zeros(length(track_ids), 2*size(myData, 2));
            data_size = size(myData, 2);
            for i = 1:length(track_ids)
                track_inds_1 = obj.track_id == track_ids(i) & obj.subject == 1;
                track_inds_2 = obj.track_id == track_ids(i) & obj.subject == 2;
                global_velocity_dist_features(i, 1:data_size) = mean(myData(track_inds_1,:),1);
                %global_velocity_dist_features(i, data_size+1) = 1;
                global_velocity_dist_features(i, 1+data_size:end) = mean(myData(track_inds_2,:),1);
            end
            
            labeltr = obj.larger_tracklet_interaction_type(1:2:end);
            have_global_features = 0;
            %myData = [myData, global_velocity_dist_features];
            switch conf.feature_number
                case 1 %velocity+distance features
                    myData = global_velocity_dist_features;
                case 2 %hog+hof features
                    hog_hof_feat = cell2mat(obj.larger_tracklet_hoghof_pose_features);
                    %hog_hof_feat = cell2mat(obj.larger_tracklet_hog_hof_k_means);
                    %hog_hof_feat = cell2mat(obj.larger_tracklet_hog_hof_gmm);
                    myData = [hog_hof_feat(1:2:end, :), hog_hof_feat(2:2:end, :)];
                    %save([conf.datapath '/data/UT/' scene '_global_hog_hof_features.mat'], 'myData');
                    %load([conf.datapath '/data/UT/' scene '_global_hog_hof_features.mat'], 'myData');
                    
                case 3 %hof+hof+velocity+distance features
                    hog_hof_feat = cell2mat(obj.larger_tracklet_hoghof_pose_features);
                    %hog_hof_feat = cell2mat(obj.larger_tracklet_hog_hof_gmm);
                    myData = [hog_hof_feat(1:2:end, :), hog_hof_feat(2:2:end, :)];
                    %load([conf.datapath '/data/UT/' scene '_global_hog_hof_features.mat'], 'myData');
                    myData = [myData, coeff_hog .* global_velocity_dist_features];
            end
            
            
        end
        
        myData = prep_data(myData, 'KINTERS', kernel_expansion_n);
        if have_global_features == 1
            data_w_init_with_subject = cat(2, myData(1:end/2,:), ones(size(myData,1)/2, 1), myData(end/2+1:end,:), ones(size(myData,1)/2, 1));
        end
        global_data = single(myData);
        global_data = zscore(global_data, 0, 1);
        
        %prepare information for latent variable
        
        
        
        
        dim = size(global_data, 2);
        if have_global_features == 1
            dim = size(data_w_init_with_subject, 2);
        end
        w_init = [ones(dim - 1, conf.kc); ones(1, conf.kc)]';
        if conf.latent_region == 1
            %w_init_latent_1 = initialize_w(latent_data(obj.subject==1,:), conf.kc);
            %w_init_latent_2 = initialize_w(latent_data(obj.subject==2,:), conf.kc);
            %w_init = [w_init, w_init_latent_1, w_init_latent_2];
            w_init_latent = [ones(size(latent_data,2)*1, conf.kc)]';
            w_init = [w_init, w_init_latent];
        else
            w_init = [w_init, ones(size(w_init,1), 2)];
        end
        if conf.randidx == 1
            if have_global_features == 1
                w_init = initialize_w([data_w_init_with_subject], conf.kc);
            else
                w_init = initialize_w([myData ones(size(myData,1),1)], conf.kc);
            end
            if ~isempty(latent_data)
                w_init_latent_1 = initialize_w(latent_data(obj.subject==1,:), conf.kc);
                %w_init_latent_2 = initialize_w(latent_data(obj.subject==2,:), conf.kc);
                w_init_latent_2 = [];
                w_init = [w_init, w_init_latent_1, w_init_latent_2];
            end
            fprintf('initialization done!')
        end
        
        
        clear interactionHists n_pInteractionHists myData labels negs hog_hof_features myData;
        
        
    case 4
        [global_data, latent_data, labeltr] = loadCollectiveActivity(conf);
        latent_aux_data = [];
        
        num_data = size(latent_data, 1);% N
        %num_latent = 40;% H
        feature_size = size(latent_data{1}, 1);% F
        num_clusters = conf.kc;% K
        num_latent = 40;
        
        w_init = ones(num_clusters*(1+feature_size)+num_latent*feature_size+num_latent*num_clusters,1 );
    case 5
        [global_data, latent_data, labeltr] = loadNursingHome(conf);
        latent_aux_data = [];
        num_data = size(latent_data, 1);% N
        %num_latent = 40;% H
        feature_size = size(latent_data{1}, 1);% F
        num_clusters = conf.kc;% K
        num_latent = 40;
        w_init = ones(num_clusters*(1+feature_size)+num_latent*feature_size+num_latent*num_clusters,1 );
        %{
  case 2 % trecvid: tagsc
        load([conf.datapath, 'trecvid11_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'trecvid11_tagsc.mat'], 'tagsctr');
        data = single(tagsctr);
        data = zscore(data, 0, 1);
        clear tagsctr;
    case 3 % trecvid: global + tagsc
        load([conf.datapath, 'trecvid11_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'trecvid11_hog3d_1000.mat'], 'gfeat');
        load([conf.datapath, 'trecvid11_tagsc.mat'], 'tagsctr');
        data = single([gfeat, tagsctr]);
        clear gfeat tagsctr;
    case 12 % kth
        load([conf.datapath, 'kth_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'kth_actionbank.mat'], 'abfeat');
        data = single(abfeat);
        data = zscore(data, 0, 1);
        clear abfeat;
    case 22 % ucfsports
        load([conf.datapath, 'ucfsports_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'ucfsports_actionbank.mat'], 'abfeat');
        data = single(abfeat);
        data = zscore(data, 0, 1);
        clear abfeat;myData = prep_data(myData, 'KINTERS', kernel_expansion_n);
                m = single(myData);
                global_data = zscore(global_data, 0, 1);
    case 32 % ucf50
        load([conf.datapath, 'ucf50_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'ucf50_actionbank.mat'], 'abfeat');
        data = single(abfeat);
        data = zscore(data, 0, 1);
        clear abfeat;
    case 42 % hmdb51
        load([conf.datapath, 'hmdb51_classlabels.mat'], 'labeltr');
        load([conf.datapath, 'hmdb51_actionbank.mat'], 'abfeat');
        data = single(abfeat);
        data = zscore(data, 0, 1);
        clear abfeat;
        %}
end

if conf.latent == 0 && conf.data == 3
    global_data = [global_data(:, 1:end/2),  ones(size(global_data, 1), 1), global_data(:,1+end/2:end)];
end
global_data = [global_data,  ones(size(global_data, 1), 1)];
%%%%%%%%%% What's this?
%[~, labeltr] = max(labeltr, [], 2);