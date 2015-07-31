function [global_data, latent_data, labels] = loadCollectiveActivity(conf)
% data = loadCollectiveActivity(conf)
%
    data_path = '/cs/vml2/hosseinh/others/for-mehran/activity/activity_conFeat_data.mat';
    
    %data_path = '/cs/vml2/hosseinh/others/for-mehran/activity/activity_data.mat';
    load(data_path);
    n_kinters = 3;
    if conf.feature_number == 1
        %
        load_vl_feat   
        expanded_features = cellfun(@(x) vl_homkermap(x', n_kinters, 'KINTERS')', Features_test, 'UniformOutput', false); 
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', expanded_features', 'UniformOutput', false));
        unload_vl_feat
        latent_data = expanded_features';
        %}
        %{
          load_vl_feat   
        expanded_features = cellfun(@(x) vl_homkermap(x, n_kinters, 'KINTERS'), Features_test, 'UniformOutput', false); 
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', expanded_features', 'UniformOutput', false));
        unload_vl_feat
        latent_data = expanded_features';
        %latent_data = cellfun(@transpose, expanded_features', 'UniformOutput', false);
    %}
    elseif conf.feature_number == 2
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', Features_test', 'UniformOutput', false));
        latent_data = Features_test';
    elseif conf.feature_number == 3
    	data_path = '/cs/vml2/hosseinh/others/for-mehran/activity/activity_conFeat_data_scaled.mat';
        %data_path = '/cs/vml3/mkhodaba/data/collective activity/activity_data.mat';
        load(data_path);
        load_vl_feat   
        expanded_features = cellfun(@(x) vl_homkermap(x', n_kinters, 'KINTERS')', Features_test, 'UniformOutput', false); 
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', expanded_features', 'UniformOutput', false));
        unload_vl_feat
        latent_data = expanded_features';
    
    else
    	%data_path = '/cs/vml3/exports/vml/mkhodaba/data/collective activity/activity_conFeat_data.mat';
        data_path = conf.datapath;
        load(data_path);
        global_data = cell2mat(cellfun(@(x) [sum(x, 2)]', Features_test', 'UniformOutput', false));
        %global_data = cell2mat(cellfun(@(x) rand(1, 5), Features_test', 'UniformOutput', false));
        latent_data = Features_test';
        
    end
    %% Zero mean unit variance
    %{
    mean_vec = mean(global_data, 1);
    global_data = bsxfun(@minus, global_data, mean_vec);
    v = std(global_data, 1, 1)+0.0001;
    global_data = bsxfun(@rdivide, global_data, v);
    %}
    
    %%
    %latent_data = Features_test';
    %latent_data = expanded_features';
    
    %latent_data = cellfun(@(x) x.^ (0.5), Features_test', 'UniformOutput', false); 
    %cellfun(@transpose, Features_test', 'UniformOutput', false);
    %global_data = cellfun(@transpose, global_data, 'UniformOutput', false);
    labels = Labels_test;
   
