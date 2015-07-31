%load('/cs/vml3/avahdat/data/UT/ftr_set1.mat');
%load('/cs/vml3/avahdat/data/UT/ftr_set2.mat');

% will load the features extracted from UT interaction dataset.
% tr_data is a matrix of size n_bounding_box x 3052
% where the columns are ordered as following:
% [1:1521] : hog feature
% [1521 + 1: 1521 + 1521]: hof feature
% [3043:3052]: meta data:
%   3043: action label \in {1,2,..., 6}
%   3044: seqID \in {1,.., 10} for set1 and {11,.., 20} for set2
%   3045: frame number
%   3046: row index of top left corner of bounding box
%   3047: column index of top left corner of bounding box
%   3048: width of bounding box
%   3049: height of bounding box
%   3050: index of training interaction example \in {1,2,3,..., 60}
%   3051: scale of bounding box \in {0.8, 1} for set1 and {0.9} for set2
%   3052: track id for the interaction \in {1,2} 1 for the first subject
%   and 2 for the second subject

% 1)
% note that because of perturbation around tracks there are 9 bounding boxes
% extracted around each subject, three perturbations in x and three
% perturbations in y axes for the center of track select every 9 bounding
% boxes

% 2)
% UT videos in set 1 are captures in two different scales. Therefore
% features are extracted on two different scale around each track [0.8 1]
% however set 2 is captures in one scale, so there is only one scale for
% this set [0.9]

% 3)
% both set 1 and set 2 have 60 interaction samples each.
% the sequences 1 to 10 belongs to set1 and sequences 11 to 20 belongs to
% set2.


frame_dir = '/cs/vml/users/bog/data/frame/';
%index = 1;
seq = 10;
z = 1;
subject = 1;
a = [];
ftrLen = 3042;
for index=1:60
    %data_ind = tr_data(:, ftrLen + 8) == index & abs(tr_data(:, ftrLen + 9) - z) < 1e-3 & tr_data(:, ftrLen + 10) == subject; 
    data_ind = tr_data(:, ftrLen + 2) == seq & abs(tr_data(:, ftrLen + 9) - z) < 1e-3 & tr_data(:, ftrLen + 10) == subject; 
    a = [a;sum(data_ind)/9];
end


data = tr_data(data_ind, :);
data = data(5:9:end, :); % remove the perturbation around track
for i = 1:size(data)
    meta = data(i,ftrLen+1:end);
	img = imread(sprintf('%s%s%d%s%.3d%s',frame_dir,'seq',meta(1,2),'/frame',meta(1,3),'.png'));
	im = imcrop(img,floor([meta(1,4) meta(1,5) meta(1,6) meta(1,7)]));
	im = imresize(im,[120 80]);
    
    imshow(im);
    pause(0.01)
end




