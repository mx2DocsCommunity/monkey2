
Namespace ted2go


Class CodeMapView Extends View
	
	Const WIDTH:=160
	Const PAD:=3.0
	Field scale:Float=0.33
	
	Method New( sourceView:CodeTextView )
	
		Super.New()
	
		Style=GetStyle( "CodeMapView" )
		
		_codeView=sourceView
	
		OnThemeChanged()
	End
	
	
	Protected
	
	Method OnThemeChanged() Override
		
		_selColor=App.Theme.GetColor( "codemap-selection" )
		_padding=PAD*App.Theme.Scale.x
	End
	
	Method OnMeasure:Vec2i() Override
	
		Local ww:=WIDTH*App.Theme.Scale.x
		Local size:=New Vec2i( ww,VisibleHeight )
		Return size
	End
	
	Method OnMouseEvent( event:MouseEvent ) Override
		
		Local posY0:Float=event.TransformToView(Self).Location.Y
		Local posY:=Max( Float(0.0),posY0-BubbleHeight*.5 )
		
		Select event.Type
			
			Case EventType.MouseDown
				
				If posY0>ContentHeight Return 'small content height
				
				Local top:=_clickedScrollY*(scale-ScrollKoef)
				Local inside := posY0>=top And posY0<=top+BubbleHeight
				If Not inside Then ScrollTo( posY )
				
				_dragging=True
				_clickedMouseY=posY0
				_clickedScrollY=OwnerScrollY
				
			Case EventType.MouseMove
				
				If _dragging
					Local dy:=(posY0-_clickedMouseY)
					Local hh:=Min( VisibleHeight,ContentHeight )
					Local percent:=dy/(hh-BubbleHeight)
					Local dy2:=_maxOwnerScroll*percent
					Local yy:=_clickedScrollY+dy2
					OwnerScrollY=yy
				Endif
				
			Case EventType.MouseUp
				
				_dragging=False

			Case EventType.MouseWheel
				
				_codeView.Scroll=_codeView.Scroll+New Vec2i( 0, -RenderStyle.Font.Height*event.Wheel.y*12 )
				
		End
		
		event.Eat()
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		Super.OnRender( canvas )
		
		OnRenderMap( canvas )
		
		' selection overlay
		Local ww:=Rect.Width
		Local hh:Float=BubbleHeight
		
		Local yy:Float=OwnerScrollY*(scale-ScrollKoef)
		
		canvas.Color=_selColor
		canvas.DrawRect( 0,yy,ww,hh )
		
	End
	
	
	Private
	
	Field _codeView:CodeTextView
	Field _maxOwnerScroll:Float=1.0
	Field _maxSelfScroll:Float=1.0
	Field _selColor:Color
	Field _clickedMouseY:Float
	Field _clickedScrollY:Float
	Field _dragging:=False
	Field _padding:Float
	
	
	Property OwnerScrollY:Float()
	
		Return _codeView.Scroll.y
	
	Setter( value:Float )
	
		Local sc:=_codeView.Scroll
		sc.Y=Int(value)
		_codeView.Scroll=sc
	End
	
	Property ScrollKoef:Float()
	
		Local hh:=OwnerContentHeight
		_maxSelfScroll=Max( Float(0.0),hh*scale-VisibleHeight )
		_maxOwnerScroll=Max( 0.0,hh-VisibleHeight )
	
		Return _maxOwnerScroll > 0 ? _maxSelfScroll/_maxOwnerScroll Else 1.0
	End
	
	Property OwnerContentHeight:Float()
	
		Return _codeView.ContentView.Frame.Height
	End
	
	Property OwnerContentWidht:Float()
	
		Return _codeView.ContentView.Frame.Width
	End
	
	Property BubbleHeight:Float()
	
		Return VisibleHeight*scale
	End
	
	Property VisibleHeight:Float()
	
		Return _codeView.VisibleRect.Height
	End
	
	Property ContentHeight:Float()
	
		Return OwnerContentHeight*scale
	End
	
	Method ScrollTo( posY:Float )
	
		Local scrl:=_codeView.Scroll
		Local hg:=Min( VisibleHeight,ContentHeight )
		Local percent:=posY/(hg-BubbleHeight)
		Local yy:=_maxOwnerScroll*percent
		scrl.Y=yy
		_codeView.Scroll=scrl
	
	End
	
	Method OnRenderMap( canvas:Canvas )
	
		Local yy:Float=_codeView.Scroll.y
	
		canvas.PushMatrix()
	
		canvas.Translate( _padding,-yy*ScrollKoef+_padding )
		canvas.Scale( scale,scale )
		
		Local whiteSpaces:=_codeView.ShowWhiteSpaces
		
		_codeView.ShowWhiteSpaces=False
		Local top:=yy*ScrollKoef/scale
		
		Local r:=New Recti( 0,top,OwnerContentWidht,top+VisibleHeight/scale )
		CodeTextViewBridge.ProcessRender( _codeView,r,canvas )
		
		_codeView.ShowWhiteSpaces=whiteSpaces
		
		canvas.PopMatrix()
		
	End
	
End


Private

' get access to protected methods w/o inheritance

Class CodeTextViewBridge Extends CodeTextView Abstract

	Function ProcessRender( item:CodeTextView,rect:Recti,canvas:Canvas )
		
		item.OnRenderContent( canvas,rect )
	End
	
End
