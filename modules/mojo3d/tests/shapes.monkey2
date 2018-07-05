
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'uncomment this to create a mojo3d scene file in monkey2 dir!
'#Reflect mojo3d

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _marker:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		CreateScene()
	End

	Method CreateGround()

		Local box:=New Boxf( -60,-1,-60,60,0,60 )
		
		Local material:=New PbrMaterial( Color.Green )
		
		Local model:=Model.CreateBox( box,16,16,16,material )
		model.Name="Ground"
		
		model.Collided+=Lambda( body:RigidBody )
'			Print "Ground hit: "+body.Entity.Name
		End

		Local collider:=model.AddComponent<BoxCollider>()
		collider.Box=box

		Local body:=model.AddComponent<RigidBody>()
		body.CollisionGroup=64
		body.CollisionMask=127
		body.Mass=0
	End

	Method CreateBodies()		
		
		Local material:=New PbrMaterial( Color.White )

		Local box0:=New Boxf( -1,-5,-1,1,5,1 )		
		Local model0:=Model.CreateBox( box0,1,1,1,material )
		model0.Name="Box"
		Local collider0:=New BoxCollider( model0 )
		collider0.Box=box0
		Local body0:=New RigidBody( model0 )
		body0.CollisionGroup=1
		body0.CollisionMask=127
		
		Local model1:=Model.CreateSphere( 1,32,16,material )
		model1.Name="Sphere"
		Local collider1:=New SphereCollider( model1 )
		Local body1:=New RigidBody( model1 )
		body1.CollisionGroup=2
		body1.CollisionMask=127

		Local model2:=Model.CreateCylinder( 1,8,Axis.Y,32,material )
		model2.Name="Cylinder"
		Local collider2:=New CylinderCollider( model2 )
		collider2.Radius=1
		collider2.Length=8
		Local body2:=New RigidBody( model2 )
		body2.CollisionGroup=4
		body2.CollisionMask=127

		Local model3:=Model.CreateCapsule( 1,10,Axis.Y,32,material )
		model3.Name="Capsule"
		Local collider3:=New CapsuleCollider( model3 )
		collider3.Radius=1
		collider3.Length=10
		Local body3:=New RigidBody( model3 )
		body3.CollisionGroup=8
		body3.CollisionMask=127
		
		Local model4:=Model.CreateCone( 2.5,5,Axis.Y,32,material )
		model4.Name="Cone"
		Local collider4:=New ConeCollider( model4 )
		collider4.Radius=2.5
		collider4.Length=5
		Local body4:=New RigidBody( model4 )
		body4.CollisionGroup=16
		body4.CollisionMask=127
		
		Local models:=New Model[]( model0,model1,model2,model3,model4 )
		
		For Local x:=-40 To 40 Step 8
			
			For Local z:=-40 To 40 Step 8
				
				Local i:=Int( Rnd( models.Length ) )
				
				Local model:=models[i].Copy()
				
				model.Materials=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
				
				model.Move( x,10,z )
				
			Next
			
		Next
		
		For Local model:=Eachin models
			
			model.Visible=False
			
			'model.Destroy()
		Next
	End

	Method CreateMarker()
					
		_marker=Model.CreateCone( 1,2,Axis.Y,12,New PbrMaterial( Color.Red ),Null )
		
		_marker.Mesh.FitVertices( New Boxf( -.125,0,-.125,.125,1,.125 ),False )
	End
	
	Method CreateScene()
		
		_scene=New Scene( True )
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Name="Camera"
		_camera.Near=.1
		_camera.Far=60
		_camera.Move( 0,10,-10 )
		_camera.AddComponent<FlyBehaviour>()
		
		Local collider:=_camera.AddComponent<SphereCollider>()
		collider.Radius=1
		
		Local body:=_camera.AddComponent<RigidBody>()
		body.CollisionGroup=32
		body.CollisionMask=127
		body.Kinematic=True
		body.Friction=0	'no friction best for kinematic bodies?
		body.Mass=0
		
		'create light
		'
		Local light:=New Light
		light.RotateX( 75,15 )
		light.CastsShadow=true
		
		CreateGround()
		
		CreateBodies()
		
		If _scene.Editable 
			_scene.Save( "shapes-scene.mojo3d","modules/mojo3d/tests/assets/" )
			_scene=Scene.Load( "shapes-scene.mojo3d" )
			_camera=Cast<Camera>( _scene.FindEntity( "Camera" ) )
		Endif

		CreateMarker()
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		If _marker
			Local raycast:=_camera.MousePick( 127 )
			
			Local picked:=""
			
			If raycast
				
				Local j:=raycast.normal,i:Vec3f,k:Vec3f
				
				If Abs( j.x )>.5
					k=New Vec3f( 0,0,1 )
					i=j.Cross( k ).Normalize()
					k=i.Cross( j ).Normalize()
				Else
					i=New Vec3f( 1,0,0 )
					k=i.Cross( j ).Normalize()
					i=j.Cross( k ).Normalize()
				Endif
				
				_marker.Position=raycast.point
				_marker.Basis=New Mat3f( i,j,k )
				_marker.Visible=True
				picked=raycast.body.Entity.Name+" "+_marker.Basis.j
				
			Else
				
				_marker.Visible=False
				
			Endif
		Endif
				
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
