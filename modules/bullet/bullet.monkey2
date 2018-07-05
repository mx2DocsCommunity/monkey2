	
Namespace bullet

#Import "<libc>"
#Import "<std>"

#Import "bullet3-2.85.1/src/*.h"

#Import "bullet_glue.cpp"
#Import "bullet_glue.h"

#Import "makefile_linearmath"
#Import "makefile_collision"
#Import "makefile_dynamics"

Using std.geom

Alias btScalar:Float

Extern

Struct btVector3
	
	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	
	Method New()
	
	Method New( x:btScalar,y:btScalar,z:btScalar )
	
End

Struct btVector4
	
	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	Field w:btScalar="m_floats[3]"
	
	Method New()
		
	Method New( x:btScalar,y:btScalar,z:btScalar,w:btScalar )
	
End

Struct btMatrix3x3

	Method New()
		
	Method New( xx:btScalar,xy:btScalar,xz:btScalar,yx:btScalar,yy:btScalar,yz:btScalar,zx:btScalar,zy:btScalar,zz:btScalar )
	
	Method getRow:btVector3( i:Int )
		
	Method getColumn:btVector3( j:Int )
End

Struct btQuaternion

	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	Field w:btScalar="m_floats[3]"

	Method New()
		
	Method New( x:btScalar,y:btScalar,z:btScalar,w:btScalar )	
End

Struct btTransform
	
	Method New()
		
	Method New( q:btQuaternion,c:btVector3=New btVector3( 0,0,0 ) )

	Method New( b:btMatrix3x3,c:btVector3=New btVector3( 0,0,0 ) )
		
	Method setOrigin( origin:btVector3 )
	
	Method getOrigin:btVector3()
	
	Method setBasis( basis:btMatrix3x3 )
	
	Method getBasis:btMatrix3x3()
	
	Method setFromOpenGLMatrix( m:Float Ptr )
		
	Method getOpenGLMatrix( m:Float Ptr )
		
	Method getOpenGLMatrix2( m:Float Ptr )
		
	Function getIdentity:btTransform()
End

Class btObject Extends Void
	
	Method destroy() Extension="delete"
End

Class btBroadphaseInterface Extends btObject
End

Class btDbvtBroadphase Extends btBroadphaseInterface
End

Class btMultiSapBroadphase Extends btBroadphaseInterface
End

Class btSimpleBroadphase Extends btBroadphaseInterface
End

Class btCollisionConfiguration Extends btObject
End

Class btDefaultCollisionConfiguration Extends btCollisionConfiguration
End

Class btConstraintSolver Extends btObject
End

Class btSequentialImpulseConstraintSolver Extends btConstraintSolver
End

Class btDispatcher Extends btObject
End

Class btCollisionDispatcher Extends btDispatcher
	
	Method New( collisionConfiguration:btCollisionConfiguration )
End

Class btBroadphaseProxy Extends btObject
End

Class btCollisionWorld Extends btObject
	
	Struct LocalShapeInfo
		
		Field m_shapePart:Int
		Field m_triangleIndex:int
	End
	
	Struct LocalRayResult
		
		Field m_collisionObject:btCollisionObject
		Field m_localShapeInfo:LocalShapeInfo Ptr
		Field m_hitNormalLocal:btVector3
		Field m_hitFraction:btScalar
	End

	Struct RayResultCallback
		
		Field m_closestHitFraction:btScalar
		Field m_collisionObject:btCollisionObject
		Field m_collisionFilterGroup:Short
		Field m_collisionFilterMask:Short
		Field m_flags:UInt
		
		Method hasHit:Bool()
