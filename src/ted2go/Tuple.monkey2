
Namespace ted2go


Class Tuple Abstract

End

'---------------------------
' Tuple 2
'---------------------------

Class Tuple2<T1,T2> Extends Tuple Final
	
	Method New( item1:T1,item2:T2 )
		
		_i1=item1
		_i2=item2
	End
	
	Property Item1:T1()
		Return _i1
	End
	
	Property Item2:T2()
		Return _i2
	End
	
	Private
	
	Field _i1:T1,_i2:T2
End


'---------------------------
' Tuple 3
'---------------------------

Class Tuple3<T1,T2,T3> Extends Tuple Final
	
	Method New( item1:T1,item2:T2,item3:T3 )
		
		_i1=item1
		_i2=item2
		_i3=item3
	End
	
	Property Item1:T1()
		Return _i1
	End
	
	Property Item2:T2()
		Return _i2
	End
	
	Property Item3:T3()
		Return _i3
	End
	
	Private
	
	Field _i1:T1,_i2:T2,_i3:T3
End


'---------------------------
' Tuple 4
'---------------------------

Class Tuple4<T1,T2,T3,T4> Extends Tuple Final
	
	Method New( item1:T1,item2:T2,item3:T3,item4:T4 )
		
		_i1=item1
		_i2=item2
		_i3=item3
		_i4=item4
	End
	
	Property Item1:T1()
		Return _i1
	End
	
	Property Item2:T2()
		Return _i2
	End
	
	Property Item3:T3()
		Return _i3
	End
	
	Property Item4:T4()
		Return _i4
	End
	
	Private
	
	Field _i1:T1,_i2:T2,_i3:T3,_i4:T4
End
