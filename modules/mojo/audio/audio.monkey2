
#rem monkeydoc

Highly experimental audio module!

#end
Namespace mojo.audio

#Import "native/bbmusic.cpp"

#Import "native/bbmusic.h"

Extern Private

Function playMusic:Int( file:libc.FILE ptr,callback:Int,source:Int )="bbMusic::playMusic"
Function getBuffersProcessed:Int( source:Int )="bbMusic::getBuffersProcessed"
Function endMusic:Void( source:Int )="bbMusic::endMusic"
	
Private

Const MUSIC_BUFFER_MS:=100
Const MUSIC_BUFFER_SECS:=0.1

Function ALFormat:ALenum( format:AudioFormat )
	Local alFormat:ALenum
	Select format
	Case AudioFormat.Mono8
		alFormat=AL_FORMAT_MONO8
	Case AudioFormat.Mono16
		alFormat=AL_FORMAT_MONO16
	Case AudioFormat.Stereo8
		alFormat=AL_FORMAT_STEREO8
	Case AudioFormat.Stereo16
		alFormat=AL_FORMAT_STEREO16
	End
	Return alFormat
End

Public

#rem monkeydoc Global instance of the AudioDevice class.
#end
Const Audio:=New AudioDevice

#rem monkeydoc The AudioDevice class.

An instance of the AudioDevice class is automatically created when an [[AppInstance]] is created, and can be accessed via the global [[Audio]] const.

#end
Class AudioDevice
	
	#rem monkeydoc Starts streaming audio playback.
	
	PlayMusic starts a piece of audio streaming from a file in the background.

	When the audio finishes, the optional `finished` function is invoked.
	
	The returned [[Channel]] instance is automatically discarded when the audio stops, so should not be discarded by your code.
	
	The audio file must be in .ogg format.
	
	#end
	Method PlayMusic:Channel( path:String,finished:Void()=Null,paused:Bool=False )

		'DO NOT use AutoDiscard here or music wont receive 'stop' signal!
		'		
		Local channel:=New Channel( ChannelFlags.Music )
		
		Local callback:=async.CreateAsyncCallback( Lambda()
			channel.Discard()
			endMusic( channel._alSource )
			finished()
		End,True )
		
		Local file:=filesystem.OpenCFile( path,"r" )
		
		Local sampleRate:=playMusic( file,callback,channel._alSource )
	
		If Not sampleRate
			async.DestroyAsyncCallback( callback )
			Return Null
		Endif
		
		channel._sampleRate=sampleRate
		
		Return channel
	End

	Internal
	
	Method Init()
	
		Local error:=""

		_alcDevice=alcOpenDevice( Null )
		If _alcDevice
			_alcContext=alcCreateContext( _alcDevice,Null )
			If _alcContext
				If alcMakeContextCurrent( _alcContext )
					Return
				Else
					error="Failed to make OpenAL current"
				Endif
			Else
				error="Failed to create OpenAL context"
			Endif
		Else
			error="Failed to create OpenAL device"
		Endif

	End
	
	Private
	
	Field _alcDevice:ALCdevice Ptr
	Field _alcContext:ALCcontext Ptr
	Field _error:String
	
End

#rem monkeydoc The Sound class.
#end
Class Sound Extends Resource

	#rem monkeydoc Creates a new sound.
	#end
	Method New( data:AudioData )
		
		alGenBuffers( 1,Varptr _alBuffer )
		alBufferData( _alBuffer,ALFormat( data.Format ),data.Data,data.Size,data.Hertz )
		_format=data.Format
		_length=data.Length
		_hertz=data.Hertz
	End
	
	#rem monkeydoc The length, in samples, of the sound.
	#end
	Property Length:Int()
		
		Return _length
	End
	
	#rem monkeydoc The format of the sound.
	#end
	Property Format:AudioFormat()
		
		Return _format
	End
	
	#rem monkeydoc The playback rate of the sound.
	#end
	Property Hertz:Int()
		
		Return _hertz
	End
	
	#rem monkeydoc The duration, in seconds, of the sound.
	#end
	Property Duration:Double()
		
		Return Double(_length)/Double(_hertz)
	End
	
	#rem monkeydoc Plays a sound through a temporary channel.
	
	The returned channel will be automatically discarded when it finishes playing or is stopped with [[Channel.Stop]].
	
	#end
	Method Play:Channel( loop:Bool=False )
	
		Local channel:=New Channel( ChannelFlags.AutoDiscard )
		
		channel.Play( Self,loop )
		
		Return channel
	End
	
	#rem monkeydoc Loads a sound.
	#end
	Function Load:Sound( path:String )
	
		Local data:=AudioData.Load( path )
		If Not data Return Null
		
		Local sound:=New Sound( data )

		data.Discard()
		Return sound
	End
	
	Protected
	
	Method OnDiscard() Override
		
		If _alBuffer alDeleteBuffers( 1,Varptr _alBuffer )
			
		_alBuffer=0
	End
	
	Method OnFinalize() Override
		
		If _alBuffer alDeleteBuffers( 1,Varptr _alBuffer )
	End
	
	Private
	
	Field _alBuffer:ALuint
	Field _format:AudioFormat
	Field _length:Int
	Field _hertz:Int

