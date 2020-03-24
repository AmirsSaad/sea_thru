function [Iout,BS] = removeBS(I,depth,coefs,withNorm,meanValue)
    BS=zeros(size(I));
    if withNorm
        %MEAN_VALUE = 10.234190813810601;
        gray = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
        meangray=mean(gray,'all');
        I=I+(meanValue-meangray);
    end
    for i=1:3    
       BStemp=coefs(i,1)*(1-exp(-coefs(i,2).*(depth)));
       %BStemp(depth==0)=coefs(i,1);
       BS(:,:,i)=BStemp;
    end
    Iout = I - BS;
    
    if withNorm
        Iout= Iout-(meanValue-meangray);
    end
end