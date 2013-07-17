import matplotlib.pyplot as plt
from PIL import Image
import Image
import ImageEnhance
import PIL.ImageChops
import os, sys
import math, operator
import ImageFilter
import pylab as pl

def normalize(h):
  #print h
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
    #print "new_scale: ", scale, result[scale]
  #for scale, counter in enumerate(result):
  #  print scale, counter
  return result

def plotLine(his, name):
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
  
def saveFile(data, filename):
  f = open("../data/wiping/img/"+filename, "w")
  for item in data:
    f.write("%s\n" % item)
  f.close()

def plotline(his1, his2, name):
  fig = pl.figure()
  ax = pl.subplot(111)
  ax.plot(range(len(his1)), his1)
  ax.plot(range(len(his2)), his2)
  fig.autofmt_xdate()
  pl.savefig("../data/wiping/img/" + name + "_line.png")

def rmBkgrd(img):
  pix = img.load()
  width, height = img.size
  for i in range (0, width):
    for j in range (0, height):
      if pix[i,j] > 200:
        img.putpixel([i,j], 255)
      if pix[i,j] < 50:
        img.putpixel([i,j], 0)
  return img 

def calBrightness(image):
  img = image.convert('RGB')
  x,y = 0,0
  #x_last, y_last = img.size
  #x_last = x_last - 1 
  #y_last = y_last - 1 
  rgb1 = img.getpixel((0,0))
  rgb2 = img.getpixel((250,250)) 
  rgb3 = img.getpixel((100,100))
  #pixelRGB_last = img.getpixel((x_last,y_last))
  R = (rgb1[0] + rgb2[0] + rgb3[0]) /3
  G = (rgb1[1] + rgb2[1] + rgb3[1]) /3
  B = (rgb1[2] + rgb2[2] + rgb3[2]) /3
  #R_last,G_last,B_last = pixelRGB_last
  #brightness = sum([R_first,G_first,B_first, R_last,G_last,B_last])/6
  #brightness = sum([R,G,B])/3
  brightness = 0.4124 * R + 0.3576 * G + 0.1805 * B 
  return brightness
 
def compare():
  file1 = "../data/wiping/img/before.png"
  file2 = "../data/wiping/img/after.png"

  img1 = Image.open(file1)
  img2 = Image.open(file2)

  bright1 = calBrightness(img1)
  bright2 = calBrightness(img2)

  #l,a,b = color.rgb2lab(img1)
  #print l
  print "Brightness: ", calBrightness(img1)
  print "Brightness: ", calBrightness(img2)
  brightness_scale = float(bright2) / float(bright1)
  print "brightness_scale: ", brightness_scale
  enhancer = ImageEnhance.Brightness(img1)
  bright = enhancer.enhance(brightness_scale)
  bright.save("../data/wiping/img/brighter.png") 
  img1 = bright 
  
  gray1 = img1.convert('L')
  gray2 = img2.convert('L')
  gray1.save("../data/wiping/img/gray1.png")
  gray2.save("../data/wiping/img/gray2.png")

  #invert1 = Image.eval(gray1, lambda(x):255-x)
  #invert2 = Image.eval(gray2, lambda(x):255-x)
  #invert1.save("../data/wiping/img/invert1.png")
  #invert2.save("../data/wiping/img/invert2.png")

  temp1 = rmBkgrd(gray1)
  temp2 = rmBkgrd(gray2)
  temp1.save("../data/wiping/img/result1.png")	
  temp2.save("../data/wiping/img/result2.png")	
  
  temp1.convert('L')
  temp1.save("../data/wiping/img/result1.png")	
  his1 = temp1.histogram()
  his2 = temp2.histogram()
  
  #for index, value in enumerate(his1):
  #  print index, value
  #for index, value in enumerate(his2):
  #  print index, value
    
  #plotLine(his1, "his1")
  #plotLine(his2, "his2") 
  #print "his1:  ", his1, "\nhis2:  ",his2
  #plotline(his1, his2, "non-normalized") 
  his1_norm = normalize(his1) 
  his2_norm = normalize(his2) 
  
  #his1_norm = his1
  #his2_norm = his2
  #plotline(his1_norm, his2_norm, "normalized") 
  #saveFile(his1_norm, "his1_norm.txt")  
  #saveFile(his2_norm, "his2_norm.txt")  
  
  #print "non_normalized:  ", math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, his1, his2))/len(his1))
  rms = math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, his1_norm, his2_norm))/len(his1_norm))
  return rms	
