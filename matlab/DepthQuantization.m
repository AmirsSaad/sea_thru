function D = DepthQuantization(d,n)
d_max=max(max(d));
ranges=linspace(0,d_max,n+1);
D=zeros([size(d) n]);
for i=1:n
    mask=(d>=ranges(i) & d<=ranges(i+1));
    D(:,:,i)=mask;
end
end
