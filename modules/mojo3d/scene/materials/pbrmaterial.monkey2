
Namespace mojo3d

#rem monkeydoc The PbrMaterial class.
#end
Class PbrMaterial Extends Material
	
	#rem monkeydoc Creates a new pbr material.
	
	All properties default to white or '1' except for emissive factor which defaults to black. 
	
	If you set an emissive texture, you will also need to set emissive factor to white to 'enable' it.
	
	The metalness value should be stored in the 'blue' channel of the metalness texture if the texture has multiple color channels.
	
	The roughness value should be stored in the 'green' channel of the metalness texture if the texture has multiple color channels.
	
	The occlusion value should be stored in the 'red' channel of the occlusion texture if the texture has multiple color channels.
	
	The above last 3 rules allow you to pack metalness, roughness and occlusion into a single texture.
	
	#end
	Method New()
		
		Init()
		
		AddInstance()
	End
	
	Method New( color:Color,metalness:Float=1.0,roughness:Float=1.0 )
		
		Init()
		
		ColorFactor=color
		MetalnessFactor=metalness
		RoughnessFactor=roughness
		
		AddInstance( New Variant[]( color,metalness,roughness ) )
	End
	
	Method New( material:PbrMaterial )
		
		Super.New( material )
		
		AddInstance( material )
	End
	
	#rem monkeydoc Creates a copy of the pbr material.
	#end
	Method Copy:PbrMaterial() Override
	
		Return New PbrMaterial( Self )
	End
	
	'***** textures *****
	
	[jsonify=1]
	Property Boned:Bool()
		
		Return (AttribMask & 192)=192
		
	Setter( boned:Bool )
		
		If boned AttribMask|=192 Else AttribMask&=~192
	End
	
	[jsonify=1]
	Property ColorTexture:Texture()
	
		Return Uniforms.GetTexture( "ColorTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "ColorTexture",texture )
		
		UpdateAttribMask()
	End
	
	[jsonify=1]
	Property AmbientTexture:Texture()
		
		Return Uniforms.GetTexture( "AmbientTexture" )
	
	Setter( texture:Texture )
		
		Uniforms.SetTexture( "AmbientTexture",texture )

		UpdateAttribMask()
	End
	
	[jsonify=1]
	Property EmissiveTexture:Texture()
	
		Return Uniforms.GetTexture( "EmissiveTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "EmissiveTexture",texture )
		
		UpdateAttribMask()
	End
	
	[jsonify=1]
	Property MetalnessTexture:Texture()
	
		Return Uniforms.GetTexture( "MetalnessTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "MetalnessTexture",texture )
		
		UpdateAttribMask()
	End

	[jsonify=1]
	Property RoughnessTexture:Texture()
	
		Return Uniforms.GetTexture( "RoughnessTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "RoughnessTexture",texture )
		
		UpdateAttribMask()
	End
	
	[jsonify=1]
	Property OcclusionTexture:Texture()
	
		Return Uniforms.GetTexture( "OcclusionTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "OcclusionTexture",texture )
		
		UpdateAttribMask()
	End
	
	[jsonify=1]
	Property NormalTexture:Texture()
	
		Return Uniforms.GetTexture( "NormalTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "NormalTexture",texture )
		
		If texture AttribMask|=32 Else AttribMask&=~32
			
		UpdateAttribMask()
	End
	
	'***** factors *****
	[jsonify=1]
	Property ColorFactor:Color()
	
		Return Uniforms.GetColor( "ColorFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "ColorFactor",color )
	End
	
	[jsonify=1]
	Property AmbientFactor:Color()
	
		Return Uniforms.GetColor( "AmbientFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "AmbientFactor",color )
	End
	
	[jsonify=1]
	Property EmissiveFactor:Color()
	
		Return Uniforms.GetColor( "EmissiveFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "EmissiveFactor",color )
	End
	
	[jsonify=1]
	Property MetalnessFactor:Float()
	
		Return Uniforms.GetFloat( "MetalnessFactor" )
		
	Setter( factor:Float )

		Uniforms.SetFloat( "MetalnessFactor",factor )
	End
	
	[jsonify=1]
	Property RoughnessFactor:Float()
	
		Return Uniforms.GetFloat( "RoughnessFactor" )
		
	Setter( factor:Float )
	
		Uniforms.SetFloat( "RoughnessFactor",factor )
	End
	
	#rem monkeydoc Loads a PbrMaterial from a 'file'.
	
	A .pbr file is actually a directory containing a number of textures in png format. These textures are:
	
	color.png (required)
	emissive.png
	metalness.png
	roughness.png
	occlusion.png
	normal.png
	
	#end
	Function Load:PbrMaterial( path:String,textureFlags:TextureFlags=TextureFlags.WrapST|TextureFlags.FilterMipmap )
		
		Local scene:=Scene.GetCurrent(),editing:=scene.Editing
		
		If editing 
			scene.Jsonifier.BeginLoading()
		Endif

		Local material:=New PbrMaterial
		
		Local texture:=scene.LoadTexture( path,textureFlags )
		If texture
			material.ColorTexture=texture
			Return material
		Endif
		
		texture=LoadTexture( path,"color",textureFlags )
		If texture
			material.ColorTexture=texture
		Endif
		
		texture=LoadTexture( path,"emissive",textureFlags )
		If texture
			material.EmissiveTexture=texture
			material.EmissiveFactor=Color.White
		Endif
		
		texture=LoadTexture( path,"metalness",textureFlags )
		If texture
			material.MetalnessTexture=texture
		Endif
		
		texture=LoadTexture( path,"roughness",textureFlags )
		If texture
			material.RoughnessTexture=texture
		Endif
		
		texture=LoadTexture( path,"occlusion",textureFlags )
		If texture
			material.OcclusionTexture=texture
		Endif
		
		texture=LoadTexture( path,"normal",textureFlags )
		If Not texture texture=LoadTexture( path,"unormal",textureFlags,True )
		If texture
			material.NormalTexture=texture
		Endif
		
		Local jobj:=JsonObject.Load( path+"/material.json" )
		If jobj
			If jobj.Contains( "colorFactor" ) material.ColorFactor=jobj.GetColor( "colorFactor" )
			If jobj.Contains( "emissiveFactor" ) material.EmissiveFactor=jobj.GetColor( "emissiveFactor" )
			If jobj.Contains( "metalnessFactor" ) material.MetalnessFactor=jobj.GetNumber( "metalnessFactor" )
			If jobj.Contains( "roughnessFactor" ) material.RoughnessFactor=jobj.GetNumber( "roughnessFactor" )
		Endif
		
		If editing 
			scene.Jsonifier.EndLoading()
			scene.Jsonifier.AddInstance( material,"mojo3d.PbrMaterial.Load",New Variant[]( path,textureFlags ) )
		Endif
		
		Return material
	End
	
	Private
	
	Field _boned:Bool
	
	Method Init()
		
		Uniforms.DefaultTexture=Texture.ColorTexture( Color.White )
		
		ShaderName="materials/pbr-default"
		AttribMask=1|2|4
		
		ColorTexture=Null
		AmbientTexture=Null
		EmissiveTexture=Null
		MetalnessTexture=Null
		RoughnessTexture=Null
		OcclusionTexture=Null
		NormalTexture=Null
		
		ColorFactor=Color.White
		AmbientFactor=Color.Black
		EmissiveFactor=Color.Black
		MetalnessFactor=1.0
		RoughnessFactor=1.0
	End
	
	Method UpdateAttribMask()
		
		If Uniforms.NumTextures<>0 AttribMask|=24 Else AttribMask&=~24
	End
	
End

Private

Function MakeColor:Color( jobj:JsonObject )
	
	Local r:=jobj.Contains( "r" ) ? jobj.GetNumber( "r" ) Else 1.0
	Local g:=jobj.Contains( "g" ) ? jobj.GetNumber( "g" ) Else 1.0
	Local b:=jobj.Contains( "b" ) ? jobj.GetNumber( "b" ) Else 1.0
	Local a:=jobj.Contains( "a" ) ? jobj.GetNumber( "a" ) Else 1.0
	
	Return New Color( r,g,b,a )
End

Class JsonObject Extension

	Method GetColor:Color( key:String )
		
		Local jobj:=GetObject( key )
		If Not jobj Return Color.White
		
		Return MakeColor( jobj )
	End
End

