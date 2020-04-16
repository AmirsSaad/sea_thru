import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time
from PIL import Image
from mpl_toolkits.axes_grid1 import make_axes_locatable
import warnings
# sklearn imports
from sklearn.feature_extraction import image
from sklearn.cluster import spectral_clustering, KMeans

warnings.filterwarnings(category=UserWarning, action="ignore")

start_time = time.time()
original_img = Image.open("sandbox/pallete.png")
grayscale_image = original_img.convert("L")  # convert to grayscale
img = np.array(grayscale_image)
img[img<100] = 255
# mask = img.astype(np.bool)
# img = img.astype(float) / 255
# plt.figure
plt.imshow(img)
plt.show()

# k_means = KMeans(n_clusters=10, max_iter=100)
# k_means.fit(img.reshape(-1,1))




# fig = plt.figure(figsize=(14,8))
# ax1 = fig.add_subplot(121)
# imsh = ax1.imshow(k_means.labels_.reshape(img.shape), cmap=plt.cm.rainbow)
# ax1.set_axis_off()
# divider = make_axes_locatable(ax1)
# cax = divider.append_axes("right", size="5%", pad=0.05)
# plt.colorbar(imsh, cax=cax)
# ax2 = fig.add_subplot(122)
# ax2.imshow(np.array(original_img))
# ax2.set_axis_off()
# print("total time: {:.3f} sec".format(time.time() - start_time))
# ax1.set_title('K-means with k = 3')
# plt.show()


# graph = image.img_to_graph(img=img, mask=mask)
# graph.data = np.exp(-graph.data / graph.data.std())  # build a graph with the gradients as weights
# labels = spectral_clustering(graph, n_clusters=20, eigen_solver='arpack')  # run spectral clustering
# label_im = np.full(mask.shape, -1.0)  # labels -> image
# label_im[mask] = labels  # assign correct labels
# plt.imshow(label_im)
# plt.show()
# img = np.array(grayscale_image)  # convert to np.array
# img[img==255] = 0  # zero-out the background, we don't care about it
# mask = img.astype(np.bool)  # create a mask for the graph-building function
# img = img.astype(float) / 255  # convert to numbers in [0,1]
# # img += 1 / 255 + (0.2 / 255) * np.random.randn(img.shape)  # add random noise

# graph = image.img_to_graph(img, mask=mask)  # build a graph with the gradients as weights
# graph.data = np.exp(-graph.data / graph.data.std())  # convert gradients to affinity

# labels = spectral_clustering(graph, n_clusters=60, eigen_solver='arpack')  # run spectral clustering
# label_im = np.full(mask.shape, -1.0)  # labels -> image
# label_im[mask] = labels  # assign correct labels

# fig = plt.figure(figsize=(14,8))
# ax1 = fig.add_subplot(121)
# imsh = ax1.imshow(label_im)#, cmap=plt.cm.rainbow)
# ax1.set_axis_off()
# divider = make_axes_locatable(ax1)
# cax = divider.append_axes("right", size="5%", pad=0.05)
# plt.colorbar(imsh, cax=cax)
# ax2 = fig.add_subplot(122)
# ax2.imshow(np.array(original_img))
# ax2.set_axis_off()
# print("total time: {:.3f} sec".format(time.time() - start_time))