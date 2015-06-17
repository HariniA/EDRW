% This function evaluates the classification performance of the classifier
% Inputs: clusterLabels (the predicted labels), classLabels (the actual
% labels), fixLabels (classLabels with unlabelled nodes denoted by -1), c
% (number of classes)
function [accuracy macroF1]=evalClassification(clusterLabels, classLabels, fixLabels, c)

numUnknowns = length(find(fixLabels==-1));
numUnKnownClass = zeros(c,1);
numCorrectClassifiedInstances = zeros(c,1);

for i = 1:c
    numUnKnownClass(i) = size(find(fixLabels(classLabels==i)==-1), 1);
end

display('-------------------------------------------------------------------------');


sF = 0;
c1 = c;

prec = zeros(c, 1);
rec = zeros(c, 1);
numMissClassified = zeros(c, 1);
f1 = zeros(c, 1);

for i = 1:c   
    numMissClassified(i) = size(find(clusterLabels(classLabels==i) - i), 1);   %numMissClassified
    numCorrectClassifiedInstances(i) = length(find(classLabels(fixLabels==-1)==i)) - numMissClassified(i);
    
    if (numCorrectClassifiedInstances(i) == 0 && numUnKnownClass(i)==0)
        c1 = c1 -1;
        continue;
    end
    
    prec(i) = numCorrectClassifiedInstances(i)/length(find(clusterLabels(fixLabels==-1)==i));
    rec(i) = numCorrectClassifiedInstances(i)/length(find(classLabels(fixLabels==-1)==i));
    
    if prec(i)==0 || rec(i)==0
        f1(i) = 0;
    else    
        f1(i) = 2*prec(i)*rec(i)/(prec(i) + rec(i));
    end
    sF = sF + f1(i);
end

fprintf('Class \t UnknownInstances \t CorrectlyClassified \t Precision \t Recall \t F1\n');
for i = 1:c
    fprintf('%d \t\t %d \t\t\t %d \t\t %.3f \t\t %.3f \t\t %.3f\n', i, numUnKnownClass(i), numCorrectClassifiedInstances(i), prec(i), rec(i), f1(i));
end

display('-------------------------------------------------------------------------');

accuracy = length(find(classLabels(fixLabels==-1) == clusterLabels(fixLabels==-1)))/numUnknowns;
fprintf('Accuracy = %.3f\n', accuracy);

macroF1 = sF/c1;
fprintf('Macro F1 = %.3f\n', macroF1);