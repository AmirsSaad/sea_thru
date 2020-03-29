import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import accumulate_histograms,channel_depth_curve 
import pandas as pd
from os.path import join
import glob
import utils
import cv2

# data_path = r'C:\Users\amirsaa\Documents\GitHub\sea_thru\histogram_database\sensor_histograms\D5'
data_path = r'C:\Users\amirsaa\Documents\GitHub\sea_thru\histogram_database\sensor_histograms\D5' #
histograms_path_list = [x for x in glob.glob(join(data_path,'*.npy')) if (('rgb_bins' not in x) and ('depth_bins' not in x))]
rgb_bins = np.load(join(data_path,'rgb_bins.npy'))
dbins = np.load(join(data_path,'depth_bins.npy'))


bins = (rgb_bins[1:]+rgb_bins[:-1])/2
# dbins = (dbins[1:]+dbins[:-1])/2

H  = accumulate_histograms(histograms_path_list,bins,mean_shift='gray')

# print(H.shape)
plt.hist(bins, rgb_bins, weights=H[:,0,70])#.sum(axis=1)
plt.show()