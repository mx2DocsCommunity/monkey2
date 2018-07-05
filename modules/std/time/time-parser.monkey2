
Namespace std.time

Using std.stringio

#rem monkeydoc The TimeParser class.

A very simple parser for use by the [[Time.Parse]] function.

#end
Class TimeParser

	Field day:Int
	Field month:Int
	Field year:Int
	Field hours:Int
	Field minutes:Int
	Field seconds:Int
	
	Method Parse:Bool( str:String )
		
		'Thu 21 Jun 2018 10:21:2
		
		_str=str
		_len=_str.Length
		_pos=0
		_err=False
		
		Bump()
		
		'Parse day...
		Local dname:=CParseString()	'ignore optional day name
		day=ParseInt()

		'Parse month...
		If _toke And IsDigit( _toke[0] )
			Self.month=ParseInt()-1
		Else
			Local mname:=ParseString()
			For Local month:=0 Until 12
				If Not mname.ToLower().StartsWith( _months[month] ) Continue
				Self.month=month
				Exit
			Next
		Endif

		'Parse year...
		Self.year=ParseInt()
		If Not Toke Return Not _err

		'Parse time...		
		Self.hours=ParseInt()
		Self.minutes=ParseInt()
		Self.seconds=ParseInt()
		
		Return Not _err
	End
	
	Private
	
	Const _months:=New String[]( "jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec" )
	
	Field _str:String
	Field _len:int
	Field _pos:Int
	Field _err:Bool
	Field _toke:String
	
	Property Toke:String()
		
		Return _toke
	End
	
	Method Bump:String()
		
		While _pos<_len
			Local chr:=_str[_pos]
			If chr>32 And chr<>58 And chr<>47 Exit	' : and / are space...
			_pos+=1
		Wend
		
		If _pos=_len 
			_toke=""
			Return ""
		Endif

		Local pos:=_pos		
		Local chr:=_str[_pos]
		_pos+=1
		
		If IsAlpha( chr )
			While _pos<_len And IsAlpha( _str[_pos] )
				_pos+=1
			Wend
		Else If IsDigit( chr )
			While _pos<_len And IsDigit( _str[_pos] )
				_pos+=1
			Wend
		Endif
		
		_toke=_str.Slice( pos,_pos )
		
		Return _toke
	End
	
	Method ParseToke( str:String )
		
		If _err Return
		
		If _toke<>str
			DebugStop()
			_err=True
			Return
		Endif
		
		Bump()
	End
	
	Method ParseString:String()
		
		If _err Return ""
		
		If Not _toke Or Not IsAlpha( _toke[0] )
			DebugStop()
			_err=True
			Return ""
		Endif
		
		Local str:=_toke
		Bump()
		Return str
	End
	
	Method CParseString:String()
		
		If _err Or Not _toke Or Not IsAlpha( _toke[0] ) Return ""
		
		Local str:=_toke
		Bump()
		Return str
	End
	
	Method ParseInt:Int()
		
		If _err Return 0
		
		If Not _toke Or Not IsDigit( _toke[0] ) 
			DebugStop()
			_err=True
			Return 0
		Endif
		
		Local val:=Int( _toke )
		Bump()
		Return val
	End

End

