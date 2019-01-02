
Namespace ted2go


Class ThemesInfo
	
	Global ActiveThemePath:String
	
	Function Load( path:String )
		
		_json=JsonObject.Load( path )
		_names.Clear()
		For Local it:=Eachin _json
			_names.Add( it.Key )
		Next
	End
	
	Function IsActiveThemeDark:Bool()
		
		For Local it:=Eachin _json
			Local jobj:=_json[it.Key].ToObject()
			If jobj["path"].ToString()=ActiveThemePath
				Return jobj["dark"].ToBool()
			Endif
		Next
		
		Return False
	End
	
	Function GetCount:Int()
		
		Return _json.Count()
	End
	
	Function GetNameAt:String( index:Int )
		
		Return _names[index]
	End
	
	Function GetPathAt:String( index:Int )
		
		Return _json[_names[index]].ToObject()["path"].ToString()
	End
	
	
	Private
	
	Global _json:JsonObject
	Global _names:=New StringStack
	
End
