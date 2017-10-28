
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _donut:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )
		
		'create donut - metallic silver...
		
		Local material:=New PbrMaterial( Color.Silver,1,0.5 )
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
		
		_donut.Move( 0,10,0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		If Keyboard.KeyHit( Key.Space ) _donut.Visible=Not _donut.Visible
		
		_donut.Rotate( .1,.2,.3 )
		
		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
