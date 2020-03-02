function [Iout,BS] = removeBS(I,depth,coefs)
    BS=zeros(size(I));
    
    for i=1:3
       BS(:,:,i)=coefs(i,1)*exp(-coefs(i,2).*depth);
    end
    
    Iout = I - BS;
    
end