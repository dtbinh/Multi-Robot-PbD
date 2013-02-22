import sys
import time
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
IP = '10.26.210.61' 
PORT = 9559
proxy = ALProxy("ALMotion", IP, PORT)
mem = ALProxy('ALMemory', IP, PORT)
proxy.setStiffnesses("RArm", 1.0)

names  = "RArm"
numJoints = len(proxy.getJointNames(names))
print "numJoints", numJoints

filename = "approaching_repro.data"
f = open(filename)
line = f.readlines()
f.close


def headTouch():
  headFront = mem.getData('Device/SubDeviceList/Head/Touch/Front/Sensor/Value')
  headMiddle = mem.getData('Device/SubDeviceList/Head/Touch/Middle/Sensor/Value')
  headRear = mem.getData('Device/SubDeviceList/Head/Touch/Rear/Sensor/Value')
  return headFront or headMiddle or headRear

stiffnessLists = 1.0
timeLists = 2.0
proxy.stiffnessInterpolation(names, stiffnessLists, timeLists)

proxy.setStiffnesses("LHand", 1.0)
proxy.closeHand('LHand')
proxy.setStiffnesses("LHand", 1.0)
for i in range(0, len(line)):
  targetAngle = []
  #print i, line[i]
  targetAngle = line[i].split('\t')
  targetAngle = map(float, targetAngle)
  #targetAngle[5] = 0.1
  print "targetAngle:  ",targetAngle
  i = i + 1
  if headTouch():
    break

  new = targetAngle[0:6]
  print "new: ",new
  # Using 10% of maximum joint speed
  maxSpeedFraction  = 0.05
  proxy.angleInterpolationWithSpeed(names, new, maxSpeedFraction)
 
proxy.openHand('LHand') 
proxy.setStiffnesses("Body", 0.0)
