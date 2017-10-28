
Namespace ted2go


Class CodeParserPlugin Extends PluginDependsOnFileType Implements ICodeParser

	Property Name:String() Override
		Return "CodeParserPlugin"
	End
	
	Property Items:Stack<CodeItem>()
		Return _items
	End
	
	Property ItemsMap:StringMap<Stack<CodeItem>>()
		Return _itemsMap
	End
	
	Property UsingsMap:StringMap<UsingInfo>()
		Return _usingsMap
	End
	
	Property ExtraItemsMap:StringMap<Stack<CodeItem>>()
		Return _extraItemsMap
	End
	
	Method CheckStartsWith:Bool( ident1:String,ident2:String ) Virtual
	
		ident1=ident1.ToLower()
		ident2=ident2.ToLower()
		
		Return ident1.StartsWith( ident2 )
	End
	
	Method SetEnabled( enabled:Bool )
		
		_enabled=enabled
	End
	
	Operator []:CodeItem( ident:String )
		
		For Local i:=Eachin _items
			If i.Ident=ident Return i
		Next
		Return Null
	End
	
	Protected
	
	Field _enabled:=True
	
	Method New()
		AddPlugin( Self )
	End
	
	
	Private
	
	Field _items:=New Stack<CodeItem>
	Field _itemsMap:=New StringMap<Stack<CodeItem>>
	Field _usingsMap:=New StringMap<UsingInfo>
	Field _extraItemsMap:=New StringMap<Stack<CodeItem>>
	
End
