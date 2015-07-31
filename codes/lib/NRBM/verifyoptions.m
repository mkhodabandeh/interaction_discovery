function options_out = verifyoptions(options)

options_out = options;
if ~(isfield(options_out, 'maxiter'))
    options_out.maxiter = 1000;
end
if ~(isfield(options_out, 'maxCP'))
    options_out.maxCP = 1000;
end
if ~(isfield(options_out, 'epsilon'))
    options_out.epsilon = 0.01;
end
if ~(isfield(options_out, 'fpositive'))
    options_out.fpositive = 1;
end
if ~(isfield(options_out, 'computeGapQP'))
    options_out.computeGapQP = 1;
end
if ~(isfield(options_out, 'verbosity'))
    options_out.verbosity = 0;
end
if ~(isfield(options_out, 'LS'))
    options_out.LS = 1;
end
if ~(isfield(options_out, 'nonconvex'))
    options_out.nonconvex=1;
end
if ~(isfield(options_out, 'cuttingPlanAtOptimumDual'))
    options_out.cuttingPlanAtOptimumDual = 0; % put 1 to guarantee the progess of dual
end
if ~(isfield(options_out, 'solver'))
    listSolver = {'mdm', 'imdm', 'iimdm', 'kozinec', 'keerthi', 'kowalczyk'};
    options_out.solver = listSolver{6};
    % imdm is the default solver of gmnp, but it fail sometime.
    % For instance: Q = 1e+3 * [0.0053, -0.0728; -0.0728, 1.0000]; B = 1e-6 * [0.0707; 0.2621];
end
