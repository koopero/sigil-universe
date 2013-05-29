import math
import OSC
import sys
import threading, os, random
import RPi.GPIO as GPIO, Image, time

running = False

def splitSign ( num ) :
	if num < 0 :
		return ( -1, -num )
	else :
		return ( 1, num )

class FM :
	@classmethod
	def mod ( cls, val, mod ) :
		if mod == 0 :
			return 0

		if val <= 0 :
			return 0

		return pow( val, pow( 1.0/mod, 1.6 ) )

	@classmethod
	def sine ( cls, phase, mod ) :
		return cls.mod( math.sin( phase * math.pi * 2 ) * 0.5 + 0.5, mod )

	@classmethod
	def halfsine ( cls, phase, mod ) :
		return cls.mod( math.sin( phase * math.pi * 2 ), mod )

	@classmethod
	def square ( cls, phase, mod ) :
		if phase > mod : 
			return 0

		return 1

	@classmethod
	def saw ( cls, phase, mod ) :
		return cls.mod( phase, mod )

	@classmethod
	def noise ( cls, phase, mod ) :
		return cls.mod( random.random(), mod )

class Blend :
	@classmethod
	def add ( cls, alpha, under, over ) :
		return (
			under[0] + over[0] * alpha,
			under[1] + over[1] * alpha,
			under[2] + over[2] * alpha,
			)


class Modulator :

	def addToOSC ( self, path ) :
		None



		return 1

	blend 	= Blend.add
	func 	= FM.sine
	r 		= 0.0
	g		= 0.0
	b 		= 0.0

	speed 	= 1

	phase	= 0.0
	wavelength	= 1.0
	mod 	= 0.5

	clock = 0.0



	def setValue ( self, path, value ) :
		print path, value
		if path == [ 'blend', 'value' ] and value in ( 'add', 'mult' ):
			self.blend = getattr( Blend, value)

		if path == [ 'func', 'value'] and hasattr( FM, value ):
			self.func = getattr( FM, value )

		if path == [ 'speed', 'value' ] :		self.speed = float( value )
		if path == [ 'wavelength', 'value' ] :	self.wavelength = pow ( 2, ( float ( value ) - 0.1 ) * 4 )

		if path == [ 'mod', 'value' ] :		self.mod = float( value )


		if path == [ 'colour', 'r' ] : self.r = value
		if path == [ 'colour', 'g' ] : self.g = value
		if path == [ 'colour', 'b' ] : self.b = value




	def execute ( self, buf, wavelength = 32,  speed = 1, alpha = 1 ) :
		length = len(buf)

		self.clock = self.clock + ( self.speed * speed )

		mod = self.mod
		
		for i in range( 0, length, 3 ) :

			r = self.r
			g = self.g
			b = self.b
			over  = ( self.g, self.r, self.b )

			x = float( i / 3 ) / wavelength * self.wavelength

			phase = self.phase + x + self.clock
			phase = phase % 1.0

			alpha = self.func( phase, mod )
			under = buf[ i : i + 3 ]

			c = self.blend( alpha, under, over )

			buf[ i ] = c[0]
			buf[ i + 1 ] = c[1]
			buf[ i + 2] = c[2]
			




mods = []

for i in range(2) :
	mods.append( Modulator () )


def onOSC ( path, tags, args, source):
	path = path.strip('/').split('/')
	
	if path[0] == 'mod' :
		mod = mods[int(path[1])]
		mod.setValue ( path[2:], args[0] )


class OSCThread( threading.Thread ) :
	def run( self ) :
		print 'running osc thread'
		osc = OSC.OSCServer ( ( '10.4.1.112', 8001 ) )
		osc.noCallback_handler = onOSC
		osc.addDefaultHandlers( )

		while running :
			osc.handle_request()



oscThread = OSCThread ()







gamma = 1.2

def colourValToInt ( val ):
	val = float( val )
	val = min ( 1, val )
	val = max ( 0, val )
	return 0x80 | int(pow(val, gamma) * 127.0 + 0.5)

# Configurable values
dev       = "/dev/spidev0.0"
 
spidev    = file(dev, "wb")

length 		= 57

running = True
oscThread.start()

while True :
	buf = [0] * (length * 3)

	for mod in mods :
		mod.execute ( buf, length, 1.0 / 12.0 )
	
	

	buf = map( colourValToInt, buf )
	buf.append ( 0 )
	buf.append ( 0 )
	buf.append ( 0 )
	buf.append ( 0 )

	
	buf = bytearray ( buf );


	spidev.write( buf )
	spidev.flush()

	time.sleep(1.0 / 60)


