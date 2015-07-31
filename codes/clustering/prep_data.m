function [ output ] = prep_data( data, kernel, n)
%PREP_DATA Summary of this function goes here
%   Detailed explanation goes here
      
        %output = data;
        
    %
    
        load_vl_feat
        
        data = vl_homkermap(data', n, kernel);
        output = data';
        unload_vl_feat

    %}
    
end

