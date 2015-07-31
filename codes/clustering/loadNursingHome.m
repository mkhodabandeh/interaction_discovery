function [global_data, latent_data, labels] = loadNursingHome(conf)
% data = loadCollectiveActivity(conf)
%
    %data_path = '/cs/vml3/mkhodaba/data/collective activity/activity_conFeat_data_scaled.mat';
    data_path = '/cs/vml2/mkhodaba/data/CVPR2015/nursing home/pretrain.mat';
    load(data_path);
    n_kinters = 3;
    if conf.feature_number == 1
        %{
        load_vl_feat   
        expanded_features = cellfun(@(x) vl_homkermap(x', n_kinters, 'KINTERS'), test_data.feat', 'UniformOutput', false); 
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', expanded_features, 'UniformOutput', false));
        unload_vl_feat
        latent_data = expanded_features;
        %}
        load_vl_feat   
        expanded_features = cellfun(@(x) vl_homkermap(x, n_kinters, 'KINTERS')', test_data.feat', 'UniformOutput', false); 
        global_data = cell2mat(cellfun(@(x) [mean(x, 2)]', expanded_features, 'UniformOutput', false));
        unload_vl_feat
        latent_data = expanded_features;
    else
    	load(data_path);
        global_data = cell2mat(cellfun(@(x) [mean(x, 1)], test_data.feat', 'UniformOutput', false));
        global_data = cell2mat(cellfun(@(x) rand(1, 5), test_data.feat', 'UniformOutput', false));
        latent_data = cellfun(@transpose, test_data.feat', 'UniformOutput', false);
    end
    labels = test_data.label;