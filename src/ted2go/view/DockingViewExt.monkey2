
Namespace ted2go


Class DockingViewExt Extends DockingView
	
	Field Rendered:Void( canvas:Canvas )
	
	Protected
	
	Method OnRender( canvas:Canvas ) Override
		
		Super.OnRender( canvas )
		
		Rendered( canvas )
	End
	
End
