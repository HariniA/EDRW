classdef HypergraphDRandomWalk
    properties
        alphaMap
        betaMap
        L
        theta
        fixLabels
        numClasses
        numInstances
    end
    
    methods
        
         %% Constructor
        function model = HypergraphDRandomWalk(fixLabels, L)
            model.numInstances = length(fixLabels);
            model.numClasses = max(fixLabels);
            model.fixLabels = fixLabels;
            model.theta = [];
            model.L = L;
            model.alphaMap = NaN(model.numInstances, L, model.numClasses);
            model.betaMap = NaN(model.numInstances, L, model.numClasses);
        end
        
        %% Compute forward variable 
        function [alpha, model]=computeAlpha(model, t, y, q)
            if ~isnan(model.alphaMap(q, t, y))
                alpha = model.alphaMap(q, t, y);
                return;
            end
            
            if t==1
                Ly = find(model.fixLabels==y);
                alpha = 0;
                for j=1:length(Ly)
                    q1 = Ly(j);
                    p = model.theta(q1, q);
                    
                    alpha = alpha + p/(length(Ly));
                end
                model.alphaMap(q, t, y) = alpha;
                return;
            end
            
            Lny = find(model.fixLabels~=y);
            alpha = 0;
            for j = 1:length(Lny)
                q1 = Lny(j);
                [alphaprev, model] = model.computeAlpha(t-1, y, q1);
                alpha = alpha + alphaprev*model.theta(q1, q);
            end
            model.alphaMap(q, t, y) = alpha;
        end
        
        %% Compute backward variable
        
        function [beta, model]=computeBeta(model, t, y, q)
            if ~isnan(model.betaMap(q, t, y))
                beta = model.betaMap(q, t, y);
                return;
            end
            
            if t==1
                Ly = find(model.fixLabels==y);
                beta = 0;
                for j=1:length(Ly)
                    q1 = Ly(j);
                    beta = beta + model.theta(q, q1);
                end
                model.betaMap(q, t, y) = beta;
                return;
            end
            
            Lny = find(model.fixLabels~=y);
            beta = 0;
            for j = 1:length(Lny)
                q1 = Lny(j);
                [betaprev, model] = model.computeBeta(t-1, y, q1);
                beta = beta + betaprev*model.theta(q, q1);
            end
            model.betaMap(q, t, y) = beta;
        end
        
         %% Transductive inference using D-Walks
        function [clusterLabels, Bl] = performDWalk(model)
            unknowns = find(model.fixLabels==-1);
            c = max(model.fixLabels);
            Bl = zeros(length(model.fixLabels), c);      %betweeness values
            
            %compute betweeness for each unknown instance
            denom = zeros(c, 1);
            
            for y=1:c
                Ly = find(model.fixLabels==y);
                for l=1:model.L
                    for j=1:length(Ly)
                        q1 = Ly(j);
                        [alpha, model] = model.computeAlpha(l, y, q1);
                        denom(y, 1) = denom(y, 1) + alpha;
                    end
                     fprintf('Computed denominator for y=%d, l=%d\n', y, l);
                end
            end
            
            for i=1:length(unknowns)
                q = unknowns(i);
                for y = 1:c
                    tot1 = 0;
                    
                    for l=1:model.L
                        tot2 = 0;
                        for t=1:l-1
                            [alpha, model] = model.computeAlpha(t, y, q);
                            [beta, model] = model.computeBeta(l-t, y, q);
                            tot2 = tot2 +  alpha * beta;
                        end
                        tot1 = tot1+tot2;
                    end
                    
                    Bl(q, y) = tot1/denom(y, 1);
                end
            end
            
            norm = sum(Bl, 2);
            
            for i=1:c
                Bl(:, i) = Bl(:, i)./norm; %likelihood
                Bl(:, i) = Bl(:, i).*(length(model.fixLabels==i)/length(model.fixLabels)); %posterior probability
            end
            clear norm;
            
            [~, clusterLabels] = max(Bl, [], 2);    %argmax
            clusterLabels(model.fixLabels~=-1) = model.fixLabels(model.fixLabels~=-1);
        end
           
        %% with weights 
        function [clusterLabels, Bl, W] = predict(model, H, G, alpha, views)
            %H is a cell array with H{k} representing
            %kth hypergraph
            %fixLabels contain class labels of instances. fixLabels = -1
            %for instances whose class labels are not known.
            numHGraphs = length(H);
            numGGraphs = length(G);
            numGraphs = numHGraphs + numGGraphs;
            
            Pi = zeros(model.numInstances, numGraphs);
            
            % Use Naive Bayes to get an initial label estimate
            if ~isempty(views)
                hellingerLabels = HypergraphUtils.computeLabelsForHellingerDis(views, model.fixLabels);
            else
                hellingerLabels = model.fixLabels;
            end
            
            W = {};
            
            for i = numHGraphs:-1:1
                W{i} = HypergraphUtils.computeWeights(H{i}, hellingerLabels);
                [thetaH{i}, Pi(:, i)] = HypergraphUtils.computeStochaticMatrix_hypergraph(H{i}, W{i});
            end
            
            for i = numGGraphs:-1:1
                [thetaH{numHGraphs+i}, Pi(:, numHGraphs+i)] = HypergraphUtils.computeStochasticMatrix_graph(G{i});
            end

            [~, model.theta] = HypergraphUtils.combineRandomWalk(Pi, thetaH, alpha);
            clear thetaH Pi;
            [clusterLabels, Bl] = model.performDWalk(); 
            
        end   
    end
end