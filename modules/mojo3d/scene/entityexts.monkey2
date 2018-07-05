
Namespace mojo3d

Private

Const DegreesToRadians:=Pi/180.0

Const RadiansToDegrees:=180.0/Pi

Public

#rem monkeydoc Utility extension methods for entities.
#end
Class Entity Extension
	
	#rem monkeydoc The rigid body attached to the entity.
	#end
	Property RigidBody:RigidBody()
		
		Return GetComponent<RigidBody>()
	End
	
	#rem monkeydoc The collider attached to the entity.
	#end
	Property Collider:Collider()
		
		Return GetComponent<Collider>()
	End

	#rem monkeydoc The joint attached to the entity.
	#end
	Property Joint:Joint()
		
		Return GetComponent<Joint>()
	End

	#rem monkeydoc The animator attached to the entity.
	#end
	Property Animator:Animator()
		
		Return GetComponent<Animator>()
	End

	#rem monkeydoc World space rotation in degrees.
	#end
	Property Rotation:Vec3f()
		
		Return Basis.GetRotation() * RadiansToDegrees
	
	Setter( rotation:Vec3f )
		
		Basis=Mat3f.Rotation( rotation * DegreesToRadians )
	End
	
	#rem monkeydoc Local space rotation in degrees.
	#end
	Property LocalRotation:Vec3f()
		
		Return LocalBasis.GetRotation() * RadiansToDegrees
	
	Setter( rotation:Vec3f )
		
		LocalBasis=Mat3f.Rotation( rotation * DegreesToRadians )
	End
	
	#Rem monkeydoc World space rotation around the X axis in degrees.
	#End
	Property Rx:Float()
		
		Return Rotation.x
		
	Setter( rx:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( rx,r.y,r.z )
	End

	#Rem monkeydoc World space rotation around the Y axis in degrees.
	#End
	Property Ry:Float()
		
		Return Rotation.y
		
	Setter( ry:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( r.x,ry,r.z )
	End

	#Rem monkeydoc World space rotation around the Z axis in degrees.
	#End
	Property Rz:Float()
		
		Return Rotation.z
		
	Setter( rz:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( r.x,r.y,rz )
	End
	
	#Rem monkeydoc Local space rotation around the X axis in degrees.
	#End
	Property LocalRx:Float()
		
		Return LocalRotation.x
		
	Setter( rx:Float )
		
		Local r:=LocalRotation
		LocalRotation=New Vec3f( rx,r.y,r.z )
	End

	#Rem monkeydoc Local space rotation around the Y axis in degrees.
	#End
	Property LocalRy:Float()
		
		Return LocalRotation.y
		
	Setter( ry:Float )
		
		Local r:=LocalRotation
		LocalRotation=New Vec3f( r.x,ry,r.z )
	End

	#Rem monkeydoc Local space rotation around the Z axis in degrees.
	#End
	Property LocalRz:Float()
		
		Return LocalRotation.z
		
	Setter( rz:Float )
		
		Local r:=LocalRotation
		LocalRotation=New Vec3f( r.x,r.y,rz )
	End

	#rem monkeydoc World space X coordinate.
	#end
	Property X:Float()
		
		Return Position.x
		
	Setter( x:Float )
		
		Local v:=Position
		Position=New Vec3f( x,v.y,v.z )
	End
	
	#rem monkeydoc World space Y coordinate.
	#end
	Property Y:Float()
	
		Return Position.y
	
	Setter( y:Float )
		
		Local v:=Position
		Position=New Vec3f( v.x,y,v.z )
	End

	#rem monkeydoc World space Z coordinate.
	#end
	Property Z:Float()
	
		Return Position.z
	
	Setter( z:Float )
		
		Local v:=Position
		Position=New Vec3f( v.x,v.y,z )
	End
	
	#rem monkeydoc Local space X coordinate.
	#end
	Property LocalX:Float()
		
		Return LocalPosition.x
		
	Setter( x:Float )

		Local v:=LocalPosition		
		LocalPosition=New Vec3f( x,v.y,v.z )
	End
	
	#rem monkeydoc Local space Y coordinate.
	#end
	Property LocalY:Float()
	
		Return LocalPosition.y
	
	Setter( y:Float )
		
		Local v:=LocalPosition		
		LocalPosition=New Vec3f( v.x,y,v.z )
	End

	#rem monkeydoc Local space Z coordinate.
	#end
	Property LocalZ:Float()
	
		Return LocalPosition.z
	
	Setter( z:Float )
		
		Local v:=LocalPosition		
		LocalPosition=New Vec3f( v.x,v.y,z )
	End
	
	#rem monkeydoc World space scale on the X axis.
	#end
	Property Sx:Float()
		
		Return Scale.x
	
	Setter( sx:Float )
		
		Local s:=Scale
		Scale=New Vec3f( sx,s.y,s.z )
	End
	
	#rem monkeydoc World space scale on the Y axis.
	#end
	Property Sy:Float()
		
		Return Scale.y
	
	Setter( sy:Float )
		
		Local s:=Scale
		Scale=New Vec3f( s.x,sy,s.z )
	End
	
	#rem monkeydoc World space scale on the Z axis.
	#end
	Property Sz:Float()
		
		Return Scale.z
	
	Setter( sz:Float )
		
		Local s:=Scale
		Scale=New Vec3f( s.x,s.y,sz )
	End
	
	#rem monkeydoc Local space scale on the X axis.
	#end
	Property LocalSx:Float()
		
		Return LocalScale.x
	
	Setter( sx:Float )
		
		Local s:=LocalScale
		
		LocalScale=New Vec3f( sx,s.y,s.z )
	End
	
	#rem monkeydoc Local space scale on the Y axis.
	#end
	Property LocalSy:Float()
		
		Return LocalScale.y
	
	Setter( sy:Float )
		
		Local s:=LocalScale
		LocalScale=New Vec3f( s.x,sy,s.z )
	End
	
	#rem monkeydoc Local space scale on the Z axis.
	#end
	Property LocalSz:Float()
		
		Return LocalScale.z
	
	Setter( sz:Float )
		
		Local s:=LocalScale
		LocalScale=New Vec3f( s.x,s.y,sz )
	End
	
	#rem monkeydoc Sets entity position in local or world space.
	#end
	Method SetPosition( position:Vec3f,localSpace:Bool=False )
		
		If localSpace LocalPosition=position Else Position=position
	End
	
	Method SetPosition( x:Float,y:Float,z:Float,localSpace:Bool=False )
		
		SetPosition( New Vec3f( x,y,z ),localSpace )
	End
	
	#rem monkeydoc Gets entity position in local or world space.
	#end
	Method GetPosition:Vec3f( localSpace:Bool=False )
		
		Return localSpace ? LocalPosition Else Position
	End
	
	#rem monkeydoc Sets entity basis matrix in local or world space.
	#end
	Method SetBasis( basis:Mat3f,localSpace:Bool=False )
		
		If localSpace LocalBasis=basis Else Basis=basis
	End
	
	#rem monkeydoc Gets entity basis matrix in local or world space.
	#end
	method GetBasis:Mat3f( localSpace:Bool=False )
		
		Return localSpace ? LocalBasis Else Basis
	
	End

	#rem monkeydoc Sets entity rotation in euler angles in local or world space.
	#end
	Method SetRotation( rotation:Vec3f,localSpace:Bool=False )
		
		Local basis:=Mat3f.Rotation( rotation * DegreesToRadians )
		
		If localSpace LocalBasis=basis Else Basis=basis
	End
	
	Method SetRotation( rx:Float,ry:Float,rz:Float,localSpace:Bool=False )
		
		SetRotation( New Vec3f( rx,ry,rz ),localSpace )
	End
	
	#rem monkeydoc Gets entity rotation in euler angles in local or world space.
	#end
	Method GetRotation:Vec3f( localSpace:Bool=False )
		
		Local basis:=localSpace ? LocalBasis Else Basis
		
		Return basis.GetRotation() * RadiansToDegrees
	End
	
	#rem monkeydoc Sets entity scale in local or world space.
	#end
	Method SetScale( scale:Vec3f,localSpace:Bool=False )
		
		If localSpace LocalScale=scale Else Scale=scale
	End
	
	Method SetScale( sx:Float,sy:Float,sz:Float,localSpace:Bool=False )
		
		SetScale( New Vec3f( sx,sy,sz ),localSpace )
	End

	#rem monkeydoc Gets entity scale in local or world space.
	#end
	Method GetScale:Vec3f( localSpace:Bool=False )
		
		Return localSpace ? LocalScale Else Scale
	End
	
	#rem monkeydoc Moves the entity.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method Move( tv:Vec3f,localSpace:Bool=False )
		
		If localSpace LocalPosition+=tv Else Position+=Basis * tv
	End
	
	Method Move( tx:Float,ty:Float,tz:Float )
		
		Move( New Vec3f( tx,ty,tz ) )
	End
	
	#rem monkeydoc Moves the entity on the X axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveX( tx:Float,localSpace:Bool=False )
		
		If localSpace LocalX+=tx Else Position+=Basis.i * tx
	End
	
	#rem monkeydoc Moves the entity on the Y axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveY( ty:Float,localSpace:Bool=False )

		If localSpace LocalY+=ty Else Position+=Basis.j * ty
	End
	
	#rem monkeydoc Moves the entity on the Z axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveZ( tz:Float,localSpace:Bool=False )

		If localSpace LocalZ+=tz Else Position+=Basis.k * tz
	End
	
	#rem monkeydoc Rotates the entity.
	
	Rotates the entity.
	
	If `localSpace` is false, the rotation is applied after the entity's world rotation.
		
	If `localSpace` is true, the rotation is applied before the entity's local rotation.
		
	#end
	Method Rotate( rv:Vec3f,localSpace:Bool=False )
		
		Local basis:=Mat3f.Rotation( rv * DegreesToRadians )
		
		If localSpace LocalBasis*=basis Else Basis=basis*Basis
	End
	
	Method Rotate( rx:Float,ry:Float,rz:Float,localSpace:Bool=False )
		
		Rotate( New Vec3f( rx,ry,rz ),localSpace )
	End
	
	#rem monkeydoc Rotates the entity around the X axis.
	#end
	Method RotateX( rx:Float,localSpace:Bool=False )
		
		Local basis:=Mat3f.Pitch( rx * DegreesToRadians )
		
		If localSpace LocalBasis=basis*LocalBasis Else Basis*=basis
	End

	#rem monkeydoc Rotates the entity around the Y axis.
	#end
	Method RotateY( ry:Float,localSpace:Bool=False )

		Local basis:=Mat3f.Yaw( ry * DegreesToRadians )
		
		If localSpace LocalBasis=basis*LocalBasis Else Basis*=basis
	End

	#rem monkeydoc Rotates the entity around the Z axis.
	#end
	Method RotateZ( rz:Float,localSpace:Bool=False )

		Local basis:=Mat3f.Roll( rz * DegreesToRadians )
		
		If localSpace LocalBasis=basis*LocalBasis Else Basis*=basis
	End

	#rem monkeydoc Points the entity at a target.
	#end
	Method PointAt( target:Vec3f,up:Vec3f=New Vec3f( 0,1,0 ) )
		
		Local k:=(target-Position).Normalize()
		
		Local i:=up.Cross( k ).Normalize()
		
		Local j:=k.Cross( i )
		
		Basis=New Mat3f( i,j,k )
	End
	
	Method PointAt( target:Entity,up:Vec3f=New Vec3f( 0,1,0 ) )
		
		PointAt( target.LocalPosition )
	End
	
	
End
