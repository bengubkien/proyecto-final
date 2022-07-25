import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties
from scipy import signal

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

# Primer ensayo

i_FP = np.genfromtxt('Datos/i_FP.txt', delimiter=',')
i_SC = np.genfromtxt('Datos/i_SC.txt', delimiter=',')
u_bus = np.genfromtxt('Datos/u_bus.txt', delimiter=',')
u_SC = np.genfromtxt('Datos/u_SC.txt', delimiter=',')
i_SC_ref = np.genfromtxt('Datos/i_SC_ref.txt', delimiter=',')
i_FP_ref = np.genfromtxt('Datos/i_FP_ref.txt', delimiter=',')
t = np.linspace(0, len(i_FP)/1000, len(i_FP))

# Tensiones con saltos de resistencia

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Tensiones con saltos de resistencia', x=0.5, y=0.96)
ax1.plot(t, u_bus, '#00575f', linewidth=0.8)
yticks = [23, 24, 25]
ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
ax1.legend(['Tensión de la carga'], fontsize=7)
ax2.plot(t, u_SC, '#00575f', linewidth=0.8)
yticks = [11.5, 12, 12.5]
ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [s]', ylabel='Tensión [V]')
# ax2.legend(['Corriente entregada por los supercapacitores', 'Corriente entregada por la fuente'], fontsize=7)
ax2.legend(['Tensión del banco de supercapacitores'], fontsize=7)
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Tensiones con saltos de resistencia.pdf')

# Corrientes con saltos de resistencia

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Corrientes con saltos de resistencia', x=0.5, y=0.96)
ax1.plot(t, i_SC, '#00575f', linewidth=0.8)
ax1.plot(t, i_SC_ref/pow(2,11), '#7fafb0', linewidth=0.60)
# yticks = [15, 24]
# ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Corriente [A]')
ax1.legend(['Corriente de supercapacitores', 'Referencia de corriente'], fontsize=7)
# yticks = np.append(ax1.get_yticks(), 24)
# ax1.set_yticks(yticks)
ax2.plot(t, i_FP, '#00575f', linewidth=0.8)
ax2.plot(t, i_FP_ref/pow(2,11), '#7fafb0', linewidth=0.8)
# yticks = [0.8, 2.7]
# ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [s]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)
# yticks = [0.8, 2.7]
# ax2.set_yticklabels(yticks)
ax2.legend(['Corriente de fuente de potencia', 'Referencia de corriente'], fontsize=7)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Corrientes con saltos de resistencia.pdf')