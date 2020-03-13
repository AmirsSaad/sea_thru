function [Iout] = AttenFix(I,depth,coefs,ver)
    MEAN_VALUE = 10.234190813810601;
    gray = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
    meangray=mean(gray,'all');
    I=I*(MEAN_VALUE/meangray);
    for i=1:3
        if ver==1
            C=ones(size(I(:,:,1)))*coefs(i,3);
            I(:,:,i)=I(:,:,i)-C;
        end
       I(:,:,i)=I(:,:,i).*exp(coefs(i,2)*depth);
       if ver==1
            I(:,:,i)=I(:,:,i)+C;
       end
    end
    Iout= I/(MEAN_VALUE/meangray);
end