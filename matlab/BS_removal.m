

meanH=importdata('mean_hist_0.02.csv',',');
lowH=importdata('bs_0.05.csv',',');

BScoefs = fitBSModel(meanH,lowH);
modeledBShist=BScoefs(:,1)'.*(1-exp(-((meanH.data(:,5))*BScoefs(:,2)')));
meanHpostBS=meanH.data(:,2:4)-modeledBShist;
AttenCoeffs=fitAttenModel(meanHpostBS,meanH.data(:,5));
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
[IremBS,BS] = removeBS(I*255,depth,[ BScoefs [0;0;0] ]);
IremBS=AttenFix(IremBS,depth,AttenCoeffs,1);
IpostBS = convert_sensors2viewable(IremBS/255,info);
Ipre = convert_sensors2viewable(I,info);
figure();
imshowpair(Ipre,IpostBS,'montage');
%BS =convert_sensors2viewable(BS/255,info);

saveas(gcf,[savepath,strrep(dngs(file).name,'.dng','.png')])

end
close all;