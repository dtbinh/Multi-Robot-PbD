import os
import sys
from time import *
from naoqi import * 

class ROBOT():
  def __init__(self, ip, port, side, name):
    self.ip = ip
    self.name = name
    self.port = port
    self.side = side
    self.motion = ALProxy('ALMotion', self.ip, self.port)
    self.memory = ALProxy('ALMemory', self.ip, self.port)
    self.camera = ALProxy('ALVideoDevice', self.ip, self.port)
    self.redballtracker = ALProxy('ALRedBallTracker', self.ip, self.port)
    self.speech = ALProxy('ALTextToSpeech', self.ip, self.port)
    self.controllJoints = [self.side+'Arm', 'LHipPitch', 'RHipPitch'] 

  def headTouch(self):
    headFront = self.memory.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
    headMiddle = self.memory.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
    headRear = self.memory.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
    return headFront or headMiddle or headRear

  def readAngles(self):
    filename = '../data/rolling/' + self.name + '.txt'
    f = open(filename)
    line = f.readlines()
    f.close
    return line
  
  def closeHand(self):
    self.motion.closeHand(self.side+'Hand')
    self.motion.setStiffnesses(self.side+'Hand', 1.0)

  def setStiffness(self):
    stiffnessLists = 1.0
    timeLists = 1.0
    self.motion.stiffnessInterpolation(self.controllJoints, stiffnessLists, timeLists)
    self.motion.stiffnessInterpolation(self.controllJoints, stiffnessLists, timeLists)
    

############### main ####################
if __name__ == '__main__':
  ironhide = ROBOT('10.26.210.60', 9559, 'R', 'ironhide')
  bumblebee = ROBOT('10.26.210.59', 9559, 'L', 'bumblebee')

  ironhide.speech.say('Start rolling')
  bumblebee.speech.say('Start rolling')
  ironhide.closeHand()
  bumblebee.closeHand()
  
  ironhide.setStiffness()
  bumblebee.setStiffness()

  line_ironhide = ironhide.readAngles()
  line_bumblebee = bumblebee.readAngles()
  for i in range(0, len(line_ironhide)):
    targetAngle_ironhide = []
    targetAngle_bumblebee = []
    #print i, line[i]
    targetAngle_ironhide = line_ironhide[i].split('\t')
    targetAngle_bumblebee = line_bumblebee[i].split('\t')
    targetAngle_ironhide = map(float, targetAngle_ironhide)
    targetAngle_bumblebee = map(float, targetAngle_bumblebee)
    targetAngle_ironhide[5] = 0.0  #hand close
    targetAngle_bumblebee[5] = 0.0  #hand close
    joints_ironhide = targetAngle_ironhide[0:8]
    joints_bumblebee = targetAngle_bumblebee[0:8]
    
    if ironhide.headTouch() or bumblebee.headTouch():
      ironhide.speech.say('Stop rolling')
      bumblebee.speech.say('Stop rolling')
      break
    
    isAbsolute = True
    timeLists =0.05
    ironhide.motion.angleInterpolation(ironhide.controllJoints, joints_ironhide, timeLists, isAbsolute)
    bumblebee.motion.angleInterpolation(bumblebee.controllJoints, joints_bumblebee, timeLists, isAbsolute)
    #maxSpeedFraction  = 0.2
    #ironhide.motion.angleInterpolationWithSpeed(ironhide.controllJoints, joints_ironhide, maxSpeedFraction)
    #bumblebee.motion.angleInterpolationWithSpeed(bumblebee.controllJoints, joints_bumblebee, maxSpeedFraction)
    #ironhide.motion.setAngles(ironhide.controllJoints, joints, maxSpeedFraction)
   
    print i

  ironhide.motion.openHand(ironhide.side + 'Hand') 
  bumblebee.motion.openHand(bumblebee.side + 'Hand') 
  ironhide.motion.setStiffnesses("Body", 0.0)
  bumblebee.motion.setStiffnesses("Body", 0.0)

  ironhide.speech.say('Finish rolling')
  bumblebee.speech.say('Finish rolling')
