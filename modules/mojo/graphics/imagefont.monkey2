Namespace mojo.graphics

Using std.resource

#rem monkeydoc @hidden The ImageFont class.
#end
Class ImageFont Extends Font
	
	Method New( pixmap:Pixmap,charWidth:Int,charHeight:Int,firstChar:Int=32,numChars:Int=96,padding:Int=1,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local charsPerRow:=pixmap.Width/charWidth
		Local numRows:=(numChars-1)/charsPerRow+1
		
		Local ipixmap:Pixmap
		If padding
			ipixmap=New Pixmap( charsPerRow*(charWidth+padding),numRows*(charHeight+padding),pixmap.Format )
			ipixmap.Clear( Color.None )
		Endif
		
		_glyphs=New Glyph[numChars]

		Local spos:=New Vec2i,gpos:=New Vec2i,gsize:=New Vec2i( charWidth,charHeight )
		
		For Local i:=0 Until numChars
			
			Local char:=firstChar+i
			
			Local glyph:Glyph
			glyph.rect=New Recti( gpos,gpos+gsize )
			glyph.offset=Null
			glyph.advance=charWidth
			
			_glyphs[i]=glyph
			
			If ipixmap
				Local src:=pixmap.Window( spos.x,spos.y,charWidth,charHeight )
				ipixmap.Paste( src,gpos.x,gpos.y )
			Endif
			
			spos.x+=charWidth
			gpos.x+=charWidth+padding
			If spos.x+charWidth>pixmap.Width
				spos.y+=charHeight
				gpos.y+=charHeight+padding
				spos.x=0
				gpos.x=0
			Endif
			
		Next

		_page=New Image( ipixmap ?Else pixmap,textureFlags,shader )
		
		Init( charHeight,firstChar,numChars )
	End
	
	Method GetGlyph:Glyph( char:Int ) Override
		
		char-=FirstChar
		If char<0 Or char>=NumChars Return _glyphs[0]
		
		Return _glyphs[char]
	End
	
	Method GetGlyphPage:Image( char:Int ) Override
		
		Return _page
	End
	
	Function Load:ImageFont( path:String,charWidth:Int,charHeight:Int,firstChar:Int=32,numChars:Int=96,padding:Int=1,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local pixmap:=Pixmap.Load( path,Null,True )
		If Not pixmap
			If Not ExtractRootDir( path ) pixmap=Pixmap.Load( "font::"+path,Null,True )
			If Not pixmap Return Null
		Endif
		
		Local pshader:=shader ?Else (pixmap.Format=PixelFormat.I8 ? Shader.Open( "font" ) Else Shader.Open( "sprite" ))

		Local font:=New ImageFont( pixmap,charWidth,charHeight,firstChar,numChars,padding,pshader,textureFlags )
		
		Return font
	End
		
	Protected
	
	Method OnDiscard() Override
		
		_page.Discard()
	End
	
	Private
	
	field _glyphs:Glyph[]
	Field _page:Image
End
