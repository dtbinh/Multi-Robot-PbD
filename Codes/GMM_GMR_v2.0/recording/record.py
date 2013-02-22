import sys
from naoqi import ALProxy
import motion
from time import *

IP = '10.26.210.61'
PORT = 9559
global mem, motion, redBallTracker, behav
mem = ALProxy('ALMemory', IP, PORT)
motion = ALProxy('ALMotion', IP, PORT)
redBallTracker = ALProxy("ALRedBallTracker", IP, PORT)
behav = ALProxy('ALBehaviorManager', IP, PORT)

def headTouch():
  headFront = mem.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
  headMiddle = mem.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
  headRear = mem.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
  return headFront or headMiddle or headRear

def JointData():
  #pprint.pprint(mem.getDataListName())
  #stiffnessLists = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0]
  #timeLists = 2.0
  #motion.stiffnessInterpolation('LArm', stiffnessLists, timeLists) 
  LShoulderPitch = mem.getData('Device/SubDeviceList/RShoulderPitch/Position/Sensor/Value')
  LShoulderRoll = mem.getData('Device/SubDeviceList/RShoulderRoll/Position/Sensor/Value')
  LElbowYaw = mem.getData('Device/SubDeviceList/RElbowYaw/Position/Sensor/Value')
  LElbowRoll = mem.getData('Device/SubDeviceList/RElbowRoll/Position/Sensor/Value')
  LWristYaw = mem.getData('Device/SubDeviceList/RWristYaw/Position/Sensor/Value')
  LHand = mem.getData('Device/SubDeviceList/RHand/Position/Sensor/Value')
  # LHipYawPitch and RHipYawPitch share the same motor
  Hip = mem.getData('Device/SubDeviceList/LHipYawPitch/Position/Sensor/Value')  
  
  result = [LShoulderPitch, LShoulderRoll, LElbowYaw, LElbowRoll, LWristYaw, LHand, Hip]
  return str(result) + "\t"

def HandData():
  # 0-torso, 1-world, 2-robot
  space = 0
  useSensorValues = True
  return str(motion.getPosition("RArm", space, useSensorValues)) + "\t"

def BallData():
  if not redBallTracker.isActive():
    print "Tracker is not active."
    sys.exit(1)
  return str(redBallTracker.getPosition()) + "\n"

####### main function ######
filename = '../record_data_' + str(time())
f = open(filename, 'w+')

# set head stiffness for ball tracking
motion.setStiffnesses("Head", 1.0)
#close hand
motion.closeHand('RHand')
motion.setStiffnesses("RHand", 0.8)
# start traking
redBallTracker.startTracker()

counter = 0
while not headTouch():
  Data = JointData()+HandData()+BallData()
  print counter, Data
  counter += 1
#  f.write(Data)
f.close()

#stop tracking
redBallTracker.stopTracker()  
# remove whole body stiffness
motion.setStiffnesses('Body', 0)
print "Exit recording."
