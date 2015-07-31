function [latent_aux_data, labeltr, w_init, global_data, latent_data ] = loadVIRAT(conf)
clear obj objm number_of_tracklets number_of_tracklets_m number_of_tracks number_of_tracks_m;
        
        scene = conf.scene;
        load([conf.datapath '/VIRAT/' scene '_global_all.mat']);
        %{
        a = dir(conf.respath);
        load([conf.respath, '/' a(3).name]);
        names = fieldnames(obj);
        number_of_tracklets_m = number_of_tracklets;
        number_of_tracks_m = number_of_tracks;
        objm = obj;
        for i = 4:length(a)
            load([conf.respath '/' a(i).name]);
            for f = 1:numel(names)
                objm.(names{f}) = cat(1, objm.(names{f}), obj.(names{f}));
            end
            number_of_tracklets_m = number_of_tracklets + number_of_tracklets_m;
            number_of_tracks_m = number_of_tracks + number_of_tracks_m;
        end
        %}
        myData = objm.ten_sec_feature;
        gmm_bins = 3;
        kernel_expansion_n = 3;
        
        %ten_sec_tracklets = myData;
        ten_sec_tracklets = gmm_fit(myData, gmm_bins, 1);
        
        myData = cell2mat(objm.small_tracklet_features)';
        number_of_mini_tracklets = size(myData,1);
        mini_tracklets = gmm_fit(myData(:), gmm_bins, 1);
        %mini_tracklets = myData;
        mini_tracklets = reshape( mini_tracklets', [(gmm_bins)*number_of_mini_tracklets number_of_tracklets_m])';
        
        myData = [mini_tracklets, ten_sec_tracklets];
        %myData = gmm_fit(myData, gmm_bins);
        myData1 = [cell2mat(objm.nearest_person_dist_hist), cell2mat(objm.nearest_person_small_dist_hist), ...
            cell2mat(objm.nearest_vehicle_dist_hist), cell2mat(objm.nearest_vehicle_small_dist_hist)];
        myData = [myData, myData1];
        %features = myData;
        %save([conf.datapath '/VIRAT/0401_features.mat'], 'features');
        myData = prep_data(myData, 'KINTERS', kernel_expansion_n);
        %labeltr = [labels, ones(1, negs)*(max(labels)+1)]';
        %myData = [ n_pInteractionHists(:,1:16); interactionHists(1:negs,1:16)];
        %labels2 = [labels(327:621) labels(1:236)];
        %labeltr = labels2(1:size(myData,1))';
        %labeltr = [1:size(myData,1)]';
        load(['/cs/vml2/mkhodaba/data/AutoTrackerManuallyInitialized/annotations/' scene '_alltracks.mat']);
        
        labels = arrayfun(@(x) x.label, all_tracks(objm.track_id))';
        ids = labels == 1; %
        labels(ids) = 3; % relabel people standing alone near a car to peolpe interacting with a car
        ids = labels == 7; %
        labels(ids) = 3; % relabel people standing alone near a car to peolpe interacting with a car
        unique_labels = unique(labels);
        num_clusters = conf.kc;
        labeltr = zeros(size(labels));
        for i = 1:num_clusters
            inds = labels == unique_labels(i);
            labeltr(inds) = i;
        end
        save([conf.datapath, '/VIRAT/virat_global.mat'], 'myData','labeltr');
        %save([conf.datapath '/VIRAT/0401_all.mat'], 'objm', 'number_of_tracklets_m', 'number_of_tracks_m');
        
        global_data = single(myData);
        global_data = zscore(global_data, 0, 1);
        
        %prepare information for latent variable
        latent_aux_data = struct;
        latent_aux_data.larger_tracklet = objm.larger_tracklet;
        latent_aux_data.larger_tracklet_frames = objm.larger_tracklet_frames;
        latent_aux_data.larger_tracklet_track_id = objm.larger_tracklet_track_id;
        latent_aux_data.larger_tracklet_video_no = objm.larger_tracklet_video_no;
        
        
        global_feature_size = size(myData, 2);
        
        clear interactionHists n_pInteractionHists myData labels negs objm obj;
   
        load([conf.datapath '/VIRAT/' scene '_latent_all.mat']);
        
        
        myData = objm.ten_sec_feature;
        gmm_bins = 3;
        kernel_expansion_n = 3;
        
        %ten_sec_tracklets = myData;
        ten_sec_tracklets = gmm_fit(myData, gmm_bins, 1);
        
        myData = cell2mat(objm.small_tracklet_features)';
        number_of_mini_tracklets = size(myData,1);
        mini_tracklets = gmm_fit(myData(:), gmm_bins, 1);
        %mini_tracklets = myData;
        mini_tracklets = reshape( mini_tracklets', [(gmm_bins)*number_of_mini_tracklets number_of_tracklets_m])';
        
        myData = [mini_tracklets, ten_sec_tracklets];
        %myData = gmm_fit(myData, gmm_bins);
        myData1 = [cell2mat(objm.nearest_person_dist_hist), cell2mat(objm.nearest_person_small_dist_hist), ...
            cell2mat(objm.nearest_vehicle_dist_hist), cell2mat(objm.nearest_vehicle_small_dist_hist)];
        myData = [myData, myData1];
        %features = myData;
        %save([conf.datapath '/VIRAT/0401_features.mat'], 'features');
        myData = prep_data(myData, 'KINTERS', kernel_expansion_n);
        %labeltr = [labels, ones(1, negs)*(max(labels)+1)]';
        %myData = [ n_pInteractionHists(:,1:16); interactionHists(1:negs,1:16)];
        %labels2 = [labels(327:621) labels(1:236)];
        %labeltr = labels2(1:size(myData,1))';
        %labeltr = [1:size(myData,1)]';
        %load(['/cs/vml2/mkhodaba/data/AutoTrackerManuallyInitialized/annotations/' scene '_alltracks.mat']);
        
        latent_data = myData;
        save([conf.datapath, '/VIRAT/virat.mat'], 'latent_data');
        %save([conf.datapath '/VIRAT/0401_all.mat'], 'objm', 'number_of_tracklets_m', 'number_of_tracks_m');
        
        latent_data = single(myData);
        latent_data = zscore(latent_data, 0, 1);
        
        %prepare information for latent variable
        latent_aux_data = struct;
        latent_aux_data.larger_tracklet = objm.larger_tracklet;
        latent_aux_data.larger_tracklet_frames = objm.larger_tracklet_frames;
        latent_aux_data.larger_tracklet_track_id = objm.larger_tracklet_track_id;
        latent_aux_data.larger_tracklet_video_no = objm.larger_tracklet_video_no;
        
        
        latent_feature_size = size(myData, 2);

        %w_init = initialize_w([myData ones(size(myData,1),1)], conf.kc);
        if conf.latent == 0
            w_init = ones(num_clusters*(1+global_feature_size), 1);
        else
            w_init = ones(num_clusters*(1+global_feature_size+latent_feature_size), 1);
        end
