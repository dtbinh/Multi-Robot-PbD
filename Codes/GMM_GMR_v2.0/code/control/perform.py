import os, sys
from naoqi import *
from action import * 
from robot import * 
from test import *

if __name__ == "__main__":
  argv = sys.argv[1:]
  robot_name = argv[0] 
  action_name = argv[1]

  if robot_name == "ironhide":
    robot_ip = "10.26.210.60"
  elif robot_name == "bumblebee":
    robot_ip = "10.26.210.59"
  else:
    robot_ip = "lap77.local"
 
  robot = ROBOT(robot_ip, 9559, 'R')
  
  #robot.fixLegs()
  #moveHand(robot) 
  #moveJoints(robot, action_name) 
   
  # test scripts
  #test_handpos(robot)
  #test_moveJoints(robot)
  #test_closeHand(robot)
  #test_handpos(robot)
  test_ForwardKinect(robot)
  #test_robotInfo(robot)
  robot.exit()
