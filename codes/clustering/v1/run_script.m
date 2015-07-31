%
[synthetic_data, synthetic_data_labels] = ...
generate_synthetic_data(4, 'guassian', [200 200 15 20], [[15 3]; [4 25]; [10 400]; [600 30]],[4 5 1 3]);
data_url = '../data/synthetic_data/';
save([data_url 'synthetic_data.mat'], 'synthetic_data', 'synthetic_data_labels');
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


params = [1 0.06 1.1 3 1 1];
mode = 'NonRegular';
run_mmca(params(1),params(2),params(3),params(4),params(5), params(6), mode);
params(5) = 10^params(5);
load(['../data/synthetic_data/results/mmca_' strjoin(strtrim(mat2cell(num2str(params'),[1 1 1 1 1 1])'), '_') '_' mode '.mat']);
labels1 = find(results.labels==1)
labels2 = find(results.labels==2)
labels3 = find(results.labels==3)
%labels4 = find(results.labels==4)
%labels(labels1)
%labels(labels2)
%labels(labels3)
%labels(labels4)
%labels3 = find(results.labels==3)

plot_results(synthetic_data, results.labels, w);


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