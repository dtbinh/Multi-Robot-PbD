import sys
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
    self.mouthCam()
    sleep(1)
    self.motion.setStiffnesses("Head", 1.0)
    self.redballtracker.startTracker()

    if not self.redballtracker.isActive():
      self.speech.say('Can not start tracking')
      self.exit()
    #[ballx, bally, ballz] = self.redballtracker.getPosition()
    angle = 0.4
    speed = 0.1
    while(1):
      self.mouthCam()
      self.speech.say("Search ball")
      self.motion.setAngles("HeadYaw", angle, speed)
      if self.redballtracker.isNewData():
        break
      sleep(2)
      self.motion.setAngles("HeadPitch", angle, speed)
      if self.redballtracker.isNewData():
        break
      sleep(2)
      self.motion.setAngles("HeadYaw", -angle, speed)
      if self.redballtracker.isNewData():
        break
      sleep(2)
      self.motion.setAngles("HeadPitch", -angle, speed)
      if self.redballtracker.isNewData():
        break
      sleep(2)
    self.speech.say("Find ball, start tracking") 

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
    return headMiddle

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
    return str(self.redballtracker.getPosition()) 
  
  def mouthCam(self):
    while self.camera.getParam(18) == 0:
      self.camera.setParam(18, 1)
    return None

  def exit(self):
    try:
      self.redballtracker.stopTracker()
    except Exception,e:
      self.speech.say('Cannot stop tracking')      
    try:
      self.motion.setStiffnesses('Body', 0)
      self.motion.openHand(self.side+'Hand')
    except Exception,e:
      self.speech.say('Cannot relax')
    
    self.speech.say('Exit normaly')

def main(argv):
  if argv[0] == "ironhide":
    ip = "10.26.210.60"
  if argv[0] == "bumblebee":
    ip = "10.26.210.59"
  action_name = argv[1]
  
  robot = ROBOT(ip, 9559, 'R')

  filename = "../data/" + action_name + "/record_data_" + str(time())
  f = open(filename, 'w+')
  
  robot.searchBall()
  count = 0
  while not (robot.headTouch()):
    if not robot.redballtracker.isActive():
       robot.speech.say('Can not start tracking')
    Data = robot.BallData() + " " + robot.JointData() + " " + robot.HandData()
    Data = Data + '\n'
    count += 1
    f.write(Data)
    robot.pickBall()
    robot.dropBall()
    print count, Data
    
  robot.exit()
  print "<<< Exit recording normally."

if __name__== '__main__':
	print sys.argv
	argv = sys.argv[1:]
	main(argv)
