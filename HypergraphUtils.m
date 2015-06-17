classdef HypergraphUtils
    methods (Static)
        
        %% stochastic matrix for graph
        function [theta, Pi] = computeStochasticMatrix_graph(G)
            %G is an adjacency matrix
            outDegree = sum(G, 2);
            invOutDegree = outDegree.^(-1);
            Dv = diagonalize(outDegree);
            invDv = diagonalize(invOutDegree);
            theta = invDv*G;
            theta = full(theta);
            Pi = outDegree/trace(Dv);
        end
        
        %% stochastic matrix for hypergraph
        function [theta, Pi] = computeStochaticMatrix_hypergraph(H, W)
            dv = sum(H*W, 2); %vertex degree vector
            invdv = dv.^(-1);
            Pi = dv/sum(dv);
            clear dv;
            invDv = diagonalize(invdv);
            clear invdv;
            de = sum(H, 1)-1; %edge degree vector
            De = diagonalize(de); %edge degree diagonal matrix
            clear de;

            theta = invDv*H*W*De^(-1)*H';  % stochastic matrix
            theta(speye(size(theta))==1) = 0;        
        end
        
       
        %% Compute weights to maximize purity
        function W = computeWeights(H, fixLabels)
            display('Computing weights of hyperedges');
            e = size(H, 2);
            W = zeros(e,3);
            c = max(fixLabels);
            
            classDist = zeros(c, 1);
            for i=1:c
                classDist(i) = length(find(fixLabels==i));
            end

            for i = 1:e
                edgeClassDist = zeros(c, 1);
                for j=1:c
                    edgeClassDist(j) = length(find(fixLabels(H(:, i)==1)==j));
                end
                
                edgeClassDistRatio = edgeClassDist./classDist;
                
                [~, yPos] = max(edgeClassDistRatio);   %max occuring label and its frequency
                yNegLengthk = sum(edgeClassDist) - edgeClassDist(yPos);   %number of instances in that edge with other labels (don't change logic... think deep :P)
                numNegativeInstances = sum(classDist) - classDist(yPos); % Number of negative instances overall

                hellingerSimilarity =  ( (edgeClassDist(yPos)/classDist(yPos) )^0.5 - (yNegLengthk/numNegativeInstances)^0.5 )^2;
                W(i,:) = [i i hellingerSimilarity];
            end

            index = ~isnan(W(:,3));
            W(isnan(W)) = mean(W(index,3));
            W = spconvert(W);
        end
        
        %% Combine Pi
        function [Pi_mix, Theta_mix] = combineRandomWalk(pi, theta, alpha)
            % pi is nXd matrix where n is the number of instances and d is
            % the number of views
            
            if length(alpha)==1
                Pi_mix = pi;
                Theta_mix = theta{1};
                return;
            end
            
            n = size(pi, 1);
            Pi_mix = sparse(n, 1);

            for i=1:length(alpha)
                Pi_mix = Pi_mix + alpha(i)*pi(:, i);
            end
            
            beta = zeros(size(pi));
            
            for i = 1:length(alpha)
                beta(:, i) = alpha(i)*(pi(:, i)./Pi_mix);
            end
             
            clear pi;
            
            Theta_mix = sparse(n, n);
            for i=1:length(alpha)
                Theta_mix = Theta_mix + diagonalize(beta(:, i))*theta{i};
            end
        end
        
        function hellingerLabels = computeLabelsForHellingerDis(views, fixLabels)
            display('Estimating few labels for weights');
            c = max(fixLabels);
            hellingerLabels = fixLabels;
            posteriorVals = zeros(length(find(fixLabels==-1)), c);
            flag = 1;
            
            for i = 1:length(views)
                view = views{i};
                nb = NaiveBayes.fit(view(fixLabels~=-1, :), fixLabels(fixLabels~=-1), 'Distribution', 'mn');
                [post, ~] = posterior(nb, view(fixLabels==-1, :));  
                
                if (size(post, 2) ~= size(posteriorVals, 2))
                    post = sparse(post);
                    post(size(posteriorVals, 1), c) = 0;
                end
         
                if flag==1
                    posteriorVals = posteriorVals + post;
                    flag = 0;
                else
                    posteriorVals = posteriorVals.*post;
                end
            end
            
            [posteriorVals, cpre] = max(posteriorVals, [], 2);
            %add top K from each class to fixLabel pool
            
            hellingerLabels(fixLabels==-1) = cpre;
            hellingerLabels(posteriorVals<0.98) = -1;
           
            display('Labels for hellinger distance computed');
        end

        
         function W=computePurity(H, fixLabels)
            e = size(H, 2);
            W = zeros(e,3);

            for i=1:e
                [~,freq] = mode(fixLabels(H(:, i)==1));
                purity = freq/length(find(H(:, i)));
                W(i, :) = [i i purity];
            end

            W = spconvert(W);
         end      
    end
end