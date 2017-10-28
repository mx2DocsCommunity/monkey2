
Namespace ted2go


Class TextFieldExt Extends TextField 'Implements IKeyView
	
	Method New()
		
		Super.New()
		CursorBlinkRate=2.5
		BlockCursor=False
	End
	
	Method New( maxLength:Int )
		
		Self.New()
		MaxLength=maxLength
	End
	
	Method New( text:String,maxLength:Int=80 )
		
		Self.New( maxLength )
		Text=text
	End
	
	Property NextView:TextFieldExt()
		
		Return _next
		
	Setter( view:TextFieldExt )
		
		_next=view
		view._prev=Self 'set prev automatically
	End
	
	Property PrevView:TextFieldExt()
		
		Return _prev
		
	Setter( view:TextFieldExt )
		
		_prev=view
		view._next=Self 'set next automatically
	End
	
	Method OnKeyEvent( event:KeyEvent ) Override
		
		If ProcessKeyEvent( event ) Return
		
		Super.OnKeyEvent( event )
	End
	
	Method MakeMeKeyView()
		
		MakeKeyView()
	End
	
	Protected
	
	Method OnMeasureContent:Vec2i() Override
		
		Local size:=Super.OnMeasureContent()
		size=size+New Vec2i( 0,2 ) ' 2px to fix underline character '_' visibility
		Return size
	End
	
	Private
	
	Field _next:TextFieldExt,_prev:TextFieldExt
	
	Method ProcessKeyEvent:Bool( event:KeyEvent )
		
		If event.Key=Key.Tab 
			Local shift:=(event.Modifiers & Modifier.Shift)
			If _next And Not shift
				If event.Type=EventType.KeyUp Then _next.MakeMeKeyView()
				Return True
			Elseif _prev And shift
				If event.Type=EventType.KeyUp Then _prev.MakeMeKeyView()
				Return True
			Endif
		Endif
		
		If event.Key=Key.Enter Or event.Key=Key.KeypadEnter
			If event.Type=EventType.KeyDown
				Entered()
			Endif
			Return True
		Endif
		
		Return False
	End
	
End


'Interface IKeyView
'	
'	Method ProcessKeyEvent:Bool( event:KeyEvent )
'	Method MakeMeKeyView()
'	Method SetNextView:IKeyView( view:IKeyView )
'	Method SetPrevView:IKeyView( view:IKeyView )
'	
'End
