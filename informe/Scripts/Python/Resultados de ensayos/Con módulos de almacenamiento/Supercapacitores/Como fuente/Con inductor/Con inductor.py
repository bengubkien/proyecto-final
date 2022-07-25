import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties
from scipy import signal

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

# Escalón positivo de resistencia

ii_20_40 = np.genfromtxt('Datos/ii_20_40.txt', delimiter=',')
iC_20_40 = np.genfromtxt('Datos/iC_20_40.txt', delimiter=',')
u_20_40 = np.genfromtxt('Datos/u_20_40.txt', delimiter=',')
ii_40_20 = np.genfromtxt('Datos/ii_40_20.txt', delimiter=',')
iC_40_20 = np.genfromtxt('Datos/iC_40_20.txt', delimiter=',')
u_40_20 = np.genfromtxt('Datos/u_40_20.txt', delimiter=',')
t = np.linspace(0, 400, 10000)

b, a = signal.butter(25, 0.15)
zi = signal.lfilter_zi(b, a)
u_20_40 = signal.filtfilt(b, a, u_20_40)*24/11520+1.5

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Escalón positivo de resistencia de 20Ω a 40Ω', x=0.5, y=0.96)
ax1.plot(t, u_20_40, '#00575f', linewidth=0.8)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
yticks = [20, 24, 35]
ax1.yaxis.set_ticks(yticks)
ax2.plot(t, (iC_20_40+25000)*1.37/22186, '#7fafb0', linewidth=0.8)
ax2.plot(t, (ii_20_40*2+36544)*1.37/22186, '#00575f', linewidth=0.8)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.legend(['Corriente de entrada al convertidor', 'Corriente entregada por la fuente'], fontsize=7)
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Escalón positivo de resistencia.pdf')

# Escalón negativo de resistencia

t = np.linspace(0, 400, 10000)

b, a = signal.butter(25, 0.15)
zi = signal.lfilter_zi(b, a)
u_40_20 = signal.filtfilt(b, a, u_40_20)
u_40_20 = signal.filtfilt(b, a, u_40_20)*24/10016

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Escalón negativo de resistencia de 40Ω a 20Ω', x=0.5, y=0.96)
ax1.plot(t, u_40_20, '#00575f', linewidth=0.8)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
yticks = [20, 24, 30]
ax1.yaxis.set_ticks(yticks)
ax2.plot(t, (iC_40_20+10000)*2.7/14864.768, '#7fafb0', linewidth=0.8)
ax2.plot(t, (ii_40_20*2+35123.072)*2.7/14864.768, '#00575f', linewidth=0.8)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)
ax2.legend(['Corriente de entrada al convertidor', 'Corriente entregada por la fuente'], fontsize=7)
for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Escalón negativo de resistencia.pdf')
