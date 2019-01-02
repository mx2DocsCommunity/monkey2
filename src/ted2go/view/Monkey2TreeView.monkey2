
Namespace ted2go


Class Monkey2TreeView Extends JsonTreeView

	Method New( doc:TextDocument )
	
		_doc=doc
	
		_doc.TextChanged+=OnTextChanged

	End
	
	Private
	
	Field _doc:TextDocument
	
	Field _timer:Timer
	
	Method OnTextChanged()
	
		If _timer _timer.Cancel()
		
		_timer=New Timer( 1,Lambda()
		
			Local tmp:=MainWindow.AllocTmpPath( "_mx2cc_parse_",".monkey2" )
			
			Print "parsing:"+tmp
			
			SaveString( _doc.Text,tmp )
		
			UpdateTree( tmp )
			
			Print "finished:"+tmp
			
			DeleteFile( tmp )
			
			_timer.Cancel()
			
			_timer=Null
		
		End )
	End
	
	Method UpdateTree( path:String )
		
		Local cmd:=Monkey2Parser.GetFullParseCommand( path )
		If Not cmd Return
		
		Local str:=LoadString( "process::"+cmd )
		
		Local jobj:JsonObject,i:=str.Find( "{" )
		
		If i<>-1 jobj=JsonObject.Parse( str.Slice( i ) )
		
		Super.Value=jobj
		
	End

End
