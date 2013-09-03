import sys
from naoqi import ALProxy
import motion
from time import *
import almath

def main(robotIP):
  PORT = 9559
  motion = ALProxy("ALMotion", robotIP, PORT)
  
  name = "RArm"
  space = 0 #motion.FRAME_TORSO
  print str(space)
  useSensorValues = True 
  current = motion.getPosition(name, space, useSensorValues)
  print "getPosition: ", current
  
  target = [
           current[0]+0.05,
	   current[1]+0.0,
	   current[2]+0.0,
	   current[3]+0.0,
	   current[4]+0.0,
	   current[5]+0.0
           ]
  print "targetPosition: ", target 
  
  fractionMaxSpeed = 0.1
  axisMask = 7
  motion.setStiffnesses("RArm", 1.0)
  #for i in range(1, 5):
    #motion.setPosition(name, space, target, fractionMaxSpeed, axisMask)
    #sleep(3)
    #motion.setPosition(name, space, current, fractionMaxSpeed, axisMask)
    #sleep(3)

  jangleLists = [-100*almath.TO_RAD]
  print "jangleLists: ", jangleLists 
  timeLists = [1.0]
  motion.angleInterpolation("RHand", jangleLists, timeLists, False)
  sleep(3)  
  motion.setStiffnesses("RArm", 0.0)

if __name__ == "__main__" :
  print ">>> Start"
  robotIP = "10.26.210.60"
  main(robotIP)
