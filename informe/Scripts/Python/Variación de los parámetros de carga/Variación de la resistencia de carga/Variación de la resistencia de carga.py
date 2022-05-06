import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

t_filtered = np.loadtxt('Datos/t_filtered.txt')
t = np.loadtxt('Datos/t.txt')
iL_filtered = np.loadtxt('Datos/iL_filtered.txt')
u = np.loadtxt('Datos/u.txt')
r = np.loadtxt('Datos/r.txt')
vo = np.loadtxt('Datos/vo.txt')

# Variación de la resistencia

plt.figure('Variación de la resistencia')
plt.title('Variación de la resistencia', pad=11)
plt.plot(t[60300:], r[60300:], '#00575f', linewidth=0.8)
plt.ylabel('Resistencia [Ω]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Variación de la resistencia.pdf')


# Tension en la salida

plt.figure('Tensión en la salida')

plt.title('Tensión en la salida', pad=11)
plt.plot(t, vo, '#00575f', linewidth=1)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Tensión en la salida.pdf')


# Corriente por el inductor

plt.figure('Corriente por el inductor filtrada')

plt.title('Corriente por el inductor filtrada', pad=11)
plt.plot(t_filtered[50000:], iL_filtered[50000:], '#00575f', linewidth=1)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor filtrada.pdf')


# Acción de control

plt.figure('Acción de control')

plt.title('Acción de control', pad=11)
plt.plot(t_filtered, u, '#00575f', linewidth=1)
plt.ylabel('Ciclo de trabajo')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Acción de control.pdf')

