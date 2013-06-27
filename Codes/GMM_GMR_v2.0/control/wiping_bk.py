import os
import sys
import time
from naoqi import ALProxy
import naoqi
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
photo = ALProxy("ALVisionToolbox", IP, PORT)
proxy.setStiffnesses("RArm", 1.0)

names  = ["RArm", "LHipPitch", "RHipPitch"]
#names  = "RArm"
#numJoints = len(proxy.getJointNames(names))
#print "numJoints", numJoints

filename = "../data/wiping/reproduced.txt"
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

proxy.setStiffnesses("RHand", 1.0)
proxy.closeHand('RHand')
proxy.setStiffnesses("RHand", 1.0)

'''
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
photo.stopTPR("/tmp/cameras/test_","jpg")
print "Start taking picture"
print photo.backlighting()
print photo.isItDark()
try:
  photo.takePictureRegularly(0.5, "/tmp/cameras/test_", True, "jpg", 0)
except Exception, e:
  print "Error recording"
  print str(e)
  exit(1) 
#photo.takePicture()

print "Finish taking picture"
   
proxy.openHand('LHand') 
proxy.setStiffnesses("Body", 0.0)
