function main_mmca(conf)

clearvars -global;
global data latent_data perf;
perf.iter = 0;


[data, latent_data, labeltr, w_init, latent_aux_data] = read_data(conf); 
perf.labeltr = labeltr;
auxdata.labeltr = labeltr;

auxdata.kc = conf.kc;
auxdata.clsrbalL = conf.clsrbalL;
auxdata.clsrbalU = conf.clsrbalU;


% model file
%conf.rootpath = ['/cs/vml2/mkhodaba/codes/ECCV 2014/'];
conf.rootpath = ['/cs/vml3/mkhodaba/codes/ECCV14extension/codes/clustering/'];
respath = '/cs/vml3/mkhodaba/results/CVPR2015/';
if ~exist(respath, 'dir'), mkdir(respath); end
modelname = conf.model_name;
%modelname = ['mmca_', num2str(conf.data), '_', num2str(conf.clsrbalL), ...
%    '_', num2str(conf.clsrbalU), '_', num2str(conf.kc), '_', num2str(conf.alpha), ...
%    '_', num2str(conf.randidx), '_', conf.scene];

auxdata.modelfile = [respath, modelname, '.mat'];
delete(auxdata.modelfile);
save(auxdata.modelfile, 'perf');
auxdata.diaryfile = [respath, 'log/', modelname, '.log'];
if ~exist([respath, 'log/'], 'dir'), mkdir([respath, 'log/']); end
if exist(auxdata.diaryfile, 'file'), delete(auxdata.diaryfile); end
diary(auxdata.diaryfile);

% initialize weights
dim = size(data, 2);
% if conf.randidx == 0
%     if conf.latent ~= 1
%         w_init = [ones(dim - 1, conf.kc); ones(1, conf.kc)];
%     end
%     %w(1,:) = -1*w(1,:);
%     w0 = w_init(:)';
% else
%     %inimodelname = ['kmeans_', num2str(conf.data), ...
%     %    '_', num2str(conf.kc), '_', num2str(conf.randidx), '_', conf.mode];
%     %load([conf.datapath, 'results_imcluster/kmeans/', inimodelname, '.mat'], 'w');
%     %w = initialize_w(data, conf.kc);
%     w0 = w_init(:)';
% end

if conf.latent == 0
    w_init = [ones(dim - 1, conf.kc); ones(1, conf.kc)];
    w0 = w_init(:)';
else
    %conf_temp = conf;
    %conf_temp.latent = 0;
    %conf_temp.latent_region = 0;
    %model_name = create_model_name(conf_temp);
%     saved_w = load([model_name, '.mat']);
    %w0 =  ones(size(w_init(:)'));
%     w0(1:length(saved_w.w)) = saved_w.w;
    w0 = w_init(:)';
end


auxdata.mode = conf.mode;
% NRBM training
tic;
times.cpu = cputime;
lambda = conf.alpha;
conf.nrbm.nonconvex = 0;
conf.nrbm.fpositive = 1;
auxdata.latent_data = latent_aux_data;
if conf.latent == 1
    
    %grad_fun = @grad_lmmca;
    %eval_fun = @eval_lmmca;
    if conf.data == 3 % if database is UT
        %grad_fun = @grad_lmmca_with_global;
        %eval_fun = @eval_lmmca_with_global;
        
        grad_fun = @grad_lmmca_with_global_subject1;
        eval_fun = @eval_lmmca_with_global_subject1;
        
        %grad_fun = @grad_lmmca_with_global_syncronized;
        %eval_fun = @eval_lmmca_with_global_syncronized;
    elseif conf.data == 4
        data = data';
        auxdata.num_data = size(data, 2);
        auxdata.num_latent = 40;
        auxdata.feature_size = size(data, 1)-1;

        grad_fun = @grad_lmmca_with_global_group_activity;
        eval_fun = @eval_lmmca_with_global_group_activity;
    else
        grad_fun = @grad_lmmca;
        eval_fun = @eval_lmmca;
    end
else
    grad_fun = @grad_mmca;
    eval_fun = @eval_mmca;
end
%[w, ~, ~, ~] = NRBM(w0, lambda, conf.nrbm, @grad_mmca, auxdata);
[fval, ~] = grad_fun(w0, auxdata);
if fval ~= 0
        [w, bestf, ~, ~] = NRBM(w0, lambda, conf.nrbm, grad_fun, auxdata);
else
    fprintf('fval == 0');
    bestf = fval;
    w = w0;
end
times.cpu = cputime - times.cpu;
times.tic = toc;

%results = eval_mmca(w, auxdata);
results = eval_fun(w, auxdata);
results.bestf = bestf;
if conf.randidx == 0
    save(auxdata.modelfile, 'w', 'conf', 'results', 'times', '-append');
else
    save(auxdata.modelfile, 'w', 'conf', 'results', 'times', '-append', 'w_init');
end
