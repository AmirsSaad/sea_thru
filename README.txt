%% main file to correct color is "run_experiment.m"
it uses an image list in "data.csv" and a config "config.json" which should be in an dedicated experiment folder (the path is hardcoded in run_experiment)

data.csv is can be created using python code: create_db_list.py
example config is in "matlab" folder

%% to create multi image stats -
1. convert to DNG (leave "linear (demo...)" unchecked)
2. run "sensor_dng_folder_2tiff.m" (change path)
3. run generate_histograms.py (change path) (if a plot shows up, close it)
4. run scene_statistics.py using: %%%change path and scene number
./scene_statistics.py -i /Users/oferhazut/Desktop/D4/hists -n D4 

then the csv should appear in "statistics" folder

%%%%%%%%

%% to tag photos, put them in evaluation/images, and run main.m
first crop the whole color palette (to later delete it from the image)
then select 4 corners, starting from white corner (right on its edge) and going clockwise (white, black, ....)

%% to eval grays
run "simple.m" - it will evaluate all images in the "images" folder

