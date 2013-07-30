import os
import sys
import time
from naoqi import ALProxy

class  ROBOT():
  def __init__(self, ip, port, side):
    self.ip = ip
    self.port = port
    try:
      self.motion = ALProxy("ALMotion", self.ip, self.port)
      self.speech = ALProxy("ALTextToSpeech", self.ip, self.port)
    except Exception, e:
      print "Could not create proxy"
      print "Error: ", e
      sys.exit(1)

def main(IP, DEBUG, action_name):
	print ">>> Start ", action_name
	robot = ROBOT(IP, 9559, 'R') 
 	
	robot.speech.say("Testing, move head")
   
  	names  = "HeadYaw"
	robot.motion.setStiffnesses("Head", 1.0)
	angle = 0.2
	maxSpeedFraction  = 0.08
	robot.motion.angleInterpolationWithSpeed(names, angle, maxSpeedFraction)
	robot.motion.angleInterpolationWithSpeed(names, -angle, maxSpeedFraction)
	robot.motion.setStiffnesses("Body", 0.0)
 	robot.speech.say("Finish Testing")
	print ">>> Exit ", action_name, " normally"

if __name__ == "__main__":
	ironhide = "10.26.210.60"
	main(ironhide, False, "testing")
