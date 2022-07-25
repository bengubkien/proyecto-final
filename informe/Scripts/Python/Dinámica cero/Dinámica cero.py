import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties
from scipy import signal

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

# Escalón positivo de resistencia

v_o = np.genfromtxt('Datos/v_o.txt', delimiter=',')
i_L = np.genfromtxt('Datos/i_L.txt', delimiter=',')
t = np.genfromtxt('Datos/t.txt', delimiter=',')

# Corriente por el inductor

plt.figure('Corriente por el inductor')
plt.title('Corriente por el inductor', pad=11)
plt.plot(t, i_L, '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [1.5, 3]
# plt.yticks(yticks)
plt.savefig('Corriente por el inductor.pdf')

# Tensión en la carga

plt.figure('Tensión en la salida')
plt.title('Tensión en la salida', pad=11)
plt.plot(t, v_o, '#00575f', linewidth=0.8)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [24, 24.6, 23.8]
# plt.yticks(yticks)
plt.savefig('Tensión de carga.pdf')