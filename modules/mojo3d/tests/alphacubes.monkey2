Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=New Scene
		_scene.ClearColor=Color.Sky
		_scene.FogColor=Color.Sky
		_scene.FogNear=25
		_scene.FogFar=50
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 30,60,0 )
		
		'Create cube
		'
		Local cube:=Model.CreateBox( New Boxf( -1,1 ),1,1,1,New PbrMaterial( Color.Grey ) )
		
		cube.CastsShadow=False
		
		For Local x:=-50.0 To 50.0 Step 2.5
			For Local z:=-50.0 To 50.0 Step 2.5
				Local copy:=cube.Copy()
				copy.Move( x,0,z )
				
				copy.Alpha=(x+50)/100
			Next
		Next
		
		cube.Destroy()
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
