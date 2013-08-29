import sys
import time
from naoqi import ALProxy
import almath

joint = [0.40041595697402954, 0.03677403926849365, 0.7838320732116699, 0.4709799885749817, 0.552198052406311, 1]
print "joint", joint

motionProxy = ALProxy("ALMotion", "10.26.210.60", 9559)
name = "RArm"
space = 0
useSensorValues = True
result = motionProxy.getTransform(name, space, useSensorValues)

for i in range(0, 4):
  for j in range(0, 4):
    print result[4*i + j],
  print ''


path = [result]
print almath.position3DFromTransform(result)

#print 6DPos


