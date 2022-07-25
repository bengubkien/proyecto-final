import matplotlib.pyplot as plt
import os
import numpy as np
from scipy import signal
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

t = np.loadtxt('Datos/t.txt')
x_32 = np.loadtxt('Datos/x_32.txt')
x_64 = np.loadtxt('Datos/x_64.txt')
u_32 = np.loadtxt('Datos/u_32.txt')
u_64 = np.loadtxt('Datos/u_64.txt')

# Tensión de carga

plt.figure('Tensión de carga con un control de 24V')
plt.title('Tensión de carga con un control a 24V', pad=11)
plt.plot(t[85000:], x_32[85000:], '#7fafb0', linewidth=0.9)
plt.plot(t[85000:], x_64[85000:], '#00575f',  linewidth=0.9)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)
plt.legend(['sfix32_En16', 'sfix32_En24'])
plt.yticks([12, 24, 23])

plt.savefig('Tensión de carga.pdf')

# Acción de control de tensión

plt.figure('Acción de control de tensión')
plt.title('Acción de control de tensión', pad=11)
plt.plot(t[85000:], u_32[85000:]/pow(2,16), '#7fafb0', linewidth=0.9)
plt.plot(t[85000:], u_64[85000:]/pow(2,16), '#00575f',  linewidth=0.9)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)
plt.legend(['sfix32_En16', 'sfix32_En24'])
# plt.yticks([12, 24, 23])

plt.savefig('Acción de control de tensión.pdf')

# Acción de control de tensión en detalle

# plt.figure('Acción de control de tensión en detalle')
# plt.title('Acción de control de tensión en detalle', pad=11)
# plt.plot(t[165000:165050], u_32[165000:165050]/pow(2,16), '#7fafb0', linewidth=0.9)
# plt.plot(t[165000:165050], u_64[165000:165050]/pow(2,16), '#00575f',  linewidth=0.9)
# plt.ylabel('Corriente [A]')
# plt.xlabel('Tiempo [ms]')
# plt.grid(True, ls="-", linewidth=0.4)
# plt.legend(['sfix32_En16', 'sfix32_En24'])
# # plt.yticks([12, 24, 23])

# plt.savefig('Acción de control de tensión en detalle.pdf')