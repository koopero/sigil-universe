import math
import OSC
import sys


class Modulator :

	def addToOSC ( self, path ) :
		None

	def func_sine ( phase, mod ) :
		return math.sin( phase * math.pi * 2 ) * 0.5 + 0.5

	def func_halfsine ( phase, mod ) :
		return math.sin( phase * math.pi * 2 )

	def func_square ( phase, mod ) :
		if phase > mod : 
			return 0

		return 1

	blend = 'add'
	func = 'sine'


	def setValue ( self, path, value ) :
		if path == [ 'blend', 'value' ] and value in ( 'add', 'mult' ):
			self.blend = value

		if path == [ 'func', 'value'] and value in ( 'sine', 'halfsine', 'square', 'saw' ):
			self.func = value



mods = []

for i in range(1) :
	mods.append( Modulator () )



osc = OSC.OSCServer ( ( '10.4.1.112', 8001 ) )

def onOSC ( path, tags, args, source):
	path = path.strip('/').split('/')
	
	if path[0] == 'mod' :
		mod = mods[int(path[1])]
		mod.setValue ( path[2:], args[0] )

osc.noCallback_handler = onOSC
osc.addDefaultHandlers( )


while True :
	osc.handle_request()


