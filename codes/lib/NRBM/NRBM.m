function [wbest fbest numfeval fstart] = NRBM(w0,lambda,options,f,auxdata,freport1,freport2)
%function [wbest fbest numfeval fstart] = NRBM(w0,lambda,options,f,auxdata,freport1,freport2)
%
% Non-convex Regularized Bundle Method for solving the unconstrained problem
% min_w 0.5 lambda ||w||^2 + f(w)
%
% (here f is the risk R in our papers !!)
%
% [wbest fbest numfeval fstart] = NCB(w0,lambda,options,f,auxdata,freport1,freport2)
% Non Convex Bundle Method for optimizating regularized function
% w0		: [1xdim] starting point
% lambda	: [1x1] double , the regularization parameter. attention lambda>0
% f     	: non regularized objective function, takes the form f(x0, auxdata) and returns
%			[fvalue, gradient, varargout] = f(x0, auxdata)
% options	: struct
%	maxiter : [1x1] double , maximum number of iteration
%	maxCP	: [1x1] double , maximum number of cutting plane
%	epsilon	: [1x1] double , the precision of solution %
%	positive: [1x1] 0 or 1 , say if f is positive function (f(w)>0 forall w)
% freport1	: the function for extra reporting, save current model, estimate err, will be called when a better point is found
% freport2	: the function for extra reporting, save current model, estimate err, will be called every 10 iteration
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trinh Minh Tri Do
% Last revised 24 June 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if nargin<6
		freport1=[];
	end
	if nargin<7
		freport2=[];
	end
	options		= verifyoptions(options);
	maxiter		= options.maxiter;
	maxCP		= min(options.maxCP,maxiter*2); % max number of cutting plane is maxiter
	epsilon		= options.epsilon;
	fpositive	= options.fpositive;
	computeGapQP	= options.computeGapQP;
	verbosity	= options.verbosity;
	LS		= options.LS;
	cuttingPlanAtOptimumDual = options.cuttingPlanAtOptimumDual;
	if verbosity>=2
		disp('BEGIN NonConvexBundle');
		disp('NonConvexBundle options:');
		disp(options);
		update_diary();	
	end

	listw = w0;
	dimW     = size(w0,2);
	if verbosity>=2
		disp(sprintf('NonConvexBundle::dimW=%d',dimW));
	end
	wbest    = zeros(1,dimW);
	gVec     = zeros(maxCP,dimW);		% set of gradient
	wVec	 = zeros(maxCP,dimW);
	bias     = zeros(maxCP,1);
	Q        = zeros(maxCP,maxCP);		% precompute gVec*gVec'
	inactive = ones(maxCP,1) * maxCP;	% number of consecutive iteration that the cutting plane is inactive (alpha=0);
	cp_ite   = ones(maxCP,1); 		% the iteration where cp is built
	cp_ite(maxCP) = 0;
	alpha    = zeros(maxCP,1); 		% lagrangian multipliers

	s	 = 0;
	distCum	 = zeros(maxCP,1);	% Cumulate distance 
	sumdist = 0;
	w        = w0;			% current solution
	fbest = inf; Rbest = inf;tbest=1;jbest=1;dual = -inf;
	strbest = '';

	wolfe = struct(...
                'a1', 0.5000,...
                'a0', 0.0100,...
                'c1', 1.0000e-04,...
                'c2', 0.9000,...
                'maxiter', 5,...
                'amax', 1.1000);

	newW     = zeros(wolfe.maxiter,dimW);
	newGrad  = zeros(wolfe.maxiter,dimW);
	newF     = zeros(wolfe.maxiter,1);

	[newF(1),newGrad(1,:)] = FGgrad_objective(w0,  {auxdata f lambda},verbosity);
	fstart = newF(1);
	newW(1,:) = w0;
	nbNew     = 1; % one cutting plane to be add in next iteration
	astar     = wolfe.a0;
	numfeval=1;
	gap = inf;

	for t=1:maxiter
		% find memory slots of new cutting planes
		listCPold = find(inactive<maxCP);
		[v,idx] = sort(inactive*maxiter*2 + cp_ite,'descend'); % sort by num of inactive, then by iteration number
		listCPnew = idx(1:nbNew);

		listCPold = setdiff(listCPold,listCPnew); % performance ?
		inactive(listCPnew) = 0;
		cp_ite(listCPnew) = t;
		listCP = find(inactive<maxCP);
		% =====================================
		% precompute Q for new cutting planes
		% =====================================
		gVec(listCPnew,:) = newGrad(1:nbNew,:) - lambda*newW(1:nbNew,:);
		Q(:,listCPnew) = gVec* gVec(listCPnew,:)';
		Q(listCPnew,:) = Q(:,listCPnew)';

		% ===============================================================================================
		% precompute Q for aggregation cutting plane, this code could be optimized by working only on Q
		% ===============================================================================================
		Q(:,maxCP) = gVec* gVec(maxCP,:)';
		Q(maxCP,:) = Q(:,maxCP)';

		wbestold = wbest;

		for k=1:nbNew
			reg  = 0.5*lambda*newW(k,:)*newW(k,:)';
			Remp = newF(k) - reg;
			j = listCPnew(k);
			bias(j) = Remp - gVec(j,:) * newW(k,:)';
			wVec(j,:) = newW(k,:);
			fcurrent = newF(k);
			if verbosity>=2
				disp(sprintf('NonConvexBundle::t=%d k=%d j=%d fcurrent=%e reg=%e Remp=%e',t,k,j,fcurrent,reg,Remp));
			end
			distCum(j) = (wbest - newW(k,:))*(wbest - newW(k,:))';
			if(fbest > fcurrent)
				fbest	= fcurrent;
				Rbest   = Remp;
				wbest	= newW(k,:);
				tbest	= t;
				jbest	= j;
				dist = (wbest - wbestold)*(wbest - wbestold)';
				sumdist = sumdist+dist;
				if verbosity>0
				    disp(sprintf('norm wbest=%g dist=%g sumdist=%g',norm(wbest),dist,sumdist));
				end
				distCum = distCum + dist;
				distCum(j) = 0;
			end

			if options.nonconvex
				% solving conflict
				if (jbest==j) % descent step
					list = [listCPold;listCPnew(1:k-1)];
					if 0
					if ~isempty(list)
						score = gVec(list,:)*wbest' + bias(list);
						gamma = max(0, dual - fbest + 0.5 * lambda * distCum(maxCP));
						if gamma>0
							disp(sprintf('NCO::DESCENT STEP Conflict dist_aggregation=%g gamma=%g',distCum(maxCP),gamma));
							bias(list) = bias(list)-gamma;
						end
					end
					else
						for i=list'
							score = 0.5*lambda*wbest*wbest' + gVec(i,:)*wbest' + bias(i);
							gamma = max(0, score - fbest + 0.5 * lambda * distCum(i));
							bias(i) = bias(i)-gamma;
						end
					end
				else % null step
					% estimate g_t at w_tbest
					dist = distCum(j);
					score = 0.5*lambda*dist + gVec(j,:)*wbest' + bias(j);
					if (score > Rbest) % conflict
						% trying to solve conflict by descent g_t so that g_t(w_t) = fbest
						U = Rbest - 0.5*lambda*dist - gVec(j,:)*wbest';
						L = fbest - reg - gVec(j,:)*newW(k,:)';
                                	        disp(sprintf('NCO::NULL STEP CONFLICT Rbest=%g score=%g L=%g U=%g dist=%g',Rbest,score,L,U,dist));
						if (L<=U)
							disp('NCO::NULL STEP CONFLICT LEVEL 1');
							bias(j) = L; 
						else
							disp('NCO::NULL STEP CONFLICT LEVEL 2');
							gVec(j,:) = - lambda * wbest;
							bias(j) = fbest - (reg + gVec(j,:)*newW(k,:)');
							Q(:,j) = gVec* gVec(j,:)';
							Q(j,:) = Q(:,j)';
						end
        	                                score = 0.5*lambda*dist + gVec(j,:)*wbest' + bias(j);
						disp(sprintf('new score=%g',score));
					end
				end
			end
		end

		%===========================================
		% Solving QP program
		%===========================================
		t1=cputime;
%		if verbosity>=2	disp('==NCO== Solving QP...');update_diary();end
		[alpha(listCP),dual] = minimize_QP(lambda,Q(listCP,listCP),bias(listCP),fpositive,epsilon);
%		if verbosity>=2	disp(sprintf('==NCO== Done QP . time QP=%.2f',cputime-t1));update_diary();end
	
		%===========================================
		% get QP program solution
		%===========================================
		% update w and counting inactive
		listA = find(alpha(listCP)>0);
		listI = find(alpha(listCP)==0);
		w = wsum_col(gVec,-alpha(listCP(listA))/lambda,listCP(listA));
		inactive(listCP(listA)) = 0;
		inactive(listCP(listI)) = inactive(listCP(listI)) + 1;
		if 0
			w = zeros(1,dimW);
			for i=listCP'
				if(alpha(i)>0)
					w = w - gVec(i,:)*alpha(i) / lambda;
					inactive(i)=0;
				else
					inactive(i)=inactive(i)+1;
				end
			end
		end

		inactive(jbest)=0; % make sure that the best point is always in the set
		%=====================================
		% gradient aggregation
		%=====================================
		gVec(maxCP,:) = - lambda * w;
		bias(maxCP) = dual + 0.5 * lambda * w*w';
		distCum(maxCP) = alpha(listCP)' * distCum(listCP);
		inactive(maxCP)=0; % make sure that aggregation cp is always active

		%===============================================
		% estimate the gap of approximated dual problem
		%===============================================
		if computeGapQP
			score = gVec * w' + bias;
			if (fpositive)
				primal = 0.5*lambda*w*w' + max( [score(listCP);0]);
			else
				primal = 0.5*lambda*w*w' + max(score(listCP));
			end
			gapQP = primal - dual;
			if verbosity>=1
				disp(sprintf('NCBlight::quadratic programming : primal = %e dual=%e gap=%.2f%%',primal,dual,gapQP*100.0/(abs(primal))));
			end
			if (gapQP<-1e-6)||(gapQP > epsilon*abs(primal))
%				disp(sprintf('gapQP = %e',gapQP));keyboard;
			end
		end
		if verbosity>=2
			disp(sprintf('NonConvexBundle::Time QP and update = %.2f seconds',cputime-t1));
		end
		gap_old = gap;
		gap   = fbest-dual;
		if (gap_old<gap)||(gap<0)
%			disp(sprintf('gap %e -> %e',gap_old,gap));keyboard;
		end
		if(tbest==t)
			if(~isempty(freport1))
				strbest = feval(freport1, wbest, auxdata);
			end
		elseif (mod(t,10)==0)
			if(~isempty(freport2))
				feval(freport2, w, auxdata);
			end
		end
		if verbosity>=2
			disp(sprintf('NCBlight::t=%d nfeval=%d f=%e fbest=%e Rbest=%e tbest=%d dual=%e gap=%g =%.5f%%\n===== (%s) ===========',t,numfeval,fcurrent,fbest,Rbest,tbest,dual,gap,gap*100/abs(fbest),strbest));
			update_diary();
		end
		if ((gap/abs(fbest) < epsilon)||(gap<1e-6)||(t>=maxiter))
			break;
		end
		if (~options.LS)
			nbNew = 1;
			[newF(1) newGrad(1,:)] = FGgrad_objective(w,  {auxdata f lambda},verbosity);
			newW(1,:)    = w;
			numfeval = numfeval + 1;
			continue;
		end		

		% doing line search from wbest to w
		search_direction = w-wbest; norm_dir = norm(search_direction);
		if (cuttingPlanAtOptimumDual) || (t==1)
			astar = 1.0;
		else
			astar = min(astar / norm_dir,1.0);
			if astar==0	astar = 1.0;end
		end
%		[astar xstar fstar gstar x1 f1 g1 varargout] = myLineSearchWolfe(x0, f0, g0, s0, a1, amax, c1, c2, maxiter, f, varargin)
		[astar wLineSearch fLineSearch gLineSearch w1 f1 g1 nfeval] = myLineSearchWolfe(wbest, fbest, gVec(jbest,:)+lambda*wbest, search_direction, astar, wolfe.amax, wolfe.c1, wolfe.c2, wolfe.maxiter, @FGgrad_objective, {auxdata f lambda});
		numfeval = numfeval + nfeval;
		if f1~=fLineSearch
			nbNew = 2;
			newF(1:2)      = [f1;fLineSearch];
			newW(1:2,:)    = [w1;wLineSearch];
			newGrad(1:2,:) = [g1;gLineSearch];
		else
			nbNew = 1;
			newF(1)      = fLineSearch;
			newW(1,:)    = wLineSearch;
			newGrad(1,:) = gLineSearch;
		end
		astar = astar*norm_dir; % true step length
		if verbosity>=2	disp(sprintf('NonConvexBundle::step length=%e',astar));update_diary();	end
	end
	if verbosity>=1
		disp(sprintf('DONE NonConvexBundle numfeval=%d',numfeval));update_diary();
	end

%====================================================================
function options_out = verifyoptions(options)
	options_out=options;
	if ~(isfield(options_out,'maxiter'))
		options_out.maxiter = 1000;
	end
	if ~(isfield(options_out,'maxCP'))
		options_out.maxCP = 1000;
	end
	if ~(isfield(options_out,'epsilon'))
		options_out.epsilon = 0.01;
	end
	if ~(isfield(options_out,'fpositive'))
		options_out.fpositive = 1;
	end
	if ~(isfield(options_out,'computeGapQP'))
		options_out.computeGapQP = 1;
	end
	if ~(isfield(options_out,'verbosity'))
		options_out.verbosity = 0;
	end
	if ~(isfield(options_out,'LS'))
		options_out.LS = 1;
	end
	if ~(isfield(options_out,'nonconvex'))
		options_out.nonconvex=1;
	end
	if ~(isfield(options_out,'cuttingPlanAtOptimumDual'))
		options_out.cuttingPlanAtOptimumDual = 0; % put 1 to guarantee the progess of dual
	end
	if ~(isfield(options_out,'solver')) 
		listSolver = {'mdm' 'imdm' 'iimdm' 'kozinec' 'keerthi' 'kowalczyk'};
		options_out.solver = listSolver{6};
		% imdm is the default solver of gmnp, but it fail sometime. For instance:  Q = 1e+3* [0.0053, -0.0728;  -0.0728 ,   1.0000]; B=1e-6 * [0.0707;0.2621];
	end

%====================================================================
function [alpha,dual] = minimize_QP(lambda,Q,B,fpositive,EPS,verbosity)
        if nargin<6
	    verbosity=0;
	end
	
	T = size(Q,1);
	if (T+fpositive)==1
		alpha = 1;
		dual = -0.5 * Q / lambda + B;
		return;
	end
	if (fpositive)
		B = [B;0];
		Q = [[Q,zeros(T,1)];zeros(1,T+1)];
	end
	SCALE = abs(max(max(abs(Q)))) / (1000.0 * lambda);
	Q = Q / SCALE;
	B = B / SCALE;
%        listSolver = {'imdm' 'kowalczyk' 'kozinec' 'keerthi'};% 'kozinec' 'keerthi' 'mdm'};
%        listSolver = {'imdm' 'kowalczyk' 'iimdm' 'kozinec' 'keerthi'};% 'kozinec' 'keerthi' 'mdm'};
        listSolver = {'libqp' 'imdm' 'kowalczyk' 'keerthi'};% 'kozinec' 'keerthi' 'mdm'};
	for k=6:10
                if (T>1)&&(~fpositive)&&(0)
        	        [alpha,dual,stat] = myquadprog(Q/lambda,-B',alpha0,10^k,0,1e-1*EPS,-inf,0);
       			if stat<10^k
			    if verbosity>0
				disp(sprintf('solver=%s maxiter=%e stat=%d','myquadprob',10^k,stat));
			    end
				stat = struct('exitflag',stat);
        		        break;
			end
	 	end
		for j=1:numel(listSolver)
			t0= cputime;
			if strcmpi(listSolver{j},'libqp')
				opt = struct('MaxIter',10^k,'TolRel',1e-2*EPS);
				[alpha,stat] = libqp_splx(Q/lambda,-B,1,ones(1,numel(B)),0,[],opt);
				dual = stat.QP;
				niter = stat.nIter;
			else
				[alpha,dual,stat] = gmnp(Q/lambda,-B',{'solver',listSolver{j},'tmax',10^k,'tolrel',1e-2*EPS});
                                niter = stat.t;
			end
			if verbosity>0
			    disp(sprintf('solver %s k=%d time=%.1fs stat.exitflag=%d niter=%d',listSolver{j},k,cputime-t0,stat.exitflag,niter));
			end
			% ======================================================
			% verify the solution of approximated dual problem
			% because gmnp returns invalid solution sometime
			% ======================================================
			eps = 1e-4;
			if (min(alpha)<-eps)||(abs(sum(alpha)-1)>eps)
				stat.exitflag = 0;
%				keyboard;
			end;
			if stat.exitflag>0
			    if verbosity>0
				disp(sprintf('solver=%s maxiter=%e',listSolver{j},10^k));
			    end
				break;
			end
		end
		if stat.exitflag~=0
			break;
		end
	end
	if stat.exitflag==0
		disp('WARNING Solving QP problem failled, do not reach enough accuracy !!!');
	end
	B = B * SCALE;
	dual = -dual*SCALE;
	if (fpositive)
		alpha = alpha(1:T);
	end

%====================================================================
function [fval grad tt] = FGgrad_objective(w, auxdata_f_lambda,verbosity)
    if nargin<3
	    verbosity=0;
	end
	
	[auxdata f lambda] = deal(auxdata_f_lambda{:});
	[fval grad] = feval(f,w,auxdata);
	reg = 0.5 * lambda * (w*w');
	fval = fval + reg;
    grad = grad + lambda * w;
    
    save(auxdata.modelfile, 'w', '-append');
    %% DETAILS MEHRAN
    %disp(sprintf('function evaluation fval=%g |w|=%g |grad|=%g',fval,norm(w),norm(grad)));
    update_diary();
	
    tt = [];
