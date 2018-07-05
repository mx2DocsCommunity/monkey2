
Namespace ted2go


Class CodeTextView Extends TextView

	Field Formatter:ICodeFormatter
	Field Keywords:IKeywords
	Field Highlighter:Highlighter
	
	Field LineNumChanged:Void( prevLine:Int,newLine:Int )
	Field TextChanged:Void()
	
	Class Folding
		Field folded:Int
		Field startLine:Int
		Field endLine:Int
		Field parent:Folding
	End
	
	Method New()
		
		Super.New()
		
		CursorBlinkRate=2.5
		BlockCursor=False
		
		CursorMoved += OnCursorMoved
		Document.TextChanged += TextChanged
		
		TabStop=Prefs.EditorTabSize
		LineSpacing=Prefs.EditorLineSpacing
		
		Document.LinesModified+=Lambda( first:Int,removed:Int,inserted:Int )
			
			Local delta:=inserted-removed
			If delta=0 Return
			
			'Local prevLine:=Document.FindLine( _storedCursor )
			
			'Print "modif line: "+first+", "+removed+", "+inserted
			
			' line with folding was removed
			'
			If removed<>0
				Local dd:=(_delKey=Key.Backspace) ? -removed Else removed
				Local i1:=Min( first,first+dd )
				Local i2:=Max( first,first+dd )
				For Local i:=i1 Until i2
					Local f:=_folding[i]
					If Not f Continue
					If f.folded<10
						_folding.Remove( i )
					Else
						f.folded-=10
						f.endLine+=1
						UpdateLineWidth( i )
					Endif
				Next
			Endif
			
			
			Local flag:=False
			Local indent:=Utils.GetIndent( LineTextAtCursor )
			Local less:=(PosInLineAtCursor<=indent)
			
			For Local line:=Eachin _folding.Keys
				
				Local f:=_folding[line]
				
				' move foldings which are under changed line
				Local shiftBlock:=False
				Local expandBlock:=False
				
				If line>=first
				
					If line>first Or less ' shift down whole block
						shiftBlock=True
					Else
						expandBlock=True
					Endif
					
				Elseif first>f.startLine And first<=f.endLine ' changed line is inside of folding
					
					expandBlock=(first<f.endLine Or less) ' expand block ending
					
					If f.folded>=30
						expandBlock=False
						f.folded-=30
					Endif
					
					If f.folded>=20
						shiftBlock=True
					Endif
				Endif
				
				If shiftBlock ' shift down whole block
					
					If f.folded
						flag=True
					Endif
					f.startLine+=delta
					f.endLine+=delta
					_foldingTmpMap[line]=f
					
					If f.folded>=20
						SetLineVisible( f.startLine,True )
						f.folded-=20
					Endif
					
				Elseif expandBlock
					
					f.endLine+=delta
					
				Endif
				
			Next
			
			For Local line:=Eachin _foldingTmpMap.Keys
				Local f:=_foldingTmpMap[line]
				_folding.Remove( line )
				_folding[f.startLine]=f
			Next
			_foldingTmpMap.Clear()
			
			If flag
				OnValidateStyle()
				RequestRender()
			Endif
			
		End
		
		
		UpdateThemeColors()
	End
	
	Method DeleteLineAtCursor()
	
		Local line:=Document.FindLine( Cursor )
		Local pos:=Cursor
		SelectText( Document.StartOfLine( line ),Document.EndOfLine( line )+1 )
		ReplaceText( "" )
		pos=Min( pos,Document.EndOfLine( line ) )
		SelectText( pos,pos )
	End
	
	Method DeleteWordBackward()
	
		If CanCopy ' try to delete selected area
			ReplaceText( "" )
			Return
		Endif
	
		Local line:=Document.FindLine( Cursor )
		Local found:Word=Null
		For Local word:=Eachin WordIterator.ForLine( Self,line )
			If Cursor>word.index And Cursor<=word.index+word.length
				found=word
				Exit
			Endif
		Next
		If found
			SelectText( found.index,Cursor )
			ReplaceText( "" )
		Endif
	End
	
	Method DeleteWordForward()
	
		If CanCopy ' try to delete selected area
			ReplaceText( "" )
			Return
		Endif
	
		Local line:=Document.FindLine( Cursor )
		Local found:Word=Null
		For Local word:=Eachin WordIterator.ForLine( Self,line )
			If Cursor>=word.index And Cursor<word.index+word.length
				found=word
				Exit
			Endif
		Next
		If found
			SelectText( Cursor,found.index+found.length )
			ReplaceText( "" )
		Endif
	End
	
	Method DeleteToEnd()
	
		Local i1:=Min( Anchor,Cursor )
		Local i2:=Max( Anchor,Cursor )
	
		SelectText( i1,Document.EndOfLine( Document.FindLine( i2 ) ) )
		ReplaceText( "" )
	End
	
	Method DeleteToBegin()
	
		Local i1:=Min( Anchor,Cursor )
		Local i2:=Max( Anchor,Cursor )
	
		SelectText( Document.StartOfLine( Document.FindLine( i1 ) ),i2 )
		ReplaceText( "" )
	End
	
	Method LowercaseSelection()
	
		Local txt:=SelectedText
		If txt
			Local a:=Anchor,c:=Cursor
			ReplaceText( txt.ToLower() )
			SelectText( a,c )
		Endif
	End
	
	Method UppercaseSelection()
	
		Local txt:=SelectedText
		If txt
			Local a:=Anchor,c:=Cursor
			ReplaceText( txt.ToUpper() )
			SelectText( a,c )
		Endif
	End
	
	Method SwapCaseSelection()
	
		Local txt:=SelectedText
		If txt
			Local a:=Anchor,c:=Cursor
			ReplaceText( SwapCase( txt ) )
			SelectText( a,c )
		Endif
	End
	
	Property SelectedText:String()
		
		If Not CanCopy Return ""
		
		Local i1:=Min( Anchor,Cursor )
		Local i2:=Max( Anchor,Cursor )
		
		Return Text.Slice( i1,i2 )
	End
	
	Property IsCursorAtTheEndOfLine:Bool()
		
		Local line:=Document.FindLine( Cursor )
		Local pos:=Document.EndOfLine( line )
		Return pos=Cursor
	End
	
	Method IdentAtCursor:String()
		
		Local text:=Text
		Local start:=Cursor
		
		While start And Not IsIdent( text[start] ) And text[start-1]<>10
			start-=1
		Wend
		While start And IsIdent( text[start-1] ) And text[start-1]<>10
			start-=1
		Wend
		While start<text.Length And IsDigit( text[start] ) And text[start]<>10
			start+=1
		Wend
		
		Local ends:=start
		
		While ends<text.Length And IsIdent( text[ends] ) And text[ends]<>10
			ends+=1
		Wend
		
		Return text.Slice( start,ends )
	End
	
	Method IdentBeforeCursor:String( withDots:Bool=True )
		
		Local info:=GetIndentBeforePos_Mx2( LineTextAtCursor,PosInLineAtCursor,withDots )
		Return info.ident
	End
	
	Property WordAtCursor:String()
		
		Local text:=Text
		Local cur:=Cursor
		Local n:=Cursor-1
		Local line:=Document.FindLine( Cursor )
		Local start:=Document.StartOfLine( line )
		Local ends:=Document.EndOfLine( line )
		
		While n >= start
			If Not IsIdent( text[n] ) Exit
			n-=1
		Wend
		Local p1:=n+1
		n=cur
		While n < ends And IsIdent( text[n] )
			n+=1
		Wend
		Local p2:=n
		Local ident:=(p1 < cur Or p2 > cur) ? text.Slice( p1,p2 ) Else ""
		
		Return ident
	End
		
	Property FullIdentAtCursor:String()
		
		Local text:=Text
		Local cur:=Cursor
		Local n:=Cursor-1
		Local line:=Document.FindLine( Cursor )
		Local start:=Document.StartOfLine( line )
		Local ends:=Document.EndOfLine( line )
		
		While n >= start
			
			If text[n] = Chars.DOT 'dot
				
			ElseIf Not (IsIdent( text[n] ) Or text[n] = Chars.GRID) '#
				Exit
			Endif
			
			n-=1
		Wend
		Local p1:=n+1
		n=cur
		While n < ends And IsIdent( text[n] )
			n+=1
		Wend
		Local p2:=n
		Local ident:=(p1 < cur Or p2 > cur) ? text.Slice( p1,p2 ) Else ""
		
		Return ident
	End
	
	Method FirstSelectedLine:Int()
		
		Local min:=Min( Anchor,Cursor )
		Return Document.FindLine( min )
	End
	
	Method LastSelectedLine:Int()
	
		Local max:=Max( Anchor,Cursor )
		Return Document.FindLine( max )
	End
	
	Method FirstIdentInLine:String( cursor:Int )
	
		Local line:=Document.FindLine( cursor )
		Local text:=Document.GetLine( line )
		Local n:=0
		'skip empty chars
		While n < text.Length And text[n] <= 32
			n+=1
		Wend
		Local indent:=n
		While n < text.Length And (IsIdent( text[n] ) Or text[n] = 35)
			n+=1
		Wend
		Return (n > indent ? text.Slice( indent,n ) Else "")
	End
	
	Method GetIndent:Int( text:String )
	
		Local n:=0
		While n < text.Length And text[n] <= 32
			n+=1
		Wend
		Return n
	End

	Method GotoPosition( pos:Vec2i,lenToSelect:Int=0 )
	
		'If pos.y = 0
		'	GotoLine( pos.x )
		'Else
			Local dest:=Document.StartOfLine( pos.x )+pos.y
			SelectText( dest,dest+lenToSelect )
		'Endif
		
		MakeCentered()
	End
	
	Property LineTextAtCursor:String()
		Return Document.GetLine( Document.FindLine( Cursor ) )
	End
	Property LineTextAtAnchor:String()
		Return Document.GetLine( Document.FindLine( Anchor ) )
	End
	
	Property LineNumAtCursor:Int()
		Return Document.FindLine( Cursor )
	End
	
	Property LineNumAtAnchor:Int()
		Return Document.FindLine( Anchor )
	End
	
	Property PosInLineAtCursor:Int()
		Return Cursor-Document.StartOfLine( LineNumAtCursor )
	End
	
	Property PosInLineAtAnchor:Int()
		Return Anchor-Document.StartOfLine( LineNumAtAnchor )
	End
	
	Property StartOfLineAtCursor:Int()
		Return Document.StartOfLine( LineNumAtCursor )
	End
	
	Property CursorPos:Vec2i()
		Return New Vec2i( LineNumAtCursor,PosInLineAtCursor )
	End
	
	Property AnchorPos:Vec2i()
		Return New Vec2i( LineNumAtAnchor,PosInLineAtAnchor )
	End
	
	Property ShowWhiteSpaces:Bool()
	
		Return _showWhiteSpaces
	
	Setter( value:Bool )
	
		_showWhiteSpaces=value
	End
	
	Property OverwriteMode:Bool()
	
		Return _overwriteMode
	
	Setter( value:Bool )
	
		_overwriteMode=value
		
		BlockCursor=_overwriteMode
	End
	
	Method MarkSelectionAsExtraSelection()
		
		_extraSelStart=Anchor
		_extraSelEnd=Cursor
		RequestRender()
	End
	
	Method ResetExtraSelection()
		
		_extraSelStart=-1
		_extraSelEnd=-1
		RequestRender()
	End
	
	Property ExtraSelectionStart:Int()
		Return _extraSelStart
	Setter( value:Int )
		_extraSelStart=value
		RequestRender()
	End
	
	Property ExtraSelectionEnd:Int()
		Return _extraSelEnd
	Setter( value:Int )
		_extraSelEnd=value
		RequestRender()
	End
	
	Property HasExtraSelection:Bool()
		Return _extraSelStart>=0
	End
	
	Method SetTextSilent( text:String )
		
		Local curLine:=LineNumAtCursor
		Local ancLine:=LineNumAtAnchor
		Local curPos:=PosInLineAtCursor
		Local ancPos:=PosInLineAtAnchor
		Local scroll:=Scroll
		
		Text=text
		
		SelectText( Document.StartOfLine( ancLine )+ancPos,Document.StartOfLine( curLine )+curPos )
		Scroll=scroll
		
	End
	
	Method ResetFolding()
		
		_folding.Clear()
	End
	
	Method MarkAsFoldable( line:Int,endLine:Int,parent:Folding )
		
		' try to fix folding bounds - we get incorrect endLine from mx2cc
		While endLine>line
			' searching for End keyword with the same indentation as [line]
			Local ok:=Document.GetLine( endLine ).Trim().ToLower().StartsWith( "end" )
			If ok
				ok = ok And Utils.GetIndent( Document.GetLine( line ) )=Utils.GetIndent( Document.GetLine( endLine ) )
			Endif
			If ok
				' parser based on colors, OMG :)
				Local color:=Document.Colors[Document.StartOfLine( endLine )]
				ok = ok And Not (color=Highlighter.COLOR_COMMENT Or color=Highlighter.COLOR_STRING)
			Endif
			If ok
				Exit
			Endif
			endLine-=1
		Wend
		
		Local folding:Folding
		If Not _folding.Contains( line )
			
			If endLine>line
				folding=New Folding
				folding.startLine=line
				_folding[line]=folding
			Endif
			
		Else
			folding=_folding[line]
		Endif
		
		If folding
			folding.endLine=endLine
			folding.parent=parent
		Endif
	End
	
	Method SwitchFolding( line:Int,gotoLine:Bool=False )
		
		If Not _folding.Contains( line ) Return
		
		If gotoLine
			GotoLine( line )
		Endif
		
		If _folding[line].folded
			UnfoldBlock( line )
		Else
			FoldBlock( line )
		Endif
	End
	
	Method FoldBlock( startLine:Int,updateLines:Bool=True,findBlock:Bool=False )
		
		If findBlock
			Local f:=FindNearestFolding( startLine )
			If Not f Return
			startLine=f.startLine
		Endif
		
		If Not _folding.Contains( startLine ) Return
		Local f:=_folding[startLine]
		If f.folded Return
		
		f.folded=True
		Local endLine:=f.endLine
		Local curLine:=LineNumAtCursor
		Local moveCursor:=False
		
		For Local line:=startLine+1 To endLine
			SetLineVisible( line,False )
			If line=curLine Then moveCursor=True
		Next
		
		If moveCursor
			Local pos:=Document.StartOfLine( startLine )
			SelectText( pos,pos )
		Endif
		
		If updateLines
			OnValidateStyle()
			RequestRender()
		Endif
	End
	
	Method UnfoldBlock( startLine:Int,updateLines:Bool=True,findBlock:Bool=False,unfoldChildren:Bool=False )
		
		If findBlock
			Local f:=FindNearestFolding( startLine )
			If Not f Return
			startLine=f.startLine
		Endif
		
		If Not _folding.Contains( startLine ) Return
		If Not _folding[startLine].folded Return
		
		_folding[startLine].folded=False
		Local endLine:=_folding[startLine].endLine
		
		For Local line:=startLine+1 To endLine
			
			SetLineVisible( line,True )
			Local folding:=_folding[line]
			If folding And folding.folded
				line=folding.endLine
			Endif
		Next
		
		If updateLines
			OnValidateStyle()
			RequestRender()
		Endif
	End
	
	Method FindNearestFolding:Folding( line:Int )
		
		Local maxLine:=-1
		Local found:Folding
		For Local i:=Eachin _folding.Keys
			If maxLine<>-1 And i>maxLine Exit
			Local f:=_folding[i]
			If line>=f.startLine And line<=f.endLine
				found=f
				maxLine=f.endLine
			Endif
			
		Next
	
		Return found
	End
	
	Method UnfoldAtLine( line:Int )
		
		' find folding block at line
		Local found:=FindNearestFolding( line )
		
		If Not found Return
		
		' unfold nearest block
		UnfoldBlock( found.startLine,False )
		Local par:=found.parent
		While par
			' and all its parents
			UnfoldBlock( par.startLine,False )
			par=par.parent
		Wend
		
		OnValidateStyle()
		RequestRender()
		
	End
	
	Method GetFolding:Folding( line:Int )
	
		Return _folding.Contains( line ) ? _folding[line] Else Null
	End
	
	Method FoldAll()
	
		For Local line:=Eachin _folding.Keys
			FoldBlock( line,False )
		Next
		
		OnValidateStyle()
		RequestRender()
	End
	
	Method UnfoldAll()
	
		For Local line:=Eachin _folding.Keys
			UnfoldBlock( line,False )
		Next
		
		OnValidateStyle()
		RequestRender()
	End
	
	
	Protected
	
	Field _folding:=New IntMap<Folding>
	Field _delKey:Key
	
	Method CheckFormat( event:KeyEvent )
		
		Select event.Type
		
			Case EventType.KeyChar
				
				If IsIdent( event.Text[0] )
					_typing=True
				Else
					If _typing Then FormatWord()
				Endif
				
			Case EventType.KeyDown
				
				local key:=FixNumpadKeys( event )
				Select key
					
					Case Key.Tab
						If _typing Then FormatWord() ' like for Key.Space
					
					Case Key.Backspace,Key.KeyDelete,Key.Enter,Key.KeypadEnter
						_typing=True
					
				End
				
		End
	End
	
	Method OnContentMouseEvent( event:MouseEvent ) Override
		
		Select event.Type
			
			Case EventType.MouseWheel 'little faster scroll
		
				Scroll-=New Vec2i( 0,RenderStyle.Font.Height*event.Wheel.Y*3 )
				Return
			
			Case EventType.MouseDown 'prevent selection by dragging with right-button
				
				If event.Button = MouseButton.Right
					If Not CanCopy
						Local cur:=CharAtPoint( event.Location )
						SelectText( cur,cur )
					Else
						Local i1:=Min( Cursor,Anchor )
						Local i2:=Max( Cursor,Anchor )
						Local l1:=Document.FindLine( i1 )
						Local l2:=Document.FindLine( i2 )
						Local r:Recti=Null
						For Local line:=l1 To l2
							If r=Null
								r=LineRect( line )
							Else
								r|=LineRect( line )
							Endif
						Next
						If Not r.Contains( event.Location )
							Local cur:=CharAtPoint( event.Location )
							SelectText( cur,cur )
						Endif
					Endif
					Return
				Endif
				
			Case EventType.MouseUp
				
				If event.Button = MouseButton.Right
					
					MainWindow.ShowEditorMenu( Self )
					Return
				Endif
			
			Case EventType.MouseEnter
				
				Mouse.Cursor=MouseCursor.IBeam
				
			Case EventType.MouseLeave
				
				Mouse.Cursor=MouseCursor.Arrow
				
		End
		
		' correct click position for beam cursor
		event=event.Copy( event.Location+New Vec2i( 6,3 ) ) 'magic offset
		
		Super.OnContentMouseEvent( event )
		
	End
	
	Method OnKeyEvent(event:KeyEvent) Override
	
		Select event.Type
			
			Case EventType.KeyChar
				
				' select next char in overwrite mode
				If Cursor=Anchor And _overwriteMode
				
					' don't select new-line-char ~n
					If Cursor < Text.Length And Text[Cursor]<>10
						SelectText( Cursor,Cursor+1 )
					Endif
				Endif
			
		End
		
		Super.OnKeyEvent( event )
		
	End
	
	Property Line:Int()
		Return _line
	End
	
	Method OnCut( wholeLine:Bool=False )
	
		If wholeLine
			Local line:=Document.FindLine( Cursor )
			SelectText( Document.StartOfLine( line ),Document.EndOfLine( line )+1 )
		Else
			SelectText( Cursor,Anchor )
		Endif
		SmartCopySelected()
		ReplaceText( "" )
	End
	
	Method OnCopy( wholeLine:Bool=False )
	
		If wholeLine
			Local line:=Document.FindLine( Cursor )
			SelectText( Document.StartOfLine( line ),Document.EndOfLine( line ) )
		Else
			SelectText( Cursor,Anchor )
		Endif
		SmartCopySelected()
	
		SelectText( Cursor,Anchor )
	End
	
	Method GetPosInLineAtCursorCheckingTabSize:Int()
	
		Return TextUtils.GetPosInLineCheckingTabSize( LineTextAtCursor,PosInLineAtCursor,TabStop )
	End
	
	Method InsertTabulation()
		
		Local useSpaces:=Prefs.EditorUseSpacesAsTabs
		Local tabSize:=Prefs.EditorTabSize
		
		If useSpaces ' use spaces
			
			Local pos:=GetPosInLineAtCursorCheckingTabSize()
			Local chars:=(pos Mod tabSize)
			ReplaceText( " ".Dup( tabSize-chars ) )
			
		Else ' use tabs
			
			ReplaceText( "~t" )
			
		Endif
		
	End
	
	Method SmartCopySelected()
	
		' here we strip indents from all lines - the same as in first-line indent
		Local min:=Min( Cursor,Anchor )
		Local max:=Max( Cursor,Anchor )
		Local line:=Document.FindLine( min )
		Local line2:=Document.FindLine( max )
	
		If line = line2 'nothing to strip
			Copy()
			Return
		Endif
	
		Local txt:=Document.GetLine( line )
		Local indent:=GetIndent( txt )
		Local posInLine:=min-Document.StartOfLine( line )
		indent=Min( indent,posInLine )
	
		If indent = 0 'nothing to strip
			Copy()
			Return
		Endif
	
		Local selText:=Document.Text.Slice( min,max )
		Local lines:=selText.Split( "~n" )
	
		Local indent2:=indent
	
		' get min indent, except of first
		For Local i:=1 Until lines.Length
			Local s:=lines[i]
			If Not s.Trim() Continue 'skip empty lines
			indent2=Min( indent2,GetIndent(s) )
		Next
	
		If indent2 = 0 'nothing to strip
			Copy()
			Return
		Endif
	
		Local result:=txt.Slice( posInLine )
		' strip
		For Local i:=1 Until lines.Length
			Local s:=lines[i]
			If result Then result+="~n"
			result+=s.Slice( indent2 )
		Next
	
		App.ClipboardText=result
	End
	
	Method SmartHome( shift:Bool )
	
		Local line:=Document.FindLine( Cursor )
		Local txt:=Document.GetLine( line )
		Local n:=0
		Local n2:=txt.Length
		'check for whitespaces before cursor
		While (n < n2 And IsSpace( txt[n]) )
			n+=1
		Wend
		Local posStart:=Document.StartOfLine( line )
		n+=posStart
		Local newPos:=0
		If n >= Cursor And Cursor > posStart
			newPos=posStart
		Else
			newPos=n
		Endif
	
		If shift 'selection
			SelectText( Anchor,newPos )
		Else
			SelectText( newPos,newPos )
		Endif
	End
	
	Method SmartEnd( shift:Bool )
	
		Local line:=Document.FindLine( Cursor )
		Local newPos:=Document.EndOfLine( line )
	
		If shift 'selection
			SelectText( Anchor,newPos )
		Else
			SelectText( newPos,newPos )
		Endif
	End
	
	Method SmartPaste( customText:String=Null )
	
		Local txt:= customText ? customText Else App.ClipboardText
	
		ReplaceText( PrepareSmartPaste( txt ) )
		
	End
	
	Method PrepareSmartPaste:String( txt:String )
	
		' get indent of cursor's line
		Local cur:=Min( Cursor,Anchor )
		Local line:=Document.FindLine( cur )
		Local indent:=GetIndent( Document.GetLine( line ) )
		Local posInLine:=cur-Document.StartOfLine( line )
		indent=Min( indent,posInLine )
	
		txt=txt.Replace( "~r~n","~n" )
		txt=txt.Replace( "~r","~n" )
		Local lines:=txt.Split( "~n" )
		
		' add indent at cursor
		If indent
			Local add:=Utils.RepeatStr( "~t",indent )
			For Local i:=1 Until lines.Length
				lines[i]=add+lines[i]
			Next
		Endif
	
		' result text
		Local result:=""
		For Local i:=0 Until lines.Length
			If i>0 Then result+="~n"
			result+=lines[i]
		Next
		
		Return result
	End
	
	Method OnThemeChanged() Override
		
		Super.OnThemeChanged()
		
		UpdateThemeColors()
	End
	
	Method UpdateThemeColors() Virtual
		
		_whitespacesColor=App.Theme.GetColor( "textview-whitespaces" )
		_extraSelColor=App.Theme.GetColor( "textview-extra-selection" )
		_commentsColor=App.Theme.GetColor( "textview-color"+Highlighter.COLOR_COMMENT )
	End
	
	Method OnRenderContent( canvas:Canvas,clip:Recti ) Override
		
		' extra selection
		If _extraSelStart<>-1
			Local min:=CharRect( Min( _extraSelStart,_extraSelEnd ) )
			Local max:=CharRect( Max( _extraSelStart,_extraSelEnd ) )
			
			canvas.Color=_extraSelColor
			
			If min.Y=max.Y
				canvas.DrawRect( min.Left,min.Top,max.Left-min.Left,min.Height )
			Else
				canvas.DrawRect( min.Left,min.Top,(clip.Right-min.Left),min.Height )
				canvas.DrawRect( 0,min.Bottom,clip.Right,max.Top-min.Bottom )
				canvas.DrawRect( 0,max.Top,max.Left,max.Height )
			Endif
		Endif
		
		Super.OnRenderContent( canvas,clip )
	End
	
	Property TabStr:String()
		
		Return Prefs.EditorUseSpacesAsTabs ? TextUtils.GetSpacesForTabEquivalent() Else "~t"
	End
	
	Method OnRenderLine( canvas:Canvas,line:Int ) Override
		
		Super.OnRenderLine( canvas,line )
		
		' show folded lines number
		'
		Local folding:=_folding[line]
		If folding And folding.folded
			Local r:=LineRect( line )
			Local tx:=r.Right+20
			Local ty:=r.Top+RenderStyle.Font.Height*.5
			Local a:=canvas.Alpha
			canvas.Alpha=0.75
			canvas.Color=_commentsColor
			canvas.DrawText( "..."+(folding.endLine-folding.startLine)+" line(s)",tx,ty,0,.5 )
			canvas.Alpha=a
		Endif
		
		' draw whitespaces
		'
		If Not _showWhiteSpaces Return
	
		Local text:=Document.Text
		Local start:=Document.StartOfLine( line )
		Local ending:=Document.EndOfLine( line )
		Local right:=0
		Local lineStr:=Document.GetLine( line )
		
		canvas.Color=_whitespacesColor
		
		For Local word:=Eachin WordIterator.ForLine( Self,line )
			
			Local atEnd:=(word.Index+word.Length=ending)
			
			If text[word.Index]=Chars.TAB Or (text[word.Index]=Chars.SPACE And (word.Length>=TabStop Or atEnd)) ' indent chars
				
				Local wordStr:=text.Slice( word.Index,word.Index+word.Length )
				wordStr=wordStr.Replace( "~t",TextUtils.GetSpacesForTabEquivalent() )
				
				Local i1:=word.Index-start
				Local i2:=i1+word.Length
				i1=TextUtils.GetPosInLineCheckingTabSize( lineStr,i1,TabStop )
				i2=TextUtils.GetPosInLineCheckingTabSize( lineStr,i2,TabStop )
				If atEnd Then i2+=1
				
				Local r:=word.Rect
				Local x0:=right,y0:=r.Top+1,y1:=y0+r.Height
				For Local i:=i1+1 Until i2
					If i Mod TabStop = 0
						Local dx:=Float(i-i1)*_charw
						canvas.DrawLine( x0+dx,y0,x0+dx,y1 )
					Endif
				Next
				
			Endif
			
			right=word.Rect.Right
			
		Next
		
	End
	
	Method OnValidateStyle() Override
		
		Super.OnValidateStyle()
		
		Local style:=RenderStyle
		_charw=style.Font.TextWidth( "X" )
		_tabw=_charw*TabStop
	End
	
	
	Private
	
	Field _line:Int
	Field _whitespacesColor:Color,_commentsColor:Color
	Field _showWhiteSpaces:Bool
	Field _tabw:Int,_charw:Int
	Field _overwriteMode:Bool
	Field _extraSelStart:Int=-1,_extraSelEnd:Int
	Field _extraSelColor:Color=Color.DarkGrey
	Field _storedCursor:Int
	Field _typing:Bool
	Field _foldingTmpMap:=New IntMap<Folding>
	
	Method OnCursorMoved()
		
		Local line:=Document.FindLine( Cursor )
		
		' if cursor is inside of invisible line - unfold area with cursor
		If Not IsLineVisible( line )
			'Print "show line: "+line
			Local c:=Cursor,a:=Anchor
			UnfoldAtLine( line )
			SelectText( a,c )
		Endif
		
		' emit line changed signal
		If line <> _line
			If _typing Then FormatLine( _line )
			
			LineNumChanged( _line,line )
			_line=line
		Endif
		
		_storedCursor=Cursor
	End
	
	Method FormatWord( customCursor:Int=-1 )
	
		_typing=False
		If Formatter
			Local cur:=(customCursor<>-1) ? customCursor Else _storedCursor
			Formatter.FormatWord( Self,cur )
		Endif
	End
	
	Method FormatLine( line:Int )
	
		_typing=False
		If Formatter
			Formatter.FormatLine( Self,line )
		Endif
	End
	
