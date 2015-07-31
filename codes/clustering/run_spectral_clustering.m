function [ results ] = run_spectral_clustering( id )
%RUN_SPECTRAL_CLUSTERING Summary of this function goes here

%% settings

    conf.replicates = 5;
    conf.kc = 5;
    conf.data = 4;
    conf.scene = '0001';
    conf.id = id;
    conf.feature_number = 1;
    conf.latent = 0;
    conf.latent_region = 1;
    conf.randidx = 0;
    conf.datapath = '/cs/vml2/mkhodaba/data/CVPR2015/';
    conf.respath = ['/cs/vml2/mkhodaba/results/CVPR2015/VIRAT/spectral_clustering/' date '/'];
%% run kmeans    
    results = main_spectral_clustering(conf)
%% save results    
    model_name = create_model_name(conf, 'spectral');
    respath = [conf.respath  model_name '.mat'];
    if ~exist(conf.respath, 'dir'), mkdir(conf.respath); end
    save(respath, 'results');
end

