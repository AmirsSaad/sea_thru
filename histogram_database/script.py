import cv2
import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import generate_depth_quantized_histograms, accumulate_histograms , plot_depth_quantized_histograms, depth_envelopes


# hist = utils.accumulate_histograms('D:/sea_thru/3148_3248/histograms/')
# lower,mid,upper = utils.depth_envelopes(hist)
# plt.plot(lower[0,:])
# plt.plot(mid[0,:])
# plt.plot(upper[0,:])

def main3():
    histogram = accumulate_histograms('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/T*')
    bins = np.load('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/bins.npy')
    bins = (bins[1:]+bins[:-1])/2
    channels = list()
    for c in range (3):
        depth = list()
        for d in range(histogram.shape[2]):
            depth.append(depth_envelopes(histogram[:,c,d],bins))
        channels.append(depth)
    
    colors = ['r','g','b']
    plt.figure
    for mid,color in zip(channels,colors):
        plt.plot(mid,color=color)

    plt.xlabel('Depth[cm]')
    plt.ylabel('Mean Histogram Value')
    plt.legend(['red channel','green channel','blue channel'])
    plt.grid()
    plt.savefig('C:\\Users\\amirsaa\Documents\GitHub\sea_thru\histogram_database\channel_depth_characterization.png',bbox_inches='tight',dpi=100)
    plt.show()


def main2():
    histogram = accumulate_histograms('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/T*')
    bins = np.load('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/bins.npy')
    drange = np.arange(0.5,1.76,0.01)
    plot_depth_quantized_histograms(histogram,bins,drange)

def main():
    generate_depth_quantized_histograms()

if __name__ == "__main__":
    main3()