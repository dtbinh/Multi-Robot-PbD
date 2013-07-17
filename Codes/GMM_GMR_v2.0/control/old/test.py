import os, sys
from PIL import Image
import matplotlib.pyplot as plt
import ImageFilter
import pylab as pl
import shlex
import operator, math

def readin(filename):
  with open(filename) as f:
    lines = f.read().splitlines()
  i = 0
  res = [0] * len(lines) 
  for line in lines:
    new = line.split()
    res[i] = ((int)(new[0]))
    i = i + 1
 
  return res 

def plotline(his1, his2, name):
  fig = pl.figure()
  ax = pl.subplot(111)
  ax.plot(range(len(his1)), his1)
  ax.plot(range(len(his2)), his2)
  fig.autofmt_xdate()
  pl.savefig("../data/wiping/img/" + name + "_line.png")

def compdiff(h1, h2):
  s = 0
  for i in range(len(h1)):
    s = s + ((int)(h1[i]) - (int)(h2[i])) ** 2
  return math.sqrt(s/len(h1))
  
  #return math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, h1,h2))/len(h1))

#x1 = readin("foo1")
#x2 = readin("foo2")
#print compdiff(x1, x2)

x1 = readin("../data/wiping/img/his1.txt")
x2 = readin("../data/wiping/img/his2.txt")
plotline(x1, x2, "diff")
print compdiff(x1, x2)
