import os
import sys
import time
from naoqi import ALProxy
import vision_definitions
import Image

from wiping import wiping
from compare import compare

####### main ########
if __name__ == '__main__':
  ironhideIP = "10.26.210.60"
  wiping(ironhideIP, False)

  diff = compare()

  print diff 
