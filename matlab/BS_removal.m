[I,info] = convert_dng2sensor('sandbox/D5/LFT_3399.dng');
depth=imread('sandbox/D5/depthLFT_3399.tif');

meanH=importdata('mean_hist_0.02.csv',',');
lowH=importdata('bs_0.02.csv',',');

coefs = fitModel(meanH,lowH);

[IremBS,BS] = removeBS(I*255,depth,coefs);

Ifinal =convert_sensors2viewable(IremBS/255,info);
BS =convert_sensors2viewable(BS/255,info);
