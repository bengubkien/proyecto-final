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
u_i = np.genfromtxt('Datos/u_i.txt', delimiter=',')
u_u = np.genfromtxt('Datos/u_u.txt', delimiter=',')
t = np.linspace(0, 592, len(v_o[9200:]))

# Corriente por el inductor

plt.figure('Corriente por el inductor')
plt.title('Corriente por el inductor', pad=11)
plt.plot(t, i_L[9200:], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [1.5, 3]
# plt.yticks(yticks)

plt.savefig('Corriente por el inductor.pdf')

# Tensión en la carga

plt.figure('Tensión en la carga')
plt.title('Tensión en la carga', pad=11)
plt.plot(t, v_o[9200:], '#00575f', linewidth=0.8)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [24, 24.6, 23.8]
# plt.yticks(yticks)

plt.savefig('Tensión en la carga.pdf')

# Acción de control de corriente

t = np.linspace(0, 592, len(u_i[9200:]))
plt.figure('Acción de control de tensión')
plt.title('Acción de control de tensión', pad=11)
plt.plot(t, u_i[9200:], '#00575f', linewidth=0.8)
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [0.515, 0.525, 0.535]
# plt.yticks(yticks)

plt.savefig('Control de tensión.pdf')

# Acción de control de tensión

t = np.linspace(0, 592, len(u_u[9200:]))
plt.figure('Acción de control de corriente')
plt.title('Acción de control de corriente', pad=11)
plt.plot(t, u_u[9200:], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)
# yticks = [1.5, 3]
# plt.yticks(yticks)

plt.savefig('Control de corriente.pdf')