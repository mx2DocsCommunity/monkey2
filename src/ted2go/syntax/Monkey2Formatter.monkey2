
Namespace ted2go


Class Monkey2CodeFormatter Extends CodeFormatterPlugin
	
	Property Name:String() Override
		Return "Monkey2CodeFormatter"
	End
	
	
	Private
	
	Global _instance:=New Monkey2CodeFormatter
	
	Method New()
		Super.New()
		_types=New String[](".monkey2")
	End
	
	Method FormatWord( view:CodeTextView,customCursor:Int=-1 )
		
		Local doc:=view.Document
		Local cursor:=(customCursor<>-1) ? customCursor Else view.Cursor
		
		'ignore comments...
		'
		Local state:=doc.LineState( doc.FindLine( cursor ) )
		If state & 255 <> 255 Return
		
		Local text:=doc.Text
		Local start:=cursor
		Local term:=text.Length
		
		'find start of ident
		'
		While start And IsIdent( text[start-1] )
			start-=1
		Wend
		While start<cursor And IsDigit( text[start] )
			start+=1
		Wend
		If start>=term Or Not IsIdent( text[start] ) Return
		
		'only capitalize keywords and idents
		'
		Local color:=doc.Colors[start]
		If color<>Highlighter.COLOR_KEYWORD And color<>Highlighter.COLOR_IDENT
			'
			If color<>Highlighter.COLOR_PREPROC Return
			'
			'only do first ident on preproc line
			'
			Local i:=start
			While i And text[i-1]<=32
				i-=1
			Wend
			If Not i Or text[i-1]<>Chars.GRID Return
			i-=1
			While i And text[i-1]<>10
				i-=1
				If text[i]>32 Return
			Wend
			'
		Endif
		
		'find end of ident
		Local ends:=start
		'
		While ends<term And IsIdent( text[ends] ) And text[ends]<>10
			ends+=1
		Wend
		If ends=start Return
		
		Local ident:=text.Slice( start,ends )
		
		Local kw:=view.Keywords.Get( ident )
		
		If Not kw Or kw=ident Return
		
		doc.ReplaceText( start,ends,kw )
	End
	
	Method FormatLine( view:CodeTextView,line:Int )
		
		Local doc:=view.Document
		
		'ignore comments...
		'
		Local state:=doc.LineState( line )
		If state & 255 <> 255 Return
		
		Local text:=doc.Text
		Local i:=doc.StartOfLine( line )
		Local term:=doc.EndOfLine( line )+1 ' grab \n char too
		
		Local identStart:=-1
		
		While i<term
			
			Local isIdent:=IsIdent( text[i] ) And doc.Colors[i]=Highlighter.COLOR_KEYWORD
			Local isLastPart:=(i=term-1)
			If isIdent
				If identStart=-1 Then identStart=i
			Endif
			If (Not isIdent Or isLastPart) And identStart<>-1 ' end of ident
				Local ident:=text.Slice( identStart,i )
				Local kw:=view.Keywords.Get( ident )
				If kw And kw<>ident
					doc.ReplaceText( identStart,i,kw )
				Endif
				identStart=-1
			Endif
			i+=1
		Wend
		
	End
	
End
