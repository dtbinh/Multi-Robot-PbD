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
  bumblebeeIP = "10.26.210.59"

  #wiping(ironhideIP, False)
  #wiping(bumblebeeIP, False)

  diff = compare()

  print diff 
