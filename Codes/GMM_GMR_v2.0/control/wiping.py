import os
import sys
import time
from naoqi import ALProxy
import vision_definitions
import Image
 
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
  
  def headTouch(self):
    headFront = mem.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
    headMiddle = mem.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
    headRear = mem.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
    return headFront or headMiddle or headRear


  def pictureCapture(self):
    resolution = vision_definitions.kQQVGA
    colorSpace = vision_definitions.kYUVColorSpace
    fps = 30
    nameID = self.camera.subscribe("python_GVM", resolution, colorSpace, fps)
    print nameID
    self.camera.setResolution(nameID, resolution)  

    print "getting images in remote"
    for i in range(0, 20):
      self.camera.getImageRemote(nameID)
    
    self.camera.unsubscribe(nameID)
    print "end of gvm_getImageRemote python script"

  def pictureShow(self):
    resolution = 2
    colorSpace = 11
    videoClient = self.camera.subscribe("python_client", resolution, colorSpace, 5)
    
    t0 = time.time()
    naoImage = self.camera.getImageRemote(videoClient) 
    t1 = time.time()
    print "acquistion delay", t1 - t0
    self.camera.unsubscribe(videoClient)

    imageWidth = naoImage[0]
    imageHeight = naoImage[1]
    array = naoImage[6]
    im = Image.fromstring("RGB", (imageWidth, imageHeight), array)

    im.save("../data/wiping/img/camImage.png", "PNG")
    im.show()

####### main ########
if __name__ == '__main__':
  ironhide = ROBOT('10.26.210.60', 9559, 'R') 
  
  #ironhide.motion.setStiffnesses("RArm", 1.0)

  #names  = ["RArm", "LHipPitch", "RHipPitch"]
  #names  = "RArm"
  #numJoints = len(proxy.getJointNames(names))
  #print "numJoints", numJoints

  #filename = "../data/wiping/reproduced.txt"
  #f = open(filename)
  #line = f.readlines()
  #f.close
  '''
  stiffnessLists = 1.0
  timeLists = 2.0
  proxy.stiffnessInterpolation(names, stiffnessLists, timeLists)


  proxy.setStiffnesses("RHand", 1.0)
  proxy.closeHand('RHand')
  proxy.setStiffnesses("RHand", 1.0)


for i in range(0, len(line)):
  #photo.takePictureRegularly(1, "/tmp/cameras", 1, "jpg", 2)
  targetAngle = []
  #print i, line[i]
  targetAngle = line[i].split('\t')
  targetAngle = map(float, targetAngle)
  targetAngle[5] = 0.0  #hand close
  print "targetAngle:  ",targetAngle
  i = i + 1
  if headTouch():
    break

  joints = targetAngle[0:8]
  print "joints ",joints
  #print "RArm ",joints[0:6]
  #print "LHip ", joints[6]
  #print "RHip ", joints[7]
  # Using 10% of maximum joint speed
  maxSpeedFraction  = 0.1
  #proxy.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
  #proxy.setAngles(names, joints, maxSpeedFraction) #angleInterpolationWithSpeed works better than setAngles, regarding the speed
'''
  ironhide.pictureCapture()
  ironhide.pictureShow()

  print "Finish taking picture"
   
  ironhide.motion.openHand('LHand') 
  ironhide.motion.setStiffnesses("Body", 0.0)
  
  print "Exit normally"
