import os
import sys
import time
from naoqi import ALProxy
import vision_definitions
import Image

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
    print "acquistion delay", t1 - t0
    robot.camera.unsubscribe(videoClient)

    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    im = Image.fromstring("RGB", (imageWidth, imageHeight), array)

    im.save("../data/wiping/img/"+imgName+".png", "PNG")
    im.show()
    print ">>> Finish taking picture"

####### main ########
def wiping(IP, DEBUG):
  ironhide = ROBOT(IP, 9559, 'R') 
   
  #set stiffness
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  stiffnessLists = 1.0
  timeLists = 2.0
  ironhide.motion.stiffnessInterpolation(names, stiffnessLists, timeLists)

  filename = "../data/wiping/reproduced.txt"
  f = open(filename)
  line = f.readlines()
  f.close
  
  takePicture(ironhide, "before")
  
  for i in range(0, len(line)):
    targetAngle = []
    #print i, line[i]
    targetAngle = line[i].split('\t')
    targetAngle = map(float, targetAngle)
    targetAngle[5] = 0.0  #hand close
    if DEBUG:
      print "targetAngle:  ",targetAngle
    i = i + 1
    if touchHead(ironhide):
      break

    joints = targetAngle[0:8]
    if DEBUG:
      print "joints ",joints
    # Using 10% of maximum joint speed
    maxSpeedFraction  = 0.1
    ironhide.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
    #proxy.setAngles(names, joints, maxSpeedFraction) #angleInterpolationWithSpeed works better than setAngles, regarding the speed

  takePicture(ironhide, "after")
  
  #ironhide.motion.openHand('LHand') 
  ironhide.motion.setStiffnesses("Body", 0.0)
 
  print "Exit wiping normally"
