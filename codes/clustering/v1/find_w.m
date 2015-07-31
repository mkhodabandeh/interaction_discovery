function [ scores ] = find_w( labels, auxdata )
%FIND_W Summary of this function goes here
%   Detailed explanation goes here
    kernel = auxdata.kernel;
    c = auxdata.cost;
    global data pref;

    [ni, dim] = size(data);
    kc = auxdata.kc;

    un_labaled = find(labels==0);
    labels1 = removerows(labels, un_labaled);
    data1 = removerows(data, data1);
    options = '-m CS -k 2 -q';
    model = trainmsvm(data1, labels1, options);
    [~, scores] = predmsvm(model, data, labels);
    clear data1 labels1;
    
end

