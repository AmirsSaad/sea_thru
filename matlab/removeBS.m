function [Iout,BS] = removeBS(I,depth,coefs)
    BS=zeros(size(I));
    MEAN_VALUE = 10.234190813810601;
    gray = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
    meangray=mean(gray,'all');
    I=I*(MEAN_VALUE/meangray);
    for i=1:3    
       BStemp=coefs(i,1)*(1-exp(-coefs(i,2).*depth));
       %BStemp(depth==0)=coefs(i,1);
       BS(:,:,i)=BStemp;
    end
    Iout = I - BS;
    
    
    Iout= Iout/(MEAN_VALUE/meangray);
end