import cv2
import numpy as np
from matplotlib import pyplot as plt
from os import listdir
import glob
import os
from os.path import join

def unused_rgb_histogram(img):
    color = ('r','g','b')
    for i,col in enumerate(color):
        plt.hist(img[:,:,i],bins=256,range=[0,256])
    plt.show()

def generate_depth_quantized_histograms(depths_path,raw_path,histogram_path,resume=True):
    
    dbins,depth_hist = generate_depth_histogram(depths_path,plot=True)
    dbins = dbins[1:-1]
    lower_bound = np.min(dbins[depth_hist[1:]>0],axis=0)
    upper_bound = np.max(dbins[depth_hist[1:]>0],axis=0)
    print("lower_bound: {}".format(lower_bound))
    print("upper_bound: {}".format(upper_bound))
    drange = np.arange(lower_bound,upper_bound+0.1,0.1)
    N = drange.shape[0]-1

    for raw_file in listdir(raw_path):

        if resume and os.path.exists(join(histogram_path,raw_file.replace('tif','npy'))):
            continue
        else:
            print("file name.:{}".format(raw_file))
            depth_file = 'depth' + raw_file
            depth_hist = np.zeros(shape=[256,3,N])
            bgr_img = cv2.imread(join(raw_path,raw_file))
            b,g,r = cv2.split(bgr_img)
            depth = cv2.imread(join(depths_path,depth_file),-1)
            d = cv2.resize(depth,r.T.shape)
            for i in range (N):
                norm = np.sum((d>drange[i]) & (d<drange[i+1]))
                if norm > 0 :
                    depth_hist[:,0,i] , bins =  np.histogram(r[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256],density=True)
                    depth_hist[:,1,i] , _ =  np.histogram(g[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256],density=True)
                    depth_hist[:,2,i] , _ =  np.histogram(b[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256],density=True)
            
            np.save(join(histogram_path,raw_file.replace('tif','npy')),depth_hist)

    np.save(join(histogram_path,'rgb_bins.npy'),bins)
    np.save(join(histogram_path,'depth_bins.npy'),drange)

def generate_depth_histogram(depthMaps_path,plot=False,figrue_save_path=None):
    
    drange = np.arange(0,11,0.01)
    depth_hist = np.zeros(drange.shape[0]-1)
    for i,depth_file in enumerate(listdir(depthMaps_path)):         
        depth = cv2.imread(join(depthMaps_path,depth_file),-1)
        print(depth_file)
        temp_hist , bins = np.histogram(depth,bins = drange)
        depth_hist += temp_hist

    if plot:
        plt.figure()
        plt.hist(bins[:-1], bins, weights=depth_hist)    
        plt.show()
        if figrue_save_path:
            plt.savefig(os.path.join(figrue_save_path,'depth_histogram'))
    
    return(bins,depth_hist)
    
def verify_histogram(histograms_path_list):
    for i,file in enumerate(histograms_path_list):
        hist = np.load(file)
        print(np.sum(hist[:,0,:]))
        break

def accumulate_histograms(histograms_path_list,rgb_bins,mean_shift='gray'):
    
    for i,file in enumerate(histograms_path_list):
        hist = np.load(file)
        if i==0:
            summed_histogram = hist
        else:
            summed_histogram += hist

    mean_val = None
    if mean_shift == 'gray':
        gray = 0.2989 * summed_histogram[:,0,:] + 0.5870 * summed_histogram[:,1,:] + 0.1140 * summed_histogram[:,2,:]
        mean_val = np.sum(np.multiply(np.sum(gray,axis=1),rgb_bins))/np.sum(gray)
        print(mean_val)
    for i,file in enumerate(histograms_path_list):
        hist = np.load(file)
        if mean_val:
            gray = 0.2989 * hist[:,0,:] + 0.5870 * hist[:,1,:] + 0.1140 * hist[:,2,:]
            hist_mean = np.sum(np.multiply(np.sum(gray,axis=1),rgb_bins))/np.sum(gray)
            if hist_mean-mean_val > 0:
                shift = int(hist_mean-mean_val)
                tmp = np.delete(hist,range(shift),axis=0)
                hist = np.concatenate((tmp,np.zeros((shift,hist.shape[1],hist.shape[2]))))
            else:
                shift = int(hist_mean-mean_val)
                tmp = np.delete(hist,range(256+shift,256),axis=0)
                hist = np.concatenate((np.zeros((-shift,hist.shape[1],hist.shape[2])),tmp))



        if i==0:
            summed_histogram = hist
        else:
            summed_histogram += hist
    return(summed_histogram)

def depth_envelopes(histogram,bins):
    histogram =  histogram/np.sum(histogram)
    low_idx = np.cumsum(histogram)<0.005
    low = np.sum(np.multiply(histogram[low_idx],bins[low_idx])) / (np.sum(histogram[low_idx])+0.0001)
    mid = np.sum(np.multiply(histogram,bins))
    # high = np.where(np.cumsum(histogram)>0.95)[0][0]
    return(mid,low)
    # return([low,mid,high])

def channel_depth_curve(histogram , rgb_bins ):
    channels = list()
    bs_channels = list()
    for d in range(histogram.shape[2]):
        depth = list()
        bs_depth = list()
        for c in range (3):
            depth.append(depth_envelopes(histogram[:,c,d],rgb_bins)[0])
            bs_depth.append(depth_envelopes(histogram[:,c,d],rgb_bins)[1])
        channels.append(depth)
        bs_channels.append(bs_depth)
    return(channels,bs_channels)

def npy2mat():
    # data = np.load(r"C:\Users\amirsaa\Documents\sea_thru_data\D3\histograms_linear\T_S04869.npy")
    # depth_bins = np.load(r"C:\Users\amirsaa\Documents\sea_thru_data\D3\histograms_linear\depth_bins.npy")
    # rgb_bins = np.load(r"C:\Users\amirsaa\Documents\sea_thru_data\D3\histograms_linear\rgb_bins.npy")
    # scipy.io.savemat('T_S04869.mat', dict(data=data,depth_bins=depth_bins,rgb_bins=rgb_bins))
    pass

