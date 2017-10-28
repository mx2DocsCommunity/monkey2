
Namespace mojo.input

#rem monkeydoc Global instance of the TouchDevice class.
#end
Const Touch:=New TouchDevice

#rem monkeydoc The TouchDevice class.

To access the touch device, use the global [[Touch]] constant.

The touch device should only used after a new [[AppInstance]] is created.

#end
Class TouchDevice Extends InputDevice

	Method FingerDown:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].down
	End
	
	Method FingerPressed:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].pressed=_frame
	End
	
	Method FingerReleased:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].released=_frame
	End
	
	Method FingerPressure:Float( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].pressure
	End

	Method FingerX:Int( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location.x
	End
	
	Method FingerY:Int( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location.y
	End
	
	Method FingerLocation:Vec2i( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location
	End
	
	'***** INTERNAL *****
	
	#rem monkeydoc @hidden
	#end
	Method Init()
	End
	
	#rem monkeydoc @hidden
	#end
	Method Update()
		_frame+=1
	End
	
	#rem monkeydoc @hidden
	#end
	Method EventLocation:Vec2i( tevent:SDL_TouchFingerEvent Ptr )
	
		Local window:=App.ActiveWindow
	
		Local p:=New Vec2i( tevent->x * window.Frame.Width,tevent->y * window.Frame.Height )

		Return window.TransformPointFromView( p,Null )
	End
	
	#rem monkeydoc @hidden
	#end
	Method SendEvent( event:SDL_Event Ptr )
	
		If Not App.ActiveWindow Return

		Select event->type
			
		Case SDL_FINGERDOWN
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
'			Print "SDL_FINGERDOWN, id="+tevent->fingerId
		
			Local id:=-1
			For Local i:=0 Until 10
				If _fingers[i].down Continue
				_fingers[i].id=tevent->fingerId
				id=i
				Exit
			Next
			If id=-1 Return
			
			_fingers[id].down=True
			_fingers[id].pressed=_frame
			_fingers[id].pressure=tevent->pressure
			_fingers[id].location=EventLocation( tevent )
		
		Case SDL_FINGERUP

			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
'			Print "SDL_FINGERUP, id="+tevent->fingerId
		
			Local id:=-1
			For Local i:=0 Until 10
				If Not _fingers[i].down Or _fingers[i].id<>tevent->fingerId Continue
				id=i
				Exit
			Next
			If id=-1 Return
			
			_fingers[id].down=False
			_fingers[id].released=_frame
			_fingers[id].pressure=0
			_fingers[id].location=EventLocation( tevent )
			
		Case SDL_FINGERMOTION

			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
'			Print "SDL_FINGERMOTION, id="+tevent->fingerId
			
			Local id:=-1
			For Local i:=0 Until 10
				If Not _fingers[i].down Or _fingers[i].id<>tevent->fingerId Continue
				id=i
				Exit
			Next
			If id=-1 Return
			
			_fingers[id].pressure=tevent->pressure
			_fingers[id].location=EventLocation( tevent )
		
		End

	End
	
	Private
	
	Struct FingerState
		Field id:Long
		Field down:Bool
		Field pressed:Int
		Field released:Int
		Field pressure:Float
		Field location:Vec2i
	End

	Field _frame:Int=1	
	Field _fingers:=New FingerState[10]
	
	Method New()
	End

End
