function minh = minhist(h)
size=length(h(:,1))
for i=1:size
    minh(i)=min(h(i,:));
end
end