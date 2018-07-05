
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojox>"
#Import "<httprequest>"

Using std..
Using mojo..
Using mojox..
Using httprequest..

Class MyWindow Extends Window
	
	Method New( title:String="HttpRequest demo",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )

		Layout="letterbox"		
		
		Local label:=New Label
		
		Local req:=New HttpRequest
		
		req.Timeout=10

		req.ReadyStateChanged=Lambda()
		
			label.Text="Ready state changed to "+Int( req.ReadyState )+" status="+req.Status
			
			If req.ReadyState=ReadyState.Done Print "Request response:~n"+req.ResponseText
		End
		
	#If __TARGET__="emscripten"
		Const url:="test.txt"
	#else
		Const url:="https://www.github.com"
	#endif
		
		req.Open( "GET",url )
		
		Local button:=New Button( "CANCEL!" )
		
		button.Clicked+=Lambda()
		
			req.Cancel()
		End
		
		Local dockingView:=New DockingView
		
		dockingView.AddView( label,"top" )
		
		dockingView.ContentView=button
		
		ContentView=dockingView
		
		req.Send()
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()	'need this for ios?
	End
	
	Method OnMeasure:Vec2i() Override
		
		Return New Vec2i( 320,240 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
