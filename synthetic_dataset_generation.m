% The following code generates synthetic graphs and hypergraphs

folderName = 'syntheticData/';
% Desired skew, it will be 1 : skew_value
class_skews = [20];
% In order to generate the graphs for different graph and hypergraph
% homophily values at the same time, the following can be used. 
hypergraph_homophily_vals = [2];
graph_homophily_vals = [2];
% The number of different sets of graph + hypergraph needed, for every
% value of skew and graph/hypergraph homophilies
numSets = 1;
% Number of nodes in the graph
numNodes = 1000;

for i = 1 : numel(class_skews)
    skew = class_skews(i);
    % Number of nodes of class A
    numANodes = ceil(numNodes / (1 + skew));
    % Number of nodes of class B
    numBNodes = numNodes - numANodes;
    % The first ceil(numNodes / (1 + skew)) frzction of nodes belong to class A and the rest to class B
    ANodes = 1:numANodes;
    BNodes = numANodes + 1 : numNodes;

    % Set the number of hyperedges required
    numRequiredEdges = floor(1.5 * numNodes);
	for h = 1 : numel(hypergraph_homophily_vals)
		for j = 1 : numSets
			numEdges = 0;
			H = [];			
			flag = 0;
			while (numEdges < numRequiredEdges)
% 				numEdges

				r = rand();
				if (r <= 0.75)
					n = randi(floor(0.03 * numNodes), 1, 1);
				elseif (r <= 0.95)
					n = floor(0.03 * numNodes) + randi(floor(0.47 * numNodes), 1, 1);
				else
					n = floor(0.5 * numNodes) + randi(floor(0.5 * numNodes), 1, 1);
				end

				if ((n <= 1) || (n >= numNodes))
					continue;
				end
				% Should this edge exhibit homophily?
				r = rand();
				if (r <= hypergraph_homophily_vals(h) / 10)
					% Yes homophily
					% Strength of homophily?
					% Anything between 1.2 and 3 times
					s = 1.2 + (rand() * 1.8);
					if (flag == 0) % Make class A better
						flag = 1;
						numEdgeANodes = floor((n * s) / (s + skew));
						numEdgeBNodes = n - numEdgeANodes;
						edgeANodes = ANodes(randi(numANodes, 1, numEdgeANodes));
						edgeBNodes = BNodes(randi(numBNodes, 1, numEdgeBNodes));
						H(edgeANodes, numEdges + 1) = 1;
						H(edgeBNodes, numEdges + 1) = 1;
					else % Make class B better
						flag = 0;
						numEdgeANodes = ceil(n / (1 + s * skew));
						numEdgeBNodes = n - numEdgeANodes;
						edgeANodes = ANodes(randi(numANodes, 1, numEdgeANodes));
						edgeBNodes = BNodes(randi(numBNodes, 1, numEdgeBNodes));
						H(edgeANodes, numEdges + 1) = 1;
						H(edgeBNodes, numEdges + 1) = 1;
					end
				else
					H(randi(numNodes, n, 1), numEdges + 1) = 1;
				end
				numEdges = numEdges + 1;
			end
			csvwrite([folderName, 'synthetic_hypergraph_skew_', num2str(skew), '_h_', num2str(hypergraph_homophily_vals(h)), '_set_', num2str(j), '.csv'], H);
		end
	end
end

% Graph generation
% You can specify the number of required edges. If the graph is still not
% connected even after generating those many edges, the script runs till
% the graph is connected
for i = 1 : numel(class_skews)
	skew = class_skews(i);
	
	numRequiredEdges = 0;
	numEdges = 0;
	numANodes = ceil(numNodes / (1 + skew));
	numBNodes = numNodes - numANodes;
	ANodes = 1:numANodes;
	BNodes = numANodes + 1 : numNodes;
	for g = 1 : numel(graph_homophily_vals)
		for j = 1 : numSets
		G = zeros(numNodes);
		while (isconnected(G) ~= true || numEdges < numRequiredEdges)
			% Homophily of 0.4
			r = rand();
			if (r <= graph_homophily_vals(g) / 10)
				% homophily
				r1 = rand();
				if (r1 <= 1 / (skew + 1))
					% class A
					n1 = ANodes(randi(numANodes, 1, 1));
					n2 = ANodes(randi(numANodes, 1, 1));
				else
					% class B
					n1 = BNodes(randi(numBNodes, 1, 1));
					n2 = BNodes(randi(numBNodes, 1, 1));
				end
			else
				n1 = randi(numNodes, 1, 1);
				n2 = randi(numNodes, 1, 1);
			end
			if (n1 == n2)
				continue;
			end
			G(n1, n2) = 1;
			G(n2, n1) = 1;
			numEdges = numEdges + 1;
		end
		csvwrite([folderName, 'synthetic_graph_skew_', num2str(skew), '_g_', num2str(graph_homophily_vals(g)), '_set_', num2str(j), '.csv'], G);
		end
	end
end