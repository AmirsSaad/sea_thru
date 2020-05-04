function [I,depth] = deletePalettes(I,depth,params)
    n=length(params);
    for i=1:n
        I(ceil(params(i).rect(2)):floor(params(i).rect(2)+params(i).rect(4)),ceil(params(i).rect(1)):floor(params(i).rect(1)+params(i).rect(3)),:)=0;
        depth(ceil(params(i).rect(2)):floor(params(i).rect(2)+params(i).rect(4)),ceil(params(i).rect(1)):floor(params(i).rect(1)+params(i).rect(3)))=0;
        
    end
end