
Namespace mojo3d

#rem monkeydoc The Pivot class.
#end
Class Pivot Extends Entity

	#rem monkeydoc Creates a new pivot.
	#end	
	Method New( parent:Entity=Null )
		
		Super.New( parent )
		
		Visible=True
		
		AddInstance()
	End

	#rem monkeydoc Copies the pivot.
	#end
	Method Copy:Pivot( parent:Entity=Null ) Override
		
		Local copy:=OnCopy( parent )
		
		CopyTo( copy )
		
		Return copy
	End
	
	Protected

	Method New( pivot:Pivot,parent:Entity )
		
		Super.New( pivot,parent )
		
		AddInstance( pivot )
	End
	
	Method OnCopy:Pivot( parent:Entity ) Override
		
		Return New Pivot( Self,parent )
	End
	
End
