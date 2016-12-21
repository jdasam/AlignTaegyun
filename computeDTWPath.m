function [alignTimeAtoB,alignTimeBtoA] = computeDTWPath(filterBankResponseA,filterBankResponseB)
% [alignTimeAtoB,alignTimeBtoA] = computeDTWPath(filterBankResponseA,filterBankResponseB)
% Compute simmilarty matrix between two filterBankResponse from different
% Audio(From same score) return corrisponding DTW path for each.

%	Version 1.00
%	06.07.2016
%	Copyright (c) by Taegyun Kwon
%	ilcobo2@kaist.ac.kr
cosineSimilarity=simmx(filterBankResponseA,filterBankResponseB);
[p,q,~,~] = dpfast(1-cosineSimilarity,[1 1 1.0;0 1 1.0;1 0 1.0],0,0.02);
alignTimeAtoB=zeros(1,size(filterBankResponseA,2));
alignTimeBtoA=zeros(1,size(filterBankResponseB,2));
for k = 1:length(alignTimeAtoB); 
    if k < p(end); 
        alignTimeAtoB(k)=q(find(p>=k,1,'first'));
    else alignTimeAtoB(k)=q(end); 
    end
end
for k = 1:length(alignTimeBtoA); 
    if k < q(end); 
        alignTimeBtoA(k)=p(find(q>=k,1,'first'));
    else alignTimeBtoA(k)=p(end); 
    end
end


end

