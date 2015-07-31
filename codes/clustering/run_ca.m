function run_ca(id)
% This particular function runs the clustering algorithm on data
    repeat = 10; % If repeat is set to 10 the algorithm runs 10 times with different initializations
    interactive_options.active = 1; % This should be set to 1 to active the interactive algorithm
    interactive_options.num_iter = 15; % Number of iterations (each iteration is getting feedback from user and re-clustering data)
    interactive_options.num_pairs = 5; % Number of mis-clustered points that the user is required to annotate from each cluster
    interactive_options.group_size = 1; % Number of correctly clustered points that the user is required to annotate from each cluster
    number_of_clusters = 5; % Number of clusters
    lower_bound = [0.6]; % Lower bound of each cluster is: lower_bound * (total number of data / number_of_clusters) 
    upper_bound = [1.4]; % Upper bound of each cluster is: upper_bound * (total number of data / number_of_clusters) 
    alpha_power = [2]; % 10^alpha_power is the Lambda in our clustering formulation
    database_no = 4; %  2 -> VIRAT, 3 -> UT, 4 -> Collective activity
    latent = 1; % 1 -> yes, 0 -> no
    feature_number = [4]; % 1 -> expand 2 -> don't expand, 3-> scale and expand 4-> scale but don't expand

    model_name = run_mmca(database_no, lower_bound, upper_bound, number_of_clusters, alpha_power, 0, '', latent, 'Regular', 1, feature_number, interactive_options, repeat, 1)

end

