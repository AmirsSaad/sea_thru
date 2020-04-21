import os
import pandas as pd 
# from sklearn.model_selection import train_test_split

data_paths = {
    # "D1" : {"dng_path": r"D:\sea_thru\D1\dng" , "depth_path": r"D:\sea_thru\D1\depthMaps"},
    # "D2" : {"dng_path": r"D:\sea_thru\D2\dng" , "depth_path": r"D:\sea_thru\D2\depthMaps"},
    "D3" : {"dng_path": r"D:\sea_thru\D3\dng_sensor" , "depth_path": r"D:\sea_thru\D3\depthMaps"},
    "D5" : {"dng_path": r"D:\sea_thru\D5\dng_sensor" , "depth_path": r"D:\sea_thru\D5\depthMaps"}
}

dng , depth , db = [] , [] , []

for d , paths in data_paths.items():
    for file in os.listdir(paths['dng_path']):
        dfile = 'depth'+file.replace('dng','tif')
        assert os.path.exists(os.path.join(paths['depth_path'],dfile))
        dng.append(os.path.join(paths['dng_path'],file))
        depth.append(os.path.join(paths['depth_path'],dfile))
        db.append(d)

df = pd.DataFrame({"dng":dng,"depth":depth,"db":db})
df.sample(frac=1).to_csv(r'D:\sea_thru_experiments\04_20__00_57\data.csv',index=False)


