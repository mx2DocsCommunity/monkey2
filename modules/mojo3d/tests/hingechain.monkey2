Namespace myapp3d

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'#Reflect mojo3d

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	Field _camera:Camera
	Field _light:Light
	Field _ground:Model
	Field _donut:Model
	
	Method New( title:String="Simple mojo3d app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
	End
	
	Method OnCreateWindow() Override
		
		_scene=New Scene( True )
		
		_scene.ClearColor = New Color( 0.2, 0.6, 1.0 )
		_scene.AmbientLight = _scene.ClearColor * 0.25
		_scene.FogColor = _scene.ClearColor
		_scene.FogFar = 1.0
		_scene.FogFar = 200.0
		
		'create camera
		Local camera:=New Camera( Self )
		camera.AddComponent<FlyBehaviour>()
		camera.Move( 0,2.5,-5 )
		
		'create light
		Local light:=New Light
		light.CastsShadow=True
		light.Rotate( 45, 45, 0 )
		
		'create ground
		Local groundBox:=New Boxf( -100,-1,-100,100,0,100 )
		Local groundMaterial:=New PbrMaterial( Color.Lime )
		Local ground:=Model.CreateBox( groundBox,1,1,1,groundMaterial )
		ground.AddComponent<BoxCollider>().Box=groundBox
		ground.AddComponent<RigidBody>().Mass=0
		ground.CastsShadow=False

		'create chain link
		Local box:=New Boxf( -.2,-.45,-.01,.2,.45,.01 )
		Local material:=New PbrMaterial( Color.Red, 0.05, 0.2 )
		Local model:=Model.CreateBox( box,1,1,1,material )
		model.AddComponent<BoxCollider>().Box=box
		model.AddComponent<RigidBody>()

		Local prev:Model

		For Local y:=0 Until 100
			
			Local copy:=model.Copy()
			
			copy.Position=New Vec3f( 0,y+10,0 )
			
			If prev
				Local joint:=copy.AddComponent<HingeJoint>()
				joint.ConnectedBody=prev.RigidBody
				joint.Pivot=New Vec3f( 0,-.5,0 )
				joint.Axis=New Vec3f( 1,0,0 )
				joint.MinAngle=-90
				joint.MaxAngle=90
			Endif
			
			prev=copy
		Next
		
		prev.RigidBody.Mass=0
		
		model.Visible=False
		
		If _scene.Editable 
			Print "Saving mojo3d scene file"
			_scene.Save( "hingechain-scene.mojo3d","modules/mojo3d/tests/assets/" )
			_scene=Scene.Load( "hingechain-scene.mojo3d" )
		Endif
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
