import os
import pandas as pd 
import sys
# from sklearn.model_selection import train_test_split

data_paths = {
#    "D1" : {"dng_path": r"sandbox/D1/dng_sensor" , "depth_path": r"sandbox/D1/depthMaps"},
 #   "D2" : {"dng_path": r"sandbox/D2/dng_sensor" , "depth_path": r"sandbox/D2/depthMaps"},
  #  "D3" : {"dng_path": r"sandbox/D3/dng_sensor" , "depth_path": r"sandbox/D3/depthMaps"},
   # "D4" : {"dng_path": r"sandbox/D4/dng_sensor" , "depth_path": r"sandbox/D4/depthMaps"},
    #"D5" : {"dng_path": r"sandbox/D5/dng_sensor" , "depth_path": r"sandbox/D5/depthMaps"}
    "D1" : {"dng_path": r"sandbox/PLTs/D1/dng_sensor" , "depth_path": r"sandbox/PLTs/D1/depthMaps"},
    "D2" : {"dng_path": r"sandbox/PLTs/D2/dng_sensor" , "depth_path": r"sandbox/PLTs/D2/depthMaps"},
    "D3" : {"dng_path": r"sandbox/PLTs/D3/dng_sensor" , "depth_path": r"sandbox/PLTs/D3/depthMaps"},
    "D4" : {"dng_path": r"sandbox/PLTs/D4/dng_sensor" , "depth_path": r"sandbox/PLTs/D4/depthMaps"},
    "D5" : {"dng_path": r"sandbox/PLTs/D5/dng_sensor" , "depth_path": r"sandbox/PLTs/D5/depthMaps"}
}

dng , depth , db = [] , [] , []

for d , paths in data_paths.items():
    for file in os.listdir(paths['dng_path']):
        if file != '.DS_Store':
            dfile = 'depth'+file.replace('dng','tif')
            #print(file)
            assert os.path.exists(os.path.join(paths['depth_path'],dfile))
            dng.append(os.path.join(paths['dng_path'],file))
            depth.append(os.path.join(paths['depth_path'],dfile))
            db.append(d)

df = pd.DataFrame({"dng":dng,"depth":depth,"db":db})
df.to_csv(r'data.csv',index=False)


