% UT set 1
%load('ut_set1_labels.mat');
%load('/cs/vml2/mkhodaba/results/CVPR2015/UT/keep/for confusion matrices/mmca_300_3_0.9_1.1_6_10_0_ftr_set1_1_1_3_0_10_1_5_1.mat')
%gtlabels = labeltr(1:60);
%pdlabels = results.labels;

% UT set 2
%load('ut_set2_labels.mat');
%load('/cs/vml2/mkhodaba/results/CVPR2015/UT/keep/for confusion matrices/mmca_300_3_0.9_1.1_6_10_0_ftr_set2_1_1_3_0_10_1_5_1.mat')
%gtlabels = labeltr(1:60);
%pdlabels = results.labels;

% CA
load('labeltr.mat');
%load('/cs/vml2/mkhodaba/results/CVPR2015/keep/collective activity/for confusion matrix/mmca_ca_8_0.6_1.4_5_1_1_1_15_5_5_1_0.01.mat')
load('/cs/vml2/mkhodaba/results/CVPR2015/VIRAT/12-Nov-2014/mmca_virat_0_0.4_1.6_5_1_1_0_10_2_8_1_1000.mat')
pdlabels = results.labels;
gtlabels = labeltr;

unigt = unique(gtlabels);
nugt = length(unigt);

unipd = unique(pdlabels);
unipd(unipd == 0) = [];
nupd = length(unipd);

% intersection
count_int = zeros(nugt, nupd);
for i = 1:nugt
    for j = 1:nupd
        count_int(i, j) = sum((gtlabels == unigt(i)) & (pdlabels == unipd(j)));
    end
end
cluster_true_labels = arrayfun(@(x) mode(gtlabels(pdlabels==x)), 1:nugt);
[~, ids] = sort(cluster_true_labels);
cluster_sizes = arrayfun(@(x) sum(gtlabels==x), 1:nugt)';
conf = count_int(:, ids);
conf = bsxfun(@rdivide, conf, cluster_sizes);
conf = conf([4 1 2 3 5], :);
%conf = conf([1 4 3 5 2], :);
%conf = rand(6,6);
figure
per_frame=0;

t=sum(conf,2);
t=repmat(t,1,size(conf,2));
conf=conf./t;
maxnum=max(conf(:));
minnum=min(conf(:));

%compute a and b
a=255/(minnum-maxnum);
b=-a*maxnum;

newconf=a*conf+b;
image(newconf);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'Position',[0.20 0.17 0.775 0.815]);

colormap(gray(256));
fontsize=18;
for i=1:size(conf,1);
   for j=1:size(conf,2)
       conf(i,j);
       numstr=sprintf('%.2f',conf(i,j));
       h=text(j,i,numstr);
       if conf(i,j)>0.5
           set(h,'Color',[1 1 1]);
       end
       set(h,'FontSize',fontsize);
       set(h,'HorizontalAlignment','center');
   end
end


%actions={'Hand-shake','Hug','Kick','Point','Punch','Push'};
%actions={'Crossing', 'Waiting', 'Queuing', 'Walking', 'Talking'};
actions={'Walk alone', 'Walk with a person', 'Interact with car', 'Stand alone', 'Talk'};
actions = actions([4 1 2 3 5]);
pos=0.4;
fontname='Helvetica';

for i=1:length(actions)
h=text(pos,i,actions{i},'FontSize',fontsize,'HorizontalAlignment','right','FontName',fontname);
end

%ut
%pos=6.8;

%ca
pos =5.8

%virat
%pos=6.8;


shift=0;
cluster_names = {'C1', 'C2', 'C3', 'C4', 'C5'};
%cluster_names = {'C1', 'C2', 'C3', 'C4', 'C5'};
for i=1:length(cluster_names)
h=text(i-shift,pos,cluster_names{i},'FontSize',fontsize,'HorizontalAlignment','left','Rotation',330,'FontName',fontname);
end