from utils import generate_depth_quantized_histograms

depths_path = r'C:\Users\amirsaa\Documents\sea_thru_data\D5\depthMaps'
raw_path = r'C:\Users\amirsaa\Documents\sea_thru_data\D5\tifs_v4'
histogram_path = r'C:\Users\amirsaa\Documents\sea_thru_data\D5\histograms_v4'

generate_depth_quantized_histograms(depths_path , raw_path , histogram_path )