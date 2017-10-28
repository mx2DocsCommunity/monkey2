
Namespace ted2

Class HelpActions

	Field onlineHelp:Action
	Field viewManuals:Action
	Field uploadModules:Action
	Field about:Action

	Method New()
	
		onlineHelp=New Action( "Online help" )
		onlineHelp.Triggered=lambda()
		
			OpenUrl( "http://monkeycoder.co.nz/modules-reference/" )
		End
		
		viewManuals=New Action( "Browse manuals" )
		viewManuals.Triggered=Lambda()
		
			OpenUrl( RealPath( "docs/index.html" ) )
		End
		
		uploadModules=New Action( "Upload module" )
		uploadModules.Triggered=Lambda()
		
			Alert( "Now taking you to the module manager page at monkeycoder.co.nz~n~nNote: You must have an account at monkeycoder.co.nz and be logged in to upload modules" )
		
			OpenUrl( RealPath( "http://monkeycoder.co.nz/module-manager/" ) )
		End

		about=New Action( "About monkey2" )
		about.Triggered=Lambda()
		
			Local htmlView:=New HtmlView
			htmlView.Go( "ABOUT.HTML" )
	
			Local dialog:=New Dialog( "About monkey2" )
			dialog.ContentView=htmlView

			dialog.MinSize=New Vec2i( 640,600 )

			dialog.AddAction( "Okay!" ).Triggered=dialog.Close
			
			dialog.Open()
		End

	End

End
