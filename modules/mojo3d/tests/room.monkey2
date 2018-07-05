Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/fish.glb"
#Import "assets/monkey2-logo.png"

Using std..
Using mojo..
Using mojo3d..

Function Main()
	
	SetConfig( "MOJO_OPENGL_PROFILE","es" )
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _room:Model
	
	Field _fish:Entity
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		CreateScene()
	End
	
	Method CreateRoom()

		Local box:=New Boxf( -15,15 )
		
		Local material:=New PbrMaterial( Color.Orange )
		
		Local model:=Model.CreateBox( box,1,1,1,material )
		model.Mesh.FlipTriangles()
		model.Mesh.UpdateNormals()
		model.Mesh.UpdateTangents()
		model.CastsShadow=False
	
	End
	
	Method CreateFishes()
		
		Local model:=Model.Load( "asset::fish.glb" )
		model.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		Local root:=New Pivot
		root.AddComponent<RotateBehaviour>().Speed=New Vec3f( 0,.1,0 )
		
		For Local an:=0 Until 360 Step 9
			
			Local copy:=model.Copy( root )
			
			copy.Rotate( 0,an,0 )
			copy.Move( 0,Sin( an )*3,Rnd( 2.5,9.5 ) )
			copy.Rotate( 0,-90,0 )
			
		Next
		
		model.Destroy()
	End
	
	Method CreateScene()
		
		'Create scene
		_scene=New Scene
		_scene.ClearColor=Color.Black
		_scene.AmbientLight=Color.Black
		_scene.EnvColor=Color.Black
		_scene.ShadowAlpha=.7
		
		'Create camera
		Local camera:=New Camera( Self )
		camera.Move( 0,1,-5 )
		camera.AddComponent<FlyBehaviour>()
		camera.Far=100
		
		'Create light
		Local light:=New Light
		light.Type=LightType.Point
		light.Color=Color.White
		light.Texture=Texture.Load( "asset::monkey2-logo.png",TextureFlags.Filter|TextureFlags.Cubemap )
		light.CastsShadow=True
		light.Range=25
		light.AddComponent<RotateBehaviour>().Speed=New Vec3f( 0,-.05,0 )
		
		CreateRoom()
		
		CreateFishes()
	End
		
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS "+App.FPS,Width,0,1,0 )
	End
	
End

