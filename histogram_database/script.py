import cv2
import numpy as np
from matplotlib import pyplot as plt
from os import listdir
from utils import generate_depth_quantized_histograms, accumulate_histograms , plot_depth_quantized_histograms, depth_envelopes
from utils import channel_depth_curve
from utils import generate_depth_histogram
import pandas as pd



def main3():

    channels = channel_depth_curve()
    df = pd.DataFrame.from_records(channels)
    df.columns=(['r','g','b'])
    df = df.interpolate()
    # df = df - df.mean()
    # print(df)
    for (ch,color) in zip(df,['r','g','b']):
        plt.plot(df[ch],color=color)

    plt.plot(df.b.div(df.r))
    # df[['b']].div(df.r, axis=0)


    

    # print(channel_stat)
    # print(np.mean(blue))
    # # print(blue-np.mean(blue))
    # # print(red-np.mean(red))
    # plt.plot((blue-np.mean(blue)),color='b')
    # plt.plot(2*(red-np.mean(red)),color='r')
    # plt.plot(blue-red)
    plt.show()

def main2():
    histogram = accumulate_histograms('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/T*')
    bins = np.load('C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/bins.npy')
    drange = np.arange(0.5,1.76,0.01)
    plot_depth_quantized_histograms(histogram,bins,drange)

def main():
    generate_depth_quantized_histograms()

if __name__ == "__main__":
    main()
    # generate_depth_histogram('C:\\Users/amirsaa/Documents/sea_thru_data/3047_3147/depthMaps/','C:\\Users\\amirsaa\Documents\\sea_thru_data\\3047_3147')
    