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
vref = np.loadtxt('Datos/vref.txt')
vo = np.loadtxt('Datos/vo.txt')


# Referencia de tensión
plt.figure('Referencia de tensión')


plt.title('Referencia de tensión', pad=11)
plt.plot(t, vref, '#00575f', linewidth=1)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Referencia de tensión.pdf')

# Tension en la salida

plt.figure('Tensión en la salida')

plt.title('Tensión en la salida', pad=11)
plt.plot(t, vo, '#00575f', linewidth=1)
plt.ylabel('Tensión [V]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Tensión en la salida.pdf')


# Corriente por el inductor

plt.figure('Corriente por el inductor')

plt.title('Corriente por el inductor', pad=11)
plt.plot(t[60300:], iL[60300:], '#00575f', linewidth=1)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor.pdf')



# Corriente por el inductor filtrada

plt.figure('Corriente por el inductor filtrada')

plt.title('Corriente por el inductor filtrada', pad=11)
plt.plot(t_filtered[50000:], iL_filtered[50000:], '#00575f', linewidth=1)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [s]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Corriente por el inductor filtrada.pdf')



