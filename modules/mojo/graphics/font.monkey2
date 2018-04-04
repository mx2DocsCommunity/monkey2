
Namespace mojo.graphics

Using std.resource

#rem monkeydoc @hidden The Glyph struct.

Glyph are used to store the individual character data for fonts.

#end
Struct Glyph

	Field rect:Recti
	Field offset:Vec2f
	Field advance:Float
	Field page:Int

End

#rem monkeydoc The Font class.

Fonts are used when drawing text to a canvas using [[Canvas.DrawText]].

To load a font, use the [[Font.Load]] function. Fonts should be in .otf, .ttf or .fon format.

Once a font is loaded it can be used with a canvas via the [[Canvas.Font]] property.

#end
Class Font Extends Resource
	
	#rem monkeydoc The font height in pixels.
	#end
	Property Height:Float()
	
		Return _height
	End

	#rem monkeydoc The first character in the font.
	#end
	Property FirstChar:Int()
		
		Return _firstChar
	End
	
	#rem monkeydoc The number of characters in the font.
	#end
	Property NumChars:Int()
		
		Return _numChars
	End
	
	#rem monkeydoc Gets the glyph for a character.
	#end
	Method GetGlyph:Glyph( char:Int ) Abstract

	#rem monkeydoc Gets the glyph page for a character.
	#end
	Method GetGlyphPage:Image( char:Int ) Abstract
	
	#rem monkeydoc Gets the kerning between 2 characters.
	#end
	Method GetKerning:Float( firstChar:Int,secondChar:Int ) Virtual
		Return 0
	End
	
	#rem monkeydoc Measures the width of some text when rendered by the font.
	#end
	Method TextWidth:Float( text:String )
		
		Local w:=0.0,lastChar:=0

		For Local char:=Eachin text
			w+=GetKerning( lastChar,char )+GetGlyph( char ).advance
			lastChar=char
		Next
		
		Return w
	End

	#rem monkeydoc Loads a font from a file.
	#end
	Function Load:Font( path:String,size:Float,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local font:Font
		
		Select ExtractExt( path )
		Case ".ttf",".otf",".fon"
			font=FreeTypeFont.Load( path,size,shader,textureFlags )
		Case ".fnt"
			font=AngelFont.Load( path,shader,textureFlags )
		Case ""
			font=FreeTypeFont.Load( path+".ttf",size,shader,textureFlags )
			If Not font 
				font=FreeTypeFont.Load( path+".otf",size,shader,textureFlags )
				If Not font font=FreeTypeFont.Load( path+".fon",size,shader,textureFlags )
			Endif
		End
		
		Return font
	End
	
	Protected
	
	Method Init( height:Float,firstChar:Int,numChars:Int )
		
		_height=height
		_firstChar=firstChar
		_numChars=numChars
	End
	
	Private
	
	Field _height:Float
	Field _firstChar:Int
	Field _numChars:Int
End

Class ResourceManager Extension

	Method OpenFont:Font( path:String,height:Float,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
	
		Local slug:="Font:name="+StripDir( StripExt( path ) )+"&height="+height+"&shader="+(shader ? shader.Name Else "")+"&textureFlags="+Int(textureFlags)
		
		Local font:=Cast<Font>( OpenResource( slug ) )
		If font Return font
		
		font=Font.Load( path,height,shader,textureFlags )
		
		AddResource( slug,font )
		Return font
	End

End

