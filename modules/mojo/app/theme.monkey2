
Namespace mojo.app

Class Theme

	Field ThemeChanged:Void()

	Method New()
		_defaultStyle=New Style
		_defaultStyle.Font=App.DefaultFont
	End
	
	Property Scale:Vec2f()
	
		Return _themeScale
	
	Setter( scale:Vec2f )
		If scale=_themeScale Return
		
		_themeScale=scale
		
		Reload()
	End
	
	Property DefaultStyle:Style()
	
		Return _defaultStyle
	End
	
	#rem monkeydoc Gets a font from the theme.
	
	If no font named `name` is found, [[AppInstance.DefaultFont|App.DefaultFont]] is returned.

	#end
	Method GetFont:Font( name:String )
	
		Local font:=_fonts[name]
		If font Return font
		
		Return App.DefaultFont
	End
	
	#rem monkeydoc Gets a color from the theme.
	
	If no color named `name` is found, [[std:std.graphics.Color.Grey|Color.Grey]] is returned.
	
	#end
	Method GetColor:Color( name:String )
	
		If _colors.Contains( name ) Return _colors[name]
		
		Return Color.Grey
	End
	
	#rem monkeydoc Gets a style from the theme.
	
	If no style named `name` is found, the [[DefaultStyle]] for the theme is returned.
	
	#end
	Method GetStyle:Style( name:String )
	
		Local style:=_styles[name]
		If style Return style
		
		Return _defaultStyle
	End
	
	#rem monkeydoc Loads a font from a file.
	
	If `file` is an absolute path, this method is effectively the same as calling [[Font.Load]].
	
	If `file` is not an absolute path, the font is searched for in the following locations:
	
	* The theme's directory.
	
	* The asset::fonts/ directory.
	
	#end
	Method OpenFont:Font( path:String,size:Float )
	
		size*=_themeScale.y
		
		Local font:Font
		If Not ExtractRootDir( path ) font=_res.OpenFont( "theme::"+path,size )
		If Not font font=_res.OpenFont( path,size )
		If Not font Return App.DefaultFont
		
		Return font
	End
	
	Method OpenImage:Image( path:String )
	
		Local image:Image
		If Not ExtractRootDir( path ) image=_res.OpenImage( "theme::"+path )
		If Not image image=_res.OpenImage( path )
		If Not image Return null
		
		image.Scale=_themeScale
		
		Return image
	End
	
	#rem monkeydoc Loads an array of icon images from a file.
	
	Loads an array of icons from an image file.
	
	The icons should be square, and laid out in a horizontal 'strip' within the image file.
	
	The width and height of each image is taken from the height of the image file.
	
	The number of icons loaded is the width of the image file divided by its height.
	
	#end
	Method OpenIcons:Image[]( path:String )
	
		Local slug:="Icons:"+StripDir( StripExt( path ) )
		
		Local icons:=Cast<Icons>( _res.OpenResource( slug ) )
		If Not icons

			Local atlas:=OpenImage( path )
			If Not atlas Return Null
		
			Local size:=atlas.Rect.Height
			Local n:=atlas.Rect.Width/size
	
			icons=New Icons
			icons.atlas=atlas
			icons.images=New Image[n]
			
			For Local i:=0 Until n
				Local image:=New Image( atlas,New Recti( i*size,0,i*size+size,size ) )
				icons.images[i]=image
			Next
			
			_res.AddResource( slug,icons )
		Endif
		
		For Local image:=Eachin icons.images
			image.Scale=_themeScale
		Next
		
		Return icons.images
	End
	
	#rem monkeydoc Loads a skin from a file.
	
	If `file` is an absolute path, this method is effectively the same as calling [[Skin.Load]].
	
	If `file` is not an absolute path, the skin is searched for in the following locations:
	
	* The theme directory.
	
	* The asset::images/ directory.
	
	#end
	Method OpenSkin:Skin( path:String )
	
		Local skin:Skin
		If Not ExtractRootDir( path ) skin=_res.OpenSkin( "theme::"+path )
		If Not skin skin=_res.OpenSkin( path )
		
		If Not skin Return Null
		
		skin.Image.Scale=_themeScale
		
		Return skin
	End
	
	Method Load:Bool( path:String,scale:Vec2f=New Vec2f( 1 ) )
	
		If Not LoadJson( path )
			Print "Failed to load theme:"+path
			return False
		Endif

		_themeScale=scale
		
		Reload()
		
		Return True
	End

	Private
	
	Class Icons Extends Resource
		Field atlas:Image
		Field images:Image[]
	End
	
	Const _jdefault:=New JsonString( "default" )
	
	Field _res:ResourceManager

	Field _themeScale:Vec2f=New Vec2f( 1,1 )
	
	Field _jcolors:StringMap<JsonValue>
	Field _jfonts:StringMap<JsonValue>
	Field _jstyles:StringMap<JsonValue>
	
	Field _defaultStyle:Style
	
	Field _fonts:=New StringMap<Font>
	Field _colors:=New StringMap<Color>
	Field _styles:=New StringMap<Style>
	Field _cstyles:=New StringMap<Style>
	
	Method LoadJson:Bool( path:String )

		If Not ExtractRootDir( path ) path="theme::"+path
		
		If Not ExtractExt( path ) path+=".json"
	
		Local jobj:=JsonObject.Load( path )
		If Not jobj Return False
		
		If jobj.Contains( "extends" ) 

			If Not LoadJson( jobj.GetString( "extends" ) ) Return False
			
			If jobj.Contains( "colors" )
				For Local it:=Eachin jobj["colors"].ToObject()
					_jcolors[it.Key]=it.Value
				Next
			Endif
			
			If jobj.Contains( "fonts" )
				For Local it:=Eachin jobj["fonts"].ToObject()
					_jfonts[it.Key]=it.Value
				Next
			Endif
			
			If jobj.Contains( "styles" )
				For Local it:=Eachin jobj["styles"].ToObject()
					_jstyles[it.Key]=it.Value
				Next
			Endif
			
			Return True
		Endif
		
		_jcolors=jobj["colors"].ToObject()
		_jfonts=jobj["fonts"].ToObject()
		_jstyles=jobj["styles"].ToObject()

		Return True
	End
	
	Method Unload()
		_fonts.Clear()
		_colors.Clear()
		_styles.Clear()
		_defaultStyle=New Style
		_defaultStyle.Font=App.DefaultFont
	End
	
	Method Reload()
	
		Unload()
		
		Local res:=_res
		
		_res=New ResourceManager

		_defaultStyle=LoadStyle( _jdefault )
		
		For Local it:=Eachin _jcolors
			LoadColor( New JsonString( it.Key ) )
		Next
		
		For Local it:=Eachin _jfonts
			LoadFont( New JsonString( it.Key ) )
		Next
		
		For Local it:=Eachin _jstyles
			LoadStyle( New JsonString( it.Key ) )
		Next
		
		If res res.Discard()
		
		ThemeChanged()
	End
	
	Method ToRect:Recti( jrect:JsonValue )
	
		Local arr:=jrect.ToArray()
		
		Local l:=0,t:=0,r:=0,b:=0
		
		Select arr.Length
		Case 1
			l=arr[0].ToNumber() ; r=l
			t=arr[0].ToNumber() ; b=t
		Case 2
			l=arr[0].ToNumber() ; r=l
			t=arr[1].ToNumber() ; b=t
		Case 4
			l=arr[0].ToNumber()
			t=arr[1].ToNumber()
			r=arr[2].ToNumber()
			b=arr[3].ToNumber()
		End
		
		l=l*_themeScale.x
		t=t*_themeScale.y
		r=r*_themeScale.x
		b=b*_themeScale.y
		
		Return New Recti( -l,-t,r,b )
	End
	
	Method LoadColor:Color( jcolor:JsonValue )
	
		Local jarr:=Cast<JsonArray>( jcolor )
		If jarr
		
			Local r:=0.0,g:=0.0,b:=0.0,a:=1.0

			Select jarr.Length
			Case 1
				r=jarr[0].ToNumber()
				g=jarr[0].ToNumber()
				b=jarr[0].ToNumber()
			Case 3
				r=jarr[0].ToNumber()
				g=jarr[1].ToNumber()
				b=jarr[2].ToNumber()
			Case 4
				r=jarr[0].ToNumber()
				g=jarr[1].ToNumber()
				b=jarr[2].ToNumber()
				a=jarr[3].ToNumber()
			Default
				Return Color.Magenta
			End
			
			Return New Color( r,g,b,a )
		Endif
		
		Local str:=jcolor.ToString()
		
		If str.StartsWith( "#" )
		
			Local a:=1.0,r:=0.0,g:=0.0,b:=0.0
		
			If str.Length=4			'#RGB
				r=StringToULong( str.Slice( 1,2 ),16 )/15.0
				g=StringToULong( str.Slice( 2,3 ),16 )/15.0
				b=StringToULong( str.Slice( 3,4 ),16 )/15.0
			Else If str.Length=5	'#ARGB
				a=StringToULong( str.Slice( 1,2 ),16 )/15.0
				r=StringToULong( str.Slice( 2,3 ),16 )/15.0
				g=StringToULong( str.Slice( 3,4 ),16 )/15.0
				b=StringToULong( str.Slice( 4,5 ),16 )/15.0
			Else If str.Length=7	'#RRGGBB
				r=StringToULong( str.Slice( 1,3 ),16 )/255.0
				g=StringToULong( str.Slice( 3,5 ),16 )/255.0
				b=StringToULong( str.Slice( 5,7 ),16 )/255.0
			Else If str.Length=9	'#AARRGGBB
				a=StringToULong( str.Slice( 1,3 ),16 )/255.0
				r=StringToULong( str.Slice( 3,5 ),16 )/255.0
				g=StringToULong( str.Slice( 5,7 ),16 )/255.0
				b=StringToULong( str.Slice( 7,9 ),16 )/255.0
			Else
				Return Color.Magenta
			Endif
			
			Return New Color( r,g,b,a )
			
		Endif
		
		If _colors.Contains( str ) Return _colors[str]
		
		jcolor=_jcolors[str]
		If Not jcolor Return Color.Magenta
		
		Local color:=LoadColor( jcolor )
		
		_colors[str]=color
		
		Return color
	End
	
	Method LoadFont:Font( name:JsonValue )
	
		Local str:=name.ToString()
	
		If _fonts.Contains( str ) Return _fonts[str]
		
		Local jfont:=_jfonts[str]
		If Not jfont Return App.DefaultFont
		
		Local fname:=jfont.ToString()
		
		Local fsize:=0
		Local i:=fname.Find( "," )
		If i<>-1
			fsize=Int( fname.Slice( i+1 ) )
			fname=fname.Slice( 0,i )
		Endif

		Local font:=OpenFont( fname,fsize )
		
		_fonts[str]=font
		
		Return font
	End
	
	Method SetStyle( style:Style,jstyle:StringMap<JsonValue> )
	
		If jstyle.Contains( "backgroundColor" ) style.BackgroundColor=LoadColor( jstyle["backgroundColor"] )
		If jstyle.Contains( "borderColor" ) style.BorderColor=LoadColor( jstyle["borderColor"] )
		If jstyle.Contains( "textColor" ) style.TextColor=LoadColor( jstyle["textColor"] )
		If jstyle.Contains( "iconColor" ) style.IconColor=LoadColor( jstyle["iconColor"] )
		If jstyle.Contains( "skinColor" ) style.SkinColor=LoadColor( jstyle["skinColor"] )
		
		If jstyle.Contains( "padding" ) style.Padding=ToRect( jstyle["padding"] )
		If jstyle.Contains( "border" ) style.Border=ToRect( jstyle["border"] )
		If jstyle.Contains( "margin" ) style.Margin=ToRect( jstyle["margin"] )
		
		If jstyle.Contains( "icons" ) style.Icons=OpenIcons( jstyle["icons"].ToString() )
		If jstyle.Contains( "skin" ) style.Skin=OpenSkin( jstyle["skin"].ToString() )

		If jstyle.Contains( "font" ) style.Font=LoadFont( jstyle["font"] )
	End
	
	Method LoadStyle:Style( name:JsonValue )
	
		Local str:=name.ToString()
		
		If _styles.Contains( str ) Return _styles[str]
		
		Local jobj:=_jstyles[str]
		If Not jobj Return _defaultStyle
		
		Local jstyle:=jobj.ToObject()
		
		'get parent style
		'
		Local pstyle:Style
		
		If jstyle.Contains( "extends" )
			pstyle=LoadStyle( jstyle["extends"] )
		Else
			pstyle=_defaultStyle
		Endif

		'create new style
		'		
		Local style:Style
		
		Local cstyle:=_cstyles[str]
		If cstyle
			style=cstyle
			style.Set( pstyle )
		Else
			style=New Style( str,pstyle )
		Endif

		'initialize
		'		
		SetStyle( style,jstyle )
		
		For Local it:=Eachin style.States

			SetStyle( it.Value,jstyle )
		Next
		
		'create states
		'
		If jstyle.Contains( "states" )
		
			local jstates:=jstyle["states"].ToObject()
			
			For Local it:=Eachin jstates
			
				Local state:=style.AddState( it.Key )

				SetStyle( state,it.Value.ToObject() )
			Next
		
		Endif
		
		_cstyles[str]=style
		_styles[str]=style
		
		Return style
	End
	
End
