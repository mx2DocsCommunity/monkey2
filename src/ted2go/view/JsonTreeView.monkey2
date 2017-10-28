
Namespace ted2go


Class JsonTreeView Extends TreeView

	Class Node Extends TreeView.Node
	
		Method New( jval:JsonValue,parent:TreeView.Node,prefix:String="" )
			Super.New( "",parent )
		
			If Not jval
				Text=prefix+"null"
				Return
			Endif
		
			Local jobj:=Cast<JsonObject>( jval )
			If jobj
				Local obj:=jval.ToObject()
				Text=prefix+"{"+obj.Count()+"}"
				For Local it:=Eachin obj
					New Node( it.Value,Self,it.Key+":" )
				Next
				Return
			Endif
			
			Local jarr:=Cast<JsonArray>( jval )
			If jarr
				Local arr:=jarr.ToArray()
				Text=prefix+"["+arr.Length+"]"
				For Local i:=0 Until arr.Length
					New Node( arr[i],Self,String( i )+":" )
				Next
				Return
			Endif
			
			Local jstr:=Cast<JsonString>( jval )
			If jstr
				Text=prefix+"~q"+jstr.ToString()+"~q"
				Return
			End
			
			Local jnum:=Cast<JsonNumber>( jval )
			If jnum
				Text=prefix+String( jnum.ToNumber() )
				Return
			Endif
			
			Local jbool:=Cast<JsonBool>( jval )
			If jbool
				Text=prefix+( jbool.ToBool() ? "true" Else "false" )
				Return
			Endif
			
			Text="?????"
		End
		
	End
	
	Method New()
		RootNode.Text="[No Data]"
	End
	
	Method New( value:JsonValue )
		Self.New()
		
		Value=value
	End
	
	Property Value:JsonValue()
	
		Return _value
	
	Setter( value:JsonValue )
	
		RootNode.RemoveAllChildren()
		
		If Not value 
			RootNodeVisible=True
			RootNode.Text="[No Data]"
			Return
		End
		
		RootNodeVisible=False
		RootNode.Expanded=True
		
		New Node( value,RootNode )
	End
	
	Private
	
	Field _value:JsonValue
	
End
