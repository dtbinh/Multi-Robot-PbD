import os
import sys
import time
from naoqi import ALProxy

from compare import compare
 
class  ROBOT():
  def __init__(self, ip, port, side):
    self.ip = ip
    self.port = port
    try:
      self.motion = ALProxy("ALMotion", self.ip, self.port)
      self.memory = ALProxy('ALMemory', self.ip, self.port)
      self.camera = ALProxy("ALVideoDevice", self.ip, self.port)
      self.speech = ALProxy("ALTextToSpeech", self.ip, self.port)
    except Exception, e:
      print "Could not create proxy"
      print "Error: ", e
      sys.exit(1)

    #select mouth camera
    self.camera.setParam(18, 1) 
def touchHead(robot):
  headFront = robot.memory.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
  headMiddle = robot.memory.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
  headRear = robot.memory.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
  return headFront or headMiddle or headRear

def takePicture(robot, imgName):
    print ">>> Start taking picture: ", imgName
    resolution = 2 #VGA, higher than kQQVGA
    colorSpace = 11 #RGB
    videoClient = robot.camera.subscribe("python_client", resolution, colorSpace, 5)
    
    time.sleep(1)
    t0 = time.time()
    naoImage = robot.camera.getImageRemote(videoClient) 
    t1 = time.time()
    print "\t\tacquistion delay", t1 - t0
    robot.camera.unsubscribe(videoClient)

    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    im = Image.fromstring("RGB", (imageWidth, imageHeight), array)

    im.save("../data/wiping/img/"+imgName+".png", "PNG")
    im.show()
    print ">>> Finish taking picture"

def action(IP, DEBUG, action_name):
	print ">>> Start ", action_name
	robot = ROBOT(IP, 9559, 'R') 
 	
	robot.speech.say("Testing")
   
  	names  = "HeadYaw"
	robot.motion.setStiffnesses("Head", 1.0)
	joints = 0.2
	maxSpeedFraction  = 0.1
	robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
	robot.motion.setStiffnesses("Body", 0.0)
 	robot.speech.say("Testing Finish")
	print ">>> Exit ", action_name, " normally"

if __name__ == "__main__":
	ironhide = "10.26.210.60"
	action(ironhide, False, "testing")
