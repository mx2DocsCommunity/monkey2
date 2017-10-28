
Namespace ted2go


Class View Extension
	
	Method GetStyle:Style( styleName:String,parentStyleName:String )
		
		Local st:=Self.GetStyle( styleName )
		If Not st Then st=Self.GetStyle( parentStyleName )
		
		Return st
	End
	
End

Class TextView Extension
	
	Method MakeCentered()
	
		' scroll to view center
		Local yy:=CursorRect.Top-Scroll.y
		Local dy:=yy-Frame.Height*.5
		Scroll=Scroll+New Vec2i( 0,dy )
	End
	
	Method SelectText( anchor:Int,cursor:Int,makeCentered:Bool )
	
		SelectText( anchor,cursor )
		If makeCentered Then MakeCentered()
	End
End
