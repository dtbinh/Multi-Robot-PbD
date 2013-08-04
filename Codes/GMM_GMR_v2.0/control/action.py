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
     

def move(robot):
  #set stiffness
  robot.motion.openHand("RHand")
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  robot.motion.setStiffnesses("Body", 1.0)

  robot.redballtracker.startTracker()
  
  # main loop
  step = 0
  ballx = 0
  bally = 0
  ballz = 0
  while (step < 4):
    robot.headTouch()
      

    robot.mouthCam() 
    
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    robot.searchBall() 
    #check if traker lost ball 
    newx, newy, newz = robot.redballtracker.getPosition()
    if (newx - ballx) < 0.01 and (newy - bally) < 0.01 and (newz - ballz) < 0.01:
        robot.speech.say("lost ball")
	robot.searchBall()
    sumx = 0.0
    sumy = 0.0
    sumz = 0.0
    for i in range(1,201):
      robot.mouthCam() 
      
      ballx, bally, ballz = robot.redballtracker.getPosition() 
      sumx = sumx+ballx
      sumy = sumy+bally
      sumz = sumz+ballz
    sumx = sumx / 200
    sumy = sumy / 200
    sumz = sumz / 200
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
      #robot.searchBall()
    elif (ballx > 1.0 or bally > 1.0 or ballz > 1.0):
      robot.speech.say("ball out of range")
    else:
      robot.speech.say("going to move")
      sleep(2)
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      #robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
    
    step = step + 1

