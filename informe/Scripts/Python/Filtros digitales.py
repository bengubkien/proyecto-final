import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib import rc

rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
rc('text', usetex=True)


t = np.loadtxt('Datos/t.txt')
y = np.loadtxt('Datos/y.txt')
y_filtered = np.loadtxt('Datos/y_filtered.txt')

plt.figure('Corriente filtrada a 1.5kHz')
plt.rc('text', usetex=True)
plt.rc('font', family='serif')

plt.title(r'\textit{Corriente filtrada}', pad=11)
plt.plot(t/1e-3, y_filtered, '#d9534f', linewidth=0.8)
plt.xlabel(r'\textit{Tiempo (ms)}')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Simulación en Simulink.pdf')