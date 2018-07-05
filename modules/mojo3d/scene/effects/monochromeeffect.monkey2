
Namespace mojo3d

#rem monkeydoc The MonochromeEffect class.
#end
Class MonochromeEffect Extends PostEffect

	#rem monkeydoc Creates a new monochrome effect shader.
	#end
	Method New( level:Float=1.0 )
		
		_shader=Shader.Open( "effects/monochrome" )
		
		_uniforms=New UniformBlock( 3 )
		
		Level=level
	End
	
	#rem monkeydoc The effect level.
	
	0=no effect, 1=full effect.
	
	#end
	Property Level:Float()
		
		Return _uniforms.GetFloat( "Level" )
	
	Setter( level:Float )
		
		_uniforms.SetFloat( "Level",level )
	End

	Protected
	
	Method OnRender( target:RenderTarget,viewport:Recti ) Override
		
		Local size:=viewport.Size
		Local source:=target.GetColorTexture( 0 )
		
		If Not _target Or size.x>_target.Size.x Or size.y>_target.Size.y
			_target=CreateRenderTarget( size,source.Format,TextureFlags.Dynamic )
		End
		
		Super.SetRenderTarget( _target,New Recti( 0,0,size ) )

		Device.Shader=_shader
		Device.BindUniformBlock( _uniforms )
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _target:RenderTarget
	
End
