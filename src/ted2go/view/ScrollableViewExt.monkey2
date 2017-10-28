
Namespace ted2go


' Make mouse wheel's scrolling little faster

Class ScrollableViewExt Extends ScrollableView
	
	
	Protected
	
	Method OnMouseEvent( event:MouseEvent ) Override
	
		Select event.Type
	
			Case EventType.MouseWheel
	
				Scroll=Scroll+New Vec2i( 0, -RenderStyle.Font.Height*event.Wheel.y*3 )
	
			Default
				
				Super.OnMouseEvent( event )
		End
	End
End
