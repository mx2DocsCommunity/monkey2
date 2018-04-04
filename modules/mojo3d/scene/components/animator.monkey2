
Namespace mojo3d

Class Entity Extension
	
	Property Animator:Animator()
		
		Return Cast<Animator>( GetComponent( Animator.Type ) )
	End
	
End

#rem monkeydoc The Animator class.
#end
Class Animator Extends Component
	
	Const Type:=New ComponentType( "Animator",0,ComponentTypeFlags.Singleton )
	
	Field Finished:Void()
	
	Method New( entity:Entity )
		Super.New( entity,Type )
	End
	
	Method New( entity:Entity,animator:Animator )
		Self.New( entity )

		_skeleton=animator._skeleton.Slice( 0 )
		For Local i:=0 Until _skeleton.Length
			_skeleton[i]=_skeleton[i].LastCopy
		End
		_animations=animator._animations
	End
	
	Property Skeleton:Entity[]()
		
		Return _skeleton
		
	Setter( skeleton:Entity[] )
		
		_skeleton=skeleton
	End
	
	Property Animations:Stack<Animation>()
		
		Return _animations
		
	Setter( animations:Stack<Animation> )
		
		_animations=animations
	End

	Property MasterSpeed:Float()
		
		Return _speed
	
	Setter( speed:Float )
		
		_speed=speed
	End
	
	Property Animating:Animation()
		
		Return _playing ? _animation Else Null
	End

	Property Paused:Bool()
		
		Return _paused
	
	Setter( paused:Bool )
		
		_paused=paused
	End
	
	Property Time:Float()
		
		Return _time
	
	Setter( time:Float )
		
		_time=time
	End
	
	Method FindAnimation:Animation( name:String )
		
		For Local animation:=Eachin _animations
			
			If animation.Name=name Return animation
		Next
		
		Return Null
	End
	
	Method Animate( index:Int=0,transition:Float=0.0,finished:Void()=Null )
		
		Animate( _animations[index],transition,finished )
	End
		
	Method Animate( name:String,transition:Float=0.0,finished:Void()=Null )
		
		Animate( FindAnimation( name ),transition,finished )
	End
		
	Method Animate( animation:Animation,transition:Float=0.0,finished:Void()=Null )
		
		If Not animation return
		
		If _playing And _animation=animation Return
		
		If _playing And transition>0
			_animation0=_animation
			_time0=_time
			_transition=transition
			_transtime=0
			_trans=True
		Else
			_trans=False
		Endif
		_animation=animation
		_time=0
		_finished=finished
		_playing=True
		
	End
	
	Method Stop()
		
		_playing=False
	End
	
	Protected
	
	Method OnCopy:Animator( entity:Entity ) Override
		
		Return New Animator( entity,Self )
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		If _paused  Or Not _playing Return
		
		Local blend:=0.0
		
		If _trans
			_transtime+=elapsed
			If _transtime<_transition
				blend=_transtime/_transition
			Else
				_trans=False
			Endif
		Endif
		
		Local duration:=_animation.Duration/_animation.Hertz
		_time+=_speed*elapsed
		If _time>=duration
			Select _animation.Mode
			Case AnimationMode.OneShot
				_time=duration
				_playing=False
			Case AnimationMode.Looping
				_time-=duration
			End
			_finished()
		Endif
		
		If _trans
			Local duration0:=_animation0.Duration/_animation0.Hertz
			_time0+=_speed0*elapsed
			If _time0>=duration0
				Select _animation0.Mode
				Case AnimationMode.OneShot
					_time0=duration0
				Case AnimationMode.Looping
					_time0-=duration0
				End
			Endif
			UpdateSkeleton( _animation0,_time0,_animation,_time,blend )
		Else
			UpdateSkeleton( _animation,_time,Null,0,0 )
		Endif
		
	End
	
	Private
	
	Field _skeleton:Entity[]
	Field _animations:=New Stack<Animation>
	
	Field _playing:Bool=False
	Field _paused:Bool=False
	
	Field _transtime:Float
	Field _transition:Float
	Field _trans:Bool
	
	Field _animation0:Animation
	Field _speed0:Float
	Field _time0:Float
	
	Field _animation:Animation
	Field _speed:Float=1
	Field _time:Float
	
	Field _finished:Void()

	Method UpdateSkeleton( playing0:Animation,time0:Float,playing1:Animation,time1:Float,alpha:Float )
		
		time0*=playing0?.Hertz
		time1*=playing1?.Hertz
		
		For Local i:=0 Until _skeleton.Length
			
			Local chan0:=playing0 ? playing0.Channels[i] Else Null
			Local chan1:=playing1 ? playing1.Channels[i] Else Null
			
			If chan0?.PositionKeys
				If chan1?.PositionKeys
					_skeleton[i].LocalPosition=chan0.GetPosition( time0 ).Blend( chan1.GetPosition( time1 ),alpha )
				Else
					_skeleton[i].LocalPosition=chan0.GetPosition( time0 )
				Endif
			Endif
			
			If chan0?.RotationKeys
				If chan1?.RotationKeys
					_skeleton[i].LocalBasis=chan0.GetRotation( time0 ).Slerp( chan1.GetRotation( time1 ),alpha )
				Else
					_skeleton[i].LocalBasis=chan0.GetRotation( time0 )
				Endif
			Endif

			If chan0?.ScaleKeys
				If chan1?.ScaleKeys
					_skeleton[i].LocalScale=chan0.GetScale( time0 ).Blend( chan1.GetScale( time1 ),alpha )
				Else
					_skeleton[i].LocalScale=chan0.GetScale( time0 )
				Endif
			Endif

			#rem
			
			If playing0 And playing1
				
				Local pos0:=chan0 ? chan0.GetPosition( time0 ) Else New Vec3f
				Local rot0:=chan0 ? chan0.GetRotation( time0 ) Else New Quatf
				Local scl0:=chan0 ? chan0.GetScale( time0 ) Else New Vec3f( 1 )
				
				Local pos1:=chan1 ? chan1.GetPosition( time1 ) Else New Vec3f
				Local rot1:=chan1 ? chan1.GetRotation( time1 ) Else New Quatf
				Local scl1:=chan1 ? chan1.GetScale( time1 ) Else New Vec3f( 1 )

				_skeleton[i].LocalPosition=pos0.Blend( pos1,alpha )
				_skeleton[i].LocalBasis=rot0.Slerp( rot1,alpha )
				_skeleton[i].LocalScale=scl0.Blend( scl1,alpha )
			
			Else If playing0
				
				Local pos0:=chan0 ? chan0.GetPosition( time0 ) Else New Vec3f
				Local rot0:=chan0 ? chan0.GetRotation( time0 ) Else New Quatf
				Local scl0:=chan0 ? chan0.GetScale( time0 ) Else New Vec3f( 1 )
			
				_skeleton[i].LocalPosition=pos0
				_skeleton[i].LocalBasis=rot0
				_skeleton[i].LocalScale=scl0

			Else If playing1

				Local pos1:=chan1 ? chan1.GetPosition( time1 ) Else New Vec3f
				Local rot1:=chan1 ? chan1.GetRotation( time1 ) Else New Quatf
				Local scl1:=chan1 ? chan1.GetScale( time1 ) Else New Vec3f( 1 )

				_skeleton[i].LocalPosition=pos1
				_skeleton[i].LocalBasis=rot1
				_skeleton[i].LocalScale=scl1
			
			Endif
			
			#end
		
		Next
	End

End
