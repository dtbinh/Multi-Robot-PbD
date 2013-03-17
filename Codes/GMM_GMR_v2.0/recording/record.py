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
  return str(result) + " "

def HandData():
  # 0-torso, 1-world, 2-robot
  space = 0
  useSensorValues = True
  return str(motion.getPosition("RArm", space, useSensorValues)) + " "

def BallData():
  if not redBallTracker.isActive():
    print "Tracker is not active."
    sys.exit(1)
  return str(redBallTracker.getPosition()) + "\n"

####### main function ######
filename = '../data/record_data_' + str(time())
f = open(filename, 'w+')

# set head stiffness for ball tracking
motion.setStiffnesses("Head", 1.0)
#close hand
#motion.closeHand('RHand')
motion.setAngles('RHand', 0.2, 0.2)
motion.setStiffnesses("RHand", 1.0)
# set lower body stiffness and fixed pose
print "Leg angles:  ", motion.getAngles("RLeg", True)
print "Leg angles:  ", motion.getAngles("LLeg", True)
motion.setAngles("RLeg", [-0.02757003903388977, -0.001492038369178772, -1.5202360153198242, 0.8115279674530029, 0.42342597246170044, -0.001492038369178772], 0.1)
motion.setAngles("RLeg", [-0.02757003903388977, -0.001492038369178772, -1.5202360153198242, 0.8115279674530029, 0.42342597246170044, -0.001492038369178772], 0.1)
motion.setStiffnesses("RLeg", 1.0)
motion.setStiffnesses("LLeg", 1.0)

# start traking
redBallTracker.startTracker()

counter = 0
while not headTouch():
  Data = JointData()+HandData()+BallData()
  print counter, Data
  counter += 1
  f.write(Data)
f.close()

#stop tracking
redBallTracker.stopTracker()  
# remove whole body stiffness
motion.setStiffnesses('Body', 0)
print "Exit recording."
