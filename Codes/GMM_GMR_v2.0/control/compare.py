import Image
import ImageChops
import os, sys
import math, operator
import ImageFilter

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
    if (counter != 0 and max_scale != scale):
      scale = 255 * (scale-min_scale)/(max_scale - min_scale)
    result[scale] = counter
    #print "new_scale: ", scale, counter
  #for scale, counter in enumerate(h):
  #  print scale, counter
  return result
	
def compare():
  file1 = "../data/wiping/img/before.png"
  file2 = "../data/wiping/img/after.png"

  im1 = Image.open(file1)
  im2 = Image.open(file2)

  h1 = im1.convert('L')
  h2 = im2.convert('L')
	
  h1.save("../data/wiping/img/h1.png")
  h2.save("../data/wiping/img/h2.png")
	
  h1_his = h1.histogram()
  h2_his = h2.histogram()
 
  #print h1, h2 
  h1_his_norm = normalize(h1_his)
  h2_his_norm = normalize(h2_his)
  
  h1.save("../data/wiping/img/h1_norm.png")
  h2.save("../data/wiping/img/h2_norm.png")
  
  rms = math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, h1, h2))/len(h1))
  return rms	
