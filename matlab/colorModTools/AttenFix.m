function [Iout] = AttenFix(I,depth,coefs,ver,withNorm,normMeanVal)
    if withNorm
        %MEAN_VALUE = 10.234190813810601;
        gray = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
        meangray=mean(gray,'all');
        I=I+(normMeanVal-meangray);
    end
    ratiomap=zeros(size(I));
    for i=1:3
        if ver<=2
            if ver==1
                C=ones(size(I(:,:,1)))*coefs(i,6);
                I(:,:,i)=I(:,:,i)-C;
            end
           I(:,:,i)=I(:,:,i).*exp((coefs(i,2)./(depth.^coefs(i,3)+coefs(i,4))).*depth);% (x(4)*exp(x(7)*z)+x(8)*exp(x(9)*z))
           if ver==1
                I(:,:,i)=I(:,:,i)+C;
           end
        elseif ver==3
           z=coefs(:,4); h=coefs(:,1:3);
           for n=1:size(depth,1)
               for m=1:size(depth,2)
                    cz=depth(n,m);
                    k=1;
                    while k<length(z) && z(k)<cz
                        k=k+1;
                   
                    end
                    ratiomap(n,m,i)=h(k,i);
               end
           end     
        end
        
    end
    
    if ver==3
        Iout=I.*ratiomap;
    else
        Iout=I;
    end
    
    if withNorm
        Iout= Iout-(normMeanVal-meangray);
    end
end