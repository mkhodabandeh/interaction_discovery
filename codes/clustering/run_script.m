startup
%{
[synthetic_data, synthetic_data_labels] = ...
generate_synthetic_data(4, 'guassian', [200 200 15 20], [[15 3]; [4 25]; [1 150]; [150 30]],[4 5 1 3]);
save('dataset_imcluster/synthetic_data', 'synthetic_data', 'synthetic_data_labels');
%}
%{
[synthetic_data, synthetic_data_labels] = ...
    generate_synthetic_data(2, 'guassian', [50 500], [[1 20]; [20 20];],[1.5 2]);
save('dataset_imcluster/synthetic_data', 'synthetic_data', 'synthetic_data_labels');
%}

%{
params = [1 0.9 1.1 3 1 1];
mode = 'Regular';
run_mmca(params(1),params(2),params(3),params(4),params(5), params(6), mode);
params(5) = 10^params(5);
load(['dataset_imcluster/results_imcluster/mmca/mmca_' strjoin(strtrim(mat2cell(num2str(params'),[1 1 1 1 1 1])'), '_') '_' mode '.mat']);
load(['dataset_imcluster/synthetic_data.mat']);
%plot_results(synthetic_data, results.labels, w);
labeltr = synthetic_data_labels;
[pa1,pp1,~] = measure_purity(labeltr, results.labels);
[pa_un1,~] = measure_purity_unbalance(labeltr, results.labels);
nmi1 = measure_nmi(labeltr, results.labels);
nmi_pami1 = measure_nmi_pami(labeltr, results.labels);
nmi_multiclass1 = measure_nmi_multiclass(labeltr, results.labels);
%}
 

%dataset lower_bound upper_bound number_of_clusters alpha(C) initalization
%{
id = 300;
lower_bound = 0.90;
upper_bound = 1.10;
number_of_clusters = 6;
alpha_power = [1];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 3; %  2 -> VIRAT, 3 -> UT
scene = 'ftr_set1'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1]; % 1 -> yeus, 0 -> no
latent_region = 1 & latent;
clustering_mode = 'Regular';
feature_number = 3; % 1 -> Distance+Velocity, 2 -> HoG/HoF, 3 -> both of them
%alpha : 10 ^ alpha_power;
%}


%
%dataset lower_bound upper_bound number_of_clusters alpha(C) initalization
%{
lower_bound = 0.16;
upper_bound = 1.1;
number_of_clusters = 4;
alpha_power = 2;
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 2; %  2 -> VIRAT, 3 -> UT
scene = '0401'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = 1; % 1 -> yeus, 0 -> no
latent_region = 1 & latent;
mode = 'NonRegular';
feature_number = 3; % 1 -> Distance+Velocity, 2 -> HoG/HoF, 3 -> both of them
%alpha : 10 ^ alpha_power;
%}

 


%
%params = [database_no lower_bound upper_bound number_of_clusters alpha_power initialize_weights, latent];
%mode = 'NonRegular';


%{
repeat = 1;

interative_options.active = 0;
interative_options.num_iter = 10;
interative_options.num_pairs = 1;
interative_options.group_size = 5;

%h = figure;

fval = 0;
clear data global_data perf;
%%while fval == 0

    model_name = run_mmca(database_no, lower_bound, upper_bound, ...
        number_of_clusters, alpha_power, initialize_weights, ...
        scene, latent, clustering_mode, latent_region, feature_number, ...
        interative_options, repeat, id);
 
    %}
  %{  
    
    clear results perf;
    final_results = struct;
%     true_labels = obj.larger_tracklet_interaction_type(1:2:end);
    if database_no == 2
        load([model_name{1} '.mat']);
        break;
    end
    for j = 1:length(model_name)
        load([model_name{j} '.mat']);
        clear labels;
        %
        clear ground_truth_labels
        for i = 1:params(4)
            labels{i} = find(results.labels==i);
            %if latent == 1
            %ls = results.latent_variables(labels{i}, i);

            %ground_truth_labels{i} = true_labels(labels{i});

        end
        %
        labels = labels';
        %ground_truth_labels = ground_truth_labels';
        fval = results.bestf
        results;
%        final_results.labels{j} = ground_truth_labels;
        final_results.pa(j) = results.pa;
        final_results.pp(j) = results.pp;
        final_results.nmi(j) = results.nmi;
        final_results.randindex(j) = results.randindex;
        final_results.bestf(j) = results.bestf;
        final_results.labels{j} = results.labels;
        %final_results.latent_variables(j) = results.global_latent_var_assignments;
        
    end
    [~, index] = max(final_results.pa);
    results = struct;
    j = index;
%    results.labels = final_results.labels{j};
    results.pa = final_results.pa(j);
    results.pp = final_results.pp(j);
    results.nmi = final_results.nmi(j);
    results.randindex = final_results.randindex(j);
    results.bestf = final_results.bestf(j);
    results.labels = final_results.labels(j);
    
    results
    
    alpha_power(index)
   
%}    
%end
%labels4 = find(results.labels==4)
%labels(labels1)
%labels(labels2)
%labels(labels3)
%labels(labels4)
%labels3 = find(results.labels==3)

%subplot(2,1,1);
%plot_results(synthetic_data, results.labels, w);
%axesHandles = findobj(get(h,'Children'), 'flat','Type','axes');
%axis(axesHandles,'square')

%{
synthetic_data = synthetic_data(results.labels==0, :);
synthetic_data_labels = synthetic_data_labels(results.labels==0);
save('dataset_imcluster/synthetic_data_without_outlier.mat', 'synthetic_data', 'synthetic_data_labels');
params = [3 0.9 1.1 2 1 1];
mode = 'Regular';
run_mmca(params(1),params(2),params(3),params(4),params(5), params(6), mode);
params(5) = 10^params(5);
load(['dataset_imcluster/results_imcluster/mmca/mmca_' strjoin(strtrim(mat2cell(num2str(params'),[1 1 1 1 1 1])'), '_') '_' mode '.mat']);
labeltr = synthetic_data_labels;
[pa1,pp1,~] = measure_purity(labeltr, results.labels);
[pa_un1,~] = measure_purity_unbalance(labeltr, results.labels);
nmi1 = measure_nmi(labeltr, results.labels);
nmi_pami1 = measure_nmi_pami(labeltr, results.labels);
nmi_multiclass1 = measure_nmi_multiclass(labeltr, results.labels);

%}
%plot_results(synthetic_data, results.labels, w);


%{
lower_bound = [0.6 0.75 0.77 0.65 0.68];%[0.9 0.88 0.86 0.7];
upper_bound = [1.4 1.25 1.23 1.35 1.32];%[1.1 1.12 1.14 1.3];
number_of_clusters = 5; %[5 10];
alpha_power = [-3 -2 -1 0 1 -4];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 4; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
scene = '0401'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1 0]; % 1 -> yeus, 0 -> no
latent_region = 1;

mode = 'Regular';
feature_number = 3; % 1 -> Distance+Velocity, 2 -> HoG/HoF, 3 -> both of them
model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, initialize_weights, scene, latent, mode, latent_region, feature_number);
load(['/cs/vml3/mkhodaba/results/CVPR2015/' model_name{1} '.mat'])
results
%}

%% Collective Activity
%{
repeat = 1;

interactive_options.active = 1;
interactive_options.num_iter = 20;
interactive_options.num_pairs = 4;
interactive_options.group_size = 4;


lower_bound = [0.6];%[0.9 0.88 0.86 0.7];
upper_bound = [1.4];%[1.1 1.12 1.14 1.3];
number_of_clusters = 5; %[5 10];
alpha_power = [1];
%alpha_power = [1];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 4; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
scene = '0401'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1]; % 1 -> yeus, 0 -> no
latent_region = 1;
id = 1;
mode = 'Regular';
feature_number = [1]; % 1 -> expand 2 -> don't expand, 3-> scale and expand 4-> scale but don't expand
model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, initialize_weights, scene, latent, mode, latent_region, feature_number, interactive_options, repeat,id);
%}

