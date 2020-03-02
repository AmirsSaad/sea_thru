import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import accumulate_histograms,channel_depth_curve 
import pandas as pd
from os.path import join
import glob
import utils
import cv2

def scene_statistics(data_path):
    histograms_path_list = [x for x in glob.glob(join(data_path,'*.npy')) if (('rgb_bins' not in x) and ('depth_bins' not in x))]
    rgb_bins = np.load(join(data_path,'rgb_bins.npy'))
    dbins = np.load(join(data_path,'depth_bins.npy'))
    
    
    rgb_bins = (rgb_bins[1:]+rgb_bins[:-1])/2
    dbins = (dbins[1:]+dbins[:-1])/2

    accum_histogram = accumulate_histograms(histograms_path_list,rgb_bins)
    channels,bs_channels = channel_depth_curve(histogram=accum_histogram,rgb_bins=rgb_bins,low_percentile=0.01)
    mean_hist = pd.DataFrame.from_records(channels)
    mean_hist.columns=(['r','g','b'])
    mean_hist = mean_hist.interpolate()
    mean_hist['dbins'] = dbins

    for (ch,color) in zip(mean_hist,['r','g','b']):
        plt.plot(dbins,mean_hist[ch],color=color)
    
    bs = pd.DataFrame.from_records(bs_channels)
    bs.columns=(['r','g','b'])
    bs['dbins'] = dbins

    for (ch,color) in zip(bs,['r','g','b']):
        plt.plot(dbins,bs[ch],'.',color=color,markersize=3)

    # plt.ylim([0,70])
    fig = plt.figure(1)
    ax = fig.add_subplot(111)
    ax.set_xlabel('z[m]')
    ax.set_ylabel('Intensity')
    lgd = ax.legend([r"$E[I_R|z]$",r"$E[I_G|z]$",r"$E[I_B|z]$",r"$E_{0.5\%}[I_R|z]$",r"$E_{0.5\%}[I_G|z]$",r"$E_{0.5\%}[I_B|z]$"],bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
    ax.grid('on')
    fig.savefig('histogram_statistics/figs/D5_sensor.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
    
    mean_hist.to_csv('mean_hist_0.01.csv')
    bs.to_csv('bs_0.01.csv')
if __name__ == "__main__":
    scene_statistics(data_path = 'C:/Users/amirsaa/Documents/sea_thru_data/D5/sensor_histograms')
    
    # from utils import generate_depth_histogram
    # generate_depth_histogram('C:/Users/amirsaa/Documents/sea_thru_data/D5/depthMaps',plot=True,figrue_save_path=r"C:/Users/amirsaa/Documents/GitHub/sea_thru/histogram_statistics/figs/D5_sensor_dhist.png")
    
    # from utils import generate_depth_quantized_histograms
    # generate_depth_quantized_histograms(r"C:/Users/amirsaa/Documents/sea_thru_data/D5/depthMaps",r"C:/Users/amirsaa/Documents/sea_thru_data/D5/sensor_tifs",r"C:/Users/amirsaa/Documents/sea_thru_data/D5/sensor_histograms")