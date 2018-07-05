
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'uncomment this to create a mojo3d scene file in monkey2 dir!
'#Reflect mojo3d

#Import "assets/miramar-skybox.jpg"
#Import "assets/Acadia-Tree-Sprite.png"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		CreateScene()
	End
	
	Method CreateScene()
		
		_scene=New Scene( True )
		
		_scene.SkyTexture=_scene.LoadTexture( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap|TextureFlags.Envmap )
		_scene.FogColor=Color.Sky
		_scene.FogNear=10
		_scene.FogFar=30
		
		'create camera
		'
		Local camera:=New Camera( Self )
		camera.Near=.1
		camera.Far=100
		camera.Move( 0,10,-10 )
		camera.AddComponent<FlyBehaviour>()
		
		'create light
		'
		Local light:=New Light
		light.Rotate( 60,45,0 )
		
		'create ground
		'
		Local ground:=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green ) )
		
		'create sprites
		'
		Local material:=SpriteMaterial.Load( "asset::Acadia-Tree-Sprite.png" )
'		material.AlphaDiscard=1.0/255.0

		For Local i:=0 Until 1000
			
			Local sprite:=New Sprite( material )
			
			sprite.Move( Rnd(-50,50),0,Rnd(-50,50) )
			
			sprite.Scale=New Vec3f( Rnd( 1,2 ),Rnd( 2,3 ),1 )
			
			sprite.Handle=New Vec2f( .5,0 )
			
			sprite.Mode=SpriteMode.Upright
		Next
		
		For Local i:=0 Until 100
			
			Local sx:=Rnd( 1,2 )

			Local box:=Model.CreateBox( New Boxf( -sx,0,-sx,sx,Rnd( 2,10 ),sx ),1,1,1,New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
			
			box.Move( Rnd(-50,50),0,Rnd(-50,50) )
		next	

		If _scene.Editable _scene.Save( "sprites-scene.mojo3d","modules/mojo3d/tests/assets/" ) ; _scene=Scene.Load( "sprites-scene.mojo3d" )
		
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
