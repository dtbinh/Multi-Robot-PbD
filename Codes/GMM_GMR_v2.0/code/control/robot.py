import sys, os
from time import *
from naoqi import *

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
	
  def closeHand(self):
    headFront = self.memory.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value') 
    if headFront:
      self.motion.closeHand(self.side+"Hand") 
      self.motion.setStiffnesses("RHand", 1.0)
      self.speech.say("close hand") 

  def openHand(self):
    headRear = self.memory.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
    if headRear:
      self.motion.openHand(self.side+"Hand") 
      self.motion.setStiffnesses("RHand", 1.0)
      self.speech.say("open hand")
  
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
    #LHipPitch = self.memory.getData('Device/SubDeviceList/LHipPitch/Position/Sensor/Value')
    #RHipPitch = self.memory.getData('Device/SubDeviceList/RHipPitch/Position/Sensor/Value')
    #result = [ShoulderPitch, ShoulderRoll, ElbowYaw, ElbowRoll, WristYaw, Hand, LHipPitch, RHipPitch]
    result = [ShoulderPitch, ShoulderRoll, ElbowYaw, ElbowRoll, WristYaw, Hand]
    #result = [ShoulderPitch, ShoulderRoll, ElbowYaw, ElbowRoll, WristYaw]
    return result 

  def HandData(self):
    # 0-torso, 1-world, 2-robot
    space = 0 
    useSensorValues = True
    # 6 DOF: 3 position and 3 orientation
    #return self.motion.getPosition(self.side+"Arm", space, useSensorValues)
    # 3 DOF
    data = self.motion.getPosition(self.side+"Arm", space, useSensorValues)
    #action without object, like writing, waving...
    #return data[0:3]
    return data

  def fixLegs(self):
    self.motion.setStiffnesses("Body", 0.0)
    RLeg = [0.06, 0.0, -1.10, 0.74, 0.43, 0.0]
    LLeg = [0.06, 0.0, -1.10, 0.74, 0.43, 0.0]
    timeLists = 2.0
    isAbsolute = True
    
    self.motion.setStiffnesses("RLeg", 1.0)
    self.motion.angleInterpolation("RLeg", RLeg, timeLists, isAbsolute)
    self.motion.setStiffnesses("LLeg", 1.0)
    self.motion.angleInterpolation("LLeg", LLeg, timeLists, isAbsolute)
   
    #turn off torso stiffness
    #self.motion.setStiffnesses("RHipPitch", 0.0)
    #self.motion.setStiffnesses("LHipPitch", 0.0)
    sleep(2)
    print "Leg stiffnesses set."
    self.speech.say("I'm ready.")

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
