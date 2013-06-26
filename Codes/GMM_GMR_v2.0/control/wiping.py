import sys
import time
import motion 
from naoqi import ALProxy
'''
if (len(sys.argv) < 2):
    print "Usage: 'python motion_angleinterpolationwithspeed.py IP [PORT]'"
    sys.exit(1)

IP = '10.26.210.61' 
PORT = 9559
if (len(sys.argv) > 2):
    PORT = sys.argv[2]
try:
    proxy = ALProxy("ALMotion", IP, PORT)
    mem = ALProxy('ALMemory', IP, PORT)
except Exception,e:
    print "Could not create proxy to ALMotion"
    print "Error was: ",e
    sys.exit(1)
'''
IP = '10.26.210.60' 
PORT = 9559
proxy = ALProxy("ALMotion", IP, PORT)
mem = ALProxy('ALMemory', IP, PORT)
motion = ALProxy('ALMotion', IP, PORT)
proxy.setStiffnesses("RArm", 1.0)

names  = ["RArm", "LHipPitch", "RHipPitch"]
#names  = "RArm"
#numJoints = len(proxy.getJointNames(names))
#print "numJoints", numJoints

'''
filename = "../data/wiping/reproduced.txt"
f = open(filename)
line = f.readlines()
f.close
'''
def headTouch():
  headFront = mem.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
  headMiddle = mem.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
  headRear = mem.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
  return headFront or headMiddle or headRear


def HandData():
  # 0-torso, 1-world, 2-robot
  space = 0
  useSensorValues = True
  return motion.getPosition("RArm", space, useSensorValues)


stiffnessLists = 1.0
timeLists = 2.0
proxy.stiffnessInterpolation(names, stiffnessLists, timeLists)

proxy.setStiffnesses("RHand", 1.0)
proxy.closeHand('RHand')
proxy.setStiffnesses("RHand", 1.0)
'''
for i in range(0, len(line)):
  targetAngle = []
  #print i, line[i]
  targetAngle = line[i].split('\t')
  targetAngle = map(float, targetAngle)
  targetAngle[5] = 0.0  #hand close
  print "targetAngle:  ",targetAngle
  i = i + 1
  if headTouch():
    break
'''
while not headTouch():
  hand = HandData()
  print "current hand position ",hand
  var = raw_input("Enter 8 DOF joints: ")
  joints = map(float, var.split())
  print "8 DOF is: ", joints 
  # Using 10% of maximum joint speed
  maxSpeedFraction  = 0.05
  #proxy.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
  #proxy.setAngles(names, joints, maxSpeedFraction)
   
proxy.openHand('LHand') 
proxy.setStiffnesses("Body", 0.0)
