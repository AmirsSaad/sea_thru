function out = vec2qconv(vec)
len=length(vec);
[pks,locs] = findpeaks(vec);
%vecmin=min(vec)-1;

oldlen=len; newlen=oldlen-1;
while oldlen>newlen
    i=1;
    oldlen=newlen;
    while i<length(locs)
        if pks(i+1)>=pks(i)
            pks(i)=[];
            locs(i)=[];
        else
            i=i+1;
        end
    end
    newlen=length(locs);
end
start=1;
for i=1:length(locs)
    out(start:locs(i))=pks(i);
    start=locs(i)+1;
end
out(locs(end)+1:len)=vec(locs(end)+1:len);
end