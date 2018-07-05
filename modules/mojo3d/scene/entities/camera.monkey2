
Namespace mojo3d

#rem monkeydoc The Camera class.
#end
Class Camera Extends Entity

	#rem monkeydoc Creates a new camera.
	#end	
	Method New( parent:Entity=Null )
		
		Super.New( parent )
		
		Name="Camera"
		Viewport=New Recti( 0,0,640,480 )
		Near=.1
		Far=100
		FOV=90
		
		Visible=True
		
		AddInstance()
	End

	Method New( view:View,parent:Entity=Null )
		
		Super.New( parent )

		Name="Camera"		
		View=view
		Near=.1
		Far=100
		FOV=90
		
		Visible=True
		
		AddInstance()
	End
	
	#rem monkeydoc Copies the camera.
	#end
	Method Copy:Camera( parent:Entity=Null ) Override
		
		Local copy:=OnCopy( parent )
		
		CopyTo( copy )
		
		Return copy
	End
	
	#rem monkeydoc View camera is tracking.
	#end
	Property View:View()
		
		Return _view
	
	Setter( view:View )
		
		_view=view
		
		If _view SetViewport( _view.Rect )
	End

	#rem monkeydoc Viewport.
	
	If [[View]] is non-null, this property will automatically track the view's rect.
		
	This property can only be modified if View is null.
		
	#end	
	Property Viewport:Recti()
		
		Return _viewport
		
	Setter( viewport:Recti )
		
		Assert( Not _view,"Viewport cannot be manually modified for a camera with a view" )
		
		SetViewport( viewport )
	End
	
	#rem monkeydoc Aspect ratio.
	
	Defaults to 1.0.
	
	#end
	Property Aspect:Float()
		
		Return _aspect
	End
	
	#rem monkeydoc Vertical field of view in degrees.
	
	Defaults to 90.0.
	
	#end
	[jsonify=1]
	Property FOV:Float()
	
		Return _fov
		
	Setter( fov:Float )
		
		_fov=fov
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Near clip plane distance.
	
	Defaults to 0.1 (10 cenitimetres).
		
	The ratio of Far/Near clip planes should be kept as low as possible to reduce numerical precision errors.
	
	#end
	[jsonify=1]
	Property Near:Float()
	
		Return _near
	
	Setter( near:Float )
		
		_near=near
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Far clip plane distance.
	
	Defaults to 100.0 (100 metres).
	
	The ratio of Far/Near clip planes should be kept as low as possible to reduce numerical precision errors.
	
	#end
	[jsonify=1]
	Property Far:Float()
	
		Return _far
	
	Setter( far:Float )
		
		_far=far
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc The projection matrix.
	#end	
	Property ProjectionMatrix:Mat4f()
	
		If _dirty & Dirty.ProjMatrix
			
			_projMatrix=Mat4f.Perspective( _fov,_aspect,_near,_far )
		
			_dirty&=~Dirty.ProjMatrix
		Endif
		
		Return _projMatrix
		
	Setter( matrix:Mat4f )
		
		_projMatrix=matrix
		
		_dirty&=~Dirty.ProjMatrix
	End
	
	#rem monkeydoc Renders the camera to a canvas.
	#end
	Method Render( canvas:Canvas )
		
		If _view SetViewport( _view.Rect )
			
		Local gdevice:=canvas.GraphicsDevice
		
		Local rviewport:=canvas.RenderMatrix * Self.Viewport
			
		Renderer.GetCurrent().Render( gdevice.RenderTarget,gdevice.RenderTargetSize,rviewport,Scene,InverseMatrix,ProjectionMatrix,Near,Far )
	End
	
	#rem monkeydoc Converts a point from world coordinates to viewport coordinates.
	#end
	Method ProjectToViewport:Vec2f( worldVertex:Vec3f )

		Local clip_coords:=ProjectionMatrix * InverseMatrix * New Vec4f( worldVertex,1.0 )
		
		Local ndc_coords:=clip_coords.XY/clip_coords.w
		
		Local vp_coords:=Cast<Vec2f>( Viewport.Size ) * (ndc_coords * 0.5 + 0.5)
		
		vp_coords.y=Viewport.Height-vp_coords.y-1
	
		Return vp_coords
	End
	
	#rem monkeydoc Converts a point from viewport coordinates to world coordinates.
	#end
	Method UnprojectFromViewport:Vec3f( viewportCoords:Vec2f )

		viewportCoords.y=Viewport.Height-viewportCoords.y-1
	
		Local vp_coords:=viewportCoords / Cast<Vec2f>( Viewport.Size ) * 2.0 - 1.0
	
		Local clip_coords:=New Mat4f( Matrix ) * -ProjectionMatrix * New Vec4f( vp_coords,-1.0,1.0 )
		
		Local world_coords:=clip_coords.XYZ/clip_coords.w
		
		Return world_coords
	End
	
	Method Pick:RayCastResult( viewportCoords:Vec2f,collisionMask:Int=-1 )
		
		If viewportCoords.x<0 Or viewportCoords.y<0 Or viewportCoords.x>=_viewport.Width Or viewportCoords.y>=_viewport.Height Return Null
		
		Local vpcoords:=viewportCoords
		
		vpcoords.x=vpcoords.x/_viewport.Width*2-1
		vpcoords.y=vpcoords.y/_viewport.Height*2-1
		
		Local iproj:=-ProjectionMatrix
		
		Local rayFrom:=Matrix * (iproj * New Vec3f( vpcoords,-1 ))
		Local rayTo:=Matrix * (iproj * New Vec3f( vpcoords,1 ))
		
		Return Scene.RayCast( rayFrom,rayTo,collisionMask )
	End
	
	Method MousePick:RayCastResult( collisionMask:Int=-1 )
	
		Local mouse:=Cast<Vec2f>( Mouse.Location )

		If App.ActiveWindow mouse.y=App.ActiveWindow.Height-mouse.y
			
		If _view mouse=_view.TransformWindowPointToView( mouse )
			
		mouse.x-=Viewport.min.x
		mouse.y-=Viewport.min.y
		
		Return Pick( mouse,collisionMask )
	End
	
	Protected

	Method New( camera:Camera,parent:Entity )
		
		Super.New( camera,parent )
		
		Viewport=camera.Viewport
		Near=camera.Near
		Far=camera.Far
		FOV=camera.FOV
		
		AddInstance( camera )
	End
	
	Method OnCopy:Camera( parent:Entity ) Override
		
		Return New Camera( Self,parent )
	End
	
	Method OnShow() Override
		
		Scene.Cameras.Add( Self )
	End
	
	Method OnHide() Override
		
		Scene.Cameras.Remove( Self )
	End
	
	Private
	
	Enum Dirty
		ProjMatrix=1
	End

	Field _view:View	
	Field _viewport:Recti
	Field _aspect:Float
	Field _fov:Float
	Field _near:Float
	Field _far:Float
	Field _projMatrix:Mat4f
	Field _dirty:Dirty=Dirty.ProjMatrix

	Method SetViewport( viewport:Recti )
		
		If viewport=_viewport Return
			
		_viewport=viewport

		_aspect=Float( _viewport.Width )/Float( _viewport.Height )
		
		_dirty|=Dirty.ProjMatrix
	End
End
