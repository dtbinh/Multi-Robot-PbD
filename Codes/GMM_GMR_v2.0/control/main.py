import os, sys
from naoqi import *
#from compare import compare
#from action import * 
from robot import *

if __name__ == "__main__":
  ironhide = "10.26.210.60"
  robot = ROBOT(ironhide, 9559, 'R')
  robot.searchBall()
  #move(robot) 
  #action(ironhide, False, "picking")
  
  robot.exit()
  #diff = compare()
  #print "compared difference: ", diff
