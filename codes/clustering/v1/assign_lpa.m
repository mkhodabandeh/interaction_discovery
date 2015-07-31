function labels = assign_lpa(scores, auxdata)

global data perf;

[ni, dim] = size(data);
kc = auxdata.kc;

lsize = auxdata.clsrbalL * (ni / kc);
usize = auxdata.clsrbalU * (ni / kc);

%scores = data * reshape(w', [dim, kc]);

mode = auxdata.mode;

[n, k] = size(scores);
scores = double(scores);

%objective function coeficionts
htable = zeros(n, k);
for i = 1:k
    xi = scores + 1 - repmat(scores(:, i), [1, k]);
    xi(:, i) = 0;
    %xi(xi < 0) = 0;
    htable(:, i) = max(xi, 2);
end
C = htable(:); % y11...yn1; ...; y1k...ynk;


% constraints: sum_t (y_it) <= 1 forall i
is = repmat((1:n)', [1, k]);
is = is(:)';
A1 = sparse(is, 1:(n * k), 1, n, n * k);
B1 = ones(n, 1);
%if strcmp(mode, 'Regular')
%    ctype1 = repmat('S', [n, 1]); %sum_t (y_it) == 1
%else
    ctype1 = repmat('U', [n, 1]); %sum_t (y_it) <= 1
%end
    

% constraints: L <= sum_i (y_it) <= U forall t
is = repmat(1:k, [n, 1]);
is = is(:)';
A2 = sparse(is, 1:(n * k), 1, k, n * k);
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
A = [A1; A2];
B = [B1; B2];
ctype = [ctype1; ctype2];
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
