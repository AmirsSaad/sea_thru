import cv2
import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import accumulate_histograms , plot_depth_quantized_histograms


# hist = utils.accumulate_histograms('D:/sea_thru/3148_3248/histograms/')
# lower,mid,upper = utils.depth_envelopes(hist)
# plt.plot(lower[0,:])
# plt.plot(mid[0,:])
# plt.plot(upper[0,:])

histogram = accumulate_histograms('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/T*')
# histogram = np.load('T_S03148.npy')
bins = np.load('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/bins.npy')
drange = np.arange(0.5,1.76,0.01)
plot_depth_quantized_histograms(histogram,bins,drange)

