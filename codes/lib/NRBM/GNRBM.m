function [wbest fbest numfeval fstart ] = GNRBM(w0,reg,lambda,options,f,auxdata,freport1,freport2,wreg)
%function [wbest fbest numfeval fstart] = GNRBM(w0,reg,lambda,options,f,auxdata,freport1,freport2,wreg)
%
% generalized version of Non-convex Regularized Bundle Method, using a more general regularization term
% min 0.5*lambda*((w-w0).*reg)*((w-w0).*reg)' + f(w)
%
% we introduce the new variable 
%     wn = (w-wreg).* reg 
% <=>  w =  wn ./ reg + wreg
% then f(w) = f( wn ./ reg + wreg) =fn(wn)
% minimizing (a) is equivalent to
% min 0.5*lambda*wn*wn' + fn(wn) (b)
%
% where fn(wn) = f( wn ./ reg + wreg)
% and d fn(wn) / d wn = d f( wn ./ reg + w0) / d wn = (d f(w) / d w) * ( d w / d wn ) = (d f(w) / d wn) ./ reg
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trinh Minh Tri Do
% Last revised 24 June 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dim = numel(w0);
if nargin<9
  wreg = w0;
end
wn0 = (w0 - wreg).* reg;
if isempty(freport1)
	handlefreport1 = [];
else
	handlefreport1 = @freport1new;
end
if isempty(freport2)
	handlefreport2 = [];
else
	handlefreport2 = @freport2new;
end

[wnbest fnbest numfeval fstart] = NRBM(wn0,lambda,options,@fnew,{auxdata f freport1 freport2 wreg reg},handlefreport1,handlefreport2);
wbest = wnbest ./ reg + wreg;
fbest = fnbest;

function [Remp gradwn] = fnew(wn,auxdatanew)
[auxdata f freport1 freport2 wreg reg] = deal(auxdatanew{:});
w = wn ./ reg + wreg;
[Remp gradw] = feval(f,w,auxdata);
gradwn = gradw ./ reg;

function str = freport1new(wn,auxdatanew)
[auxdata f freport1 freport2 wreg reg] = deal(auxdatanew{:});
w = wn ./ reg + wreg;
str = feval(freport1,w,auxdata);

function freport2new(wn,auxdatanew)
[auxdata f freport1 freport2 wreg reg] = deal(auxdatanew{:});
w = wn ./ reg + wreg;
feval(freport2,w,auxdata);


