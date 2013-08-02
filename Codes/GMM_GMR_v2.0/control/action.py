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
    if robot.headTouch():
      break 

def move(robot):
  robot.mouthCam()
  robot.redballtracker.startTracker()
  
  # main loop
  step = 0
  ballx = 0
  bally = 0
  ballz = 0
  while (step < 100):
    if robot.headTouch():
      break
    robot.mouthCam() 
    
    #check if traker works
    while not robot.redballtracker.isActive():
      robot.redballtracker.startTracker()
      print "Tracker failed, try again"
      robot.speech.say("Tracker failed, try again.")
    
    #check if traker lost ball 
    newx, newy, newz = robot.redballtracker.getPosition()
    if (newx - ballx) < 0.01 and (newy - bally) < 0.01 and (newz - ballz) < 0.01:
        robot.speech.say("lost ball")
	robot.searchBall()

    ballx, bally, ballz = robot.redballtracker.getPosition() 
    ballPos = [ballx, bally, ballz]
    print "\n\nball position: ", ballPos
     
    output = mlab.GMR([ballx, bally, ballz])
    joints = [] 
    for index, item in enumerate(output[0:8]):
      joints.append(float(item))
    print "joints: ", joints
    
    # check if joints legal and move
    if all(jvalue == 0 for jvalue in joints) or all(bvalue == 0 for bvalue in ballPos):
      robot.speech.say("illegal ball position")
      robot.searchBall()
    else:
      robot.speech.say("going to move")
      sleep(2)
      maxSpeedFraction  = 0.1
      names  = ["RArm", "LHipPitch", "RHipPitch"]
      #robot.motion.angleInterpolationWithSpeed(names, joints, maxSpeedFraction)
    
    step = step + 1

def action(IP, DEBUG, action_name):
  print ">>> Start ", action_name
  robot = ROBOT(IP, 9559, 'R') 
  robot.mouthCam() 
  #set stiffness
  names  = ["RArm", "LHipPitch", "RHipPitch"]
  robot.motion.setStiffnesses("Body", 1.0)

  #test_move(action_name, robot)
  move(robot)
  robot.exit()
 
  print ">>> Exit ", action_name, " normally"
