function [I] = applyStatWB(I,depth,m,n,l,A)
for i=1:3
    Itemp=I(:,:,i);
    I(:,:,i)=(Itemp-m*depth-n-l.*depth.^2)*A(i)+m*depth+n+l.*depth.^2;
end

end