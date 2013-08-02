from robot import *

def record(argv):
  if argv[0] == "ironhide":
    ip = "10.26.210.60"
  if argv[0] == "bumblebee":
    ip = "10.26.210.59"
  action_name = argv[1]
  
  robot = ROBOT(ip, 9559, 'R')

  filename = "../data/" + action_name + "/record_data_" + str(time())
  f = open(filename, 'w+')
  
  robot.searchBall()
  count = 0
  while not (robot.headTouch()):
    if not robot.redballtracker.isActive():
       robot.speech.say('Can not start tracking')
    Data = robot.BallData() + " " + robot.JointData() + " " + robot.HandData()
    Data = Data + '\n'
    count += 1
    f.write(Data)
    robot.pickBall()
    robot.dropBall()
    print count, Data
    
  robot.exit()
  print "<<< Exit recording normally."

if __name__== '__main__':
	print sys.argv
	argv = sys.argv[1:]
	record(argv)
