import sys
import time
import numpy as np
#from naoqi import ALProxy

def GMR(Priors, Mu, Sigma, x, inD, outD):
	nbData = (x.shape)[0]
	nbVar = (Mu.shape)[0]
	nbStates = (Sigma.shape)[0]
	print nbData, nbVar, nbStates
	
	#Compute the influence of each GMM, given input x
	for i in range (nbStates):
		print i	

	return 0 




if __name__ == "__main__":
	Priors = np.array([0.25, 0.25, 0.25, 0.25])
	tmp = np.array([[39.9645, -0.1225, -0.0756],[-0.1225,0.0005,0.0002],[-0.0756,0.0002,0.0002]])
	Sigma = np.array([tmp, tmp, tmp, tmp])
	
	Mu =np.array([[89.7442,   36.8560,   65.2098,   11.3538],\
   [-0.0129,   -0.0389,   -0.0200,    0.0352],\
   [-0.0783,    0.0484,   -0.0160,    0.0592]])
	x = np.array([1,2,3,4,5])
	inD = 1
	outD = [2, 3]
	GMR(Priors, Mu, Sigma, x, inD, outD)

