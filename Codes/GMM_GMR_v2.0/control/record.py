from robot import *

def record(argv):
  robot_name = argv[0]
  action_name = argv[1]
  
  if robot_name == "ironhide":
    ip = "10.26.210.60"
  if robot_name == "bumblebee":
    ip = "10.26.210.59"
  robot = ROBOT(ip, 9559, 'R')

  filename = "../data/" + action_name + "/record_data_" + str(robot_name) + str("_")+ str(time())
  f = open(filename, 'w+')
  
  robot.fixLegs()
  
  OBJECT = False; 
  if action_name == "picking":
    OBJECT = True
 
  if OBJECT:
    robot.searchBall()
    #ballPos = robot.BallData()
    sleep(1) 

  robot.motion.setStiffnesses("RHipPitch", 0.0)
  robot.motion.setStiffnesses("LHipPitch", 0.0)
  
  count = 0
  while not (robot.headTouch()):
    #if not robot.redballtracker.isActive():
    #   robot.speech.say('Can not start tracking')
    #action with object, like picking ball...
    if OBJECT:
      Data = str(robot.BallData()) + " " + str(robot.HandData()) + " " + str(robot.JointData())
    else: 
      Data = str(robot.HandData()) + " " + str(robot.JointData())
    Data = Data + '\n'
    count += 1
    f.write(Data)
    robot.pickBall()
    robot.dropBall()
    print count, Data
    
  robot.exit()
  print "<<< Exit recording normally."

if __name__== '__main__':
    argv = sys.argv[1:]
    record(argv)