End


Class MouseEvent Extension
	
	Method Copy:MouseEvent( location:Vec2i )
		
		Return New MouseEvent( Self.Type,Self.View,location,Self.Button,Self.Wheel,Self.Modifiers,Self.Clicks )
	End
End


Function FixNumpadKeys:Key( event:KeyEvent )
	
	Local key:=event.Key
	If Not (event.Modifiers & Modifier.NumLock)
		Select key
		Case Key.Keypad1 key=Key.KeyEnd
		Case Key.Keypad2 key=Key.Down
		Case Key.Keypad3 key=Key.PageDown
		Case Key.Keypad4 key=Key.Left
		Case Key.Keypad6 key=Key.Right
		Case Key.Keypad7 key=Key.Home
		Case Key.Keypad8 key=Key.Up
		Case Key.Keypad9 key=Key.PageUp
		Case Key.Keypad0 key=Key.Insert
		End
	Endif
	Return key
End


Function RemoveWhitespacedTrailings:String( doc:TextDocument,linesChanged:Int Ptr )
	
	Local text:=doc.Text
	Local numLines:=doc.NumLines
	Local result:=""
	Local index:=0,changes:=0
	
	For Local line:=0 Until numLines
		
		Local start:=doc.StartOfLine( line )
		Local ends:=doc.EndOfLine( line )
		Local i:=ends-1
		If i<0 Continue
		
		Local color:=doc.Colors[i]
		If color=Highlighter.COLOR_STRING Or color=Highlighter.COLOR_COMMENT Continue
		
		While i>=start And text[i]<=Chars.SPACE
			i-=1
		Wend
		i+=1
		
		If i=ends Continue ' have no trailing
		If i=start Continue ' skip whole-whitespaced line
		
		If i>index 
			result+=text.Slice( index,i )
			changes+=1
		Endif
		index=ends ' skip trailing part of text
		
	Next
	
	If changes=0
		result=text
	Elseif index<text.Length-1
		result+=text.Slice( index,text.Length )
	Endif
	
	linesChanged[0]=changes
	Return result
