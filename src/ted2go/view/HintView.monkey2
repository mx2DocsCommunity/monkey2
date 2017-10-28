
Namespace ted2go


Function ShowHint( hint:String,location:Vec2i,sender:View,durationMs:Int=3000 )

	If Not _hint Then _hint=New HintView
	
	HideHint()
	
	NeedShow( hint,location,sender,durationMs )
End

Function HideHint()

	If Not _hint Return
	_hint.Hide()
	
	If _timer
		_timer.Cancel()
		_timer=Null
	Endif
End


Private

Global _hint:HintView
Global _timer:Timer

Function NeedShow( hint:String,location:Vec2i,sender:View,duration:Float )
	
	_timer=New Timer( 1.8, Lambda()
		_hint.Show( hint,location,sender )
		_timer.Cancel()
		_timer=Null
		NeedHide( duration )
	End )
End

Function NeedHide( duration:Float )
	
	Local hertz:=1.0/(duration/1000.0)
	_timer=New Timer( hertz, Lambda()
		If _hint Then _hint.Hide()
		_timer.Cancel()
		_timer=Null
	End )
End


Class HintView Extends TextView

	Method New()
		
		Style=GetStyle( "Hint" )
		ReadOnly=True
		Visible=False
		Layout="float"
		Gravity=New Vec2f( 0,0 )
	End
	
	Method Show( text:String,location:Vec2i,sender:View )
		
		Hide()
		
		Text=text
		MainWindow.AddChildView( Self )
		Visible=True
		
		Local window:=sender.Window
		
		location=sender.TransformPointToView( location,window )
		Local dy:=New Vec2i( 0,10 )
		
		' fit into window area
		Local size:=MeasureLayoutSize()
		Local dx:=location.x+size.x-window.Bounds.Right
		If dx>0
			location=location-New Vec2i( dx,0 )
		Endif
		If location.y+size.y+dy.y>window.Bounds.Bottom
			location=location-New Vec2i( 0,size.y )
			dy=-dy
		Endif
		Offset=location+dy
		
	End
	
	Method Hide()
		
		If Not Visible Return
		
		If Parent = MainWindow
			MainWindow.RemoveChildView( Self )
		Endif
		Visible=False
	End
	
End
