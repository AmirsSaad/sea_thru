function D = DepthQuantization(d,n)
d_max=max(max(d),'all');
d_min=min(d(d>0),'all');
ranges=linspace(d_min,d_max*1.001,n+1);
D=zeros([size(d) n]);
for i=1:n
    mask=(d>=ranges(i) & d<ranges(i+1));
    D(:,:,i)=mask;
end
end
