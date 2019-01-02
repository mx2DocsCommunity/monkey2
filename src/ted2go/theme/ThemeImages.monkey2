
Namespace ted2go


Class ThemeImages Extends Plugin

	Property Name:String() Override
		Return "ThemeImages Plugin"
	End
	
	Function Get:Image( key:String )
		
		If Not _images.Contains(key)
			Local img:=Image.Load( "theme::"+key )
			If img Then img.Scale=App.Theme.Scale
			_images[key]=img
			Return img
		Endif
		Return _images[key]
	End
	
	
	Private
	
	Global _images:=New StringMap<Image>
	Global _inst:=New ThemeImages
	
	Method New()
	End
	
	Method OnCreate() Override
		
		App.ThemeChanged+=Lambda()
			AdjustImagesScale()
		End
	End
	
	Function AdjustImagesScale()
	
		For Local key:=Eachin _images.Keys
			Local img:=_images[key]
			If img<>Null
				img.Scale=App.Theme.Scale
			Else
				Print "ThemeImages.AdjustImagesScale: image is null: "+key
			Endif
		Next
	End
	
End
