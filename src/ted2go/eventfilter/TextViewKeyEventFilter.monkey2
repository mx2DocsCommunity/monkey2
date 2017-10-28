
Namespace ted2go


'now filters depend on filetype
Class TextViewKeyEventFilter Extends PluginDependsOnFileType

	Property Name:String() Override
		Return "TextViewKeyEventFilter"
	End
		
	Function FilterKeyEvent( event:KeyEvent,textView:TextView,fileType:String=Null )
	
		'local cache
		If Not _filters Then _filters=Plugin.PluginsOfType<TextViewKeyEventFilter>()
		
		For Local filter:=Eachin _filters
		
			If event.Eaten Return
			
			If fileType = Null Or filter.CheckFileTypeSuitability(fileType)
				filter.OnFilterKeyEvent( event,textView )
			Endif
		Next
	
	End


	Protected
	
	Method New()
		AddPlugin( Self )
	End
	
	Method OnFilterKeyEvent( event:KeyEvent,textView:TextView ) Virtual

	End
	
	
	Private
	
	Global _filters:TextViewKeyEventFilter[]
	
End