'		Method needsCollision:Bool( proxy0:btBroadphaseProxy ) Virtual
'		Method addSingleResult:btScalar( rayResult:LocalRayResult Ptr,normalInWorldSpace:Bool ) Virtual
	End
	
	Struct ClosestRayResultCallback

		Field m_closestHitFraction:btScalar
		Field m_collisionObject:btCollisionObject
		Field m_collisionFilterGroup:Short
		Field m_collisionFilterMask:Short
		Field m_flags:UInt
		
		Field m_rayFromWorld:btVector3
  		Field m_rayToWorld:btVector3
  		Field m_hitNormalWorld:btVector3
		Field m_hitPointWorld:btVector3
		
		Method New( rayFromWorld:btVector3,rayToWorld:btVector3 )

		Method hasHit:Bool()
	End

	Struct ConvexResultCallback
		
		Field m_closestHitFraction:btScalar
		Field m_collisionFilterGroup:Short
		Field m_collisionFilterMask:Short

		Method hasHit:Bool()
	End
	
	Struct ClosestConvexResultCallback

		Field m_closestHitFraction:btScalar
		Field m_collisionFilterGroup:Short
		Field m_collisionFilterMask:Short
		
		Field m_convexFromWorld:btVector3
		Field m_convexToWorld:btVector3
		Field m_hitNormalWorld:btVector3
		Field m_hitPointWorld:btVector3
		Field m_hitCollisionObject:btCollisionObject
		
		Method New( castFrom:btVector3,castTo:btVector3 )

		Method hasHit:Bool()
	End
			
	Method rayTest( rayFromWorld:btVector3,rayToWorld:btVector3,resultCallback:RayResultCallback Ptr ) Extension="bbBullet::rayTest"
	
	Method convexSweepTest( castShape:btConvexShape,castFrom:btTransform,castTo:btTransform,resultCallback:ConvexResultCallback ptr,allowedCcdPenetration:btScalar=0 ) Extension="bbBullet::convexSweepTest"
		
	Method addCollisionObject( collisionObject:btCollisionObject )
		
	Method removeCollisionObject( collisionObject:btCollisionObject )
				
End

Class btDynamicsWorld Extends btCollisionWorld
	
	Method setGravity( gravity:btVector3 )
	
	Method getGravity:btVector3()
		
	Method stepSimulation( timeStep:btScalar,maxSubSteps:Int=1,fixedTimeStep:btScalar=1.0/60.0 ) Virtual
		
	Method addRigidBody( body:btRigidBody ) Virtual

	Method addRigidBody( body:btRigidBody,group:Short,mask:Short ) Virtual
		
	Method removeRigidBody( body:btRigidBody ) Virtual
		
	Method addConstraint( constraint:btTypedConstraint,disableCollisionsBetweenLinkedBodies:Bool=False )
		
	Method removeConstraint( constraint:btTypedConstraint )
End

Class btDiscreteDynamicsWorld Extends btDynamicsWorld
	
	Method New( dispatcher:btDispatcher,pairCache:btBroadphaseInterface,contraintSolver:btConstraintSolver,collisionConfiguration:btCollisionConfiguration )
		
End

Class btCollisionShape Extends btObject
	
	Method setLocalScaling( scaling:btVector3 )
	
	Method getLocalScaling:btVector3()
	
	Method setMargin( margin:btScalar )
		
	Method getMargin:btScalar()
		
	Method setUserPointer( p:Void Ptr )
	
	Method getUserPointer:Void Ptr()

	Method calculateLocalInertia:btVector3( mass:btScalar ) Extension="bbBullet::calculateLocalInertia"
End

Class btCompoundShape Extends btCollisionShape

 	Method New( enableDynamicAabbTree:Bool=True,initialChildCapacity:int=0 )
 	
	Method addChildShape( localTransform:btTransform,shape:btCollisionShape )

End

Class btConcaveShape Extends btCollisionShape
End

Class btConvexShape Extends btCollisionShape
End

Class btConvexInternalShape Extends btConvexShape
End

Class btPolyhedralConvexShape Extends btConvexInternalShape
End

Class btEmptyShape Extends btConcaveShape
	
End

Class btBoxShape Extends btPolyhedralConvexShape
	
	Method New( boxHalfExtents:btVector3 )
End	

Class btStaticPlaneShape Extends btConcaveShape
	
	Method New( planeNormal:btVector3,planeConstant:btScalar )
End

