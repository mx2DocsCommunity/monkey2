
Namespace mojo3d

#rem monkeydoc The FXAAEffect class.
#end
Class FXAAEffect Extends PostEffect

	#rem monkeydoc Creates a new fxaa effect shader.
	#end
	Method New()
		
		_shader=Shader.Open( "effects/fxaa" )
		
		_uniforms=New UniformBlock( 3 )
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
