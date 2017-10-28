
Namespace ted2go


Class SpacerView Extends View
	
	
	Method New( width:Int,height:Int )
		
		Super.New()
		
		MinSize=New Vec2i( width,height )
	End
	
	Protected
	
	Method OnMeasure:Vec2i() Override
		
		Return MinSize
	End
	
End
