import matplotlib.pyplot as plt
import os
import numpy as np
from scipy import signal
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

t = np.loadtxt('Datos/t.txt')
t_clamping = np.loadtxt('Datos/t-clamping.txt')
integrator = np.loadtxt('Datos/integrator.txt')
u = np.loadtxt('Datos/u.txt')
integrator_clamping = np.loadtxt('Datos/integrator-clamping.txt')
u_clamping = np.loadtxt('Datos/u-clamping.txt')

# Tensión de carga

plt.figure('Overflow del integrador')
plt.title('Overflow del integrador', pad=11)
plt.plot(t, u, '#7fafb0', linewidth=0.9)
plt.plot(t, integrator/pow(2,16), '#00575f',  linewidth=0.9)
plt.grid(True, ls="-", linewidth=0.4)
plt.xlabel('Tiempo [s]')
plt.legend(['Acción de control', 'Integrador'])

plt.savefig('Overflow del integrador.pdf')

# Acción de control de tensión

plt.figure('Integrador con clamping')
plt.title('Integrador con clamping', pad=11)
plt.plot(t_clamping, u_clamping, '#7fafb0', linewidth=0.9)
plt.plot(t_clamping, integrator_clamping/pow(2,16), '#00575f',  linewidth=0.9)
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
plt.legend(['Acción de control', 'Integrador'])

plt.savefig('Integrador con clamping.pdf')