from robot import *
from mlabwrap import mlab
 
def test_move(action_name, robot):
  filename = "../data/" + action_name + "/reproduced.txt"
  f = open(filename)
  line = f.readlines()
  f.close
  for i in range(0, len(line)):
    target = []
    target = line[i].split("\t")
    target = map(float, target) 
    joints = target[0:8] 
    speed = 0.1
    names  = ["RArm", "LHipPitch", "RHipPitch"]
    robot.motion.angleInterpolationWithSpeed(names, joints, speed)
    i = i + 1
    robot.headTouch()
     

def moveJoints(robot):
  #set stiffness
  robot.motion.openHand("RHand")
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  robot.motion.setStiffnesses("Body", 1.0)

  robot.redballtracker.startTracker()
  
  # main loop
  step = 1 
  ballx = 0
  bally = 0
  ballz = 0
  while (step < 4):
    print "step:  ", step
    robot.headTouch()

    robot.mouthCam() 
    
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    if step == 1:  
      robot.searchBall() 
    sumx = 0.0
    sumy = 0.0
    sumz = 0.0
    for i in range(1,501):
      robot.mouthCam() 
      
      ballx, bally, ballz = robot.redballtracker.getPosition() 
      sumx = sumx+ballx
      sumy = sumy+bally
      sumz = sumz+ballz
    sumx = sumx / 500
    sumy = sumy / 500
    sumz = sumz / 500
    print "\n\nball position: ", ballx, bally, ballz
    ballPos = [ballx, bally, ballz] 
    output = mlab.GMR([ballx, bally, ballz])
    joints = []
    for index, item in enumerate(output[0:8]):
      joints.append(float(item))
    print "joints: ", joints

    # check if joints legal and move
    if all(jvalue == 0 for jvalue in joints) or all(bvalue == 0 for bvalue in ballPos):
      robot.speech.say("illegal ball position")
      robot.searchBall()
    elif (ballx > 2 or bally > 2 or ballz > 2):
      robot.speech.say("ball out of range")
    else:
      robot.speech.say("going to move")
      sleep(2)
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
    step = step + 1    

def moveHand(robot):
  #set stiffness
  robot.motion.openHand("RHand")
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  robot.motion.setStiffnesses("Body", 1.0)

  robot.redballtracker.startTracker()
  
  # main loop
  step = 1 
  ballx = 0
  bally = 0
  ballz = 0
  while (step < 4):
    print "step:  ", step
    robot.headTouch()

    robot.mouthCam() 
    
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    if step == 1:  
      robot.searchBall() 
    sumx = 0.0
    sumy = 0.0
    sumz = 0.0
    for i in range(1,501):
      robot.mouthCam() 
      
      ballx, bally, ballz = robot.redballtracker.getPosition() 
      sumx = sumx+ballx
      sumy = sumy+bally
      sumz = sumz+ballz
    sumx = sumx / 500
    sumy = sumy / 500
    sumz = sumz / 500
    print "\n\nball position: ", ballx, bally, ballz
    ballPos = [ballx, bally, ballz] 
    output = mlab.GMR([ballx, bally, ballz])
    handPos = []
    handSta = [] 
    for index, item in enumerate(output[8:14]):
      handPos.append(float(item))
    for index, item in enumerate(output[0:8]):
      if index == 5:
        handSta.append(float(item))
    print "output: ", output
    print "handPos: ", handPos
    print "handSta: ", handSta
    
    robot.speech.say("going to move")
    sleep(2)
    maxSpeedFraction  = 0.1
    names  = "RArm"
    space = 0
    axisMask = 7
    robot.motion.setPosition(names, space, handPos, maxSpeedFraction, axisMask)
    sleep(10) 
    timeLists = 1.0
    isAbsolute = False
    robot.motion.angleInterpolation("RHand", handSta, timeLists, isAbsolute)
    sleep(3)
    step = step + 1
