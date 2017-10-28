
Namespace ted2go


Interface ICodeFormatter

	Method FormatWord( document:CodeTextView,customCursor:Int=-1 )
	Method FormatLine( document:CodeTextView,line:Int )
	
End
#Rem

#End

'base wrapper for code formatter
Class CodeFormatterPlugin Extends PluginDependsOnFileType Implements ICodeFormatter

	Property Name:String() Override
		Return "CodeFormatterPlugin"
	End
	
	
	Protected
	
	Method New()
		AddPlugin( Self )
	End
	
End


Class FormattersManager
	
	Function Get:ICodeFormatter( fileType:String )
		Local plugins:=Plugin.PluginsOfType<CodeFormatterPlugin>()
		For Local p:=Eachin plugins
			If p.CheckFileTypeSuitability( fileType ) Then Return p
		Next
		Return _empty
	End

	
	Private
	
	Global _empty:=New EmptyFormatter
	
End


Private


Class EmptyFormatter Implements ICodeFormatter
	
	Method FormatWord( document:CodeTextView,customCursor:Int=-1 )
		'do nothing
	End
	
	Method FormatLine( document:CodeTextView,line:Int )
		'do nothing
	End
	
End
