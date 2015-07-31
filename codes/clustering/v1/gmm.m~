%{
[synthetic_data, synthetic_data_labels] = ...
generate_synthetic_data(4, 'guassian', [200 200 15 20], [[15 3]; [4 25]; [10 100]; [100 30]],[4 5 1 3]);
%}
%generate_synthetic_data(3, 'guassian', [400 15 20], [[15 3]; [10 400];
%[600 30]],[9 1 3]);
%scatter(synthetic_data(:,1),synthetic_data(:,2),10,'.')
%plot_results(synthetic_data, synthetic_data_labels, []);

options = statset('Display', 'final');
obj = gmdistribution.fit(synthetic_data, 3, 'SharedCov', false, 'Options', options);


[xx,yy]=meshgrid(-30:150,-30:150);
zz = zeros(size(xx));
zz = reshape(pdf(obj, [xx(:), yy(:)]), size(xx));
pcolor(xx,yy,zz);
shading interp;
%contour(xx,yy,zz);%,[0:0.1:50]);
%figure
%h = ezcontour(@(x,y)pdf(obj,[x y]),[-15 60],[-8 60], 250);

%{
X = synthetic_data;
gm = obj;
P = posterior(gm,X);

for i = 1:3
    figure
    scatter(X(:,1),X(:,2),10,P(:,i),'+')
  %  hold on
%    scatter(X(cluster2,1),X(cluster2,2),10,P(cluster2,i),'o')
 %   scatter(X(cluster2,1),X(cluster2,2),10,P(cluster2,i),'o')
    %hold off
    legend('Cluster 1','Cluster 2','Location','NW')
    clrmap = jet(80); colormap(clrmap(9:72,:))
    ylabel(colorbar,'Component 1 Posterior Probability')
end
%}