Class btSphereShape Extends btConvexShape

	Method New( radius:btScalar )
End

Class btCapsuleShape Extends btConvexShape
	
	Method New( radius:btScalar,height:btScalar )
		
End

Class btCapsuleShapeX Extends btCapsuleShape
	
	Method New( radius:btScalar,height:btScalar )
		
End

Class btCapsuleShapeZ Extends btCapsuleShape
	
	Method New( radius:btScalar,height:btScalar )
		
End

Class btCylinderShape Extends btConvexShape
	
	Method New( halfExtents:btVector3 )
		
End

Class btCylinderShapeX Extends btCylinderShape
	
	Method New( halfExtents:btVector3 )
		
End

Class btCylinderShapeZ Extends btCylinderShape
	
	Method New( halfExtents:btVector3 )
		
End

Class btConeShape Extends btConvexShape

	Method New( radius:btScalar,height:btScalar )
			
End

Class btConeShapeX Extends btConeShape

	Method New( radius:btScalar,height:btScalar )
			
End

Class btConeShapeZ Extends btConeShape

	Method New( radius:btScalar,height:btScalar )
			
End

Class btConvexHullShape Extends btConvexShape
	
	Method New( points:btScalar Ptr,numPoints:Int,stride:Int )
		
'	Method addPoint( point:btVector3,recalculateLocalAabb:Bool=True )
	
End

Enum PHY_ScalarType
End

Const PHY_FLOAT:PHY_ScalarType
Const PHY_DOUBLE:PHY_ScalarType
Const PHY_INTEGER:PHY_ScalarType
Const PHY_SHORT:PHY_ScalarType
Const PHY_FIXEPOINT88:PHY_ScalarType
Const PHY_UCHAR:PHY_ScalarType

Class btHeightfieldTerrainShape Extends btConcaveShape

	Method New( heightStickWidth:Int,heightStickLength:Int,heightfieldData:Void Ptr,heightScale:btScalar,minHeight:btScalar,maxHeight:btScalar,upAxis:Int,heightDataType:PHY_ScalarType,flipQuadEdges:Bool )

	Method setUseDiamondSubdivision( useDiamondSubdivision:Bool=True )	

	Method setUseZigzagSubdivision( useZigZagSubdivision:Bool=True )	
End

Class btTriangleMeshShape Extends btConcaveShape
	
	Field m_convexEpsilon:btScalar
	Field m_planarEpsilon:btScalar
	Field m_equalVertexThreshold:btScalar
	Field m_edgeDistanceThreshold:btScalar
	Field m_maxEdgeAngleThreshold:btScalar
	Field m_zeroAreaThreshold:btScalar

End

Class btBvhTriangleMeshShape Extends btTriangleMeshShape

	Method New( meshInterface:btStridingMeshInterface,useQuantizedAabbCompression:Bool,buildBvh:Bool=True )

End

Class btStridingMeshInterface Extends btObject

End

Class btTriangleIndexVertexArray Extends btStridingMeshInterface

	Method New( numTriangles:Int,triangleIndexBase:Int Ptr,triangleIndexStride:Int,numVertices:Int,vertexBase:btScalar Ptr,vertexStride:Int )

End

Class btMotionState Extends btObject="bbBullet::MotionState"
	
	Method setWorldTransform( worldTrans:btTransform Ptr ) Virtual
		
	Method getWorldTransform( worldTrans:btTransform Ptr ) Virtual
	
End

Class btDefaultMotionState Extends btMotionState="bbBullet::DefaultMotionState"

	Field m_graphicsWorldTrans:btTransform
	Field m_centerOfMassOffset:btTransform
	Field m_startWorldTrans:btTransform
	Field m_userPointer:Void Ptr
	
	Method New()
 	Method New( startTrans:btTransform=btTransform.getIdentity(),centerOfMassOffset:btTransform=btTransform.getIdentity() )

End

Const ACTIVE_TAG:Int
Const ISLAND_SLEEPING:Int
Const WANTS_DEACTIVATION:Int
Const DISABLE_DEACTIVATION:Int
Const DISABLE_SIMULATION:Int

