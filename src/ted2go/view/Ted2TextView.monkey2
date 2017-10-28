
Namespace ted2go


Class Ted2TextView Extends TextView

	Method New()

		CursorType=CursorType.Line
		CursorColor=App.Theme.GetColor( "text-default" )
		SelectionColor=App.Theme.GetColor( "text-selected" )

#If __TARGET__<>"raspbian"
		CursorBlinkRate=2.5	'crashing on Pi?
#Endif

	End

	Protected
	
	Method OnKeyEvent( event:KeyEvent ) Override
	
		TextViewKeyEventFilter.FilterKeyEvent( event,Self )
		
		If Not event.Eaten Super.OnKeyEvent( event )
	End

End
