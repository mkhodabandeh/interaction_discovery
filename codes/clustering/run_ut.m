function run_ut( id )
%RUN_UT Summary of this function goes here
%   Detailed explanation goes here
for i = 1:id*10
    rand;
end
lower_bound = 0.9;
upper_bound = 1.1;
number_of_clusters = 6;
alpha_power = [-3];
initialize_weights = 0; % 1 -> yes, 0 -> initialize randomly;
database_no = 3; %  2 -> VIRAT, 3 -> UT
scene = 'ftr_set1'; % ['0000', '0001', '0102', '0401', '0502'] for VIRAT, ['ftr_set1', 'ftr_set2'] for UT;
latent = [1]; % 1 -> yeus, 0 -> no
latent_region = 1 & latent;
clustering_mode = 'Regular';
feature_number = 3; % 1 -> Distance+Velocity, 2 -> HoG/HoF, 3 -> both of them


repeat = 1;

interative_options.active = 1;
interative_options.num_iter = 3;
interative_options.num_pairs = 1;
interative_options.group_size = 1;
5
    model_name = run_mmca(database_no, lower_bound, upper_bound, ...
        number_of_clusters, alpha_power, initialize_weights, ...
        scene, latent, clustering_mode, latent_region, feature_number, ...
        interative_options, repeat, id);
    

end

