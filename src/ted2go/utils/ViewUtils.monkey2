
Namespace ted2go


' extenging of View allows us to use protected methods
'
Class ViewUtils Extends View Abstract
	
	Function SendMouseEvent( view:View,event:MouseEvent )
		view.OnMouseEvent( event )
	End
	
	Function SendMouseEvent( view:View,eventType:EventType )
		
		Local event:=New MouseEvent( eventType,view,App.MouseLocation,MouseButton.Left,Null,Modifier.None,1 )
		view.OnMouseEvent( event )
	End
	
End
