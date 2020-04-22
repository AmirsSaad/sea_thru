function [Ifixed,results] = configed_fixProcess(strDNG,strDepth,config)

depth=imread(strDepth);
disp('Convertiong DNG to Sensor space...');
[I,info] = convert_dng2sensor(strDNG);


if config.plotAllStages
    figure(10)
    subplot 331
    imshow(convert_sensors2viewable(I,info))
    title('Original Photo');
    subplot 332
    imagesc(depth); colorbar;
    title('Depth Map');
end

if config.extractBS  %sum(depth==0,'all')/(size(depth,1)*size(depth,2))>0.05
    disp('Extracting "sky" properties..');
  [BS , BSvar] = bg_pdf_estimation(I*255,depth) ;
else
   BS=[]; BSvar=[];
end

if config.statModel=="multip"
    Istruct=importdata(config.MeanHist,',');
    Jbstruct=importdata(config.BSHist,',');
elseif config.statModel=="single"
   [Istruct,Jbstruct]= getSinglePhotoStats(I,depth,99,1,0.5);
elseif config.statModel=="sandim"
   [sand,rect]=imcrop(I);
    dsand=depth(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
   [Istruct,Jbstruct]= getSinglePhotoStats(sand,dsand,0.5,0); 
end


disp('Fitting Model...');
for k=1
[JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,~,~,~,~] = fitPhyModel(Istruct,Jbstruct,config.lambda,config.betaBtype,config.DC,config.isplot,config.attenFixVer,BS,BSvar,config.extractBS);
results = struct('betaD',betaD,'Binf',Binf,'betaB',betaB);

%[JD,betaD,Binf,betaB,C,photonEQ,ratiovec,z,x0,Ihpf,Ilpf,Imef,Ivf] = fitPhyModel(Istruct,Jbstruct,config.lambda,config.betaBtype,config.factorDC,config.isplot,ver,x0)
%[m,n,l,A] = statisticalWBfit(Imef,Ihpf,Ilpf,Ivf,z,config.isplot);
end
%close all;



% fix depth map zeros to far
if config.fix_non_depth
    disp('Fixing depth map zeros...');
    depth(depth==0)=max(max(depth));
end

if config.blur_depth
    disp('Blurring Depth...');
    depth= imgaussfilt(depth,config.sigma_depth);
end

%remove backscatter with modeled coefs
disp('Removing Backscatter...');

[IremBS,BSimage] = removeBS(I*255,depth,[Binf' betaB'],config.withNorm,config.normMeanVal);

if config.plotAllStages
    figure(10)
    subplot 333
    imshow(convert_sensors2viewable(IremBS/255,info))
    title('BackScatter Removed');
    subplot 334
    imshow(convert_sensors2viewable(BSimage/255,info))
    title('BS term');
end

if config.blur_red
    disp('Blurring Red Channel...');
    IremBS(:,:,1)= imgaussfilt(IremBS(:,:,1),config.sigma_red);
end
% fix attenuation (ver=1 model with c, ver=2 model without c, ver=3 with ratio vector)

disp('Fixing Color Attenuation...');
if config.attenFixVer<3
    Ifixed=AttenFix(IremBS,depth,[JD' betaD' C'],config.attenFixVer,config.withNorm,config.normMeanVal);
else
    Ifixed=AttenFix(IremBS,depth,[ratiovec z],3,config.withNorm,config.normMeanVal);
end

if config.plotAllStages
    figure(10)
    subplot 335
    imshow(convert_sensors2viewable(Ifixed/255,info))
    title('Fixed, Pre-WB');
end

%blacken faraway
for i=1:3
    Itemp=Ifixed(:,:,i)/255;
    Itemp(depth==0) = mean(Itemp(depth>0),'all');
    Ifixed(:,:,i)=Itemp;
end

% photon equalizer / white balancing 
if config.WB>0
    disp('PhotonEQ...');
    for i=1:3

            Ifixed(:,:,i)=Ifixed(:,:,i)*photonEQ(i);%*A(i);

    end
    %Ifixed = applyStatWB(Ifixed*255,depth,m,n,l,A)/255;
end

if config.WB==1
    [~,Ifixed]=wb_adj(Ifixed);
    %Ifixed=Ifixed*255;
end

disp('Converting Sensors space to viewable...');
Ifixed = convert_sensors2viewable(Ifixed,info);


%Ifixed=Ifixed/max(Ifixed,[],'all');

if config.WB==2
    [~,Ifixed]=wb_adj(Ifixed);
end

% figure();
% subplot 221; imshow(Ipre); title('Original');
% subplot 222; imshow(IremBS); title('BS removed');
% subplot 223; imshow(Ifixed); title('Attenuation fixed');

if config.plotAllStages
    figure(10)
    subplot 336
    imshow(Ifixed)
    title('Fixed, Post-WB');
end

%%apply contrast strech
if config.contStr
    disp('Stretching contrast...');
    Ifixed=cntStretch(Ifixed);
    % Ifixed=imadjust(Ifixed,stretchlim(Ifixed),[]);
%     rHist = imhist(Ifixed(:,:,1), 256);
%     [lims,~]=histsmartedges(rHist);
%     lims=lims/255;
%     Ifixed(:,:,1) = imadjust(Ifixed(:,:,1),lims,[]);   
    %Bhist=imhist(Ifixed(:,:,3),256);
    %Ifixed(:,:,1) = histeq(Ifixed(:,:,1),Bhist);
end

if config.plotAllStages
    figure(10)
    subplot 337
    imshow(Ifixed)
    title('Post Blackening/Contrast Stretch');
end

if config.WB==3
    disp('White Balancing...');
    [~,Ifixed]=wb_adj(Ifixed);
end
%subplot 224; imshow(IfixedHS); title('Hist Stretch');
%BS =convert_sensors2viewable(BS/255,info);

%saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
