function Ifixed = fixProcess(strDNG,strDepth,strMeanHist,strBSHist,withNorm,normMeanVal,attenFixVer,lambda,betaBtype,DC,WB,contStr,fix_non_depth,blur_red,sigma_red,blur_depth,sigma_depth,statModel,isplot)

if DC
    factorDC=0;
else
    factorDC=10000;
end



depth=imread(strDepth);
disp('Convertiong DNG to Sensor space...');
[I,info] = convert_dng2sensor(strDNG);

disp('Extracting "sky" properties..');
if sum(depth==0,'all')/(size(depth,1)*size(depth,2))>0.05
  [BS , BSvar] = bg_pdf_estimation(I*255,depth) ;
  boolBS=1;
else
   boolBS=0;
   BS=[]; BSvar=[];
end


if statModel=="multip"
    Istruct=importdata(strMeanHist,',');
    Jbstruct=importdata(strBSHist,',');
elseif statModel=="single"
   [Istruct,Jbstruct]= getSinglePhotoStats(I,depth,99.5,1,0.5);
elseif statModel=="sandim"
   [sand,rect]=imcrop(I);
    dsand=depth(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
   [Istruct,Jbstruct]= getSinglePhotoStats(sand,dsand,0.5,0); 
end

disp('Fitting Model...');
x0=[];
for k=1
[JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,x0,Ihpf,Ilpf,Imef,Ivf] = fitPhyModel(Istruct,Jbstruct,lambda,betaBtype,factorDC,isplot,attenFixVer,x0,BS,BSvar,boolBS);
%[JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,x0,Ihpf,Ilpf,Imef,Ivf] = fitPhyModel(Istruct,Jbstruct,lambda,betaBtype,factorDC,isplot,ver,x0)
[m,n,l,A] = statisticalWBfit(Imef,Ihpf,Ilpf,Ivf,z,isplot);
end
%close all;



% fix depth map zeros to far
if fix_non_depth
    disp('Fixing depth map zeros...');
    depth(depth==0)=max(max(depth));
end

if blur_depth
    disp('Blurring Depth...');
    depth= imgaussfilt(depth,sigma_depth);
end

%remove backscatter with modeled coefs
disp('Removing Backscatter...');
[IremBS,~] = removeBS(I*255,depth,[Binf' betaB'],withNorm,normMeanVal);

if blur_red
    disp('Blurring Red Channel...');
    IremBS(:,:,1)= imgaussfilt(IremBS(:,:,1),sigma_red);
end
% fix attenuation (ver=1 model with c, ver=2 model without c, ver=3 with ratio vector)

disp('Fixing Color Attenuation...');
if attenFixVer<3
    Ifixed=AttenFix(IremBS,depth,[JD' betaD' C'],attenFixVer,withNorm,normMeanVal);
else
    Ifixed=AttenFix(IremBS,depth,[ratiovec z],3,withNorm,normMeanVal);
end

%blacken faraway
for i=1:3
    Itemp=Ifixed(:,:,i)/255;
    Itemp(depth==0) = mean(Itemp(depth>0),'all');
    Ifixed(:,:,i)=Itemp;
end

% photon equalizer / white balancing 
if WB>0
    disp('PhotonEQ...');
    for i=1:3

            Ifixed(:,:,i)=Ifixed(:,:,i)*photonEQ(i);%*A(i);

    end
    %Ifixed = applyStatWB(Ifixed*255,depth,m,n,l,A)/255;
end

if WB==1
    [~,Ifixed]=wb_adj(Ifixed);
    %Ifixed=Ifixed*255;
end

disp('Converting Sensors space to viewable...');
Ifixed = convert_sensors2viewable(Ifixed,info);

%Ifixed=Ifixed/max(Ifixed,[],'all');

if WB==2
    [~,Ifixed]=wb_adj(Ifixed);
end

% figure();
% subplot 221; imshow(Ipre); title('Original');
% subplot 222; imshow(IremBS); title('BS removed');
% subplot 223; imshow(Ifixed); title('Attenuation fixed');

%%apply contrast strech
if contStr
    disp('Stretching contrast...');
    Ifixed=imadjust(Ifixed,stretchlim(Ifixed),[]);
%     rHist = imhist(Ifixed(:,:,1), 256);
%     [lims,~]=histsmartedges(rHist);
%     lims=lims/255;
%     Ifixed(:,:,1) = imadjust(Ifixed(:,:,1),lims,[]);   
    %Bhist=imhist(Ifixed(:,:,3),256);
    %Ifixed(:,:,1) = histeq(Ifixed(:,:,1),Bhist);
end

if WB==3
    disp('White Balancing...');
    [~,Ifixed]=wb_adj(Ifixed);
end
%subplot 224; imshow(IfixedHS); title('Hist Stretch');
%BS =convert_sensors2viewable(BS/255,info);

%saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
