import Image
import ImageChops
import os, sys
import math, operator
import ImageFilter
	
def compare(file1, file2):
  im1 = Image.open(file1)
  im2 = Image.open(file2)

  diff = ImageChops.difference(im2, im1)
  diff.load()
  '''
  source = diff.split()
  R, G, B = 0, 1, 2
  newR = source[R].point(lambda i: 0 if i > 200 else i)
  newB = source[B].point(lambda i: 0 if i > 150 else i)
  newG = source[G].point(lambda i: 0 if i > 150 else i)
  newR.save("new.png")
  '''
	#out = diff.point(lambda i: i if i > 100 else 0)
  diff = ImageChops.difference(im2, im1)
  pix_d = diff.load()
	
  width,height = diff.size
  for i in range (0,width):
    for j in range (0,height):
      if (i > (width - 100) and j > (height - 100)):
        diff.putpixel((i,j), (0, 0, 0))	
      else:  
        tmp = pix_d[i, j]
        if (tmp[0] < 30 and tmp[1] < 30 and tmp[2] < 30):
          diff.putpixel((i,j), (0, 0, 0))	
        else:
          print i, j,tmp
        if (i > width-50  and j > height - 50):
          diff.putpixel((i,j), (0, 0, 0))	
        	
	#h = diff.histogram()
	diff.save("diff.png")
	#sq = (value*(idx**2) for idx, value in enumerate(h))
	#sum_of_squares = sum(sq)
	#rms = math.sqrt(sum_of_squares/float(im1.size[0] * im1.size[1]))
	#return rms

if __name__ == '__main__':
	file1, file2 = sys.argv[1:]
	compare(file1, file2)
