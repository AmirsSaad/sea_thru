function Ifixed = fixProcess(strDNG,strDepth,strMeanHist,strBSHist,attenFixVer,lambda,betaBtype,DC,WB,contStr,fix_non_depth,blur_red,sigma_red,blur_depth,sigma_depth)

if DC
    factorDC=0;
else
    factorDC=1000;
end

[JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z] = fitPhyModel(strMeanHist,strBSHist,lambda,betaBtype,factorDC,1);

close all;

[I,info] = convert_dng2sensor(strDNG);
depth=imread(strDepth);

% fix depth map zeros to far
if fix_non_depth
    depth(depth==0)=max(max(depth));
end

if blur_depth
    depth= imgaussfilt(depth,sigma_depth);
end

%remove backscatter with modeled coefs
[IremBS,~] = removeBS(I*255,depth,[Binf' betaB']);

if blur_red
    IremBS(:,:,1)= imgaussfilt(IremBS(:,:,1),sigma_red);
end
% fix attenuation (ver=1 model with c, ver=2 model without c, ver=3 with ratio vector)

if attenFixVer<3
    Ifixed=AttenFix(IremBS,depth,[JD' betaD' C'],attenFixVer);
else
    Ifixed=AttenFix(IremBS,depth,[ratiovec z],3);
end

% photon equalizer / white balancing 
if WB>0
    for i=1:3
        Ifixed(:,:,i)=Ifixed(:,:,i)*photonEQ(i);
    end
end

if WB==1
    [~,Ifixed]=wb_adj(Ifixed/255);
    Ifixed=Ifixed*255;
end

Ifixed = convert_sensors2viewable(Ifixed/255,info);


if WB==2
    [~,Ifixed]=wb_adj(Ifixed);
end

% figure();
% subplot 221; imshow(Ipre); title('Original');
% subplot 222; imshow(IremBS); title('BS removed');
% subplot 223; imshow(Ifixed); title('Attenuation fixed');

%%apply contrast strech
if contStr
    Ifixed=imadjust(Ifixed,stretchlim(Ifixed),[]);
end

if WB==3
    [~,Ifixed]=wb_adj(Ifixed);
end
%subplot 224; imshow(IfixedHS); title('Hist Stretch');
%BS =convert_sensors2viewable(BS/255,info);

%saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
