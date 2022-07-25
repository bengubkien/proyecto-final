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

# Tensiones en carga de los supercapacitores

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Tensiones en la carga de los supercapacitores', x=0.5, y=0.96)
ax1.plot(t[23906:225101], u_bus[23906:225101], '#00575f', linewidth=0.8)
yticks = [14, 16, 18]
ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
ax1.legend(['Tensión de la carga'], fontsize=7)
ax2.plot(t[23906:225101], u_SC[23906:225101], '#00575f', linewidth=0.8)
yticks = [11, 12, 13]
ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [ms]', ylabel='Tensión [V]')
# ax2.legend(['Corriente entregada por los supercapacitores', 'Corriente entregada por la fuente'], fontsize=7)
ax2.legend(['Tensión del banco de supercapacitores'], fontsize=7)
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Tensiones en carga de los supercapacitores.pdf')

# Corrientes en carga de los supercapacitores

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Corrientes en la carga de supercapacitores', x=0.5, y=0.96)
ax1.plot(t[23906:225101], i_SC[23906:225101], '#00575f', linewidth=0.8)
ax1.plot(t[23906:225101], i_SC_ref[23906:225101]/pow(2,11), '#7fafb0', linewidth=0.60)
# yticks = [15, 24]
# ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Corriente [A]')
ax1.legend(['Corriente de supercapacitores', 'Referencia de corriente'], fontsize=7)
# yticks = np.append(ax1.get_yticks(), 24)
# ax1.set_yticks(yticks)
ax2.plot(t[23906:225101], i_FP[23906:225101], '#00575f', linewidth=0.8)
ax2.plot(t[23906:225101], i_FP_ref[23906:225101]/pow(2,11), '#7fafb0', linewidth=0.8)
# yticks = [0.8, 2.7]
# ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)
# yticks = [0.8, 2.7]
# ax2.set_yticklabels(yticks)
ax2.legend(['Corriente de fuente de potencia', 'Referencia de corriente'], fontsize=7)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Corrientes en la carga de supercapacitores.pdf')

# Tensiones en saltos de referencia

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Tensiones en saltos de referencia', x=0.5, y=0.96)
ax1.plot(t[225101:], u_bus[225101:], '#00575f', linewidth=0.8)
yticks = [16, 24]
ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Tensión [V]')
ax1.legend(['Tensión de la carga'], fontsize=7)
ax2.plot(t[225101:], u_SC[225101:], '#00575f', linewidth=0.8)
yticks = [11.5, 12, 12.5]
ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [ms]', ylabel='Tensión [V]')
ax2.legend(['Tensión del banco de supercapacitores'], fontsize=7)
ax2.grid(True, ls="-", linewidth=0.4)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Tensiones en saltos de referencia.pdf')

# Corrientes en saltos de referencia

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle('Corrientes en saltos de referencia', x=0.5, y=0.96)
ax1.plot(t[225101:], i_SC[225101:], '#00575f', linewidth=0.8)
ax1.plot(t[225101:], i_SC_ref[225101:]/pow(2,11), '#7fafb0', linewidth=0.60)
# yticks = [15, 16, 24, 26]
# ax1.set_yticks(yticks)
ax1.grid(True, ls="-", linewidth=0.4)
ax1.set(ylabel='Corriente [A]')
ax1.legend(['Corriente de supercapacitores', 'Referencia de corriente'], fontsize=7)
ax2.plot(t[225101:], i_FP[225101:], '#00575f', linewidth=0.8)
ax2.plot(t[225101:], i_FP_ref[225101:]/pow(2,11), '#7fafb0', linewidth=0.8)
yticks = [1, 1.50]
ax2.set_yticks(yticks)
ax2.set(xlabel='Tiempo [ms]', ylabel='Corriente [A]')
ax2.grid(True, ls="-", linewidth=0.4)
ax2.legend(['Corriente de fuente de potencia', 'Referencia de corriente'], fontsize=7)

for ax in fig.get_axes():
    ax.label_outer()

plt.savefig('Corrientes en saltos de referencia.pdf')