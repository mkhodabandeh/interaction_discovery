function [model_name] = run_mmca(DataSets, ClsrBalsL, ClsrBalsU, KCs, ...
                                 AlphaPows, RandIdx, scene, latent, ...
                                 mode, latent_region, feature_number, ...
                                 interactive_options, repeat, id, respath, datapath)

% DataSets = 2;
% ClsrBals = 0.9;
% KCs = 15;
% AlphaPows = -1;
% RandIdx = 1;

addpath(genpath('toolbox/'));

conf.rootpath = pwd;
%conf.rootpath(end - 13:end) = [];
%conf.datapath = ['/cs/vml2/mkhodaba/codes/ECCV 2014/codes/data'];
%conf.datapath = ['/cs/vml2/mkhodaba/data/CVPR2015/'];
conf.datapath = datapath;
conf.nrbm = struct('lambda', 1, ... % regularization parameter
    'maxiter', 200, ... % max number of iteration
    'maxCP', 200, ... % max number of cutting plane
    'epsilon', 0.01, ... % stop criteria gap
    'fpositive', 0, ... % f is not a positive function
    'nonconvex', 1); % non-convex NRBM
model_name = {};

for i = 1:length(DataSets)
    for j = 1:length(ClsrBalsL)
        for k = 1:length(KCs)
            for l = 1:length(AlphaPows)
                conf.data = DataSets(i);
                for m = 1:length(RandIdx)
                    for lat = 1:length(latent)
                        for r = 1:repeat
                        conf.clsrbalL = ClsrBalsL(j);
                        conf.clsrbalU = ClsrBalsU(j);
                        conf.kc = KCs(k);
                        conf.alpha = 10 .^ AlphaPows(l);
                        conf.randidx = RandIdx(m);
                        conf.scene = scene;
                        conf.latent = latent(lat);
                        conf.latent_region = latent_region;
                        conf.mode = mode;
                        conf.feature_number = feature_number;
                        conf.id = id;
                        conf.num_pairs = interactive_options.num_pairs;
                        conf.group_size = interactive_options.group_size;
                        conf.user_interaction = interactive_options.active;
                        conf.num_iter = interactive_options.num_iter;
                        if AlphaPows(l) >= 1
                            conf.nrbm.maxiter = 50;
                        end
                        conf.debug = 0;
                        conf.respath = respath;
                        conf.repeat = r;
                        conf.model_name = create_model_name(conf);
                        model_name{end+1} = conf.model_name;
                        main_mmca(conf);
                        end
                    end
                end
            end
        end
    end
end
