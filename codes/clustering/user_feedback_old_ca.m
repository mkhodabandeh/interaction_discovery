function [groups, pairs, scores, num_labeled_data] = user_feedback_old_ca(w, auxdata)

global data latent_data perf;

num_latent = auxdata.num_latent;
feature_size = auxdata.feature_size;
num_clusters = auxdata.kc;
num_pairs = auxdata.num_pairs;
group_size = auxdata.group_size;

%% Extract w0 w1 w2
w0_vec = w(1:(feature_size+1)*num_clusters);
w1_vec = w((feature_size+1)*num_clusters+1: (feature_size+1)*num_clusters+num_latent*feature_size);
w2_vec = w(feature_size*(num_clusters+num_latent)+num_clusters+1:feature_size*(num_clusters+num_latent)+num_clusters+num_clusters*num_latent);


w0 = reshape(w0_vec, feature_size+1, num_clusters)'; % K by F
w1 = reshape(w1_vec, feature_size, num_latent)'; % H by F
w2 = reshape(w2_vec, num_clusters, num_latent)'; % H by K
%% Infer latent variables
% max over possible hidden variables
[scores, ~] = infer_global_latent_variables_group_activity(w0, w1, w2, auxdata);

%% Choose best labeling using Linear Programming
ni = size(scores, 1);
auxdata.lsize = auxdata.clsrbalL * (ni / num_clusters);
auxdata.usize = auxdata.clsrbalU * (ni / num_clusters);


pairs = auxdata.pairs;
groups = auxdata.groups;
[costs, merged_to_reg_ids, weights] = get_costs(scores, groups);
new_pairs = merged_to_reg_ids(pairs);
temp_labels = assign_lpa_user_interaction(costs, auxdata, new_pairs, weights);
labels = temp_labels(merged_to_reg_ids);

g = cellfun(@transpose, groups, 'UniformOutput', false);
g = [g{:}]';
previous_groups = g;
previous_groups = previous_groups(:);
previous_pairs = auxdata.pairs(:);
previous_data = unique([previous_groups; previous_pairs]);

%% get user feedback
non_zero_indx = labels ~= 0;
gtlabels = perf.labeltr(non_zero_indx);
pdlabels = labels(non_zero_indx);

pd = false(size(gtlabels));
pd(previous_data) = true;

pairs = [];
groups = {};
num_labeled_data = 0;
for k = 1:num_clusters
    k_mode = mode(gtlabels(pdlabels==k));
    false_posetives_ids = find(pdlabels==k & gtlabels ~= k_mode & ~pd);
    true_posetives_ids = find(pdlabels==k & gtlabels == k_mode & ~pd);
    groupsk = [];
    if length(false_posetives_ids) <= num_pairs || length(true_posetives_ids) <= num_pairs
        %s = min(length(false_posetives_ids), length(true_posetives_ids));
        %pairs1 = datasample(false_posetives_ids, s, 'Replace', false)';
        %pairs2 = datasample(true_posetives_ids, s, 'Replace', false)';
        %groupsk = pairs2(:);
        %pairs = [pairs; [pairs1(:), pairs2(:)]];
        if length(false_posetives_ids) <= num_pairs
            groupsk = [true_posetives_ids];
            groupsk = groupsk(:);
            num_labeled_data = num_labeled_data + length(false_posetives_ids(:));
            pairs = [pairs; [false_posetives_ids(:), false_posetives_ids(:)]];
        end
        
    else
        pairs1 = datasample(false_posetives_ids, num_pairs, 'Replace', false)';
        num_labeled_data = num_labeled_data + length(pairs1);
        pairs2 = datasample(true_posetives_ids, num_pairs, 'Replace', false)';
        groupsk = pairs2(:);
        pairs = [pairs; [pairs1(:), pairs2(:)]];
    end
    
    if length(true_posetives_ids) < group_size
        groups{k} = true_posetives_ids;
    else
        %groups{k} = datasample(true_posetives_ids, group_size, 'Replace', false);
        if ~isempty(groupsk)
            if group_size >= num_pairs
                rest = setxor(true_posetives_ids, groupsk);
                if group_size-num_pairs >= length(rest)
                    groups{k} = unique([groupsk; rest]);
                else
                    groups{k} = unique([groupsk;datasample(rest, group_size-num_pairs, 'Replace', false)]);
                end
            else
                groups{k} = [datasample(groupsk, group_size, 'Replace', false)];
            end
        else
            groups{k} = datasample(true_posetives_ids, group_size, 'Replace', false);
        end
    end
end
%% Merge similar groups
for k = 1:num_clusters-1
    for j = k+1:num_clusters
        if (~isempty(groups{k}) && ~isempty(groups{j})) && (gtlabels(groups{k}(1)) == gtlabels(groups{j}(1)))
            groups{k} = [groups{k}; groups{j}];
            groups{j} = [];
        end
    end
end

new_groups = {};
for counter = 1:length(groups)
    if ~isempty(groups{counter})
        new_groups{end+1} = groups{counter};
    end
end

%% Set true labels to false posetvise (first column of the pairs)
%

for p_i = 1:size(pairs, 1)
    flag = false;
    for k = 1:length(new_groups)
        if gtlabels(pairs(p_i, 1)) == gtlabels(new_groups{k}(1))
            new_groups{k}(end+1) = pairs(p_i, 1);
            flag = true;
        end
    end
    if ~flag
        new_groups{end+1} = [pairs(p_i, 1)];
    end
end
%}

for k = 1:length(new_groups)
    new_groups{k} = [new_groups{k}(:)];
end

%% Merge previous groups with current groups

for k_p = 1:length(auxdata.groups)
    flag = false;
    for k_c = 1:length(new_groups)
        if gtlabels(auxdata.groups{k_p}(1)) == gtlabels(new_groups{k_c}(1))
            new_groups{k_c} = [new_groups{k_c}; auxdata.groups{k_p}];
            flag = true;
        end
    end
    if ~flag
        new_groups{end+1} = auxdata.groups{k_p};
    end
end

%% Add must not link between not similar groups
p = zeros(k*(k-1)/2, 2);
i = 1;
len = length(new_groups);
for k = 1:len-1
    for j = k+1:len
        if ~isempty(new_groups{k}) && ~isempty(new_groups{j})
            p(i, :) = [new_groups{k}(1), new_groups{j}(1)];
            i = i + 1;
        end
    end
end

%% TODO: check next lines
%pairs;
%pairs = [pairs; p(1:i-1, :)];
pairs = [p(1:i-1, :)];
%groups = cellfun(@transpose, new_groups, 'UniformOutput', false);
groups = new_groups;
