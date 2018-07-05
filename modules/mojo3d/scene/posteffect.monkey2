
Namespace mojo3d

#rem monkeydoc The PostEffect class.
#end
Class PostEffect

	#rem monkeydoc Enabled state.
	
	Set to true to enable this effect and false to disable.
	
	#end
	Property Enabled:Bool()
		
		Return _enabled
	
	Setter( enabled:Bool )
		
		_enabled=enabled
	End
	
	
	#rem monkeydoc @hidden
	#end	
	Method Render()
		
		UpdateSourceUniforms()
		
		OnRender( _gdevice.RenderTarget,_gdevice.Viewport )
	End
	
	Function BeginRendering( gdevice:GraphicsDevice,runiforms:UniformBlock )

		_gdevice=gdevice
		_runiforms=runiforms
	End
	
	Function EndRendering()
		
		_gdevice=Null
		_runiforms=Null
	End

	Protected
	
	#rem monkeydoc @hidden
	#end	
	Method OnRender( target:RenderTarget,viewport:Recti ) Abstract
	
	Property Device:GraphicsDevice()
		
		Return _gdevice
	End
	
	Property Uniforms:UniformBlock()
		
		Return _runiforms
	End
	
	Property SourceBufferSize:Vec2f()
		
		Return _sourceBufferSize
	End
	
	Property SourceBufferScale:Vec2f()
		
		Return _sourceBufferScale
	End
	
	Method CreateRenderTarget:RenderTarget( size:Vec2i,format:PixelFormat,flags:TextureFlags )
		
		Local texture:=New Texture( size.x,size.y,format,flags )
		Local target:=New RenderTarget( New Texture[]( texture ),Null )
		Return target
	End
	
	Method SetRenderTarget( target:RenderTarget,viewport:Recti )
		
		UpdateSourceUniforms()
		
		_gdevice.RenderTarget=target
		_gdevice.Viewport=viewport
	End
	
	Method RenderQuad()

		Global _vertices:VertexBuffer
	
		If Not _vertices
			_vertices=New VertexBuffer( New Vertex3f[](
			New Vertex3f( 0,1,0 ),
			New Vertex3f( 1,1,0 ),
			New Vertex3f( 1,0,0 ),
			New Vertex3f( 0,0,0 ) ) )
		Endif
			
		_gdevice.VertexBuffer=_vertices
		
		_gdevice.Render( 4,1 )
	End
	
	#rem monkeydoc @hidden
	#end	
	Private
	
	Global _gdevice:GraphicsDevice
	Global _runiforms:UniformBlock
	Global _sourceBufferSize:Vec2f
	Global _sourceBufferScale:Vec2f
	
	Field _enabled:Bool=True
	
	Function UpdateSourceUniforms()

		Local rsize:=_gdevice.Viewport.Size
		Local rtarget:=_gdevice.RenderTarget
		Local rtexture:=rtarget.GetColorTexture( 0 )
		
		_sourceBufferSize=Cast<Vec2f>( rtexture.Size )
		_sourceBufferScale=Cast<Vec2f>( rsize )/Cast<Vec2f>( rtexture.Size )
		
		_runiforms.SetTexture( "SourceBuffer",rtexture )
		_runiforms.SetVec2f( "SourceBufferSize",_sourceBufferSize )
		_runiforms.SetVec2f( "SourceBufferScale",_sourceBufferScale )
	End
	
	
End
