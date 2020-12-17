import numpy as np
from sys import argv

a = np.loadtxt(argv[1])

print(a.mean(), a.std())
