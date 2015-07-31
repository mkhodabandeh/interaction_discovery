function [ results ] = main_kmeans( conf )
%RUN_KMEANS Summary of this function goes here
%   Detailed explanation goes here

clearvars -global;
global data latent_data perf;
[data, latent_data, gtlabels, ~, ~] = read_data(conf);


[pdlabels, results.centers, results.sumd] = kmeans(data, conf.kc, 'replicates', conf.replicates);
results.gtlabels = gtlabels;
results.pdlabels = pdlabels;
[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
 results.nmi = measure_nmi(gtlabels, pdlabels);
 results.randindex = measure_randindex(gtlabels, pdlabels);
 
 
end

