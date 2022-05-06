import matplotlib.pyplot as plt
import os
import numpy as np
from matplotlib.font_manager import findfont, FontProperties

plt.rcParams['font.sans-serif'] = "Open Sans"
plt.rcParams['font.family'] = "sans-serif"

escalon_negativo = np.genfromtxt('Datos/escalon_negativo.txt', delimiter=',')
escalon_positivo = np.genfromtxt('Datos/escalon_positivo.txt', delimiter=',')
t = np.linspace(0, 4, 10000)
escalon_positivo = escalon_positivo*0.0001684 + 0.9934 
escalon_negativo= escalon_negativo*0.0001684 + 0.9934 

# Escalón positivo de corriente
plt.figure('Escalón positivo de corriente')
plt.title('Escalón positivo de corriente de 3 A', pad=11)
plt.plot(t, escalon_positivo, '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Escalóno positivo de corriente.pdf')

# Escalón negativo de corriente
plt.figure('Escalón negativo de corriente')
plt.title('Escalón negativo de corriente de 3 A', pad=11)
plt.plot(t, escalon_negativo, '#00575f', linewidth=0.8)
plt.ylabel('Corriente [A]')
plt.xlabel('Tiempo [ms]')
plt.grid(True, ls="-", linewidth=0.4)

plt.savefig('Escalóno negativo de corriente.pdf')