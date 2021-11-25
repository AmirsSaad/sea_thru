# Underwater Image Color Correction using the Sea-thru model
We present our take on Sea-thru ( http://csms.haifa.ac.il/profiles/tTreibitz/webfiles/sea-thru_cvpr2019.pdf ), a method for color correction of underwater images, including a new approach for the physical model’s coeﬃcients estimation and its practical implementation. Using a single or multiple underwater images and their depth maps we output a physically corrected image.
![]()
<img src="report/figs/fixProcessSteps/01_Orig.jpg"
     alt="Original image"
     style="width:300px;" /><img src="report/figs/fixProcessSteps/07_IcontrastStr.jpg"
     alt="Corrected image"
     style="width:300px;" />
## Image formation model
The formation model discussed in the 2019 paper, treats each pixel as a sum of two physical phenomena.

<img src="https://latex.codecogs.com/gif.download?I_c%28z%29%20%3D%20%5Cunderbrace%7BJ_%7Bc%7D%5E%7BD%7D%5Ccdot%20e%5E%7B-%5Cbeta_%7Bc%7D%5E%7BD%7D%5Ccdot%20z%7D%7D_%7BAL_%7Bc%7D%7D+%5Cunderbrace%7BB_%7Bc%7D%5E%7B%5Cinfty%7D%5Cleft%281-e%5E%7B-%5Cbeta_%7Bc%7D%5E%7BB%7D%5Ccdot%20z%7D%5Cright%29%7D_%7BBS_%7Bc%7D%7D" alt="[Image Formation Model">

The ﬁrst is the attenuated light reﬂected from an object, and is absorbed or scattered away by the medium (water) on its way to the camera (denoted by AL, Attenuated Light). The second is light arriving from other objects in the area that is scattered by the medium towards the camera (denoted by BS, Backscatter). The formation model is shown  with a subscript $c$ which represents one of the RGB color channels. The AL term decays exponentially over distance $z$, at a rate deﬁned by $\beta_c^D$ from its initial (“real”/open-air) intensity $J_c^D$ and the BS is a growing term at a rate deﬁned by $\beta_c^B$ until it saturates at $B_c^{\infty}$ . These coeﬃcients and their physical justiﬁcation are broadly discussed in the 2019 paper.

## Optimization Problem
We designed the following Lagrangian $\mathcal{L}_{c}(v_{c},z)$ which we minimize in our optimization problem:


<img src="https://latex.codecogs.com/gif.download?%5Cbegin%7Baligned%7D%20%5Cmathcal%7BL%7D_%7Bc%7D%28v_%7Bc%7D%2Cz%29%3D%20%26%5Cunderbrace%7B%5Ceta%28I_%7Bc%7D%5E%7Blp%7D-BS_%7Bc%7D%29%5E%7B2%7D%7D_%7B%5Ctext%7BBackscatter/lower%20percentile%20vector%20reconstruction%20loss%7D%7D%20%5Ccr%20+%26%20%5Cunderbrace%7B%5Cmu%5Cleft%5Bmax%5Cleft%280%2CBS_%7Bc%7D-I_%7Bc%7D%5E%7Blp%7D%5Cright%29%5Cright%5D%5E%7B2%7D%7D_%7B%5Ctext%7BBS%20upper%20barrier%20function%7D%7D%20%5Ccr%20+%26%20%5Cunderbrace%7B%5Csum_%7B_%7Bi%5Cin%5C%7Blp%2Chp%2Cmean%5C%7D%7D%7D%5Cleft%5B%28I_%7Bc%7D%5E%7B%28i%29%7D-BS_%7Bc%7D%29-AL_%7Bc%7D%5E%7B%28i%29%7D%5Cright%5D%5E%7B2%7D%7D_%7B%5Ctext%7BAL%20Intensity%20vectors%20reconstruction%20loss%7D%7D%20%5Ccr%20+%26%5Cunderbrace%7B%5Clambda%5E%7B%28i%29%7D%5Cleft%5Bmax%5Cleft%280%2C%5Cleft%28I_%7Bc%7D%5E%7B%28i%29%7D-BS_%7Bc%7D%5Cright%29-AL_%7Bc%7D%5E%7B%28i%29%7D%5Cright%29%5Cright%5D%5E%7B2%7D%7D_%7B%5Ctext%7BAL%20Lower%20barrier%20function%7D%7D%5C%5C%20+%26%5Cunderbrace%7B%5Cgamma%5Cleft%5Bvar%28I_%7Bc%7D%29-%5Csigma_%7BcD%7D%5E%7B2%7De%5E%7B-2%5Cfrac%7Ba%7D%7B%5Csqrt%7Bb+z%7D%7D%5Ccdot%20z%7D-%5Csigma_%7BcB%7D%5E%7B2%7De%5E%7B-2%5Cbeta_%7Bc%7D%5E%7BB%7D%5Ccdot%20z%7D%5Cright%5D%5E%7B2%7D%7D_%7B%5Ctext%7BIntensity%20color%20variance%20loss%7D%7D%20%5Cend%7Baligned%7D" alt="Lagrangian">

$$I_c(z) = \underbrace{J_{c}^{D}\cdot e^{-\beta_{c}^{D}\cdot z}}_{AL_{c}}+\underbrace{B_{c}^{\infty}\left(1-e^{-\beta_{c}^{B}\cdot z}\right)}_{BS_{c}}$$

<img src="https://render.githubusercontent.com/render/math?math=I_c(z) = \underbrace{J_{c}^{D}\cdot e^{-\beta_{c}^{D}\cdot z}}_{AL_{c}}+\underbrace{B_{c}^{\infty}\left(1-e^{-\beta_{c}^{B}\cdot z}\right)}_{BS_{c}}">

$$
\begin{aligned}
\mathcal{L}_{c}(v_{c},z)= &\underbrace{\eta(I_{c}^{lp}-BS_{c})^{2}}_{\text{Backscatter/lower percentile vector reconstruction loss}} \cr
+& \underbrace{\mu\left[max\left(0,BS_{c}-I_{c}^{lp}\right)\right]^{2}}_{\text{BS upper barrier function}} \cr
+& \underbrace{\sum_{_{i\in\{lp,hp,mean\}}}\left[(I_{c}^{(i)}-BS_{c})-AL_{c}^{(i)}\right]^{2}}_{\text{AL Intensity vectors reconstruction loss}} \cr
+&\underbrace{\lambda^{(i)}\left[max\left(0,\left(I_{c}^{(i)}-BS_{c}\right)-AL_{c}^{(i)}\right)\right]^{2}}_{\text{AL Lower barrier function}}\\
+&\underbrace{\gamma\left[var(I_{c})-\sigma_{cD}^{2}e^{-2\frac{a}{\sqrt{b+z}}\cdot z}-\sigma_{cB}^{2}e^{-2\beta_{c}^{B}\cdot z}\right]^{2}}_{\text{Intensity color variance loss}}
\end{aligned}
$$
