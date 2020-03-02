function modBS = getBSvectors(coefs,z)
    modBS=zeros(3,length(z));
    for i=1:3
        modBS(i,:)=coefs(i,1)*(1-exp(-coefs(i,2)*z));
    end
end