End

#rem monkeydoc ChannelFlags enum.

| Flag			| Description
|:--------------|:-----------
| `AutoDiscard`	| Channel will be automatically discarded when it finishes playing, or when it is stopped using [[Channel.Stop]].

#end
Enum ChannelFlags
	
	AutoDiscard=1
	Music=2
End

Class Channel Extends Resource

	#rem monkeydoc Creates a new audio channel.
	
	If `flags` is ChannelFlags.AutoDiscard, then the channel will be automatically discarded when it finishes playing, or when it is
	stopped using [[Stop]].
	
	#end
	Method New( flags:ChannelFlags=Null )
	
		_flags=flags
	
		FlushAutoDiscard()
		
		alGenSources( 1,Varptr _alSource )
		
		If _flags & ChannelFlags.AutoDiscard _autoDiscard.Push( Self )
	End
	
	Property Flags:ChannelFlags()
	
		Return _flags
	End
	
	#rem monkeydoc True if channel is playing audio.
	
	If the channel is playing audio but is in the paused state, this property will still return true.

	#end
	Property Playing:Bool()
		If Not _alSource Return False
		
		Local state:=ALState()
		Return state=AL_PLAYING Or state=AL_PAUSED
	End
	
	#rem monkeydoc True if channel is paused.
	#end
	Property Paused:Bool()
		If Not _alSource Return False
		
		Return ALState()=AL_PAUSED
		
	Setter( paused:Bool )
		If Not Playing Return
		
		If paused
			alSourcePause( _alSource )
		Else
			alSourcePlay( _alSource )
		Endif
	End
	
	#rem monkeydoc Channel volume in the range 0 to 1.
	#end
	Property Volume:Float()
		If Not _alSource Return 0
	
		Return _volume
		
	Setter( volume:Float )
		If Not _alSource Return
		
		_volume=Clamp( volume,0.0,1.0 )
		alSourcef( _alSource,AL_GAIN,_volume )
	End
	
	#rem monkeydoc Channel playback rate.
	#end	
	Property Rate:Float()
		If Not _alSource Return 0

		Return _rate
		
	Setter( rate:Float )
		If Not _alSource Return
		
		_rate=rate
		alSourcef( _alSource,AL_PITCH,_rate )
	End
	
	#rem monkeydoc Channel pan in the range -1 (left) to 1 (right).
	#end	
	Property Pan:Float()
		If Not _alSource Return 0
	
		Return _pan
		
	Setter( pan:Float)
		If Not _alSource Return
		
		_pan=Clamp( pan,-1.0,1.0 )
		Local x:=Sin( _pan ),z:=-Cos( _pan )
		alSource3f( _alSource,AL_POSITION,x,0,z )
	End
	
	#rem monkeydoc Channel playhead sample offset.
	
	Gets or sets the sample offset of the sound currently playing.
	
	If the channel is playing when set, playback is immediately affected.
	
	If the channel is not playing when set, the offset will be applied when the Play method is invoked.
		
	#end
	Property PlayheadSample:Int()
		If Not _alSource Return 0
		
		Local sample:Int
		alGetSourcei( _alSource,AL_SAMPLE_OFFSET,Varptr sample )
		
		If _flags & ChannelFlags.Music
			
			Local samplesPerBuffer:=MUSIC_BUFFER_MS * _sampleRate / 1000
			
			Local buffersProcessed:=getBuffersProcessed( _alSource )
			
			sample+=samplesPerBuffer * buffersProcessed
			
			If sample<_sample
'				Print "Sample catch up:"+sample+"->"+_sample
				While sample<_sample
					sample+=samplesPerBuffer
				Wend
			Else
				_sample=sample
			Endif
		Endif
		
		Return sample
				
	Setter( sample:Int )
		If Not _alSource Return
		
		alSourcei( _alSource,AL_SAMPLE_OFFSET,sample )
	End
	
	#rem monkeydoc Channel playhead time offset.

	Gets or sets the time offset of the sound currently playing.
	
	If the channel is playing when set, playback is immediately affected.
	
	If the channel is not playing when set, the offset will be applied when the Play method is invoked.
		
	#end
	Property PlayheadTime:Float()
		If Not _alSource Return 0

		Local time:Float		
		alGetSourcef( _alSource,AL_SEC_OFFSET,Varptr time )
		
		If _flags & ChannelFlags.Music
			
			Local buffersProcessed:=getBuffersProcessed( _alSource )
			
			time+=MUSIC_BUFFER_SECS * buffersProcessed
			
			If time<_time
