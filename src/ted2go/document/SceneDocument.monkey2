Namespace ted2go

#Import "<mojo3d>"
#Import "<mojo3d-loaders>"
#Import "<reflection>"

'just too brutal in debug mode!
#If __RELEASE__
#Reflect mojo3d
#Endif

Using mojo3d..

Class SceneDocumentView Extends View

	Method New( doc:SceneDocument )
		_doc=doc
		
		Layout="fill"
	End
	
	Protected
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		If Not _doc.Scene Or Not _doc.Camera
			canvas.Clear( Color.Red )
			Return
		Endif
		
		If _doc.Model And _doc.Model.Animator
			Global _anim:Float=0
			If Keyboard.KeyDown( Key.A )
				_anim+=12.0/60.0
				_doc.Model.Animator.Animate( 0,_anim )
			Else
				_anim=0
			Endif
		Endif
		
		_doc.Scene.Update()
		
		_doc.Camera.Render( canvas )
	End
	
	Method OnMouseEvent( event:MouseEvent ) Override
		
		If Not _doc.Camera Or Not _doc.Model Return
		
		Global _v:Vec2i
		Global _f:Bool
		
		Select event.Type
		Case EventType.MouseDown
			_v=event.Location
			_f=True
		Case EventType.MouseMove
			If _f
				Local dv:=event.Location-_v
				Local rx:=Float(dv.x)/Height * +180.0
				Local ry:=Float(dv.y)/Height * -180.0
				_doc.Model.Rotate( ry,rx,0 )
				_v=event.Location
			Endif
		Case EventType.MouseUp
			_f=False
		Case EventType.MouseWheel
			_doc.Camera.MoveZ( Float(event.Wheel.y)*-.1 )
		End
	End
	
	Method OnKeyEvent( event:KeyEvent ) Override
		
		If Not _doc.Camera Or Not _doc.Model Return
		
		If event.Type=EventType.KeyDown
			Select event.Key
			Case Key.R
				_doc.Camera.Position=New Vec3f(0,0,-2.5)
				_doc.Model.Rotation=New Vec3f(0,0,0)
			Case Key.S
				If _doc.Light _doc.Light.CastsShadow=Not _doc.Light.CastsShadow
			Case Key.A
				
			End
		Endif
		
	End
	
	Private

	Field _doc:SceneDocument
End

Class SceneDocument Extends Ted2Document
	
	Method New( path:String )
		Super.New( path )
		
		_view=New SceneDocumentView( Self )
	End
	
	Property Scene:Scene()
		
		Return _scene
	End
	
	Property Camera:Camera()
		
		Return _camera
	End
	
	Property Model:Model()
	
		Return _model
	End
	
	Property Light:Light()
		
		Return _light
	End
	
	Protected
	
	Method OnLoad:Bool() Override
		
		If ExtractExt( Path )=".mojo3d"
			
			Print "Loading scene from "+Path
			
			_scene=Scene.Load( Path )
			
			_camera=Cast<Camera>( _scene.FindEntity( "Camera" ) )
			
			If _camera _camera.View=_view
			
			Return True
		Endif
		
		_scene=New Scene
		
		Scene.SetCurrent( _scene )

		_camera=New Camera( _view )
		_camera.Near=.01
		_camera.Far=10
		_camera.MoveZ( -2.5 )
		_camera.AddComponent<FlyBehaviour>()

		_light=New Light
		_light.RotateX( Pi/2 )
		
		_model=Model.Load( Path )
		If _model _model.Mesh.FitVertices( New Boxf( -1,1 ) )
			
		Scene.SetCurrent( Null )
		
		Return True
	End
	
	Method OnSave:Bool() Override

		Return False
	End
	
	Method OnClose() Override
		
		_scene.DestroyAllEntities()
	End
	
	Method OnCreateView:SceneDocumentView() Override
	
		Return _view
	End
	
	Private
	
	Field _view:SceneDocumentView
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _model:Model
End

Class SceneDocumentType Extends Ted2DocumentType

	Protected
	
	Method New()
		AddPlugin( Self )
		
		#If __RELEASE__
			Extensions=New String[]( ".mojo3d",".gltf",".glb",".b3d",".3ds",".obj",".dae",".fbx",".blend",".x" )
		#Else
			Extensions=New String[]( ".gltf",".glb",".b3d",".3ds",".obj",".dae",".fbx",".blend",".x" )
		#Endif
	End
	
	Method OnCreateDocument:Ted2Document( path:String ) Override
		
		Return New SceneDocument( path )
	End
	
	Private
	
	Global _instance:=New SceneDocumentType
End
