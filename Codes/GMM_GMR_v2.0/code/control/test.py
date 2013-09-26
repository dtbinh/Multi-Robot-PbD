from robot import *
from mlabwrap import mlab

def test_moveJoints_action(action_name, robot):
  robot.speech.say("test move joints")
  filename = "../data/" + action_name + "/reproduced.txt"
  f = open(filename)
  line = f.readlines()
  f.close
  robot.setStiffnesses("RArm", 1.0)
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

def test_moveJoints(robot):
  robot.speech.say("test move right arm joints")
  robot.motion.setStiffnesses("RArm", 1.0)
  joints = [0.38000555763939076, -0.8879903003067036, 0.6044293274014357, 0.9400745385166597, 0.9033239749488264, 0.9974683137855982]
  speed = 0.1
  robot.motion.angleInterpolationWithSpeed("RArm", joints, speed)
  sleep(3)

def test_closeHand(robot):
  print "test_closeHand"
  robot.motion.setStiffnesses("RArm", 1.0)
  timeLists = 1.0
  isAbsolute = True  #must be True
  handSta = 0 #0:close hand, 1:open hand
  robot.motion.angleInterpolation("RHand", handSta, timeLists, isAbsolute)
  sleep(3)

def test_ballrange(robot):
   robot.searchBall()
   while not robot.headTouch():
     if not robot.redballtracker.isActive():
       robot.speech.say("Tracking failed.")
     Data = robot.BallData() 
     print Data

def test_jointangle(robot):
   while not robot.headTouch():
     print robot.JointData()

def test_handpos(robot):
   robot.motion.setStiffnesses('RArm', 0.0)
   while not robot.headTouch():
     print robot.HandData()
#find the difference between the command and sensed angles.
#JointData() in robot.py uses sensor readings
def test_getAngles(robot):
  while not robot.headTouch():
    names = "RArm"
    useSensor = False
    commandAngles = robot.motion.getAngles(names, useSensor)
    #print "Command angles: ", str(commandAngles)

    useSensor = True
    sensorAngles = robot.motion.getAngles(names, useSensor)
    #print "Sensor angles: ", str(sensorAngles)

    errors = []
    errors2 = []
    for i in range(0, len(commandAngles)):
      errors.append(commandAngles[i] - sensorAngles[i])
    #print "Errors: ", errors, "\n"
    joints = robot.JointData()
    for i in range(0, len(commandAngles)):
      errors2.append(joints[i] - sensorAngles[i])
    #print "Errors between mydata and sensorAngles: ", errors2

    #sleep(2)
    #print "\n\n\n"
    names = "RLeg"
    useSensor = True
    sensorAngles = robot.motion.getAngles(names, useSensor)
    print names, ":  ", sensorAngles
    names = "LLeg"
    useSensor = True
    sensorAngles = robot.motion.getAngles(names, useSensor)
    print names, ":  ", sensorAngles
   
def test_ForwardKinect(robot):
  while not robot.headTouch():
    joint = robot.JointData()
    #print "joint: ", joint
    handRead = robot.HandData()
    print "handRead: ", handRead
    #output = mlab.testForwardKinect([joint])
    output = mlab.ForwardKinematics([joint])
    handComp = []
    for index, item in enumerate(output):
      handComp.append(float(item))
    print "handComp: ", handComp
  
    diff = [a-b for a, b in zip(handRead,  handComp)]
    percent_diff = [(a-b)/a for a, b in zip(handRead,  handComp)]

    print "percent_diff: ", percent_diff, "------\n"
    print "diff: ", diff, "\n\n"
    sleep(3)

def test_robotInfo(robot):
    robotConfig = robot.motion.getRobotConfig()
    for i in range(len(robotConfig[0])):
        print robotConfig[0][i], ": ", robotConfig[1][i]
    # "Model Type"   : "naoH25", "naoH21", "naoT14" or "naoT2".
    # "Head Version" : "VERSION_32" or "VERSION_33" or "VERSION_40".
    # "Body Version" : "VERSION_32" or "VERSION_33" or "VERSION_40".
    # "Laser"        : True or False.
    # "Legs"         : True or False.
    # "Arms"         : True or False.
    # "Extended Arms": True or False.
    # "Hands"        : True or False.
    # "Arm Version"  : "VERSION_32" or "VERSION_33" or "VERSION_40".
    # Number of Legs : 0 or 2
    # Number of Arms : 0 or 2
    # Number of Hands: 0 or 2

    
