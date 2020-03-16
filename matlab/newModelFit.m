
close all;
strMeanHist='mean_hist_0.02.csv';
strBSHist='bs_0.05.csv';
lambda=ones(1,3)*2;
[JD,betaD,Binf,betaB,zOS,C,photonEQ,ratiovec,z] = fitPhyModel(strMeanHist,strBSHist,lambda,1);

close all;
folder = 'sandbox/D5/';
savepath = 'sandbox/D5/pairsAtten/';
dngs = dir([folder,'*.dng']);
deps = dir([folder,'*.tif']);
files=length(dngs);
for file = 1:files
file_path = [folder,dngs(file).name];
[I,info] = convert_dng2sensor(file_path);
file_path = [folder,deps(file).name];
depth=imread(file_path);

% fix depth map zeros to far
depth(depth==0)=max(max(depth));

%remove backscatter with modeled coefs
[IremBS,BS] = removeBS(I*255,depth,[Binf' betaB' zOS']);

% fix attenuation (ver=1 model with c, ver=2 model without c, ver=3 with ratio vector)
Ifixed=AttenFix(IremBS,depth,[JD' betaD' C'],1);
%Ifixed=AttenFix(IremBS,depth,[ratiovec z],3);

% photon equalizer / white balancing 
for i=1:3
    Ifixed(:,:,i)=Ifixed(:,:,i)*photonEQ(i);
end

% from sensors data to viewable photo
IremBS = convert_sensors2viewable(IremBS/255,info);
Ifixed = convert_sensors2viewable(Ifixed/255,info);
Ipre = convert_sensors2viewable(I,info);


figure();
subplot 221; imshow(Ipre); title('Original');
subplot 222; imshow(IremBS); title('BS removed');
subplot 223; imshow(Ifixed); title('Attenuation fixed');
IfixedHS=imadjust(Ifixed,stretchlim(Ifixed),[]);
subplot 224; imshow(IfixedHS); title('Hist Stretch');
%BS =convert_sensors2viewable(BS/255,info);

saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
close all;