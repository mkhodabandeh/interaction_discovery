function [ w ] = initialize_w( data, k )
%INTIALIZE_W Summary of this function goes here
%   Detailed explanation goes here
    %[idx, c, sumd] = kmeans(data, k, 'emptyaction', 'singleton', 'replicates', 50);
    %save('/cs/vml2/mkhodaba/codes/ECCV 2014/codes/initialization_labels.mat', 'idx');
    load('/cs/vml2/mkhodaba/codes/ECCV 2014/codes/initialization_labels.mat');
    if length(idx) ~= size(data,1)
        [idx, c, sumd] = kmeans(data, k, 'emptyaction', 'singleton', 'replicates', 20);
    end
    %idx = gt;
    %sumd = sumd
    %idx = [1*ones(400,1); 2*ones(15,1);3*ones(20,1)];
    %plot_results(data, idx, []);
    tic
    sparsed_data = sparse(double(data));
    toc
    weight_options = ' ';
    for i=1:k
        w = sum(idx==i);
        weight_options = [weight_options ' -w' num2str(i) ' ' num2str(1/w)];
    end
    
    C = [-3 -2 -1 0 1];

    acc = [];

    for c = 1:size(C,2)
            acc(c) = train(idx, sparsed_data, ['-s 3 -v 5 -q -c  ' num2str(10^C(c)) weight_options]);
       %acc(c) = svmtrain(idx, data, ['-s 1 -t 0 -v 5 -q -c' num2str(10^C(c)) weight_options]);
    end
    
    c = find(acc == max(acc));
    if length(c) > 1
        c = c(1)
    end
    
    
    %model = svmtrain(idx, sparsed_data, ['-s 1 -t 0 -q -c ' num2str(10^C(c)) weight_options]);
    model = train(idx, sparsed_data, ['-s 3 -q -c ' num2str(10^C(c)) weight_options]);    
    w = model.w;
    save('/cs/vml2/mkhodaba/codes/ECCV 2014/codes/init_w.mat', 'w');
    %w =  [-0.2098   -0.1236   -0.0423   -0.1857   -0.1334   -0.0685   -0.1514   -0.2331   -0.0058];
    %w = [-0.4701   -0.1008    0.0559   -0.2055   -0.0989   -0.1082   -0.1671   -0.1417   -0.0765];
    %w = [0.4701   -0.1008    0.0559   -0.2055   -0.0989   -0.1082   -0.1671   0.1417   -0.0765];
end

