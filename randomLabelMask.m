% get a random label mask for choosing some instances as labels, uses
% stratified sampling
% 
% randomLabelMask(hypergraph, labelNum, labelRatio)
%
% hypergraph - the labeled hypergraph (or graph)
% labelNum   - number of labeled instances or []
% labelRatio - the ratio of labeled instances or []
%
% output: a sparse 1 x instanceNum logical vector
%
function out = randomLabelMask(c, labelRatio, classLabels)
% Hypergraph Analysis Toolbox (HAT)
% Copyright 2011, written by Li PU @ lia.epfl.ch, li.pu@epfl.ch

% Modifications:
% 24-aug-2011, created [Li PU]

out = classLabels;

for i=1:c
    labelIndices = find(classLabels==i);
    vnum = length(labelIndices);
    
    % If there's only onw point in that class, don't mask it
    if (vnum == 1)
        continue;
    end
    
    %num of masked instances for each label
    labelNum = ceil(length(labelIndices)*labelRatio);
    
    k = randperm(vnum);
    k = k(1:labelNum);
    
    out(labelIndices(k)) = -1;
end



