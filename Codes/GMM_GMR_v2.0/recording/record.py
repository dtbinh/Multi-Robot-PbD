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

  def headTouch(self):
    headFront = self.memory.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
    headMiddle = self.memory.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
    headRear = self.memory.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
    return headFront or headMiddle or headRear

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
    return str(result) + " "

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

############## main #################
if __name__=='__main__':

  ironhide = ROBOT('10.26.210.60', 9559, 'R')
  bumblebee = ROBOT('10.26.210.59', 9559, 'L')

  ironhide.motion.setStiffnesses("Head", 1.0)
  ironhide.motion.closeHand(ironhide.side+'Hand')
  ironhide.motion.setStiffnesses(ironhide.side+"Hand", 1.0)
  ironhide.redballtracker.startTracker()

  if not ironhide.redballtracker.isActive():
    ironhide.speech.say('Can not start tracking')
    ironhide.exit()
  else:
    ironhide.speech.say('Start tracking')


  bumblebee.motion.setStiffnesses("Head", 1.0)
  bumblebee.motion.closeHand(bumblebee.side+'Hand')
  bumblebee.motion.setStiffnesses(bumblebee.side+"Hand", 1.0)
  bumblebee.redballtracker.startTracker()
  if not bumblebee.redballtracker.isActive():
    bumblebee.speech.say('Can not start tracking')
    bumblebee.exit()
  else:
    bumblebee.speech.say('Start tracking')

  filename = '../data/rolling/record_data_' + str(time())
  f = open(filename, 'w+')
  count = 0
  while not (ironhide.headTouch() or bumblebee.headTouch()):
    if not ironhide.redballtracker.isActive():
       ironhide.speech.say('Can not start tracking')
    if not bumblebee.redballtracker.isActive():
      bumblebee.speech.say('Can not start tracking')
    
   # ironhide.mouthCam()
   # bumblebee.mouthCam()
    Data = ironhide.JointData()+ironhide.HandData()+ironhide.BallData()+bumblebee.JointData()+bumblebee.HandData()+bumblebee.BallData()
    Data = Data + '\n'
    count += 1
    f.write(Data)
    print count, Data
    
  ironhide.exit()
  bumblebee.exit()

  print "<<< Exit recording normally."
