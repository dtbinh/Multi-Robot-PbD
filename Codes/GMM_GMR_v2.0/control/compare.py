import Image
import ImageChops
import os, sys
import math, operator
import ImageFilter
	
def compare():
  file1 = "../data/wiping/img/before.png"
  file2 = "../data/wiping/img/after.png"

  im1 = Image.open(file1)
  im2 = Image.open(file2)

  h1 = im1.convert('L')
  h2 = im2.convert('L')
	
  h1.save("../data/wiping/img/h1.png")
  h2.save("../data/wiping/img/h2.png")
	
  h1 = h1.histogram()
  h2 = h2.histogram()
  '''
  print h1
  print h2
  m = map(lambda a,b: (a-b)**2, h1, h2)
  print m
  r = reduce(operator.add, m)
  tmp = math.sqrt(r)/len(h1)
  print len(h1)
  print tmp 
  '''
  rms = math.sqrt(reduce(operator.add, map(lambda a,b: (a-b)**2, h1, h2))/len(h1))
  return rms	
