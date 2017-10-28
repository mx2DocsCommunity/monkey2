
Namespace ted2go


Class BuildErrorListViewItem Extends ListViewItem
	
	Field error:BuildError
	
	Method New( text:String,icon:Image )
		
		Super.New( text,icon )
	End
	
	Method New( err:BuildError )
	
		Super.New( err.msg )
		Text="~q"+err.msg.Trim()+"~q at line "+(err.line+1)+" ("+err.path+")"
		error=err
	End
	
End
