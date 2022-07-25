import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties
from scipy import signal

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

t = np.linspace(0, 400, 10000)

# Escalón positivo de resistencia

iL_R_20_40 = np.genfromtxt('Datos/iL_R_20_40.txt', delimiter=',')
u_R_20_40 = np.genfromtxt('Datos/u_R_20_40.txt', delimiter=',')

b, a = signal.butter(25, 0.15)
zi = signal.lfilter_zi(b, a)
u_R_20_40 = signal.filtfilt(b, a, u_R_20_40)*24/11520

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Escalón positivo de resistencia de 20Ω a 40Ω', x=0.5, y=0.96)
ax1.plot(t, u_R_20_40, '#00575f', linewidth=0.8)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
ax2.plot(t, iL_R_20_40*1.2746972e-4+2.145124, '#00575f', linewidth=0.8)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Escalón positivo de resistencia.pdf')

# Escalón negativo de resistencia

iL_R_40_20 = np.genfromtxt('Datos/iL_R_40_20.txt', delimiter=',')
u_R_20_40 = np.genfromtxt('Datos/u_R_40_20.txt', delimiter=',')

b, a = signal.butter(25, 0.15)
zi = signal.lfilter_zi(b, a)
u_R_40_20 = signal.filtfilt(b, a, u_R_20_40)*24/11520

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Escalón negativo de resistencia de 40Ω a 20Ω', x=0.5, y=0.96)
ax1.plot(t, u_R_40_20, '#00575f', linewidth=0.8)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
ax2.plot(t, iL_R_40_20*1.2746972e-4+2.145124, '#00575f', linewidth=0.8)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Escalón negativo de resistencia.pdf')

# # Escalón negativo de tensión

# iL_V_24_23 = np.genfromtxt('Datos/iL_V_24_23.txt', delimiter=',')
# u_V_24_23 = np.genfromtxt('Datos/u_V_24_23.txt', delimiter=',')
# t = np.linspace(0, 4, 10000)

# b, a = signal.butter(25, 0.15)
# zi = signal.lfilter_zi(b, a)
# # u_V_24_23 = signal.filtfilt(b, a, u_V_24_23)

# fig, (ax1, ax2) = plt.subplots(2)
# fig.suptitle('Escalón negativo de tensión de 24V a 23V', x=0.5, y=0.96)
# ax1.plot(t, u_V_24_23*23/11234, '#00575f', linewidth=0.8)
# ax1.grid(True, ls="-", linewidth=0.4)
# ax1.set(ylabel='Tensión [V]')
# ax2.plot(t, iL_V_24_23, '#00575f', linewidth=0.8)
# ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
# ax2.grid(True, ls="-", linewidth=0.4)

# for ax in fig.get_axes():
#     ax.label_outer()

# plt.savefig('Escalón negativo de tensión.pdf')
