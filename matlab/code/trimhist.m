function hout = trimhist(h,edge,percent)
trimmed=0;
hsum = sum(h);
while(trimmed < 100-percent)
    if h(edge(1))<h(edge(2))
        trimmed=trimmed+h(edge(1))/hsum;
        edge(1)=edge(1)+1;
    else
        trimmed=trimmed+h(edge(2))/hsum;
        edge(2)=edge(2)-1;
    end
end
hout=zeros(size(h));
hout(edge(1):edge(2))=h(edge(1):edge(2));
end