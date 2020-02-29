from utils import generate_depth_quantized_histograms
from os.path import join


if __name__ == "__main__":
    data_path = r"C:\Users\amirsaa\Documents\sea_thru_data\\D5"
    depths_path = join(data_path,"depthMaps")
    raw_path = join(data_path,"tifs")
    histogram_path = join(data_path,"histograms")
    generate_depth_quantized_histograms(depths_path,raw_path,histogram_path)