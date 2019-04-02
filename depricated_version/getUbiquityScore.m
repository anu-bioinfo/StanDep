function [ubiScore,uScore] = getUbiquityScore(clustObj,edgeX,model)

objDist = zeros(size(clustObj.Data));
uci = 1:1:size(clustObj.C,1);
cidx = clustObj.cindex;
[~,thrVal] = clusterVariability1(clustObj,edgeX,false);
for j=1:size(clustObj.Data,2)
    for i=1:length(uci)
        ic = find(cidx==uci(i));
        objDist(ic,j) = clustObj.Data(ic,j) - (thrVal(i));
    end
end
uScore = objDist; uScore(uScore >= 0) = 1;
% ubiScore = uScore;

for i=1:size(uScore,2)
    indx = find(uScore(:,i)~=1);
    m = uScore(:,i); m(m==-inf) = []; m = min(m);
    uScore(indx,i) = 1 - uScore(indx,i)/m;
end

[uScore,rxns] = openUbiquityMatrix(clustObj,uScore);
ubiScore = repmat(-1,length(model.rxns),size(clustObj.Data,2));
for i=1:length(model.rxns)
    if sum(ismember(rxns,model.rxns{i}))~=0
        ubiScore(i,:) = max(uScore(ismember(rxns,model.rxns{i}),:),[],1);
    end
end

function [openUbi,rxns] = openUbiquityMatrix(clustObj,uMat)

k = 0;
for i=1:size(uMat,1)
    if ischar(clustObj.objectMaps{i})
        k = k+1;
        openUbi(k,:) = uMat(i,:);
        rxns{k,1} = clustObj.objectMaps{i};
    else
        n = length(clustObj.objectMaps{i});
        for j=1:n
            k = k+1;
            openUbi(k,:) = uMat(i,:);
            rxns{k,1} = clustObj.objectMaps{i}{j,1};
        end
    end
end