function main_mmca(conf)

clearvars -global;
global data perf;
perf.iter = 0;


switch conf.data
    case 1 % trecvid: global
        load([conf.datapath filesep 'synthetic_data.mat']);
        %{
        load_vl_feat
        synthetic_data_expanded = vl_homkermap(synthetic_data', 10, 'KINTERS');
        synthetic_data_expanded = transpose(synthetic_data_expanded);
        unload_vl_feat
        data = single(synthetic_data_expanded);
        %}
        %
        data = single(synthetic_data);
       %}
        % data = zscore(data, 0, 1);
        
        labeltr = zeros(size(data,1), max(synthetic_data_labels));
        b = cumsum([1;size(labeltr,2)*ones(size(data,1)-1,1)]);
        labeltr = labeltr';
        labeltr(b+(synthetic_data_labels-1)) = 1;
        labeltr = labeltr';
        labels0 = initialize_labels([synthetic_data ones(size(synthetic_data,1),1)], conf.kc);
        %w = initialize_w([synthetic_data_expanded ones(size(synthetic_data_expanded,1),1)], conf.kc);
        %%w = initialize_w([data ones(size(data,1),1)], conf.kc);
        %clear synthetic_data_expanded
        clear synthetic_data synthetic_data_labels;
%
    case 2 % trecvid: tagsc
        load([conf.datapath, 'virat/YSSinteractionInfo-case3m.mat']);
        load([conf.datapath, 'virat/YSSjointDDHOG3DHists.mat']);
        load([conf.datapath, 'virat/YSSnegJointDDHOG3DHists.mat']);
        load([conf.datapath, 'virat/YSSinteractionLabels.mat']);
        negs = 20;
        myData = [interactionHists(:,1:16); n_pInteractionHists(1:negs,1:16)];
        %labeltr = [labels, ones(1, negs)*(max(labels)+1)]';
        %myData = [ n_pInteractionHists(:,1:16); interactionHists(1:negs,1:16)];
        %labels2 = [labels(327:621) labels(1:236)];
        %labeltr = labels2(1:size(myData,1))';
        labeltr = labels(1:size(myData,1))';
        save([conf.datapath, 'virat/virat.mat'], 'myData','labeltr');
        data = single(myData);
        data = zscore(data, 0, 1);
        w = initialize_w([myData ones(size(myData,1),1)], conf.kc);
        
        clear interactionHists n_pInteractionHists myData labels negs;
  
    case 3 % trecvid: global
        load([conf.datapath filesep 'synthetic_data_without_outlier.mat']);
        data = single(synthetic_data);
       % data = zscore(data, 0, 1);
        
        labeltr = zeros(size(data,1), max(synthetic_data_labels));
        b = cumsum([1;size(labeltr,2)*ones(size(data,1)-1,1)]);
        labeltr = labeltr';
        labeltr(b+(synthetic_data_labels-1)) = 1;
        labeltr = labeltr';
        w = initialize_w([synthetic_data ones(size(synthetic_data,1),1)], conf.kc);
        %w = initialize_w([data ones(size(data,1),1)], conf.kc);
       
        clear synthetic_data synthetic_data_labels;
   
    case 4
        load([conf.datapath filesep 'virat/virat_without_outlier.mat']);
        data = single(myData);
        data = zscore(data, 0, 1);
        w = initialize_w([myData ones(size(myData,1),1)], conf.kc);
        
        clear interactionHists n_pInteractionHists myData labels negs;
  
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
        clear abfeat;
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
data = [data, ones(size(data, 1), 1)];
[~, perf.labeltr] = max(labeltr, [], 2);

auxdata.kc = conf.kc;
auxdata.clsrbalL = conf.clsrbalL;
auxdata.clsrbalU = conf.clsrbalU;
auxdata.kernel = conf.kernel;

% model file
respath = [conf.datapath, '/results/'];
if ~exist(respath, 'dir'), mkdir(respath); end
modelname = ['mmca_', num2str(conf.data), '_', num2str(conf.clsrbalL), ...
    '_', num2str(conf.clsrbalU), '_', num2str(conf.kc), '_', num2str(conf.alpha), ...
    '_', num2str(conf.randidx), '_', conf.mode];

auxdata.modelfile = [respath, modelname, '.mat'];
save(auxdata.modelfile, 'perf');
auxdata.diaryfile = [respath, 'log/', modelname, '.log'];
if ~exist([respath, 'log/'], 'dir'), mkdir([respath, 'log/']); end
if exist(auxdata.diaryfile, 'file'), delete(auxdata.diaryfile); end
diary(auxdata.diaryfile);

% initialize weights
dim = size(data, 2);
if conf.randidx == 0
   % w = [ones(dim - 1, conf.kc); ones(1, conf.kc)];
    %w(1,:) = -1*w(1,:);
    %w0 = w(:)';
else
    %inimodelname = ['kmeans_', num2str(conf.data), ...
    %    '_', num2str(conf.kc), '_', num2str(conf.randidx), '_', conf.mode];
    %load([conf.datapath, 'results_imcluster/kmeans/', inimodelname, '.mat'], 'w');
    %w = initialize_w(data, conf.kc);
%    w_init = w
    %w0 = w(:)';
end
auxdata.mode = conf.mode
% NRBM training
tic;
times.cpu = cputime;
lambda = conf.alpha;
conf.nrbm.nonconvex = 0;
conf.nrbm.fpositive = 1;
%[w, ~, ~, ~] = NRBM(w0, lambda, conf.nrbm, @grad_mmca, auxdata);

[scores, labels] =  mmc_solver(labels0, lambda, conf.nrbm, auxdata);
times.cpu = cputime - times.cpu;
times.tic = toc;

%TODO
%results = eval_mmca(w, auxdata);
results = struct;
results.scores = scores;
results.labels = labels;
if conf.randidx == 0
    save(auxdata.modelfile, 'conf', 'results',  'times', '-append');
    %save(auxdata.modelfile, 'w', 'conf', 'results', 'times', '-append');
else
    save(auxdata.modelfile, 'conf', 'results', 'times', '-append');
    %save(auxdata.modelfile, 'w', 'conf', 'results', 'times', '-append', 'w_init');
end
