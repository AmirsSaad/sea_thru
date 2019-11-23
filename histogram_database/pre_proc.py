import numpy as np
np.set_printoptions(precision=2)
from os import listdir
import cv2

def main():
    raw_folder = 'C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/tifs/'
    depth_folder = 'C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/depthMaps/'
    histograms = 'C:/Users/amirsaa/Documents/sea_thru_data/3148_3248/histograms/'
    # raw_file = 'T_S03148.tif'
    # depth_file = 'depthT_S03148.tif'


    drange = np.arange(0.5,1.76,0.01)
    N = drange.shape[0]-1

    for raw_file in listdir(raw_folder):
        print("file name.:{}".format(raw_file))
        depth_file = 'depth' + raw_file
        depth_hist = np.empty(shape=[256,3,N])
        bgr_img = cv2.imread(raw_folder+raw_file)
        b,g,r = cv2.split(bgr_img)
        depth = cv2.imread(depth_folder+depth_file,-1)
        d = cv2.resize(depth,(8000,5320))
        cv2.imshow('image',r)
        input()
        break
        for i in range (N):
                norm = np.sum((d>drange[i]) & (d<drange[i+1]))
                if norm > 0 :
                    depth_hist[:,0,i] , bins =  np.histogram(r[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256])
                    depth_hist[:,1,i] , _ =  np.histogram(g[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256])
                    depth_hist[:,2,i] , _ =  np.histogram(b[(d>drange[i]) & (d<drange[i+1])],bins=256,range=[0,256])
                    depth_hist[:,:,i] /=norm
        np.save(histograms + raw_file.replace('tif','npy'),depth_hist)

    # np.save('bins',bins)
if __name__== '__main__':
    main()