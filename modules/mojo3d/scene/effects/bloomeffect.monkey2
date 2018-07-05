
Namespace mojo3d

#rem The BloomEffect class.

This class implements a 'bloom' post processing effect.

#end
Class BloomEffect Extends PostEffect
	
	#rem monkeydoc Creates a new bloom effect.
	#end
	Method New( passes:Int=1 )
		
		_shader=Shader.Open( "effects/bloom" )
		
		_uniforms=New UniformBlock( 3 )
		
		Passes=passes
	End
	
	#rem monkeydoc The number of passes.
	
	Must be an even number greater than 0.
	
	#end
	Property Passes:Int()
		
		Return _passes
	
	Setter( passes:Int )
		Assert( passes>0,"BloomEffect passes must be >0" )
		
		_passes=passes
	End
	
	Protected
	
	Method OnRender( target:RenderTarget,viewport:Recti ) Override
		
		Local size:=viewport.Size
		Local source:=target.GetColorTexture( 0 )
		
		If Not _target0 Or size.x<>_target0.Size.x Or size.y<>_target0.Size.y
			_target0=CreateRenderTarget( size,source.Format,TextureFlags.Dynamic )
			_target1=CreateRenderTarget( size,source.Format,TextureFlags.Dynamic )
		Endif
		
		Device.Shader=_shader
		Device.BindUniformBlock( _uniforms )
		
		Local rtarget:=_target0
		
		For Local i:=0 Until _passes*2
			
			Super.SetRenderTarget( rtarget,New Recti( 0,0,size ) )
			Device.RenderPass=i ? 2-(i&1) Else 0	'0,1,2,1,2,1,2...
			
			RenderQuad()
			
			rtarget=rtarget=_target0 ? _target1 Else _target0
		Next
		
		Super.SetRenderTarget( target,viewport )
		
		Device.BlendMode=BlendMode.Additive
		Device.RenderPass=3
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _passes:Int=4
	Field _target0:RenderTarget
	Field _target1:RenderTarget
	
End
