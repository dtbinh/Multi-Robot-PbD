import os, sys
from naoqi import *
#from compare import compare
from action import * 
from robot import * 
from test import *

if __name__ == "__main__":
  ironhide = "10.26.210.60"
  robot = ROBOT(ironhide, 9559, 'R')
  #robot.searchBall()
  #robot.fixLegs()
  #moveHand(robot) 
  moveJoints(robot) 
  
  # test scripts
  #test_moveJoints(robot)
  #test_closeHand(robot)
  #test_ballrange(robot)
  #test_handpos(robot)
  

  robot.exit()
  #diff = compare()
  #print "compared difference: ", diff
