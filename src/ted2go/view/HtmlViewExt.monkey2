
Namespace ted2go


Class HtmlViewExt Extends HtmlView
	
	Field Navigated:Void( url:String )
	
	Method New()
		
		Super.New()
		
		_navOps.OnNavigate += Lambda( nav:Nav )
			
			Go( nav.url )
			Navigated( nav.url )
			
			_url=nav.url
			
			nav.state+=1
			
			UpdateCss()
			
			'navigated first time, so it's new page, don't touch the scroll
			If nav.state=1
				Return 
			Endif
			
			Scroll=nav.scroll
			
			'wait a bit for layout
			New Fiber( Lambda()
				Fiber.Sleep( 0.1 )
				Scroll=nav.scroll
			End )
			
		End
	End
	
	Method Navigate( url:String )
		
		StoreScroll()
		
		Local nav:=New Nav
		nav.url=url
		_navOps.Navigate( nav )
		
	End
	
	Method Back()
		
		StoreScroll()
		_navOps.TryBack()
	End

	Method Forward()
		
		StoreScroll()
		_navOps.TryForward()
	End
	
	Method ClearHistory()
		
		_navOps.Clear()
	End
	
	Property Url:String()
		
		Return _url
	End
	
	
	Private
	
	Field _navOps:=New NavOps<Nav>
	Field _url:String
	
	Method OnValidateStyle() Override
		
		Super.OnValidateStyle()
		
		UpdateCss()
	End
	
	Method UpdateCss()
		
		If ThemesInfo.IsActiveThemeDark()
			HtmlSource=HtmlSource.Replace( "theme.css","theme-dark.css" )
		Else
			HtmlSource=HtmlSource.Replace( "theme-dark.css","theme.css" )
		Endif
	End
	
	Method StoreScroll()
		
		If Not _navOps.Empty Return
		
		Local nav:=_navOps.Current
		If nav Then nav.scroll=Scroll
	End
	
	Class Nav ' make 'class' to use as ref in method
	
		Field url:String
		Field scroll:Vec2i
		Field state:=0 'nav counts
		
		Operator =:Bool(value:Nav)
			Return url=value.url
		End
	End
	
End
