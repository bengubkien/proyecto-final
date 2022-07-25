import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

t_filtered = np.loadtxt('Datos/t_filtered.txt')
t = np.loadtxt('Datos/t.txt')
iL_filtered = np.loadtxt('Datos/iL_filtered.txt')
iL = np.loadtxt('Datos/iL.txt')
iref = np.loadtxt('Datos/iref.txt')
vo = np.loadtxt('Datos/vo.txt')

# Referencia de corriente

plt.figure('Referencia de corriente')
plt.title('Referencia de corriente', pad=11)
plt.plot(t[60300:], iref[60300:], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Referencia de corriente.pdf')


# Corriente por el inductor

plt.figure('Corriente por el inductor')
plt.title('Corriente por el inductor', pad=11)
plt.plot(t[60300:], iL[60300:], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor.pdf')


# Corriente por el inductor filtrada

plt.figure('Corriente por el inductor filtrada')
plt.title('Corriente por el inductor filtrada', pad=11)
plt.plot(t_filtered[50000:], iL_filtered[50000:], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor filtrada.pdf')


# Tension en la salida

plt.figure('Tensión en la salida')
plt.title('Tensión en la salida', pad=11)
plt.plot(t[60300:], vo[60300:], '#00575f', linewidth=0.8)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Tensión en la salida.pdf')


# Corriente por el inductor en entorno

plt.figure('Corriente por el inductor en el entorno del escalón de referencia')
plt.title('Corriente por el inductor en el entorno del escalón de referencia', pad=11)
plt.plot(t[84695:85700], iL[84695:85700], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor en entorno.pdf')


# Corriente por el inductor filtrada

plt.figure('Corriente por el inductor filtrada en el entorno del escalón de referencia')
plt.title('Corriente por el inductor filtrada en el entorno del escalón de referencia', pad=11)
plt.plot(t_filtered[70200:71000], iL_filtered[70200:71000], '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor filtrada en entorno.pdf')
