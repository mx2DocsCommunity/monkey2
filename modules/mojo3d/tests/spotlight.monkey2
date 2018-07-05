Namespace myapp3d

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'uncomment this to create a mojo3d scene file in monkey2 dir!
'#Reflect mojo3d

#Import "assets/monkey2-logo.png"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Method New( title:String="Simple mojo3d app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
	End
	
	Method OnCreateWindow() Override
		
		'create (current) scene
		_scene=New Scene( True )
		_scene.ShadowAlpha=.75
		
		'create camera
		Local camera:=New Camera( Self )
		camera.AddComponent<FlyBehaviour>()
		camera.Move( 0,2.5,-10 )
		
		'create light
		Local light:=New Light
		light.Type=LightType.Spot
		light.Texture=_scene.LoadTexture( "asset::monkey2-logo.png" )
		light.Color=Color.White * 8
		light.Range=15
		light.InnerAngle=15
		light.OuterAngle=45
		light.CastsShadow=True
		light.Position=New Vec3f( 0,10,0 )
		light.Rotate( 90,0,0 )
		
		'create ground
		Local groundBox:=New Boxf( -100,-1,-100,100,0,100 )
		Local groundMaterial:=New PbrMaterial( Color.Brown,0,1 )
		Local ground:=Model.CreateBox( groundBox,1,1,1,groundMaterial )
		ground.CastsShadow=False
		
		'create donut
		Local donutMaterial:=New PbrMaterial( Color.White,0,1 )
		Local donut:=Model.CreateTorus( 2,.5,48,24,donutMaterial )
		donut.Move( 0,2.5,0 )
		donut.AddComponent<RotateBehaviour>().Speed=New Vec3f( .2,.4,.6 )
		
		If _scene.Editable _scene.Save( "spotlight-scene.mojo3d","modules/mojo3d/tests/assets/" ) ; _scene=Scene.Load( "spotlight-scene.mojo3d" )
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
