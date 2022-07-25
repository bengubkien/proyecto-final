import matplotlib.pyplot as plt
import os
import numpy as np
from scipy import signal
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

escalon_negativo = np.genfromtxt('Datos/escalon_negativo.txt', delimiter=',')
escalon_positivo = np.genfromtxt('Datos/escalon_positivo.txt', delimiter=',')
escalon_positivo_sim = np.loadtxt('Datos/escalon_positivo_sim.txt')
escalon_negativo_sim = np.loadtxt('Datos/escalon_negativo_sim.txt')

t = np.linspace(0, 4, 10000)
t_sim = np.linspace(0, 4, (311000-298301))
escalon_positivo = escalon_positivo*0.0001684 + 0.9934 
escalon_negativo= escalon_negativo*0.0001684 + 0.9934 
escalon_positivo_sim = (escalon_positivo_sim-1.5)
escalon_negativo_sim = (escalon_negativo_sim-1.5)

b, a = signal.butter(10 , 0.023)
zi = signal.lfilter_zi(b, a)
y = signal.filtfilt(b, a, escalon_negativo_sim)

# Escalón positivo de corriente
plt.figure('Escalón positivo de corriente')
plt.title('Escalón positivo de corriente de 3 A', pad=11)
plt.plot(t_sim, escalon_positivo_sim[298801:311500], "#7fabaf",  linewidth=0.8)
plt.plot(t, escalon_positivo, '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)
plt.legend(['Ensayo', 'Simulación'])

plt.savefig('Escalón positivo de corriente.pdf')

# Escalón negativo de corriente
plt.figure('Escalón negativo de corriente')
plt.title('Escalón negativo de corriente de 3 A', pad=11)
plt.plot(t_sim, escalon_negativo_sim[299101:311800], "#7fabaf",  linewidth=0.8)
plt.plot(t, escalon_negativo, '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)
plt.legend(['Ensayo', 'Simulación'])

plt.savefig('Escalón negativo de corriente.pdf')