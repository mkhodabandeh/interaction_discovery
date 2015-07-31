 %% Pre process data
settings;
%{


load([data_address vid_name '.mat']);
z = 0.9;
table = tr_data(:, 3043:3054);
table_inds = abs(table(:, 9) - z) < 1e-3 & table(:,12) == 5;
table = table(table_inds, [8 1 3 4 5 6 7 10 2]);
table(:,[4:7]) = table(:,[4:7]); %TODO
hoghof = tr_data(table_inds,1:3042);
mkdir(table_address);
save([table_address vid_name '_small.mat'], 'table');
save([table_address vid_name '_small_hoghof.mat'], 'hoghof');
%}

%% Fit GMM to HoG and HoF features

file_address = [data_address filesep  vid_name '.mat'];
load([table_address vid_name '_small_hoghof.mat']);
load([table_address vid_name '_small.mat']);

load(file_address);

gmm_hoghof_data = gmm_fit(hoghof, hog_hof_number_of_centers, 3);
save([table_address vid_name '_small_hoghof_gmm_3_' num2str(hog_hof_number_of_centers) '.mat'], 'gmm_hoghof_data');

