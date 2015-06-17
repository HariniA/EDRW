classLabels = load('TwitterOlympics/pp_olympics.classes');
n = 464;
c = max(classLabels);

followedByGraph = load('TwitterOlympics/pp_olympics-followedby.mtx');
linkMat{1} = followedByGraph;
G{1} = spconvert(followedByGraph);

followsGraph = load('TwitterOlympics/pp_olympics-follows.mtx');
linkMat{2} = followsGraph;
G{2} = spconvert(followsGraph);

mentionsGraph = load('TwitterOlympics/pp_olympics-mentions.mtx');
linkMat{3} = mentionsGraph;
G{3} = spconvert(mentionsGraph);

mentionedGraph = load('TwitterOlympics/pp_olympics-mentionedby.mtx');
linkMat{4} = mentionedGraph;
G{4} = spconvert(mentionedGraph);

retweetedGraph = load('TwitterOlympics/pp_olympics-retweets.mtx');
linkMat{5} = retweetedGraph;
G{5} = spconvert(retweetedGraph);

retweetedByGraph = load('TwitterOlympics/pp_olympics-retweetedby.mtx');
linkMat{6} = retweetedByGraph;
G{6} = spconvert(retweetedByGraph);

listHypergraph = load('TwitterOlympics/pp_olympics-listmergedHypergraph.mtx');
H{1} = spconvert(listHypergraph);

tweetsHypergraph = load('TwitterOlympics/pp_olympics-tweetsHypergraph.mtx');
H{2} = spconvert(tweetsHypergraph);

contentData = [H{1} H{2}];

dataMat.linkMat = linkMat;
dataMat.contentMat = contentData;
dataMat.n = n;
dataMat.c = c;

