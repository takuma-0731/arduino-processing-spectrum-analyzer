#課題1

import numpy as np
import matplotlib.pyplot as plt


f = 2          
A = 1          
phi = np.pi/4  


t = np.linspace(0, 1, 1000)

y = A * np.cos(2 * np.pi * f * t + phi)


plt.figure(figsize=(8, 4))
plt.plot(t, y)
plt.title('Cosine Wave: f=2Hz, A=1V, phase=π/4')
plt.xlabel('Time [s]')
plt.ylabel('Amplitude [V]')
plt.grid(True)
plt.show()

#課題2


import numpy as np
import matplotlib.pyplot as plt


A = 1          
tau = 1        
T = 4 * tau     
f = np.linspace(-5, 5, 1000)  


Vf = A * tau * np.sinc(f * tau)  
plt.figure(figsize=(8, 4))
plt.plot(f, np.abs(Vf))
plt.title('(a) 単一矩形パルスの|V(f)|')
plt.xlabel('Frequency [Hz]')
plt.ylabel('|V(f)|')
plt.grid(True)

n = np.arange(-10, 11)
Xn = A * (tau / T) * np.sinc(n * tau / T)
plt.figure(figsize=(8, 4))
plt.stem(n / T, np.abs(Xn), basefmt=" ")
plt.title('(b) 周期矩形波の|Xn|スペクトル')
plt.xlabel('Frequency [Hz]')
plt.ylabel('|Xn|')
plt.grid(True)

f_delta = np.arange(-5, 6)
Yf = np.ones_like(f_delta)
plt.figure(figsize=(8, 4))
plt.stem(f_delta / T, Yf, basefmt=" ")
plt.title('(c) デルタ列のスペクトル')
plt.xlabel('Frequency [Hz]')
plt.ylabel('Amplitude')
plt.grid(True)

plt.show()