'				Print "Time catchup: "+time+"->"+_time
				While time<_time
					time+=MUSIC_BUFFER_SECS
				Wend
			Else
				_time=time
			Endif
		Endif
		
		Return time
		
	Setter( time:Float )
		If Not _alSource Return
		
		alSourcef( _alSource,AL_SEC_OFFSET,time )
	End
	
	#rem monkeydoc Plays a sound through the channel.
	#end
	Method Play( sound:Sound,loop:Bool=False )
		If Not _alSource Or Not sound Or Not sound._alBuffer Return
		
		alSourcei( _alSource,AL_LOOPING,loop ? AL_TRUE Else AL_FALSE )
		
		alSourcei( _alSource,AL_BUFFER,sound._alBuffer )
		
		alSourcePlay( _alSource )
	End

	#if __TARGET__<>"emscripten"

	#rem monkeydoc @hidden - Highly experimental!!!!!
	#end
	Method WaitQueued( queued:Int )
	
		While _queued>queued
		
			FlushProcessed()
			
			If _queued<=queued Return
		
			_waiting=True
			
			_future.Get()
		
		Wend

	End
	
	#rem monkeydoc @hidden - Highly experimental!!!!!
	#end
	Method Queue( data:AudioData )
	
		Local buf:ALuint
		
		If Not _tmpBuffers
		
			_tmpBuffers=New Stack<ALuint>
			_freeBuffers=New Stack<ALuint>
			_future=New Future<Int>
			_waiting=False
			_queued=0
			
			_timer=New Timer( 60,Lambda()
				FlushProcessed()
			End )

		Endif		
		
		If _freeBuffers.Empty
			
			alGenBuffers( 1,Varptr buf )
			_tmpBuffers.Push( buf )
		
		Else
			buf=_freeBuffers.Pop()
		Endif
		
		alBufferData( buf,ALFormat( data.Format ),data.Data,data.Size,data.Hertz )
		
		alSourceQueueBuffers( _alSource,1,Varptr buf )
		_queued+=1
		
		Local state:=ALState()
		If state=AL_INITIAL Or state=AL_STOPPED alSourcePlay( _alSource )
	
	End
	
	#endif
	
	#rem monkeydoc Stops channel.
	#end
	Method Stop()
		If Not _alSource Return

		alSourceStop( _alSource )
		
		If _flags & ChannelFlags.AutoDiscard Discard()
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnDiscard() Override

		If _alSource alDeleteSources( 1,Varptr _alSource )
		
		_alSource=0
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnFinalize() Override

		If _alSource alDeleteSources( 1,Varptr _alSource )
	End

	Private
	
	Field _flags:ChannelFlags
	Field _alSource:ALuint
	Field _volume:Float=1
	Field _rate:Float=1
	Field _pan:Float=0
	
	Field _sampleRate:Int
	
	Field _time:float
	Field _sample:Int
	
	Global _autoDiscard:=New Stack<Channel>
	
	Method ALState:ALenum()
		Local state:ALenum
		alGetSourcei( _alSource,AL_SOURCE_STATE,Varptr state )
		Return state
	End
	
	Function FlushAutoDiscard()
	
		Local put:=0
		
		For Local chan:=Eachin _autoDiscard
			If Not chan._alSource Continue
		
			If chan.ALState()<>AL_STOPPED
				_autoDiscard[put]=chan;put+=1
				Continue
			Endif
			
			chan.Discard()
		Next

		_autoDiscard.Resize( put )
	End
	
	#if __TARGET__<>"emscripten"
	
	Field _tmpBuffers:Stack<ALuint>
	Field _freeBuffers:Stack<ALuint>
	Field _future:Future<Int>
	Field _waiting:Bool
	Field _queued:Int
	Field _timer:Timer
	
	Method FlushProcessed:Int()
	
		Local proc:ALint
		alGetSourcei( _alSource,AL_BUFFERS_PROCESSED,Varptr proc )
		
		If Not proc Return 0
		
		For Local i:=0 Until proc
		
			Local buf:ALuint
			
			alSourceUnqueueBuffers( _alSource,1,Varptr buf )
			_queued-=1
			
			If _tmpBuffers.Contains( buf ) _freeBuffers.Push( buf )
		Next

		If _waiting 
			_waiting=False
			_future.Set( proc )
		Endif
		
		Return proc

	End
	
	#endif
	
End
