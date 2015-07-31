function labels = assign_lpa_user_interaction(costs, auxdata, pairs, dataWeights)

%global perf;

[n, k] = size(costs);
costs = double(costs);
kc = auxdata.kc;

lsize = auxdata.lsize;
usize = auxdata.usize;

%scores = data * reshape(w', [dim, kc]);

mode = auxdata.mode;

%{
htable = zeros(n, k);
for i = 1:k
    xi = costs + 1 - repmat(costs(:, i), [1, k]);
    xi(:, i) = 0;
    xi(xi < 0) = 0;
    htable(:, i) = sum(xi, 2);
end
C = htable(:); % y11...yn1; ...; y1k...ynk;
%}
C = costs(:);

% constraints: sum_t (y_it) <= 1 forall i
is = repmat((1:n)', [1, k]);
is = is(:)';
A1 = sparse(is, 1:(n * k), 1, n, n * k);
B1 = ones(n, 1);
if strcmp(mode, 'Regular')
    ctype1 = repmat('S', [n, 1]); %sum_t (y_it) == 1
else
    ctype1 = repmat('U', [n, 1]); %sum_t (y_it) <= 1
end
    

% constraints: y_it + y_jt <= 1 forall t and i,j in pairs
A3 = [];
B3 = [];
ctype3 = [];
if ~isempty(pairs)
    nPairs = size(pairs, 1);
    pairs1 = pairs(:, 1);
    is = [1:nPairs*k];
    temp_mat = repmat([0:k-1].*n, nPairs, 1);
    pairs1Idx = bsxfun(@plus, pairs1, temp_mat);
    pairs1Idx = pairs1Idx(:)';
    pairs2 = pairs(:, 2);
    pairs2Idx = bsxfun(@plus, pairs2, temp_mat);
    pairs2Idx = pairs2Idx(:)';
    A3 = sparse([is,is], [pairs1Idx, pairs2Idx], 1, nPairs*k, n* k);
    B3 = ones(nPairs*k, 1);
    ctype3 = repmat('U', nPairs*k, 1);
end

% constraints: L <= sum_i (y_it) <= U forall t
is = repmat(1:k, [n, 1]);
is = is(:)';
weights = repmat(dataWeights, [k, 1])';
weights = weights(:)';
A2 = sparse(is, 1:(n * k), weights, k, n * k);
A2 = [A2; A2];

lsize = round(lsize);
%lsize2 = round(lsize2);
usize = round(usize);
B2 = [lsize * ones(k, 1); usize * ones(k, 1)];
%B2 = [lsize * ones(k-1, 1); round(lsize*0.06/0.06) * ones(1,1) ; ;usize * ones(k, 1)];
ctype2 = [repmat('L', [k, 1]); repmat('U', [k, 1])];

% constraints: n-L <= sum_i sum_t (y_it)
% equivalet to: sum_i (1 - sum_t (y_it)) <= L
% number of non-labeled samples are limited to L
%A3 = ones(1, n*k);
%B3 = (n-lsize) * ones( n*k, 1);
%ctype3 = repmat('L', [n*k, 1]);

% glpk input
%A = [A1; A2; A3];
%B = [B1; B2; B3];
%ctype = [ctype1; ctype2; ctype3];

%
if isempty(pairs)
    A = [A1; A2];
    B = [B1; B2];
    ctype = [ctype1; ctype2];
else
    A = [A1; A2; A3];
    B = [B1; B2; B3];
    ctype = [ctype1; ctype2; ctype3];
end
%}

clear A1 A2;

lb = zeros(n * k, 1);
ub = ones(n * k, 1);

vartype = repmat('B', n * k, 1);
sense = 1;
param.msglev = 0;
param.itlim = -1;

% tic;
[xopt, f, s, e] = glpkcc(C, A, B, lb, ub, ctype, vartype, sense, param);
% toc

xopt = reshape(xopt, [n, k]);
[mx, labels] = max(xopt, [], 2);
labels(mx == 0) = 0;