End


Class IndentationHelper Final
	
	Enum Type
		Spaces,
		Tabs,
		Mixed,
		None
	End
		
	Function AnalyzeIndentation:Type( text:String )
		
		Local len:=text.Length
		Local start:=-1,k:=0,spacesCount:=0,tabsCount:=0
		
		Local tabAsSpacesStr:=TextUtils.GetSpacesForTabEquivalent()
		
		Local lines:=New StringStack( text.Split( "~n" ) )
		
		For Local line:=Eachin lines
			
			Local lineLen:=line.Length
			
			For Local k:=0 Until lineLen
				
				Local char:=line[k]
				Local atEnd:=(k=lineLen-1)
				
				If atEnd Then k+=1
				
				If char>Chars.SPACE Or atEnd ' end of indentation
					
					If k>0
						Local indentStr:=line.Slice( 0,k )
						
						Local spaces:=(indentStr.Find( tabAsSpacesStr )<>-1)
						Local tabs:=(indentStr.Find( "~t" )<>-1)
						
						spacesCount+=Int(spaces)
						tabsCount+=Int(tabs)
						
						If spacesCount>0 And tabsCount>0 Return Type.Mixed
						
					Endif
					
					Exit
					
				Endif
			Next
		Next
		
		If spacesCount>0
			Return Type.Spaces
		Elseif tabsCount>0
			Return Type.Tabs
		Endif
		
		Return Type.None
	End
	
	Function FixIndentation:String( document:TextDocument )
		
		Local text:=document.Text
		Local useSpaces:=Prefs.EditorUseSpacesAsTabs
		Local tabSize:=Prefs.EditorTabSize
		Local tabAsSpacesStr:=TextUtils.GetSpacesForTabEquivalent()
		Local minIndent:=useSpaces ? 1 Else 2 ' minimum 1 tab or 2 spaces
		
		' will work with single lines
		Local lines:=New StringStack( text.Split( "~n" ) )
		
		For Local lineIndex:=0 Until lines.Length
			
			Local line:=lines[lineIndex]
			
			Local lineLen:=line.Length
			If lineLen=0 Continue
			
			' trim endings of lines
			Local s:=line.TrimEnd()
			If s ' don't trim whitespaced lines
				line=s
				lines[lineIndex]=line
			Endif
			
			Local start:=document.StartOfLine( lineIndex )
			Local lineStr:="" ' our new content of line 
			Local indentStart:=-1,textStart:=0
			Local replaced:=0
			
			' processing each line
			For Local k:=0 Until lineLen
				
				Local char:=line[k]
				Local atEnd:=(k=lineLen-1)
				Local isText:=(char>Chars.SPACE)
				
				If isText Or atEnd' end of indentation
					
					Local color:=document.Colors[start+k-1]
					
					' skip comments and strings areas - checking of colors isn't good but works
					Local skip:=(color=Highlighter.COLOR_COMMENT Or color=Highlighter.COLOR_STRING)
					
					If atEnd
						If indentStart=-1 Then indentStart=k ' if there is the only tab in line
						If Not isText Then k+=1
					Endif
					
					' indentation found
					If Not skip And indentStart<>-1 And k-indentStart>=minIndent
						
						replaced+=1
						
						' if there is a part of text before indent
						If textStart<>-1
							lineStr+=line.Slice( textStart,indentStart )
							textStart=k
						Endif
						' processing indent depending on "tabs or spaces" option
						Local indentStr:=line.Slice( indentStart,k )
						
						' tabs --> spaces
						If useSpaces
							
							' the first tab can be 1 to 4 spaces
							If indentStr[0]=Chars.TAB
								Local pos:=TextUtils.GetPosInLineCheckingTabSize( line,indentStart,Prefs.EditorTabSize )
								Local chars:=(pos Mod tabSize)
								Local spaces:=" ".Dup( tabSize-chars )
								If indentStr.Length=1
									' single tab - just convert into spaces
									indentStr=spaces
								Else
									' convert first part + add (4*tabsCount) spaces
									indentStr=spaces+indentStr.Slice( 1 ).Replace( "~t",tabAsSpacesStr )
								Endif
							Else
								' starts with not a tab - don't know what to do exactly
								' so convert all tabs into spaces equivalent
								indentStr=indentStr.Replace( "~t",tabAsSpacesStr )
							Endif
							
						Else ' spaces --> tabs
							
							indentStr=indentStr.Replace( "~t",tabAsSpacesStr ) ' avoid mixing of tabs and spaces
							Local size:=indentStr.Length
							Local cnt:=size/tabSize
							Local md:=size Mod tabSize
							indentStr=""
							If md>1 ' convert 2+ spaces into tab
								cnt+=1
							Elseif md>0 ' left 1 space as is at the beginning of indent
								indentStr+=" "
							Endif
							If cnt>0 ' our tabs 'replacement'
								indentStr+="~t".Dup( cnt )
							Endif
							
						Endif
						
						lineStr+=indentStr
						
					Endif
					
					If atEnd And (isText Or skip)
						
						If replaced=0 ' if do nothing with line
							lineStr=line
						Elseif textStart<>-1 ' if there is a last part of line
							lineStr+=line.Slice( textStart,k+1 )
							textStart=0
						Endif
						
					Endif
					
					indentStart=-1
					
				Elseif indentStart=-1
					
					indentStart=k ' store the nearest like-a-space position of indent
					
				Endif
			Next
			
			lines[lineIndex]=lineStr ' apply resulting string
			
		Next
		
		Return lines.Join( "~n" )
	End
	
	
	Private
	
	Method New()
	End
	
End

Function GetCursorPos:Vec2i( tv:TextView )
	
	Local cursor:=tv.Cursor,line:=tv.Document.FindLine( cursor )
	Return New Vec2i( line+1,cursor-tv.Document.StartOfLine( line ) )
End
