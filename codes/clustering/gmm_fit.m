function [ output ] = gmm_fit( data, n, rate )
%GMMFIT Summary of this function goes here
%   Detailed explanation goes here
    options = statset('Display', 'final', 'MaxIter', 500);
    replicates = 5;
    %nlogl = zeros(times,1);
    %obj = cell(times,1);
    %for i = 1:times
    %    i
    [idx, c, sumd] = kmeans(data(1:rate:end, :), n, 'replicates', replicates);
    sprintf('Kmeans Done!');
    obj = gmdistribution.fit(data, n, 'SharedCov', false, 'Options', options, 'Regularize', 1e-5, 'Start', idx);
    %obj = gmdistribution.fit(data, n, 'SharedCov', false, 'Options', options, 'Regularize', 1e-5, 'Replicates', replicates);
    %obj = gmdistribution.fit(data(1:rate:end,:), n, 'SharedCov', false, 'Options', options, 'Regularize', 1e-5, 'Replicates', replicates);
    %obj = gmdistribution.fit(data(1:rate:end,:), n, 'SharedCov', false, 'Options', options, 'Regularize', 1e-5, 'Replicates', replicates);
    
    %    nlogl(i) = obj{i}.NlogL;
    %end
    %max_nlogl = min(nlogl)
    %min_nlogl = max(nlogl)
    %[~, i] = min(nlogl);
    %obj = obj{i};
    output = posterior(obj,data);
    %save('obj.mat', 'obj');
    %{
    subplot(2,1,2);
    [xx,yy]=meshgrid(-30:170,-30:170);
    zz = zeros(size(xx));
    zz = reshape(pdf(obj, [xx(:), yy(:)]), size(xx));
    pcolor(xx,yy,zz);
    shading interp;
    %}
end

