from robot import *
from mlabwrap import mlab
 
def moveJoints(robot, action_name):
  #set stiffness
  robot.motion.openHand("RHand")
  robot.fixLegs()
  robot.motion.setStiffnesses("Body", 1.0)
  
  step = 1 
  while (step < 201):
    print "step:  ", step
    
    query = step 
    inDim = range(1, 2)
    outDim = range(2,10)
    
    output = mlab.callGMR(query, inDim, outDim)
    joints = []
    for index, item in enumerate(output):
      joints.append(float(item))
    print "joints: ", joints, "\n"
    if all(item == 0 for item in joints):
      print "illegal joints, abandom"
    else:
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      robot.motion.setStiffnesses(names, 1.0)
      robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
      step = step + 1    
    if robot.headTouch():
      break