Class btCollisionObject Extends btObject
	
	Const CF_STATIC_OBJECT:Int="btCollisionObject::CF_STATIC_OBJECT"
	Const CF_KINEMATIC_OBJECT:Int="btCollisionObject::CF_KINEMATIC_OBJECT"
	Const CF_NO_CONTACT_RESPONSE:Int="btCollisionObject::CF_NO_CONTACT_RESPONSE"
	Const CF_CUSTOM_MATERIAL_CALLBACK:Int="btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK"
	Const CF_CHARACTER_OBJECT:Int="btCollisionObject::CF_CHARACTER_OBJECT"
	Const CF_DISABLE_VISUALIZE_OBJECT:Int="btCollisionObject::CF_DISABLE_VISUALIZE_OBJECT"
	Const CF_DISABLE_SPU_COLLISION_PROCESSING:Int="btCollisionObject::CF_DISABLE_SPU_COLLISION_PROCESSING"
	
	Method isStaticObject:Bool()
		
	Method isKinematicObject:Bool()
		
	Method isStaticOrKinematicObject:Bool()
		
	Method hasContactResponse:Bool()
		
	Method setCollisionShape( collisionShape:btCollisionShape )
		
	Method getCollisionShape:btCollisionShape()
	
	Method setWorldTransform( transform:btTransform )
	
	Method getWorldTransform:btTransform()
	
	Method setRestitution( restitution:btScalar )
	
	Method getRestitution:btScalar()
	
	Method setFriction( friction:btScalar )
	
	Method getFriction:btScalar()
	
	Method setRollingFriction( friction:btScalar )
	
	Method getRollingFriction:btScalar()

	Method setSpinningFriction( friction:btScalar )
	
	Method getSpinningFriction:btScalar()
	
  	Method setContactStiffnessAndDamping( stiffness:btScalar,damping:btScalar )

	Method getContactStiffness:btScalar()
	
	Method getContactDamping:btScalar()
	
	Method setCcdSweptSphereRadius( radius:btScalar )
	
	Method getCcdSweptSphereRadius:btScalar()
	
	Method setCcdMotionThreshold( ccdMotionTheshold:btScalar )
	
	Method getCcdMotionThreshold:btScalar()
	
	Method setCollisionFlags( flags:Int )
	
	Method getCollisionFlags:Int()
		
	Method setActivationState( newState:Int )
		
	Method forceActivationState( newState:Int )
	
	Method getActivationState:Int()
		
	Method setUserPointer( p:Void Ptr )
		
	Method getUserPointer:void ptr()

End

Struct btRigidBodyConstructionInfo
	
	Field m_mass:btScalar
	Field m_motionState:btMotionState
	Field m_startWorldTransform:btTransform
	Field m_collisionShape:btCollisionShape
	Field m_localInertia:btVector3
	Field m_linearDamping:btScalar
	Field m_angularDamping:btScalar
	Field m_friction:btScalar
	Field m_rollingFriction:btScalar
	Field m_restitution:btScalar

	Field m_linearSleepingThreshold:btScalar
	Field m_angularSleepingThreshold:btScalar
	Field m_additionalDamping:Bool
	Field m_additionalDampingFactor:btScalar
	Field m_additionalLinearDampingThresholdSqr:btScalar
	Field m_additionalAngularDampingThresholdSqr:btScalar
	Field m_additionalAngularDampingFactor:btScalar
	
	Method New( mass:btScalar,motionState:btMotionState,collisionShape:btCollisionShape,localInertia:btVector3=New btVector3( 0,0,0 ) )
End
	
