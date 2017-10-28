
Namespace ted2go


Class GlslHighlighter Extends HighlighterPlugin

	Property Name:String() Override
		Return "GlslHighlighter"
	End

		
	Private
	
	Global _instance:=New GlslHighlighter
		
	Method New()
		Super.New()
		_types=New String[]( ".glsl" )
		_hl=New Highlighter
		_hl.Painter=HL
	End
	
	Method HL:Int( text:String,colors:Byte[],sol:Int,eol:Int,state:Int )

		Local i0:=sol
		Local icolor:=0
		Local istart:=sol
		
		If state>-1 Then icolor=Highlighter.COLOR_COMMENT
		
		If _keywords = Null Then _keywords=KeywordsManager.Get( GetMainFileType() )
		
		While i0<eol
			
			Local start:=i0
			Local chr:=text[i0]
			Local chr2:=(i0+1<eol) ? text[i0+1] Else 0
			
			i0+=1
			If IsSpace( chr ) Continue
			
			If state=-1 And chr=35 And istart=sol
				icolor=Highlighter.COLOR_PREPROC
				Exit ' it take whole line
			Endif
			
			If chr="/"[0] And chr2="*"[0] ' /*  opened
				
				' colors for previous line part
				For Local i:=istart Until start
					colors[i]=icolor
				Next
				istart=start
				
				state=10 ' store multi-line comment state
				icolor=Highlighter.COLOR_COMMENT
			
			Endif
			
			If state=10 
				' */  closed
				Local pos:=text.Slice( i0-1,eol ).Find( "*/" )
				If pos<>-1
					' colors for line part until comment closed
					start+=pos+2
					For Local i:=istart Until start
						colors[i]=icolor
					Next
					istart=start
					state=-1
					i0+=pos+2
					Continue ' already set colors, go to next char
				Else
					Exit ' have no closing pair - so exit and go to the next line
				Endif
			Endif
			
			Local color:=icolor
			
			If chr="/"[0] And chr2="/"[0] ' // single-line comment
			
				i0=eol
				color=Highlighter.COLOR_COMMENT
				
			Else If chr=34 Or chr=39
			
				While i0<eol And text[i0]<>34 And text[i0]<>39
					i0+=1
				Wend
				If i0<eol i0+=1
				
				color=Highlighter.COLOR_STRING
				
			Else If IsAlpha( chr ) Or chr=95 Or state>=10
	
				While i0<eol And (IsAlpha( text[i0] ) Or IsDigit( text[i0] )  Or text[i0]=95)
					i0+=1
				Wend
				
				Local id:=text.Slice( start,i0 )
				
				color=Highlighter.COLOR_IDENT
				
				If _keywords.Contains( id ) Then color=Highlighter.COLOR_KEYWORD
				
			Else If IsDigit( chr )
			
				While i0<eol And IsDigit( text[i0] )
					i0+=1
				Wend
				
				color=Highlighter.COLOR_NUMBER
				
			Else If chr=36 And i0<eol And IsHexDigit( text[i0] )
			
				i0+=1
				While i0<eol And IsHexDigit( text[i0] )
					i0+=1
				Wend
				
				color=Highlighter.COLOR_NUMBER
				
			Else
				
				color=Highlighter.COLOR_NONE
				
			Endif
			
			If color=icolor Continue
			
			' set colors for current line part
			For Local i:=istart Until start
				colors[i]=icolor
			Next
			
			icolor=color
			istart=start
		
		Wend
		
		' set colors for the last line part
		For Local i:=istart Until eol
			colors[i]=icolor
		Next
		
		Return state
	
	End
	
End
