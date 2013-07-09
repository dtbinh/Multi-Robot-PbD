import matplotlib.pyplot as plt
from PIL import Image
import PIL.ImageChops
import os, sys
import math, operator
import ImageFilter
import pylab as pl

def normalize(h):
  min_counter = -2
  max_counter = -2
  result = [0] * 256 
  for scale, counter in enumerate(h):
    if (counter != 0):
      min_scale = scale
      break;
  print "min_scale: ", min_scale

  for scale, counter in enumerate(h[::-1]):
    if (counter != 0):
      max_scale = scale
      break
  max_scale = 255 - max_scale
  print "max_scale: ", max_scale
  for scale, counter in enumerate(h):
    #print "original: ", scale, counter
    if (scale < max_scale and scale > min_scale):
      scale = 255 * (scale-min_scale)/(max_scale - min_scale)
    result[scale] = counter
  #  print "new_scale: ", scale, result[scale]
  #for scale, counter in enumerate(result):
  #  print scale, counter
  return result

def plot(his, name):
  '''
  fig = pl.figure()
  ax = pl.subplot(111)
  ax.bar(range(len(his)), his) 
  fig.autofmt_xdate()  
  pl.savefig("../data/wiping/img/" + name + ".png")
  '''
  fig = plt.figure()
  ax = plt.subplot(111)
  ax.plot(range(len(his)), his) 
  fig.autofmt_xdate()  
  plt.savefig("../data/wiping/img/"+ name + "_line.png") 
  	
def compare():
  file1 = "../data/wiping/img/before.png"
  file2 = "../data/wiping/img/after.png"

  img1 = Image.open(file1)
  img2 = Image.open(file2)

  invert1 = Image.eval(img1, lambda(x):255-x)
  invert2 = Image.eval(img2, lambda(x):255-x)
  
  gray1 = invert1.convert('L')
  gray2 = invert2.convert('L')
	
  his1 = gray1.histogram()
  his2 = gray2.histogram()
  
  #for index, value in enumerate(his1):
  #  print index, value
  #for index, value in enumerate(his2):
  #  print index, value
    
  #plot(his1, "his1")
  #plot(his2, "his2") 
  #print "his1:  ", his1, "\nhis2:  ",his2
  
  rms = math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, his1, his2))/len(his1))
  return rms	
