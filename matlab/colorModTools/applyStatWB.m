function [I] = applyStatWB(I,depth,m,n,A)
for i=1:3
    Itemp=I(:,:,i);
    I(:,:,i)=(Itemp-m*depth-n)*A(i)+n;
end

end