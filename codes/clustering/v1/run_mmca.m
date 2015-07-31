function run_mmca(DataSets, ClsrBalsL, ClsrBalsU, KCs, AlphaPows, RandIdx, mode)

% DataSets = 2;
% ClsrBals = 0.9;
% KCs = 15;
% AlphaPows = -1;
% RandIdx = 1;

addpath(genpath('toolbox/'));

conf.rootpath = pwd;
%conf.rootpath(end - 13:end) = [];
conf.datapath = ['../data/synthetic_data/'];
conf.nrbm = struct('lambda', 1, ... % regularization parameter
    'maxiter', 300, ... % max number of iteration
    'maxCP', 200, ... % max number of cutting plane
    'epsilon', 0.01, ... % stop criteria gap
    'fpositive', 0, ... % f is not a positive function
    'nonconvex', 1); % non-convex NRBM

for i = 1:length(DataSets)
    for j = 1:length(ClsrBalsL)
        for k = 1:length(KCs)
            for l = 1:length(AlphaPows)
                conf.data = DataSets(i);
                for m = 1:length(RandIdx)
                    conf.clsrbalL = ClsrBalsL(j);
                    conf.clsrbalU = ClsrBalsU(j);
                    conf.kc = KCs(k);
                    conf.alpha = 10 .^ AlphaPows(l);
                    conf.randidx = RandIdx(m);
                    conf.mode = mode;
                    conf.kernel = 2;
                    main_mmca(conf);
                end
            end
        end
    end
end
