
Namespace mojo3d

#rem monkeydoc The ReflectionEffect class.
#end
Class ReflectionEffect Extends PostEffect

	#rem monkeydoc Creates a new monochrome effect shader.
	#end
	Method New()
		
		_shader=Shader.Open( "effects/reflection" )
		
		_uniforms=New UniformBlock( 3 )
	End
	
	Protected
	
	Method OnRender( target:RenderTarget,viewport:Recti ) Override
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
End
