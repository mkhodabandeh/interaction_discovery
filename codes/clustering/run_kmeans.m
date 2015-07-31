function results = run_kmeans( id )
%   results = run_kmeans( id )

%% settings
    conf.replicates = 10;
    conf.kc = 5;
    conf.data = 4;
    conf.scene = '0001';
    conf.id = id;
    conf.feature_number = 4;
    conf.latent = 0;
    conf.latent_region = 0;
    conf.randidx = 0;
    conf.datapath = '/cs/vml2/mkhodaba/data/CVPR2015/';
    conf.respath = ['/cs/vml2/mkhodaba/results/CVPR2015/UT/kmeans/' date '/'];
%% run kmeans    
    results = main_kmeans(conf);
%% save results    
    model_name = create_model_name(conf, 'kmeans');
    respath = [conf.respath  model_name '.mat'];
    if ~exist(conf.respath, 'dir'), mkdir(conf.respath); end
    save(respath, 'results');
end

