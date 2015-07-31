function plot_results(data,labels, w)
    colors = ['brkgycm'];
    kc = max(labels);
    %scolors = hsv(kc);
    figure
   %
   w
   cluster = data(find(labels==0),:);
    plot(cluster(:,1), cluster(:,2), 'y*'); 
    hold on
   for i = 1:kc
        cluster = data(find(labels==i),:);
        %plot(cluster(:,1), cluster(:,2), 'x', 'Color', colors(i,:)); 
        plot(cluster(:,1), cluster(:,2), 'x', 'Color', colors(i)); 
        hold on
    end
    
     %}
    %{
    l = floor(length(w)/kc);
    for i = 0:kc-1
        w0 = w(i*l+1:i*l+l)
        a = [-1:0.01:30];
        plot(a, (w0(1)*a+w0(3))/(-1*w0(2)), 'Color', colors(i+1,:));
        hold on
    end
    
    %}
    hold off
    
    