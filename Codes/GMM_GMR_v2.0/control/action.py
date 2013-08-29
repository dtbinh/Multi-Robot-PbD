from robot import *
from mlabwrap import mlab
 
def moveJoints(robot, action_name):
  #set stiffness
  robot.motion.openHand("RHand")
  robot.fixLegs()
  robot.motion.setStiffnesses("Body", 1.0)
  
  OBJECT = False
  #if action_name == "picking" or action_name == "wiping":
  if action_name == "picking":
    OBJECT = True 
  if OBJECT:
    robot.searchBall()
    ballPos = robot.BallData() 
  
  #ballPos = [0.26, -0.20, 0.21]
  step = 1 
  while (step < 141):
    print "step:  ", step

    '''
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    '''
    #ballPos = robot.BallData() 
    #ballPos = robot.redballtracker.getPosition() 
    
    if OBJECT:
      #robot.mouthCam() 
      handPos = robot.HandData()
      dist = []   
      for index, item in enumerate(ballPos):
        dist.append(handPos[index] - item)
      #query = ballPos + handPos
      query = dist 
    else:
      query = step 
    print "query: ", query
    
    inDim = range(1, 2)
    #outDim = range(2,10)
    outDim = range(2,7)
    
    output = mlab.GMR(query, inDim, outDim)
    joints = []
    for index, item in enumerate(output):
      joints.append(float(item))
    joints.append(1)
    joints.append( -1.3)
    joints.append( -1.3)
    print "joints: ", joints, "\n"
    if all(item == 0 for item in joints):
      print "illegal joints, abandom"
    else:
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      #names  = ["RArm"]
      robot.motion.setStiffnesses(names, 1.0)
      robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
      step = step + 1    
    if robot.headTouch():
      break
'''
def moveHand(robot):
  #set stiffness
  robot.motion.openHand("RHand")
  robot.motion.setStiffnesses("Body", 0.7)

  robot.searchBall() 
  
  # main loop
  step = 1 
  while (step < 8):
    print "step:  ", step

    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    
    s = [0, 0, 0]
    for i in range(1,501):
      robot.mouthCam() 
      if i > 300: 
        tmpPos = robot.redballtracker.getPosition() 
        s = [a+b for a, b in zip(s, tmpPos)]
    ballPos = [item/200 for item in s]
    print "\n\nball position: ", ballPos 
    for item in ballPos:
      if abs(item) > 1: 
        robot.speech.say("Ball position out of range")
	break
    
    output = mlab.GMR(ballPos)
    handPos = []
    handSta = [] 
    for index, item in enumerate(output[8:14]):
      handPos.append(float(item))
    for index, item in enumerate(output[0:8]):
      if index == 5:
        handSta.append(float(item))
    print "handPos: ", handPos, "  handSta: ", handSta
  
    robot.speech.say("going to move")
    maxSpeedFraction  = 0.1
    names  = "RArm"
    space = 0
    axisMask = 7
    robot.motion.setPosition(names, space, handPos, maxSpeedFraction, axisMask)
    sleep(5) 
    timeLists = 1.0
    isAbsolute = True 
    robot.motion.angleInterpolation("RHand", handSta, timeLists, isAbsolute)
    sleep(3)
    if robot.headTouch():
      break
    step = step + 1


def moveJointsDist(robot):
  #set stiffness
  robot.motion.openHand("RHand")
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  robot.motion.setStiffnesses("Body", 1.0)
  robot.searchBall()
  
  # main loop
  step = 1 
  while (step < 30):
    print "step:  ", step
    robot.mouthCam() 
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    s = [0, 0, 0]

    counter = 100
    while counter > 0:  
      x, y, z = robot.redballtracker.getPosition() 
      if x < 1 and y < 1 and z < 1:
        tmpPos = [x, y, z]
        s = [a+b for a, b in zip(s, tmpPos)]
        counter = counter - 1
      else:
        print "illegal ball position"
    ballPos = [item/100 for item in s]
    handPos = robot.HandData()
    dist = [a - b for a, b in zip(handPos, ballPos)]
    query = dist + handPos

    print "\n\nball position: ", ballPos 
    print "hand position: ", handPos
    print "dist: ", dist
    print "query: ", query
    output = mlab.GMR(query)
    joints = []
    for index, item in enumerate(output[0:8]):
      joints.append(float(item))
    print "---> joints: ", joints
    if all(jvalue == 0 for jvalue in joints) or any(jvalue > 2 for jvalue in joints):
      robot.speech.say("illegal joints, abandon") 
    else:
      robot.speech.say("going to move")
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
    
    step = step + 1    
    if robot.headTouch():
      break
'''
