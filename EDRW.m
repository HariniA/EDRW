function [F1_DRW] = EDRW(H, G, fixLabels, classLabels, alpha, L)

% H{} is a cell array of the hypergraph incident matrices
% G{} is a cell array of graph adjacency matrices
% alpha is a vector of weights, the first part is the weight for
% hypergraphs and the second part for graphs
% Eg: alpha = [0.3 0.2 0.1 0.4], with two hypergraphs and two graphs means
% that hypergraphs will get weights of 0.3 and 0.2, while graphs get 0.1
% and 0.4, respectively
% classLabels: a vector containing the class assignments for each node (n x
% 1, where 'n' is the total number of points in the dataset)
% fixLabels: similar to classLabels, with '-1' for unlabelled nodes, and
% the actual class labels for the labeled ones
% L: length of DRW, we have kept it as 2 for all experiments

% If you don't want to pass in fixLabels, but want it to be generated on
% the fly, use the following (set maskPercentage depending on the percentage of unknowns you want):
% c = max(classLabels);
% maskPercentage = 0.5;
% fixLabels = randomLabelMask(c, maskPercentage, classLabels);

% As an example, to run on Twitter Olympics dataset (provided with the
% code)
%     process_TwitterOlympics_data;
%     alpha = [0.05 0.05 0.15 0.15 0.15 0.15 0.15 0.15]; % Found using cross-validation
%     maskPercentage = 0.5;
%     fixLabels = randomLabelMask(c, maskPercentage, classLabels);
%     L = 2;
    c = max(classLabels);
    clear model;
    model = HypergraphDRandomWalk(fixLabels, L);
    clusterLabels_DRW = model.predict(H, G, alpha, []);
    [accuracy_DRW F1_DRW] = evalClassification(clusterLabels_DRW, classLabels, fixLabels, c);

end