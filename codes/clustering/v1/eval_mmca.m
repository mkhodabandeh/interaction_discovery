function results = eval_mmca(w, auxdata)

global data;

[ni, dim] = size(data);
kc = auxdata.kc;

lsize = auxdata.clsrbalL * (ni / kc);
%usize = (2 - auxdata.clsrbalL) * (ni / kc);
usize = auxdata.clsrbalU * (ni / kc);

scores = data * reshape(w', [dim, kc]);
labels = assign_lpa(scores, lsize, usize, auxdata.mode);

results.scores = scores;
results.labels = labels;
