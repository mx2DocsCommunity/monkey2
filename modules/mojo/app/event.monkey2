
Namespace mojo.app

#rem monkeydoc Event types.

| EventType			| Description
|:------------------|:-----------
| KeyDown			| Key down event.
| KeyRepeat			| Key repeat event.
| KeyUp				| Key up event.
| KeyChar			| Key char event.
| MouseDown			| Mouse button down event.
| MouseClick		| Mouse left click event.
| MouseRightClick	| Mouse right click event.
| MouseDoubleClick	| Mouse double left click event.
| MouseUp			| Mouse button up event.
| MouseMove			| Mouse movement event.
| MouseWheel		| Mouse wheel event.
| MouseEnter		| Mouse enter event.
| MouseLeave		| Mouse leave event.
| WindowClose		| Window close clicked event.
| WindowMoved		| Window moved event.
| WindowResized		| Window resized event.
| WindowGainedFocus	| Window gained input focus.
| WindowLostFocus	| Window lost input focus.

#end
Enum EventType

	KeyDown,
	KeyRepeat,
	KeyUp,
	KeyChar,
	
	MouseDown,
	MouseClick,
	MouseRightClick,
	MouseDoubleClick,
	MouseUp,
	MouseMove,
	MouseWheel,
	MouseEnter,
	MouseLeave,

	TouchDown,
	TouchUp,
	TouchMove,
	
	WindowClose,
	WindowMoved,
	WindowResized,
	WindowGainedFocus,
	WindowLostFocus,
	WindowMaximized,
	WindowMinimized,
	WindowRestored,
	WindowSwapped,
	WindowVSync
	
	Eaten=$40000000
End

#rem monkeydoc The Event class.
#end
Class Event Abstract

	#rem monkedoc The event type.
	#end
	Property Type:EventType()
		Return _type
	End
	
	#rem monkeydoc The event view.
	#end
	Property View:View()
		Return _view
	End
	
	#rem monkeydoc True if event has been eaten.
	
	#end
	Property Eaten:Bool()
		Return (_type & EventType.Eaten)<>Null
	End
	
	#rem monkeydoc Eats the event.
	#end
	Method Eat()
		_type|=EventType.Eaten
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Field _type:EventType

	#rem monkeydoc @hidden
	#end
	Field _view:View
	
	#rem monkeydoc @hidden
	#end
	Method New( type:EventType,view:View )
		_type=type
		_view=view
	End
End

#rem monkeydoc The KeyEvent class.
#end
Class KeyEvent Extends Event

	#rem monkeydoc Creates a new key event.
	#end
	Method New( type:EventType,view:View,key:Key,rawKey:Key,modifiers:Modifier,text:String )
		Super.New( type,view )
		_key=key
		_rawKey=rawKey
		_modifiers=modifiers
		_text=text
	End
	
	#rem monkeydoc The key involved in the event.
	#end
	Property Key:Key()
		Return _key
	End
	
	#rem monkeydoc The raw key involved in the event.
	#end
	Property RawKey:Key()
		Return _rawKey
	End
	
	#rem monkeydoc The modifiers at the time of the event.
	#end
	Property Modifiers:Modifier()
		Return _modifiers
	End
	
	#rem monkeydoc The text for [[EventType.KeyChar]] events.
	#end
	Property Text:String()
		Return _text
	End
	
	Private
	
	Field _key:Key
	Field _rawKey:Key
	Field _modifiers:Modifier
	Field _text:String
	
End

#rem monkeydoc The MouseEvent class.
#end
Class MouseEvent Extends Event

	#rem monkeydoc Creates a new mouse event.
	#end
	Method New( type:EventType,view:View,location:Vec2i,button:MouseButton,wheel:Vec2i,modifiers:Modifier,clicks:Int )
		Super.New( type,view )
		_location=location
		_button=button
		_wheel=wheel
		_modifiers=modifiers
		_clicks=clicks
	End
	
	#rem monkeydoc Mouse location in View.
	#end
	Property Location:Vec2i()
		Return _location
	End
	
	#rem monkeydoc Mouse button.
	#end
	Property Button:MouseButton()
		Return _button
	End

	#rem monkeydoc Mouse wheel deltas.
	#end	
	Property Wheel:Vec2i()
		Return _wheel
	End
	
	#rem monkeydoc Event modifiers.
	#end
	Property Modifiers:Modifier()
		Return _modifiers
	End
	
	#rem monkeydoc Number of mouse clicks.
	#end
	Property Clicks:Int()
		Return _clicks
	End
	
	#rem monkeydoc Transforms mouse event to different view.
	#end
	Method TransformToView:MouseEvent( view:View )
		If view=_view Return self
		Local location:=view.TransformPointFromView( _location,_view )
		Return New MouseEvent( _type,view,location,_button,_wheel,_modifiers,_clicks )
	End
	
	Private
	
	Field _location:Vec2i
	Field _button:MouseButton
	Field _wheel:Vec2i
	Field _modifiers:Modifier
	Field _clicks:Int
End

#rem monkeydoc The TouchEvent class.
#end
Class TouchEvent Extends Event

	#rem monkeydoc Creates a new touch event.
	#end
	Method New( type:EventType,view:View,location:Vec2i,finger:int,pressure:Float )
		Super.New( type,view )
		_location=location
		_finger=finger
		_pressure=pressure
	End
	
	#rem monkeydoc Finger location in view.
	#end
	Property Location:Vec2i()
		Return _location
	End
	
	#rem monkeydoc Finger index (0-9).
	#end
	Property Finger:Int()
		Return _finger
	End
	
	#rem monkeydoc Finger pressure (0-1).
	#end
	Property Pressure:Float()
		Return _pressure
	End
	
	#rem monkeydoc Transforms touch event to different view.
	#end
	Method TransformToView:TouchEvent( view:View )
		If view=_view return Self
		Local location:=view.TransformPointFromView( _location,_view )
		Return New TouchEvent( _type,view,location,_finger,_pressure )
	End
	
	Private
	
	Field _location:Vec2i
	Field _finger:Int
	field _pressure:Float
End

#rem monkeydoc The WindowEvent class.
#end
Class WindowEvent Extends Event

	#rem monkeydoc Creates a new window event.
	#end
	Method New( type:EventType,window:Window )
		Super.New( type,window )
		_window=window
	End

	#rem monkeydoc The window the event was sent to.
	#end
	Property Window:Window()
		Return _window
	End
	
	Private
	
	Field _window:Window
	
End
