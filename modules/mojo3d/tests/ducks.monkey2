
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'uncomment this to create a mojo3d scene file in monkey2 dir!
'#Reflect mojo3d

#Import "assets/duck.gltf/@/duck.gltf"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		CreateScene()
	End
	
	Method CreateGround()
		
		Local box:=New Boxf( -50,-1,-50,50,0,50 )
		
		Local material:=New PbrMaterial( Color.Green,0,1 )
		
		Local model:=Model.CreateBox( box,1,1,1,material )
		
		model.CastsShadow=False
		
	End
	
	Method CreateDucks()

		Local duck:=Model.Load( "asset::duck.gltf/Duck.gltf" )
		duck.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		Local root:=duck.Copy()
		root.Move( 0,10,0 )
		root.Scale=New Vec3f( 3 )
		
		root.AddComponent<RotateBehaviour>().Speed=New Vec3f( 0,-.01,0 )
		
		For Local m:=0.0 To 1.0 Step .125
		
			For Local i:=0.0 Until 360.0 Step 24
			
				Local copy:=duck.Copy( root )
				
				copy.RotateY( i )
				
				copy.Move( 0,0,6+m*16 )

				copy.Scale=New Vec3f( 1 )
				
				Local materials:=copy.Materials.Slice( 0 )
				
				For Local j:=0 Until materials.Length
				
					Local material:=Cast<PbrMaterial>( materials[j].Copy() )
					
					material.MetalnessFactor=m
					material.RoughnessFactor=i/360.0
					
					materials[j]=material
				Next
				
				copy.Materials=materials
			Next
		Next
		
		duck.Destroy()
	End
	
	Method CreateScene()
		
		'create scene
		'		
		_scene=New Scene( True )
		
		'for softer shadows
		'
		_scene.ShadowAlpha=.6
		
		'create camera
		'
		Local camera:=New Camera( Self )
		camera.AddComponent<FlyBehaviour>()
		camera.Move( 0,15,-20 )
		
		'create light
		'
		Local light:=New Light
		light.CastsShadow=True
		light.Rotate( 90,0,0 )
		
		CreateGround()
		
		CreateDucks()
		
		If _scene.Editable _scene.Save( "ducks-scene.mojo3d","modules/mojo3d/tests/assets/" ) ; _scene=Scene.Load( "ducks-scene.mojo3d" )
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )

		canvas.DrawText( "FPS="+App.FPS,Width,0,1,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
