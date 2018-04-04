
Namespace mojo3d

#rem monkeydoc @hidden
#end
Alias PositionKey:AnimationKey<Vec3f>

#rem monkeydoc @hidden
#end
Alias RotationKey:AnimationKey<Quatf>

#rem monkeydoc @hidden
#end
Alias ScaleKey:AnimationKey<Vec3f>

Enum AnimationMode
	
	OneShot=1
	Looping
	PingPoong
End

#rem monkeydoc @hidden
#end
Class Animation
	
	Method New( name:String,channels:AnimationChannel[],duration:Float,hertz:Float,mode:AnimationMode )
		_name=name
		_channels=channels
		_duration=duration
		_hertz=hertz ?Else 24
		_mode=mode
	End
	
	#rem monkeydoc Animation name.
	#end
	Property Name:String()
		
		Return _name
	End
	
	#rem monkeydoc Animation channels. 
	
	There is a channel for each bone in the animation's skeleton.
	
	#end
	Property Channels:AnimationChannel[]()
		
		Return _channels
	End
	
	#rem monkeydoc Duration.
	
	The duration of the animation in seconds
	
	#end
	Property Duration:Float()
		
		Return _duration
	End
	
	#rem monkeydoc Hertz.
	
	The frequency of the animation in seconds
	
	#end
	Property Hertz:Float()
		
		Return _hertz
	End
	
	#rem monkeydoc Animation mode.
	#end
	Property Mode:AnimationMode()
		
		Return _mode
	End
	
	Method Slice:Animation( name:String,begin:Float,term:Float,mode:AnimationMode )
		
		Local channels:=_channels.Slice( 0 )
		
		Local duration:=term-begin
		
		For Local i:=0 Until _channels.Length
			
			Local channel:=_channels[i]
			If Not channel Continue

			Local posKeys:=New Stack<PositionKey>
			posKeys.Add( New PositionKey( 0,channel.GetPosition( begin ) ) )
			For Local key:=Eachin channel.PositionKeys
				If key.Time>=term Exit
				If key.Time>begin posKeys.Add( New PositionKey( key.Time-begin,key.Value ) )
			Next
			posKeys.Add( New PositionKey( duration,channel.GetPosition( term ) ) )
			
			Local rotKeys:=New Stack<RotationKey>
			rotKeys.Add( New RotationKey( 0,channel.GetRotation( begin ) ) )			
			For Local key:=Eachin channel.RotationKeys
				If key.Time>=term Exit
				If key.Time>begin rotKeys.Add( New RotationKey( key.Time-begin,key.Value ) )
			Next
			rotKeys.Add( New RotationKey( duration,channel.GetRotation( term ) ) )
			
			Local sclKeys:=New Stack<ScaleKey>
			sclKeys.Add( New ScaleKey( 0,channel.GetScale( begin ) ) )
			For Local key:=Eachin channel.ScaleKeys
				If key.Time>=term Exit
				If key.Time>begin sclKeys.Add( New ScaleKey( key.Time-begin,key.Value ) )
			Next
			sclKeys.Add( New ScaleKey( duration,channel.GetScale( term ) ) )
			
			channels[i]=New AnimationChannel( posKeys.ToArray(),rotKeys.ToArray(),sclKeys.ToArray() )
		Next
		
		Local animation:=New Animation( name,channels,duration,_hertz,mode )
		
		Return animation
	End
	
	Function Load:Animation( path:String )
		
		For Local loader:=Eachin Mojo3dLoader.Instances
		
			Local animation:=loader.LoadAnimation( path )
			
			If animation Return animation
		Next
		
		Return Null
	End
	
	Private
	
	Field _name:String		
	Field _channels:AnimationChannel[]
	Field _duration:Float
	Field _hertz:Float
	Field _mode:AnimationMode
End

#rem monkeydoc @hidden
#end
Class AnimationChannel
	
	Method New( posKeys:PositionKey[],rotKeys:RotationKey[],sclKeys:ScaleKey[] )
		
		_posKeys=posKeys
		_rotKeys=rotKeys
		_sclKeys=sclKeys
	End
	
	Property PositionKeys:PositionKey[]()
		
		Return _posKeys
	End
	
	Property RotationKeys:RotationKey[]()
		
		Return _rotKeys
	End
	
	Property ScaleKeys:ScaleKey[]()
	
		Return _sclKeys
	End
	
	Method GetPosition:Vec3f( time:Float )
		
		If Not _posKeys Return New Vec3f( 0 )
		
		Return GetKey( _posKeys,time )
	End
	
	Method GetRotation:Quatf( time:Float )
		
		If Not _rotKeys Return New Quatf( 0,0,0,1 )
		
		Return GetKey( _rotKeys,time )
	End
	
	Method GetScale:Vec3f( time:Float )
		
		If Not _sclKeys Return New Vec3f( 1 )
		
		Return GetKey( _sclKeys,time )
	End
	
	Method GetMatrix:AffineMat4f( time:Float )
		
		Local pos:=GetPosition( time )
		Local rot:=GetRotation( time )
		Local scl:=GetScale( time )
		
		Return New AffineMat4f( Mat3f.Rotation( rot ).Scale( scl ),pos )
	End
	
	Private
	
	Field _posKeys:PositionKey[]
	Field _rotKeys:RotationKey[]
	Field _sclKeys:ScaleKey[]
	
	Method Blend:Vec3f( a:Vec3f,b:Vec3f,alpha:Float )
		
		Return a.Blend( b,alpha )
	End
	
	Method Blend:Quatf( a:Quatf,b:Quatf,alpha:Float )
		
		Return a.Slerp( b,alpha )
	End
	
	Method GetKey<T>:T( keys:AnimationKey<T>[],time:Float )
		
		DebugAssert( keys )
		
		Local pkey:AnimationKey<T>
		
		For Local key:=Eachin keys
			
			If time<=key.Time
				
				If pkey Return Blend( pkey.Value,key.Value,(time-pkey.Time)/(key.Time-pkey.Time) )
				
				Return key.Value
				
			Endif
			
			pkey=key
		End
		
		Return pkey.Value
	End

End

#rem monkeydoc @hidden
#end
Class AnimationKey<T>
	
	Method New( time:Float,value:T )
		
		_time=time
		_value=value
	End
	
	Property Time:Float()
		
		Return _time
		
	Setter( time:Float )
			
		_time=time
	End
	
	Property Value:T()
		
		Return _value
	
	Setter( value:T )
		
		_value=value
	End

	Private

	Field _time:float
	Field _value:T
End


