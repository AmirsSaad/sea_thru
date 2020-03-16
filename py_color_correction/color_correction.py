import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# import tensorflow
from scipy.optimize import curve_fit

def plot(I,Bs):
    for (ch,color) in zip(I,['r','g','b']):
        plt.plot(I['dbins'],I[ch],color=color)

    for (ch,color) in zip(Bs,['r','g','b']):
        plt.plot(Bs['dbins'],Bs[ch],'.',color=color,markersize=3)

    fig = plt.figure(1)
    ax = fig.add_subplot(111)
    ax.set_xlabel('z[m]')
    ax.set_ylabel('Intensity')
    ax.legend([r"$E[I_R|z]$",r"$E[I_G|z]$",r"$E[I_B|z]$",r"$E_{0.5\%}[I_R|z]$",r"$E_{0.5\%}[I_G|z]$",r"$E_{0.5\%}[I_B|z]$"],bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
    ax.grid('on')
    plt.show()

if __name__ == "__main__":
    B = pd.read_csv('bs_0.02.csv')
    I = pd.read_csv('mean_hist.csv')
    z = I['dbins']

    ix = z>2
    b = B['b']/255
    # Binf = 1 #[0,1]
    # bB = 0 # [0,5]
    # J = 1 # [0,1]
    # bD = 0 # [0,5]
    
    # Bs_coeff = np.abs(B - Binf*(1 - np.exp(-bB*z)))
    # D_coeff = np.abs((I-B)-J*np.exp(-bD*z)) # replace B with estimator of B

    # x = np.ndarray(bB, bD , Binf , J)
    # L = lambda x : np.linalg.norm(x[2] + B['b'] - x[1]*(1 - np.exp(-x[0]*z)))
    # print(L0.5,0.5,0.5,0.5))

    def func(z,bB,Binf,offset):
        return Binf*(1 - np.exp(-bB*z)) + offset

    popt, pcov = curve_fit(func, z[ix], b[ix], bounds=(0, 20))

    print(popt)
    plt.plot(z, b, 'b-', label='data')
    plt.plot(z, func(z, *popt), 'g--',label='fit: a=%5.3f, b=%5.3f, c=%5.3f' % tuple(popt))
    plt.show()
    # x0 = [5,0.5,1]
    # print(minimize(L, x0, method='Nelder-Mead', tol=1e-6))