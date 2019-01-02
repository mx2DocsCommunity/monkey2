
Namespace ted2go

#Rem monkeydoc Capitalize of numOfChars first chars of the string.
#End
Function Capitalize:String( str:String,numOfChars:Int=1 )
	
	If numOfChars>=str.Length
		Return str.ToUpper()
	Endif
	
	Return str.Slice( 0,numOfChars ).ToUpper()+str.Slice( numOfChars )
End


Class TextUtils Final
	
	Function GetSpacesForTabEquivalent:String()
	
		If Prefs.EditorTabSize<>_storedTabSize
			_storedTabSize=Prefs.EditorTabSize
			_spacesForTab=" ".Dup( _storedTabSize )
		Endif
	
		Return _spacesForTab
	End
	
	Function GetIndentStr:String()
		
		Return Prefs.EditorUseSpacesAsTabs ? GetSpacesForTabEquivalent() Else "~t"
	End
	
	Function GetPosInLineCheckingTabSize:Int( line:String,posInLine:Int,tabSize:Int )
	
		Local pos:=0
		For Local i:=0 Until posInLine
			If line[i]=Chars.TAB
				Local offset:=(pos Mod tabSize)
				pos+=tabSize-offset
			Else
				pos+=1
			Endif
		Next
	
		Return pos
	End
	
	Function Split:String[]( text:String,splitters:Int[] )
		
		Local results:=New StringStack
		Local s:="",prev:=0
		For Local i:=0 Until text.Length
			Local chr:=text[i]
			For Local splt:=Eachin splitters
				If chr=splt
					If s<>""
						results.Add( text.Slice( prev,i ) )
					Endif
					prev=i+1
					s=""
					Exit
				Else
					s+=String.FromChar( chr )
				Endif
			Next
			If i=text.Length-1
				results.Add( text.Slice( prev,text.Length ) )
			Endif
		Next
		
		Return results.ToArray()
	End
	
	Private
	
	Global _storedTabSize:=0,_spacesForTab:String
	
	Method New()
	End
	
End


Struct Chars
	
	Const SINGLE_QUOTE:="'"[0] '39
	Const DOUBLE_QUOTE:="~q"[0] '34
	Const COMMA:=","[0] '44
	Const SEMICOLON:=";"[0]
	Const COLON:=":"[0]
	Const DOT:="."[0] '46
	Const EQUALS:="="[0] '61
	Const LESS_BRACKET:="<"[0] '60
	Const MORE_BRACKET:=">"[0] '62
	Const OPENED_SQUARE_BRACKET:="["[0] '91
	Const CLOSED_SQUARE_BRACKET:="]"[0] '93
	Const OPENED_ROUND_BRACKET:="("[0] '40
	Const CLOSED_ROUND_BRACKET:=")"[0] '41
	Const DIGIT_0:="0"[0] '48
	Const DIGIT_9:="9"[0] '57
	Const AT:="@"[0] '64
	Const GRID:="#"[0] '35
	Const TAB:="~t"[0] '9
	Const SPACE:=" "[0] '32
	Const NEW_LINE:="~n"[0] '10
	Const QUESTION:="?"[0]
	Const PLUS:="+"[0]
	Const MINUS:="-"[0]
	Const UNDERLINE:="_"[0]
End
