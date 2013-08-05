import sys, os
from time import *
from naoqi import *
from time import *

class ROBOT():
  def __init__(self, ip, port, side):
    self.ip = ip
    self.port = port
    self.side = side
    self.motion = ALProxy('ALMotion', self.ip, self.port)
    self.memory = ALProxy('ALMemory', self.ip, self.port)
    self.camera = ALProxy('ALVideoDevice', self.ip, self.port)
    self.redballtracker = ALProxy('ALRedBallTracker', self.ip, self.port)
    self.speech = ALProxy('ALTextToSpeech', self.ip, self.port)
	
  def searchBall(self):
    self.motion.setStiffnesses("Head", 1.0)
    self.redballtracker.stopTracker()
    sleep(1)
    self.redballtracker.startTracker()
    print self.redballtracker.getPosition()
    if not self.redballtracker.isActive():
      self.speech.say('Can not start tracking')
      self.exit()
    
    angle = 0.5
    speed = 0.1
    while True:
      self.mouthCam()
      if not self.redballtracker.isActive():
        self.speech.say('Can not start tracking')
        self.exit()
      self.speech.say("Search")
      
      self.motion.setAngles("HeadYaw", 0.5, speed)
      sleep(2)
      if self.redballtracker.isNewData():
        self.speech.say("new ball, start tracking")
        break 
      
      self.motion.setAngles("HeadPitch", 0.2, speed)
      sleep(2)
      if self.redballtracker.isNewData():
        self.speech.say("new ball, start tracking") 
        break 
      
      self.motion.setAngles("HeadYaw", -0.5, speed)
      sleep(2)
      if self.redballtracker.isNewData():
        self.speech.say("new ball, start tracking") 
        break 
      
      self.motion.setAngles("HeadPitch", -0.2, speed)
      sleep(2)
      if self.redballtracker.isNewData():
        self.speech.say("new ball, start tracking") 
        break 
      if self.headTouch():
	break
   

  def pickBall(self):
    headFront = self.memory.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value') 
    if headFront:
      self.motion.closeHand(self.side+"Hand") 
      self.motion.setStiffnesses("RHand", 1.0)
      self.speech.say("Pick ball") 

  def dropBall(self):
    headRear = self.memory.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
    if headRear:
      self.motion.openHand(self.side+"Hand") 
      self.motion.setStiffnesses("RHand", 1.0)
      self.speech.say("Drop ball")
  
  def headTouch(self):
    headMiddle = self.memory.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
    if headMiddle:
      self.speech.say("Touch stop")
      return True
    else:
      return False

  def JointData(self):
    ShoulderPitch = self.memory.getData('Device/SubDeviceList/'+self.side+'ShoulderPitch/Position/Sensor/Value')
    ShoulderRoll = self.memory.getData('Device/SubDeviceList/'+self.side+'ShoulderRoll/Position/Sensor/Value')
    ElbowYaw = self.memory.getData('Device/SubDeviceList/'+self.side+'ElbowYaw/Position/Sensor/Value')
    ElbowRoll = self.memory.getData('Device/SubDeviceList/'+self.side+'ElbowRoll/Position/Sensor/Value')
    WristYaw = self.memory.getData('Device/SubDeviceList/'+self.side+'WristYaw/Position/Sensor/Value')
    Hand = self.memory.getData('Device/SubDeviceList/'+self.side+'Hand/Position/Sensor/Value')
    # LHipYawPitch and RHipYawPitch share the same motor
    LHipPitch = self.memory.getData('Device/SubDeviceList/LHipPitch/Position/Sensor/Value')
    RHipPitch = self.memory.getData('Device/SubDeviceList/RHipPitch/Position/Sensor/Value')
    result = [ShoulderPitch, ShoulderRoll, ElbowYaw, ElbowRoll, WristYaw, Hand, LHipPitch, RHipPitch]
    return str(result) 

  def HandData(self):
    # 0-torso, 1-world, 2-robot
    space = 0
    useSensorValues = True
    return str(self.motion.getPosition(self.side+"Arm", space, useSensorValues))
  
  def BallData(self):
    if not self.redballtracker.isActive():
      print "Tracker is not active."
      self.speech.say('Fail tracking')
      self.exit()
    sumx = 0
    sumy = 0
    sumz = 0
    for i in range(1, 101):
      ballx, bally, ballz = self.redballtracker.getPosition()
      sumx = sumx + ballx
      sumy = sumy + bally
      sumz = sumz + ballz
    sumx = sumx / 100
    sumy = sumy / 100
    sumz = sumz / 100
    
    return str([sumx, sumy, sumz]) 
  
  def mouthCam(self):
    while self.camera.getParam(18) == 0:
      self.camera.setParam(18, 1)
    return None

  def exit(self):
    try:
      while self.redballtracker.isActive():
        self.redballtracker.stopTracker()
    except Exception,e:
      self.speech.say('Cannot stop tracking')      
    try:
      self.motion.setStiffnesses('Body', 0)
      self.motion.openHand(self.side+'Hand')
    except Exception,e:
      self.speech.say('Cannot relax')
    
    self.speech.say('Exit normaly')

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

