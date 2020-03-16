
close all;
strMeanHist='mean_hist_0.02.csv';
strBSHist='bs_0.02.csv';

[JD,betaD,Binf,betaB,zOS,C,photonEQ] = fitPhyModel(strMeanHist,strBSHist,[0.5 0.5 0.5],1);

close all;
folder = 'sandbox/D5/';
savepath = 'sandbox/D5/pairsAtten/';
dngs = dir([folder,'*.dng']);
deps = dir([folder,'*.tif']);
files=length(dngs);folder
for file = 1:files
file_path = [folder,dngs(file).name];
[I,info] = convert_dng2sensor(file_path);
file_path = [folder,deps(file).name];
depth=imread(file_path);

depth(depth==0)=max(max(depth));

[IremBS,BS] = removeBS(I*255,depth,[Binf' betaB' zOS']);
Ifixed=AttenFix(IremBS,depth,[JD' betaD' C'],1);
for i=1:3
    Ifixed(:,:,i)=Ifixed(:,:,i)*photonEQ(i);
end
IremBS = convert_sensors2viewable(IremBS/255,info);
Ifixed = convert_sensors2viewable(Ifixed/255,info);
Ipre = convert_sensors2viewable(I,info);
figure();
subplot 221; imshow(Ipre); title('Original');
subplot 222; imshow(IremBS); title('BS removed');
subplot 223; imshow(Ifixed); title('Attenuation fixed');
subplot 224; imshow(imadjust(Ifixed,stretchlim(Ifixed),[])); title('Hist Stretch');
%BS =convert_sensors2viewable(BS/255,info);

saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
close all;