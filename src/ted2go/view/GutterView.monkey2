
Namespace ted2go


Class GutterView Extends View

	Method New( textView:TextView )
		Style=GetStyle( "GutterView" )
	
		_textView=textView
	End
	
	Protected
	
	Method OnValidateStyle() Override
	
		Local font:=RenderStyle.Font
	
		_width=font.TextWidth( "1234567" )

		_size=New Vec2i( font.TextWidth( "12345678" ),0 )
	End
	
	Method OnMeasure:Vec2i() Override
	
		Return _size
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		canvas.Color=RenderStyle.BackgroundColor
		
		canvas.DrawRect( Rect.X,Rect.Y,Rect.Width,Rect.Height )
		
		canvas.Color=RenderStyle.TextColor
		
		Local vrect:=_textView.VisibleRect
		
		Local firstLine:=_textView.LineAtPoint( vrect.TopLeft )

		Local lastLine:=_textView.LineAtPoint( vrect.BottomLeft )+1
		
		canvas.Translate( 0,-vrect.Top )
		
		For Local i:=firstLine Until lastLine
		
			Local rect:=_textView.LineRect( i )
		
			canvas.DrawText( i+1,_width,rect.Top,1,0 )
		Next
		
	End
	
	Private
	
	Field _width:Int
	Field _size:Vec2i
	Field _textView:TextView
	
End