Class btRigidBody Extends btCollisionObject

	Method New( constructionInfo:btRigidBodyConstructionInfo )

	Method New( mass:btScalar,motionState:btMotionState,collisionShape:btCollisionShape,localInertia:btVector3=New btVector3( 0,0,0 ) )
	
	Method clearForces()
		
	Method setMassProps( mass:btScalar,inertia:btVector3 )
		
	Method updateInertiaTensor()
		
	Method getInvMass:btScalar()
		
	Method setGravity( acceleration:btVector3 )
		
	Method getGravity:btVector3()
		
	Method proceedToTransform( newTrans:btTransform )
		
	Method setLinearVelocity( lin_vel:btVector3 )
		
	Method getLinearVelocity:btVector3()
		
	Method setAngularVelocity( ang_vel:btVector3 )
	
	Method getAngularVelocity:btVector3()
		
	Method applyForce( force:btVector3,rel_pos:btVector3 )
		
	Method applyCentralForce( force:btVector3 )
		
	Method applyImpulse( impulse:btVector3,rel_pos:btVector3 )
		
	Method applyCentralImpulse( impulse:btVector3 )
		
	Method applyTorque( torque:btVector3 )
		
	Method applyTorqueImpulse( torque:btVector3 )
		
	Method setDamping( lin_damping:btScalar,ang_damping:btScalar )
		
	Method getLinearDamping:btScalar()
		
	Method getAngularDamping:btScalar()
		
	Method getLinearFactor:btVector3()
		
	Method setLinearFactor( factor:btVector3 )
		
	Method getAngularFactor:btVector3()
		
	Method setAngularFactor( factor:btVector3 )
		
End

Const BT_CONSTRAINT_ERP:Int
Const BT_CONSTRAINT_STOP_ERP:Int
Const BT_CONSTRAINT_CFM:Int
Const BT_CONSTRAINT_STOP_CFM:Int

Class btTypedConstraint Extends btObject
	
	Method setParam( num:Int,value:btScalar,axis:Int=-1 )

	Method getParam:btScalar( num:Int,axis:Int=-1 )
End

Class btPoint2PointConstraint Extends btTypedConstraint="bbBullet::Point2PointConstraint"
	
	Method New( rbA:btRigidBody,rbB:btRigidBody,pivotInA:btVector3,pivotInB:btVector3 )

	Method New( rbA:btRigidBody,pivotInA:btVector3 )
		
	Method setPivotA( pivotA:btVector3 )
		
	Method setPivotB( pivotB:btVector3 )
		
	Method getPivotA:btVector3()
		
	Method getPivotB:btVector3()
		
End

Class btHingeConstraint Extends btTypedConstraint="bbBullet::HingeConstraint"

 	method New( rbA:btRigidBody,rtB:btRigidBody,pivotInA:btVector3,pivotInB:btVector3,axisInA:btVector3,axisInB:btVector3,useReferenceFrameA:Bool=False)
 
 	Method New( rbA:btRigidBody,pivotInA:btVector3,axisInA:btVector3,useReferenceFrameA:Bool=False)
 
 	Method New( rbA:btRigidBody,rbB:btRigidBody,rbAFrame:btTransform,rbBFrame:btTransform,useReferenceFrameA:Bool=False )
 	
 	Method New( rbA:btRigidBody,rbAFrame:btTransform,useReferenceFrameA:Bool=False )
	 	
	Method getFrameOffsetA:btTransform()
		
	Method getFrameOffsetB:btTransform()
		
	Method getLowerLimit:btScalar()
		
	Method getUpperLimit:btScalar()
		
	Method setLimit( low:btScalar,high:btScalar,_softness:btScalar=.9,_biasFactor:btScalar=.3,_relaxationFactor:btScalar=1.0 )
End

Class btSliderConstraint Extends btTypedConstraint="bbBullet::SliderConstraint"
	
	Method New( rbA:btRigidBody,rbB:btRigidBody,frameInA:btTransform,frameInB:btTransform,useLinearReferenceFrameA:Bool )
 
	Method New( rbB:btRigidBody,frameInB:btTransform,useLinearReferenceFrameA:Bool )
End

Class btFixedConstraint Extends btTypedConstraint="bbBullet::FixedConstraint"
	
	Method New( rbA:btRigidBody,rbB:btRigidBody,frameInA:btTransform,frameInB:btTransform )
		
End

