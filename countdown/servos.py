import OSC
from '/home/pi/ext/Adafruit-Raspberry-Pi-Python-Code/Adafruit_PWM_Servo_Driver/Adafruit_PWM_Servo_Driver' import PWM

server = OSC.OSCServer ( ( '10.4.1.40', 8000 ) )

pwm = PWM(0x40, debug=True)

servoMin = 150.0  # Min pulse length out of 4096
servoMax = 600.0  # Max pulse length out of 4096

pwm.setPWMFreq(60)                        # Set frequency to 60 Hz


def onServo(path, tags, args, source):
	servoId = path.split('/')[1]

	val = float( args[0] )
	val = servoMin + ( servoMax - servoMin ) * val

	pwn.setPWM( servoId, 0, int( val ) )

for servoId in range(16) :
	server.addMsgHandler ( "/servo/%u" % servoId, onServo )

while True :
	server.handle_request()