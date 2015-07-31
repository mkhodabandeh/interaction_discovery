function run_virat( id )

for i = 0:(id-1)*10
    rand(i);
end

repeat = 20;

interactive_options.active = 1;
interactive_options.num_iter = 10;
interactive_options.num_pairs = 2;
interactive_options.group_size = 8;


lower_bound = [0.4];%[0.9 0.88 0.86 0.7];
upper_bound = [1.6];%[1.1 1.12 1.14 1.3];
number_of_clusters = 5; %[5 10];
%alpha_power = [-4 -3 -2 -1 0 1 2 3 4];
alpha_power = [-2];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 2; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
scene = '0001'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1]; % 1 -> yeus, 0 -> no
latent_region = 1;

cluster_mode = 'Regular';
feature_number = [1]; % 1 -> expand 2 -> don't expand, 3-> scale and expand 4-> scale but don't expand
model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, initialize_weights, scene, latent, cluster_mode, latent_region, feature_number, interactive_options, repeat,id);
%}

end

