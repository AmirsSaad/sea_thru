function [BS , BSvar] = bg_pdf_estimation(I,depth)

VarFiltSize = 51;
dmask = zeros(size(depth));
dmask(depth==0) = 1;

% vx = movvar(I.*dmask,VarFiltSize,0,1);
% vy = movvar(I.*dmask,VarFiltSize,0,2);
% v = sqrt(vx.^2 + vy.^2);
v=zeros(size(I));
for i=1:3
    v(:,:,i) = stdfilt(I(:,:,i).*dmask,true(VarFiltSize)).^2;
end

% t = sqrt(v(:,:,1).^2 + v(:,:,2).^2 + v(:,:,3).^2);
thrsh = prctile(v(v(:)>0),50);
vmask = zeros(size(v,1),size(v,2));
vmask(v(:,:,1)<thrsh & v(:,:,2)<thrsh & v(:,:,3)<thrsh)=1;

is_plot = 0;
if is_plot == 1
    histRGB(dmask.*repmat(vmask,1,1,3))
    histRGB(I.*dmask.*repmat(vmask,1,1,3))
    histRGB(v*1e5,[])
end

BS = struct('low',[],'high',[]);
BSvar = struct('low',[],'high',[]);
for i=1:3
    ch = I(:,:,i);
    chV = v(:,:,i);
    chBS = ch(dmask.*vmask>0);
    chVar = chV(dmask.*vmask>0);
    BS(i).low = prctile(chBS,20);
    BS(i).high = prctile(chBS,80);
    BSvar(i).low = prctile(chVar,20);
    BSvar(i).high = prctile(chVar,80);
end
end
