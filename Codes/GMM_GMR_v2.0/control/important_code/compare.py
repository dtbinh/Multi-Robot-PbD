import Image
import ImageEnhance
import ImageChops
import os, sys
import math, operator

def normalize(h):
  #print h
  min_counter = -2
  max_counter = -2
  result = [0] * 256 
  for scale, counter in enumerate(h):
    if (counter != 0):
      min_scale = scale
      break;
  #print "min_scale: ", min_scale

  for scale, counter in enumerate(h[::-1]):
    if (counter != 0):
      max_scale = scale
      break
  max_scale = 255 - max_scale
  #print "max_scale: ", max_scale
  for scale, counter in enumerate(h):
    if (scale < max_scale and scale > min_scale):
      scale = 255 * (scale-min_scale)/(max_scale - min_scale)
      result[scale] = counter
  return result

def calBrightness(image):
  img = image.convert('RGB')
  x,y = 0,0
  rgb1 = img.getpixel((5,5))
  rgb2 = img.getpixel((5,250)) 
  rgb3 = img.getpixel((250,5))
  rgb4 = img.getpixel((250,250))
  R = (rgb1[0] + rgb2[0] + rgb3[0] + rgb4[0]) /4
  G = (rgb1[1] + rgb2[1] + rgb3[1] + rgb4[1]) /4
  B = (rgb1[2] + rgb2[2] + rgb3[2] + rgb4[2]) /4
  brightness = 0.4124 * R + 0.3576 * G + 0.1805 * B 
  return brightness
 
def compare():
  file1 = "../data/wiping/img/before.png"
  file2 = "../data/wiping/img/after.png"

  img1 = Image.open(file1)
  img2 = Image.open(file2)

  brightness1 = calBrightness(img1)
  brightness2 = calBrightness(img2)

  print "Brightness: ", brightness1
  print "Brightness: ", brightness2
  brightness_scale = float(brightness2) / float(brightness1)
  print "brightness_scale: ", brightness_scale
  enhancer1 = ImageEnhance.Brightness(img1)
  bright1 = enhancer1.enhance(brightness_scale)
  bright1.save("../data/wiping/img/bright1.png") 
  
  diff = ImageChops.difference(img2, bright1)
  tmp = diff.convert('L')
  #diff.save("../data/wiping/img/diff.png")
  pix = tmp.load() 
  width, height = tmp.size
  print width, height
  for i in range(0, width):
    for j in range(0, height):
      if pix[i, j] < 20:
        tmp.putpixel((i, j), 0)
  #diff.save("../data/wiping/img/diff.png")
  tmp_his = tmp.histogram()
  s = 0
  for i in range (1, len(tmp_his)):
    #print i, tmp_his[i]
    s = s + float(tmp_his[i])
  rms = s / len(tmp_his)
   
  #rms = math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, black, tmp_his))/len(black))
  
  return rms	
