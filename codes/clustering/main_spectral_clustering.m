function results = main_spectral_clustering( conf )
%

clearvars -global;
global data latent_data perf;
[data, latent_data, gtlabels, ~, ~] = read_data(conf);

knn = 13;
A = gen_nn_distance_output(double(data), knn, size(data, 1), 0);
conf.data = 2;
d = A(A > 0);
sigma = mean(d);
[kmindex, ~, ~, ~] = sc(A, sigma, conf.kc);
pdlabels = double(kmindex);

results.gtlabels = gtlabels;
results.pdlabels = pdlabels;
[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
results.nmi = measure_nmi(gtlabels, pdlabels);
results.randindex = measure_randindex(gtlabels, pdlabels);

end

