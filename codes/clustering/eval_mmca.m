function results = eval_mmca(w, auxdata)

global data;

[ni, dim] = size(data);
kc = auxdata.kc;

auxdata.lsize = auxdata.clsrbalL * (ni / kc);
auxdata.usize = auxdata.clsrbalU * (ni / kc);

scores = data * reshape(w', [dim, kc]);
labels = assign_lpa(scores, auxdata);

results.scores = scores;
results.labels = labels;

non_zero_indx = labels ~= 0;
gtlabels = auxdata.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

[results.pa, results.pp] = measure_purity(gtlabels, pdlabels);
 results.nmi = measure_nmi(gtlabels, pdlabels);
 results.randindex = measure_randindex(gtlabels, pdlabels);