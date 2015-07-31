function [wbest, fbest, numfeval, fstart] = NRBM(w0, lambda, options, f, auxdata, freport1, freport2)
% function [wbest, fbest, numfeval, fstart] = NRBM(w0, lambda, options, f, auxdata, freport1, freport2)
%
% Non Convex Bundle Method for optimizating regularized function
%
% min_w 0.5 lambda ||w||^2 + f(w) (f is the risk R in ICML'09 papers)
%
% w0          : [1xdim] starting point
% lambda    : [1x1] double, the regularization parameter. Note: lambda > 0
% f             : non regularized objective function, takes the form f(x0, auxdata) and returns
%			      [fvalue, gradient, varargout] = f(x0, auxdata)
% options   : struct
%   maxiter : [1x1] double, maximum number of iteration
%   maxCP  : [1x1] double, maximum number of cutting plane
%   epsilon  : [1x1] double, the precision of solution %
%   positive : [1x1] 0 or 1, say if f is a positive function (f(w) > 0 forall w)
% freport1	: the function for extra reporting, save current model, estimate err, will be called when a better point is found
% freport2	: the function for extra reporting, save current model, estimate err, will be called every 10 iteration
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Guang-Tong Zhou
% Modified from Trinh Minh Tri Do's NRBM package
% April 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6
    freport1 = [];
end
if nargin < 7
    freport2 = [];
end
options = verifyoptions(options);
maxiter	= options.maxiter;
maxCP = min(options.maxCP,maxiter*2); % max number of cutting plane is maxiter
epsilon	= options.epsilon;
fpositive = options.fpositive;
computeGapQP = options.computeGapQP;
verbosity = options.verbosity;
LS = options.LS;
cuttingPlanAtOptimumDual = options.cuttingPlanAtOptimumDual;
if verbosity >= 2
    disp('BEGIN NonConvexBundle');
    disp('NonConvexBundle options:');
    disp(options);
    update_diary();
end













