
Namespace mojo.graphics

#Import "<freetype>"

Private

Using freetype

Global FreeType:FT_Library

Function FontError()
	RuntimeError( "Font error" )
End

Public

#rem monkeydoc @hidden
#end
Class FreeTypeFont Extends Font
	
	Method GetGlyph:Glyph( char:Int ) Override
		
		Local page:=char Shr 8
		If page<0 Or page>=_pages.Length Return _nullGlyph

		Local gpage:=_pages[page]
		If Not gpage Return _nullGlyph

		If Not gpage.image LoadGlyphPage( page,gpage )
				
		Local index:=char & 255
		If index>=gpage.glyphs.Length Return _nullGlyph
		
		Return gpage.glyphs[index]
	End
	
	Method GetGlyphPage:Image( char:Int ) Override
		
		Local page:=char Shr 8
		If page<0 Or page>=_pages.Length Return Null
		
		Local gpage:=_pages[page]
		If Not gpage Return Null
		
		If Not gpage.image LoadGlyphPage( page,gpage )
				
		Local index:=char & 255
		If index>=gpage.glyphs.Length Return Null
		
		Return gpage.image
	End
	
	Method GetKerning:Float( firstChar:Int,secondChar:Int ) Override
		
		If Not _hasKerning Return 0

		Local firstGlyph:=FT_Get_Char_Index( _face,firstChar )
		Local secondGlyph:=FT_Get_Char_Index( _face,secondChar )
		
		Local delta:FT_Vector
		
		FT_Get_Kerning( _face,firstGlyph,secondGlyph,0,Varptr delta )
		
		Return delta.x Shr 6
	End
	
	Function Load:FreeTypeFont( path:String,height:Float,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
	
		If Not FreeType And FT_Init_FreeType( Varptr FreeType ) Return Null
		
		Local data:=DataBuffer.Load( path )
		If Not data
			If Not ExtractRootDir( path ) data=DataBuffer.Load( "font::"+path )
			If Not data Return Null
		Endif
		
		Local face:FT_Face
		If FT_New_Memory_Face( FreeType,data.Data,data.Length,0,Varptr face )
			data.Discard()
			Return Null
		Endif
		
		If Not shader shader=Shader.Open( "font" )
		
		Local font:=New FreeTypeFont( data,face,height,shader,textureFlags )
		
		Return font
	End
	
	Protected
	
	Method OnDiscard() Override
	
		FT_Done_Face( _face )
		
		_data.Discard()
		
		_data=Null
		_face=Null
	End
	
	Private
	
	Class GlyphPage
		Field image:Image
		Field glyphs:Glyph[]
	End
	
	Field _data:DataBuffer
	Field _face:FT_Face
	Field _shader:Shader
	Field _textureFlags:TextureFlags
	Field _hasKerning:Bool
	
	Field _height:Int
	Field _ascent:Int
	
	Field _pages:GlyphPage[]
	
	Field _nullGlyph:Glyph
	
	Method LoadGlyphPage( page:Int,gpage:GlyphPage )
	
		Const MaxTexWidth:=1024
	
		Local firstChar:=page * 256
		Local numChars:=256
	
		Local slot:=_face->glyph
		
		'Measure atlas first
		'
		'Would really rather not render glyphs here, but can't see how...
		'
		Local tx:=0,ty:=0,texw:=0,texh:=0,maxh:=0
		
		For Local i:=-1 Until numChars
		
			If i<0
				If FT_Load_Char( _face,0,FT_LOAD_RENDER|FT_LOAD_FORCE_AUTOHINT ) FontError()
			Else
				If Not FT_Get_Char_Index( _face,firstChar+i ) Or FT_Load_Char( _face,firstChar+i,FT_LOAD_RENDER|FT_LOAD_FORCE_AUTOHINT ) Continue
			Endif
	
			Local gw:=Int( slot->bitmap.width )
			Local gh:=Int( slot->bitmap.rows )
			
			If tx+gw+1>MaxTexWidth
				texw=Max( texw,tx )
				texh+=maxh
				maxh=0
				tx=0
			Endif
			
			maxh=Max( maxh,gh+1 )
			tx+=gw+1
		Next
		
		texw=Max( texw,tx )
		If tx texh+=maxh
		
		'round up texw, texh to ^2 in case we're mipmapping on mobile/webgl.
		texw=1 Shl Int( Ceil( Log2( texw ) ) )
		texh=1 Shl Int( Ceil( Log2( texh ) ) )
		
		Local pixmap:=New Pixmap( texw,texh,PixelFormat.I8 )
		pixmap.Clear( Color.None )
	
		Local glyphs:=New Glyph[numChars],glyph:Glyph,nullGlyph:Glyph
		
		tx=0;ty=0;maxh=0
		
		For Local i:=-1 Until numChars
		
			If i<0
				If FT_Load_Char( _face,0,FT_LOAD_RENDER|FT_LOAD_FORCE_AUTOHINT ) FontError()
			Else
				If Not FT_Get_Char_Index( _face,firstChar+i ) Or FT_Load_Char( _face,firstChar+i,FT_LOAD_RENDER|FT_LOAD_FORCE_AUTOHINT )
					glyphs[i]=nullGlyph
					Continue
				Endif
			Endif
	
			Local gw:=Int( slot->bitmap.width )
			Local gh:=Int( slot->bitmap.rows )
	
			Local tmp:=New Pixmap( gw,gh,PixelFormat.I8,slot->bitmap.buffer,slot->bitmap.pitch )
			
			If tx+gw+1>pixmap.Width
				ty+=maxh
				maxh=0
				tx=0
			Endif
			
			pixmap.Paste( tmp,tx,ty )
			
			tmp.Discard()
			
			glyph.rect=New Recti( tx,ty,tx+gw,ty+gh )
			glyph.offset=New Vec2f( slot->bitmap_left,_ascent-slot->bitmap_top )
			glyph.advance=slot->advance.x Shr 6
	
			If i>=0 glyphs[i]=glyph Else nullGlyph=glyph
	
			maxh=Max( maxh,gh+1 )
			tx+=gw+1
		Next
		
		gpage.image=New Image( pixmap,_textureFlags,_shader )
		gpage.glyphs=glyphs
		
'		Print "Loading glyph page "+page+", image size="+gpage.image.Rect.Size
	End
	
	Method New( data:DataBuffer,face:FT_Face,fheight:Float,shader:Shader,textureFlags:TextureFlags )
		
		_data=data
		_face=face
		_shader=shader
		_textureFlags=textureFlags
		_hasKerning=FT_HAS_KERNING( _face )
		
		Local size_req:FT_Size_RequestRec
		
		size_req.type=FT_SIZE_REQUEST_TYPE_REAL_DIM
		size_req.width=0
		size_req.height=fheight * 64
		size_req.horiResolution=0
		size_req.vertResolution=0
		
		If FT_Request_Size( face,Varptr size_req ) FontError()
		
		_height=(face->size->metrics.height+32) Shr 6
		_ascent=(face->size->metrics.ascender+32) Shr 6

		Local gindex:FT_UInt
		Local char:=FT_Get_First_Char( face,Varptr gindex )
		Local minChar:=char,maxChar:=char,maxPage:=0
		
		_pages=New GlyphPage[256]
		
		While gindex
		
			Local page:Int=char Shr 8
			
			If page>=0 And page<_pages.Length And Not _pages[page]
				
				maxPage=Max( page,maxPage )
				_pages[page]=New GlyphPage
				
			Endif
			
			char=FT_Get_Next_Char( face,char,Varptr gindex )
			
			minChar=Min( char,minChar )
			maxChar=Max( char,maxChar )
		Wend
		
		_pages=_pages.Slice( 0,maxPage+1 )
		
		Super.Init( _height,minChar,maxChar-minChar+1 )
		
		_nullGlyph=GetGlyph( 0 )
	End
	
End
