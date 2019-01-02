
Namespace ted2go


Class CodeGutterView Extends View

	Method New( doc:CodeDocument )
		
		Style=GetStyle( "GutterView" )
	
		_doc=doc
	End
	
	Protected
	
	Method OnValidateStyle() Override
	
		Local font:=RenderStyle.Font
		Local k:=App.Theme.Scale.x
		
		_width=font.TextWidth( "1234567" )+10*k

		_size=New Vec2i( _width+8*k,0 )
	End
	
	Method OnMeasure:Vec2i() Override
	
		Return _size
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		_textView=_doc.CodeView
		
		Local cursorLine:=_textView.Document.FindLine( _textView.Cursor )
		Local anchorLine:=_textView.Document.FindLine( _textView.Anchor )
		
		canvas.Color=RenderStyle.BackgroundColor
		
		canvas.DrawRect( Rect.X,Rect.Y,Rect.Width,Rect.Height )
		
		Local textColor:=RenderStyle.TextColor
		
		Local vrect:=_textView.VisibleRect
		
		Local firstLine:=_textView.LineAtPoint( vrect.TopLeft )
		
		Local lastLine:=_textView.LineAtPoint( vrect.BottomLeft )+1
		
		canvas.Translate( 0,-vrect.Top )
		
		If _errorIcon = Null Then _errorIcon=CodeItemIcons.GetIcon( "warning" )
		
		canvas.Color=textColor
		
		Local curFolding:=FindNearestFoldingAbove( firstLine-1 )
		_folded.Clear()
		
		Local k:=App.Theme.Scale.x
		
		For Local i:=firstLine Until lastLine
			
			If Not _textView.IsLineVisible( i )
				Continue
			Endif
			
			Local rect:=_textView.LineRect( i )
			Local xx:=_width-8*k
			Local hcenter:=rect.Top+RenderStyle.Font.Height*.5
			' folding marks
			'
			Local folding:=_textView.GetFolding( i )
			If folding
				Local dx:=-2*k
				canvas.Color=textColor
				canvas.Alpha=1
				canvas.DrawLine( xx+7*k+dx,hcenter,xx+7*k+7*k+dx,hcenter ) ' horiz line
				If folding.folded
					canvas.DrawLine( xx+10*k+dx,hcenter-4*k,xx+10*k+dx,hcenter-4*k+8*k ) ' vert line to make cross
				Endif
				canvas.DrawRectWire( xx+5*k+dx,hcenter-5*k,10*k,10*k ) ' bounding rect
				If Not folding.folded
					If curFolding Then _folded.Add( curFolding )
					curFolding=folding
					Local dy:=rect.Height-RenderStyle.Font.Height
					If dy>0
						dx=8*k
						canvas.Alpha=0.5
						canvas.DrawLine( xx+dx,rect.Bottom-dy,xx+dx,rect.Bottom )
						canvas.Alpha=1
					Endif
				Endif
			Elseif curFolding
				canvas.Color=textColor
				canvas.Alpha=0.5
				Local dx:=8*k
				If i=curFolding.endLine
					If _folded.Empty
						curFolding=Null
					Else
						curFolding=_folded[0]
						_folded.Erase( 0 )
					Endif
					canvas.DrawLine( xx+dx,rect.Top,xx+dx,hcenter )
					canvas.DrawLine( xx+dx,hcenter,xx+dx+6*k,hcenter )
					If curFolding
						canvas.DrawLine( xx+8*k,hcenter,xx+8*k,rect.Bottom )
					Endif
				Else
					canvas.DrawLine( xx+dx,rect.Top,xx+dx,rect.Bottom )
				Endif
				canvas.Alpha=1
			Endif
			
			' show dots between each 10th
			'
			Local drawDot:=Prefs.EditorShowEvery10LineNumber And ((i+1) Mod 10 <> 0)
			drawDot=drawDot And Not (folding And folding.folded)
			drawDot=drawDot And i<>cursorLine And i<>anchorLine
			If drawDot
				canvas.Alpha=0.5
				canvas.DrawRect( xx-4*k,hcenter-1*k,2*k,2*k )
				canvas.Alpha=1
			Endif
			
			' show error bubble
			'
			If _doc.HasErrors And _doc.HasErrorAt( i )
				If _errorIcon <> Null
					canvas.Color=Color.White
					canvas.DrawImage( _errorIcon,xx-_errorIcon.Width,rect.Top )
					canvas.Color=textColor
				Endif
			Elseif Not drawDot
				canvas.Color=(i=cursorLine Or i=anchorLine) ? textColor*1.125 Else textColor 'make selected line number little brighter
				canvas.DrawText( i+1,xx,hcenter,1,.5 )
			Endif
			
		Next
		
		canvas.Alpha=1
		
	End
	
	Method OnMouseEvent( event:MouseEvent ) Override
		
		If event.Type=EventType.MouseUp
			
			Local pos:=event.Location-New Vec2i( 0,4*App.Theme.Scale.y )
			If pos.x<_width-6*App.Theme.Scale.x Return
			
			Local line:=_textView.LineAtPoint( pos+New Vec2i( 100,_textView.Scroll.y ) )
			
			_textView.SwitchFolding( line,True )
		End
	End
	
	
	Private
	
	Field _width:Int
	Field _size:Vec2i
	Field _textView:CodeDocumentView
	Field _doc:CodeDocument
	Field _folded:=New Stack<CodeTextView.Folding>
	
	Global _errorIcon:Image
	
	Method FindNearestFoldingAbove:CodeTextView.Folding( line:Int )
		
		For Local i:=line To 0 Step -1
			Local folding:=_textView.GetFolding( i )
			If folding
				Return folding.endLine>line ? folding Else Null
			Endif
		Next
		
		Return Null
	End
	
End


Class Canvas Extension
	
	Method DrawRectWire( x:Float,y:Float,w:Float,h:Float )
		
		Self.DrawLine( x,y,x+w,y )
		Self.DrawLine( x+w,y,x+w,y+h )
		Self.DrawLine( x+w,y+h,x,y+h )
		Self.DrawLine( x,y+h,x,y )
	End
	
End

