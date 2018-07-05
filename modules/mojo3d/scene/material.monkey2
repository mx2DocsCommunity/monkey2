
Namespace mojo3d

#rem monkeydoc The Material class.
#end
Class Material Extends Resource
	
	enum Attrib
		Position=1
		Normal=2
		Color=4
		TexCoord0=8
		TexCoord1=16
		Tangent=32
		Weights=64
		Bones=128
	End
		
	
	#rem monkeydoc Creates a copy of the material.
	#end
	Method Copy:Material() abstract
	
	#rem monkeydoc Material name.
	#end
	Property Name:String()
		
		Return _name
	
	Setter( name:String )
		
		_name=name
	End
	
	Property ShaderName:String()
		
		Return _shaderName
	
	Setter( name:String )
		
		If name=_shaderName Return
		
		_shaderName=name
		
		Invalidate()
	End
	
	Property AttribMask:Int()
		
		Return _attribMask

	Setter( mask:Int )
		
		If mask=_attribMask Return
		
		_attribMask=mask
		
		Invalidate()
	End
	
	Property SelfIlluminated:Bool()
		
		Return _selfillum
	
	Setter( selfillum:Bool )
		
		If selfillum=_selfillum Return
		
		_selfillum=selfillum
	End
	
	#Rem monkeydoc The material blendmode.
	#End
	Property BlendMode:BlendMode()
		
		Return _blendMode
	
	Setter( mode:BlendMode )
		
		_blendMode=mode
	End
	
	#Rem monkeydoc The material cullmode.
	#End
	Property CullMode:CullMode()
		
		Return _cullMode
	
	Setter( mode:CullMode )
		
		_cullMode=mode
	End
	
	#rem monkeydoc The material texture matrix.
	#end
	Property TextureMatrix:AffineMat3f()
		
		Return Uniforms.GetAffineMat3f( "TextureMatrix" )
		
	Setter( matrix:AffineMat3f )
		
		Uniforms.SetAffineMat3f( "TextureMatrix",matrix )
	End
	
	#rem monkeydoc Translates the texture matrix.
	#end
	Method TranslateTextureMatrix( tv:Vec2f )
		
		TextureMatrix=TextureMatrix.Translate( tv )
	End
	
	Method TranslateTextureMatrix( tx:Float,ty:Float )
		
		TextureMatrix=TextureMatrix.Translate( tx,ty )
	End

	#rem monkeydoc Rotates the texture matrix.
	#end
	Method RotateTextureMatrix( angle:Float )
		
		TextureMatrix=TextureMatrix.Rotate( angle )
	End
		
	#rem monkeydoc Scales the texture matrix.
	#end
	Method ScaleTextureMatrix( sv:Vec2f )
		
		TextureMatrix=TextureMatrix.Scale( sv )
	End
	
	Method ScaleTextureMatrix( sx:Float,sy:Float )
		
		TextureMatrix=TextureMatrix.Scale( sx,sy )
	End
	
	#Rem monkeydoc @hidden The material uniforms.
	
	TODO: Should really be protected...

	#End
	Property Uniforms:UniformBlock()
	
		Return _uniforms
	End

	#rem monkeydoc Gets material's shader for rendering.
	#end
	Method GetRenderShader:Shader()
		
		Validate()
		
		Return _shader
	End
	
	Function LoadTexture:Texture( path:String,textureFlags:TextureFlags,flipy:Bool=False )
		
		Local scene:=Scene.GetCurrent()
		
		Return scene.LoadTexture( path,textureFlags,flipy )
	End
	
	Function LoadTexture:Texture( path:String,name:String,textureFlags:TextureFlags,flipy:Bool=False )
		
		Local scene:=Scene.GetCurrent()
		
		Local texture:=scene.LoadTexture( path+"/"+name+".png",textureFlags,flipy )
		
		If Not texture texture=scene.LoadTexture( path+"/"+name+".jpg",textureFlags,flipy )
			
		Return texture
	End
	
	Protected
	
	Method OnValidate() Virtual
	End
	
	Method Invalidate()
		
		_shader=Null
	End
	
	Method New()

		_name="Material"
		_attribMask=1
		_blendMode=BlendMode.Opaque
		_cullMode=CullMode.Back
		_selfillum=False

		_uniforms=New UniformBlock( 3,True )
		
		TextureMatrix=New AffineMat3f
	End		
	
	Method New( material:Material )
		
		_name=material._name
		_shaderName=material._shaderName
		_attribMask=material._attribMask
		_blendMode=material._blendMode
		_cullMode=material._cullMode
		_selfillum=material._selfillum
		_shader=material._shader
		_dirty=material._dirty

		_uniforms=New UniformBlock( material._uniforms )

		TextureMatrix=material.TextureMatrix
	End
	
	Method AddInstance()

		Local scene:=Scene.GetCurrent()
		
		If scene.Editing scene.Jsonifier.AddInstance( Self,New Variant[0] )
	End
	
	Method AddInstance( args:Variant[] )
		
		Local scene:=Scene.GetCurrent()
		
		If scene.Editing scene.Jsonifier.AddInstance( Self,args )
	End
	
	Method AddInstance( material:Material )
		
		Local scene:=Scene.GetCurrent()
		
		If scene.Editing scene.Jsonifier.AddInstance( Self,New Variant[]( material ) )
	End
	
	Private

	Field _name:String
	Field _shaderName:String
	Field _attribMask:Int
	Field _selfillum:Bool
	Field _cullMode:CullMode
	Field _blendMode:BlendMode
	Field _uniforms:UniformBlock
	Field _shader:Shader
	Field _dirty:Bool=True
	
	Method Validate()
		
		If _shader Return

		Local defs:=Renderer.GetCurrent().ShaderDefs
		
		defs+=";MX2_ATTRIBMASK "+_attribMask
		
		Local shaderName:=_shaderName ?Else "materials/default"
			
		_shader=mojo.graphics.Shader.Open( shaderName,defs )
	End
	
End
