import OSC
import sys
sys.path.insert(0, '/home/pi/ext/Adafruit-Raspberry-Pi-Python-Code/Adafruit_PWM_Servo_Driver/')
from Adafruit_PWM_Servo_Driver import PWM

server = OSC.OSCServer ( ( '10.4.1.112', 8000 ) )

pwm = PWM(0x40, debug=True)

servoMin = 600.0  # Min pulse length out of 4096
servoMax = 150.0  # Max pulse length out of 4096

pwm.setPWMFreq(60)                        # Set frequency to 60 Hz


def onServo(path, tags, args, source):
	
	servoId = int(path.split('/')[2])
	val = float( args[0] )
	val = servoMin + ( servoMax - servoMin ) * val

	pwm.setPWM( servoId, 0, int( val ) )

for servoId in range(16) :
	address = "/servo/%u" % servoId
	server.addMsgHandler ( address, onServo )

while True :
	server.handle_request()