import Image
import ImageChops
import os, sys
import math, operator
import ImageFilter
	
def compare(file1, file2):
	im1 = Image.open(file1)
	im2 = Image.open(file2)

	h1 = im1.convert('L').histogram()
	h2 = im2.convert('L').histogram()
	
	rms = math.sqrt(reduce(operator.add,
	map(lambda a,b: (a-b)**2, h1, h2))/len(h1))
 	return rms	

if __name__ == '__main__':
	file1, file2 = sys.argv[1:]
	print compare(file1, file2)
