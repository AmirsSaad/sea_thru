import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import accumulate_histograms,channel_depth_curve 
import pandas as pd
from os.path import join
import glob
import utils
import cv2
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i","--histogram_dir",type=str,required=True)
    parser.add_argument('-n','--db_name',required=True)
    parser.add_argument('-lp',type=float,default=0.01)
    parser.add_argument('-norm',action='store_true',default=False)
    return parser.parse_args()
    

def scene_statistics(data_path , db_name ,lp ,norm):
    histograms_path_list = [x for x in glob.glob(join(data_path,'*.npy')) if (('rgb_bins' not in x) and ('depth_bins' not in x))]
    rgb_bins = np.load(join(data_path,'rgb_bins.npy'))
    dbins = np.load(join(data_path,'depth_bins.npy'))
    
    
    rgb_bins = (rgb_bins[1:]+rgb_bins[:-1])/2
    dbins = (dbins[1:]+dbins[:-1])/2
    
    accum_histogram = accumulate_histograms(histograms_path_list,rgb_bins,mean_shift=norm)
    channels,bs_channels = channel_depth_curve(histogram=accum_histogram,rgb_bins=rgb_bins,low_percentile=lp)
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
    is_norm = 'normalized' if norm else 'unnormalized'
    lgd = ax.legend([r"$E[I_R|z]$",r"$E[I_G|z]$",r"$E[I_B|z]$",r"$E_{0.5\%}[I_R|z]$",r"$E_{0.5\%}[I_G|z]$",r"$E_{0.5\%}[I_B|z]$"],bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
    ax.grid('on')
    ax.set_ylim(0,35)
    fig.savefig('histogram_statistics/figs/'+db_name+ '_'+ str(lp)+ '_' + is_norm +'_sensor.v5.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
    
    mean_hist.to_csv('statistics/mean_hist_'+db_name+ '_' + is_norm +'.v5.csv',index=False)
    bs.to_csv('statistics/bs_' +db_name+ '_'+ str(lp)+ '_' + is_norm +'.v5.csv',index=False)

if __name__ == "__main__":

    args = parse_args()
    norm = 'gray' if args.norm else None  

    scene_statistics(data_path = args.histogram_dir,db_name = args.db_name , lp = args.lp , norm = norm)



    
    
    
    