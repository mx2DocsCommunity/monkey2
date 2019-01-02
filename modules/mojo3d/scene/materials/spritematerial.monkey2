
Namespace mojo3d

#rem monkeydoc The SpriteMaterial class.
#end
Class SpriteMaterial Extends Material
	
	#rem monkeydoc Creates a new sprite material.
	#end	
	Method New()
		
		ShaderName="materials/sprite"
		AttribMask=1|4|8
		BlendMode=BlendMode.Alpha
		CullMode=CullMode.None
		
		ColorTexture=Texture.ColorTexture( Color.White )
		ColorFactor=Color.White
		AlphaDiscard=0
		
		AddInstance()
	End
	
	Method New( material:SpriteMaterial )
	
		Super.New( material )
		
		AddInstance( material )
	End
	
	#rem monkeydoc Creates a copy of the sprite material.
	#end
	Method Copy:SpriteMaterial() Override
	
		Return New SpriteMaterial( Self )
	End
	
	[jsonify=1]
	Property ColorTexture:Texture()
		
		Return Uniforms.GetTexture( "ColorTexture" )
	
	Setter( texture:Texture )
		
		Uniforms.SetTexture( "ColorTexture",texture )
	End
	
	[jsonify=1]
	Property ColorFactor:Color()
	
		Return Uniforms.GetColor( "ColorFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "ColorFactor",color )
	End
	
	[jsonify=1]
	Property AlphaDiscard:Float()
		
		Return Uniforms.GetFloat( "AlphaDiscard" )
	
	Setter( discard:Float )
		
		Uniforms.SetFloat( "AlphaDiscard",discard )
	End

	#rem monkeydoc Loads a sprite material from an image file.
	#end	
	Function Load:SpriteMaterial( path:String,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local scene:=Scene.GetCurrent(),editing:=scene.Editing
		
		If editing scene.Jsonifier.BeginLoading()
		
		Local texture:=LoadTexture( path,textureFlags )
		'If Not texture texture=Texture.ColorTexture( Color.Magenta )
		
		Local material:=New SpriteMaterial
		material.ColorTexture=texture
		
		If editing
			scene.Jsonifier.EndLoading()
			scene.Jsonifier.AddInstance( material,"mojo3d.SpriteMaterial.Load",New Variant[]( path,textureFlags ) )
		Endif
		
		Return material
	End
	
End
