from robot import *

def record_unstableBall(argv):
  if argv[0] == "ironhide":
    ip = "10.26.210.60"
  if argv[0] == "bumblebee":
    ip = "10.26.210.59"
  action_name = argv[1]
  
  robot = ROBOT(ip, 9559, 'R')

  filename = "../data/" + action_name + "/record_data_" + str(time())
  f = open(filename, 'w+')
  robot.fixLegs() 
  robot.searchBall()
  count = 0
  while not (robot.headTouch()):
    if not robot.redballtracker.isActive():
       robot.speech.say('Can not start tracking')
    Data = str(robot.BallData()) + " " + str(robot.HandData()) + " " + str(robot.JointData())
    Data = Data + '\n'
    count += 1
    f.write(Data)
    robot.pickBall()
    robot.dropBall()
    print count, Data
    
  robot.exit()
  print "<<< Exit recording normally."

def record(argv):
  if argv[0] == "ironhide":
    ip = "10.26.210.60"
  if argv[0] == "bumblebee":
    ip = "10.26.210.59"
  action_name = argv[1]
  
  robot = ROBOT(ip, 9559, 'R')

  filename = "../data/" + action_name + "/record_data_" + str(time())
  f = open(filename, 'w+')
  robot.fixLegs() 
  robot.searchBall()
  count = 0

  s = [0, 0, 0]
  counter = 500
  while counter > 0:    
    x, y, z = robot.redballtracker.getPosition()  
    if x < 1.5 and y < 1.5 and z < 1.5:
      tmpPos = [x, y, z]
      s = [a+b for a, b in zip(s, tmpPos)]
      counter = counter - 1
    else:
      print "illegal ball position"
  ballPos = [item/500 for item in s]

  while not (robot.headTouch()):
    if not robot.redballtracker.isActive():
       robot.speech.say('Can not start tracking')
    Data = str(ballPos) + " " + str(robot.HandData()) + " " + str(robot.JointData())
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
