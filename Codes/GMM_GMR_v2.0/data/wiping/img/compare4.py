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
	source = diff.split()
	R, G, B = 0, 1, 2
	#result = source[B].point(lambda i: 0 if i > 200 else i)
	#result = source[B].point(lambda i: 0 if i > 200 else i)
	newR = source[R].point(lambda i: 0 if i > 200 else i)
	newB = source[B].point(lambda i: 0 if i > 200 else i)
	newG = source[G].point(lambda i: 0 if i > 200 else i)
	#source.paste(newR, newG, newB)
	result = Image.merge(source.mode, (newR, newB, newG)) 
	result.save("new_before.png")
'''
	pix2 = im2.load()
	out = diff.point(lambda i: i if i > 100 else 0)
	diff = ImageChops.difference(im2, im1)
	pix_d = diff.load()
	
	width,height = diff.size
	for i in range (0,width):
		for j in range (0,height):
			tmp = pix_d[i, j] 
			if (tmp[0] < 30 and tmp[1] < 30 and tmp[2] < 30):
				diff.putpixel((i,j), (0, 0, 0))	
			else:		
				print i, j,tmp
		
	out = diff.point(lambda i: i if i > 100 else 0)
	#h = diff.histogram()
	out.save("tmp3.png")
'''
	#print len(diff)
	#sq = (value*(idx**2) for idx, value in enumerate(h))
	#sum_of_squares = sum(sq)
	#rms = math.sqrt(sum_of_squares/float(im1.size[0] * im1.size[1]))
	#return rms

if __name__ == '__main__':
	file1, file2 = sys.argv[1:]
	compare(file1, file2)
