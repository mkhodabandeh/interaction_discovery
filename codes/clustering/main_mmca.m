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
%conf.rootpath = ['/cs/vml2/mkhodaba/codes/ECCV14extension/codes/clustering/'];
%respath = ['/cs/vml2/mkhodaba/results/CVPR2015/' date '/'];
switch conf.data
    case 2
        respath = ['/cs/vml2/mkhodaba/results/CVPR2015/VIRAT/' date '/'];
    case 3
        respath = ['/cs/vml2/mkhodaba/results/CVPR2015/UT/' date '/'];
    case 4
        respath = ['/cs/vml2/mkhodaba/results/CVPR2015/CollectiveActivity/' date '/'];
    case 5
        respath = ['/cs/vml2/mkhodaba/results/CVPR2015/NursingHome/' date '/'];
end

respath = [conf.respath '/' date '/'];
if ~exist(respath, 'dir'), mkdir(respath); end
modelname = conf.model_name;
%modelname = ['mmca_', num2str(conf.data), '_', num2str(conf.clsrbalL), ...
%    '_', num2str(conf.clsrbalU), '_', num2str(conf.kc), '_', num2str(conf.alpha), ...
%    '_', num2str(conf.randidx), '_', conf.scene];

auxdata.modelfile = [respath, modelname, '.mat'];
delete(auxdata.modelfile);
save(auxdata.modelfile, 'perf');
auxdata.diaryfile = [respath, '/log/', modelname, '.log'];
if ~exist([respath, '/log/'], 'dir'), mkdir([respath, '/log/']); end
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
    if conf.data == 4 || conf.data == 5
        w_init = [ones(dim - 1, conf.kc); ones(1, conf.kc)];
    else
        w_init = ones(size(w_init));
    end
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

times.cpu = cputime;
lambda = conf.alpha;
conf.nrbm.nonconvex = 0;
conf.nrbm.fpositive = 1;
auxdata.latent_data = latent_aux_data;


auxdata.user_interaction = conf.user_interaction;
auxdata.num_pairs = conf.num_pairs;
auxdata.group_size = conf.group_size;
conf.latent
if conf.latent == 1
    
    if conf.data == 3 % if database is UT
        if auxdata.user_interaction == 1
            grad_fun = @grad_lmmca_with_global_subject1_user_interaction;
            eval_fun = @eval_lmmca_with_global_subject1_user_interaction;
            user_feedback_fun = @user_feedback_old_ut;
            %user_feedback_fun = @user_feedback;
            auxdata.pairs = [];
            auxdata.groups = {};
        else
            grad_fun = @grad_lmmca_with_global_subject1;
            eval_fun = @eval_lmmca_with_global_subject1;
        end
        
    elseif conf.data == 4 || conf.data == 5 % Collective activity and Nursing home
        data = data';
        auxdata.num_data = size(data, 2);
        auxdata.num_latent = 40;
        auxdata.feature_size = size(data, 1)-1;
            if auxdata.user_interaction == 1
                grad_fun = @grad_lmmca_with_global_group_activity_user_interaction;
                eval_fun = @eval_lmmca_with_global_group_activity_user_interaction;
                user_feedback_fun = @user_feedback_old_ca;
                auxdata.pairs = [];
                auxdata.groups = {};
            else
                grad_fun = @grad_lmmca_with_global_group_activity;
                eval_fun = @eval_lmmca_with_global_group_activity;
            end
    else %VIRAT
        grad_fun = @grad_lmmca;
        eval_fun = @eval_lmmca;
        auxdata.pairs = [];
        auxdata.groups = {};
        auxdata.num_data = size(data, 1);
        auxdata.num_latent = 3;
        auxdata.global_feature_size = size(data, 2)-1;
        auxdata.latent_feature_size = size(latent_data, 2);
        user_feedback_fun = @user_feedback_old_virat_2;
    end
else
    grad_fun = @grad_mmca;
    eval_fun = @eval_mmca;
    
end
%[w, ~, ~, ~] = NRBM(w0, lambda, conf.nrbm, @grad_mmca, auxdata);

auxdata.training = 0;
[fval, ~] = grad_fun(w0, auxdata);

res = cell(conf.num_iter, 1);
num_labaled_data_history = cell(conf.num_iter, 1);
pairs_history = cell(conf.num_iter, 1);
scores_history = cell(conf.num_iter, 1);
groups_history = cell(conf.num_iter, 1);
results = {};
if fval ~= 0
    if auxdata.user_interaction == 1
        for iteration = 1:conf.num_iter
            auxdata.training = 0;
            %tic;
            [w, bestf, ~, ~] = NRBM(w0, lambda, conf.nrbm, grad_fun, auxdata);
            results = eval_fun(w, auxdata)
            %toc
            
            
            [groups, pairs, scores, num_labeled_data] = user_feedback_fun(w, auxdata);
            auxdata.training = 1;
            w0 = w;
            
            if iteration == 1 % After the first iteration we set a wider upper bound and lower bound for clusters
                if conf.data == 4
                    auxdata.clsrbalL = 0.56;
                    auxdata.clsrbalU = 1.44;
                end
            end

            
            auxdata.groups = groups;
            auxdata.pairs = pairs;
            
            

            num_labaled_data_history{iteration} = num_labeled_data;
            pairs_history{iteration} = pairs;
            groups_history{iteration} = groups;
            scores_history{iteration} = scores;
            res{iteration} = results;           
            if results.pa == 1
                break;
            end
            
        end
    else
        [w, bestf, ~, ~] = NRBM(w0, lambda, conf.nrbm, grad_fun, auxdata);
        results = eval_fun(w, auxdata)
    end
    
else
    fprintf('fval == 0');
    bestf = fval;
    w = w0;
end
times.cpu = cputime - times.cpu;
%times.tic = toc;

%results = eval_mmca(w, auxdata);
%results = eval_fun(w, auxdata);
results.bestf = bestf;
if conf.randidx == 0
    save(auxdata.modelfile, 'w', 'conf', 'results', 'res', 'times', 'scores_history', 'pairs_history', 'groups_history', 'num_labaled_data_history', '-append');
else
    save(auxdata.modelfile, 'w', 'conf', 'results', 'res', 'times', 'scores_history', 'pairs_history', 'groups_history', 'num_labaled_data_history', 'w_init', '-append');
end
