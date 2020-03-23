function weights = getWeightVec(len,type)
switch type
    case 'exp'
        weights=exp(-linspace(0,30,len));
    case 'linear'
        weights=linspace(1,0,len);
    case 'uniform'
        weights=ones(1,len);
end
weights=weights/sum(weights);
    
end