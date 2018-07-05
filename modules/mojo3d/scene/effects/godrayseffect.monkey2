
Namespace mojo3d

#rem monkeydoc The MonochromeEffect class.
#end
Class GodraysEffect Extends PostEffect

	#rem monkeydoc Creates a new monochrome effect shader.
	#end
	Method New( light:Light=Null )
		
		_shader=Shader.Open( "effects/godrays" )
		
		_uniforms=New UniformBlock( 3 )
		
		Light=light
		NumSamples=100
		Exposure=.0034
		Decay=1.0
		Density=0.84
		Color=Color.White
		Weight=1
	End
	
	Property Light:Light()
		
		Return _light
	
	Setter( light:Light )
		
		_light=light
	End
	
	Property NumSamples:Int()
		
		Return _uniforms.GetInt( "NumSamples" )
	
	Setter( samples:Int )
		
		_uniforms.SetInt( "NumSamples",samples )
	End
	
	Property Exposure:Float()
		
		Return _uniforms.GetFloat( "Exposure" )
		
	Setter( exposure:Float )
		
		_uniforms.SetFloat( "Exposure",exposure )
	End
	
	Property Decay:Float()
		
		Return _uniforms.GetFloat( "Decay" )
		
	Setter( decay:Float )
		
		_uniforms.SetFloat( "Decay",decay )
	End
	
	Property Density:Float()
		
		Return _uniforms.GetFloat( "Density" )
		
	Setter( density:Float )
		
		_uniforms.SetFloat( "Density",density )
	End
	
	Property Color:Color()
		
		Return _uniforms.GetColor( "Color" )
	
	Setter( color:Color )
		
		_uniforms.SetColor( "Color",color )
	End
	
	Property Weight:Float()
		
		Return _uniforms.GetFloat( "Weight" )
	
	Setter( weight:Float )
		
		_uniforms.SetFloat( "Weight",weight )
	End
	
	Protected
	
	Method OnRender( target:RenderTarget,viewport:Recti ) Override
		
		If Not _light Return
		
		'computer light pos in buffer coords
		Local viewProj:=Uniforms.GetMat4f( "ViewProjectionMatrix" )

		Local lightClipPos:=viewProj * New Vec4f( -_light.Basis.k,0 )	'clip
		
		If lightClipPos.w<=0 return
		
'		If lightClipPos.x<-lightClipPos.w Or lightClipPos.x>lightClipPos.w Return
'		If lightClipPos.y<-lightClipPos.w Or lightClipPos.y>lightClipPos.w Return
		If lightClipPos.z<-lightClipPos.w Return 'Or lightClipPos.z>lightClipPos.w Return
		
		Local lightPos:=lightClipPos.XY/lightClipPos.w * 0.5 + 0.5		'NDC
		
		Local bcscale:=Uniforms.GetVec2f( "BufferCoordScale" )
		
'		Print "SourceBufferSize="+SourceBufferSize+" SourceBufferScale="+SourceBufferScale
		
		lightPos*=bcscale
		
		'set effect uniforms
		_uniforms.SetVec2f( "LightPosBufferCoords",lightPos )
		
		'render!
		#rem
		Local size:=viewport.Size
		Local source:=target.GetColorTexture( 0 )
		
		If Not _target Or size.x>_target.Size.x Or size.y>_target.Size.y
			_target=CreateRenderTarget( size,source.Format,TextureFlags.Dynamic )
		End
		
		Super.SetRenderTarget( _target,New Recti( 0,0,size ) )
		#end

		Device.Shader=_shader
		Device.BindUniformBlock( _uniforms )
		
		Device.BlendMode=BlendMode.Additive
		
		RenderQuad()
	End
	
	Private
	
	Field _light:Light
	Field _color:Color
	Field _weight:Float
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _target:RenderTarget
	
End