%% NURSING HOME (never acutally used) :)
%{ 
repeat = 1;

interactive_options.active = 0;
interactive_options.num_iter = 20;
interactive_options.num_pairs = 4;
interactive_options.group_size = 4;


lower_bound = [0.5];%[0.9 0.88 0.86 0.7];
upper_bound = [1.5];%[1.1 1.12 1.14 1.3];
number_of_clusters = 4; %[5 10];
alpha_power = [1];
%alpha_power = [1];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 5; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
scene = 'nurse'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [0]; % 1 -> yeus, 0 -> no
latent_region = 1;
id = 1;
cluster_mode = 'Regular';
feature_number = [2]; % 1 -> expand 2 -> don't expand, 3-> scale and expand 4-> scale but don't expand
model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, initialize_weights, scene, latent, cluster_mode, latent_region, feature_number, interactive_options, repeat,id);
%}

%% VIRAT
%
repeat = 1;
id = 10;

interactive_options.active = 1;
interactive_options.num_iter = 5;
interactive_options.num_pairs = 2;
interactive_options.group_size = 8;


lower_bound = [0.35];%[0.9 0.88 0.86 0.7];
upper_bound = [1.35];%[1.1 1.12 1.14 1.3];
number_of_clusters = 5; %[5 10];
alpha_power = [3];
%alpha_power = [-4 -3 -2 -1 0 1 2 3 4];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 2; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
scene = '0001'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1]; % 1 -> yeus, 0 -> no
latent_region = 1;

cluster_mode = 'Regular';
feature_number = [1]; % 1 -> expand 2 -> don't expand, 3-> scale and expand 4-> scale but don't expand
model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, initialize_weights, scene, latent, cluster_mode, latent_region, feature_number, interactive_options, repeat,id);
%}