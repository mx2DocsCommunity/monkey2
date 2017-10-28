
Namespace mojo.app

#rem monkeydoc The Style class.
#end
Class Style

	Method New()
		_font=App.DefaultFont		
	End
	
	Method New( style:Style )
		Init( style )
	End
	
	Method New( name:String,style:Style )
		_name=name
		Init( style )
	End
	
	Method Copy:Style()
		Return New Style( Self )
	End
	
	Method Set( style:Style )
		Init( style )
	End
	
	Method GetState:Style( name:String )
		Local state:=_states[name]
		If Not state Return Self
		
		Return state
	End

	Method AddState:Style( name:String )
		Local state:=_states[name]
		If state Return state

		state=New Style( Self )
		_states[name]=state

		Return state
	End
	
	#rem monkeydoc Name of the style.
	#end
	Property Name:String()
		Return _name
	End

	#rem monkeydoc Background color.
	#end
	Property BackgroundColor:Color()
		Return _bgcolor
	Setter( backgroundColor:Color )
		_bgcolor=backgroundColor
	End
	
	#rem monkeydoc Padding rect.
	#end
	Property Padding:Recti()
		Return _padding
	Setter( padding:Recti )
		_padding=padding
	End
	
	#rem monkeydoc @hidden
	#end
	Property Skin:Skin()
		Return _skin
	Setter( skin:Skin )
		_skin=skin
	End
	
	#rem monkeydoc @hidden
	#end
	Property SkinColor:Color()
		Return _skcolor
	Setter( skinColor:Color )
		_skcolor=skinColor
	End
		
	#rem monkeydoc Border rect.
	#end
	Property Border:Recti()
		Return _border
	Setter( border:Recti )
		_border=border
	End
	
	#rem monkeydoc Border color.
	#End
	Property BorderColor:Color()
		Return _bdcolor
	Setter( borderColor:Color )
		_bdcolor=borderColor
	End

	#rem monkeydoc Margin rect.
	#end
	Property Margin:Recti()
		Return _margin
	Setter( margin:Recti )
		_margin=margin
	End
	
	#rem monkeydoc Color to use when drawing text.
	#end
	Property TextColor:Color()
		Return _textColor
	Setter( color:Color )
		_textColor=color
	End
	
	#rem monkeydoc Color to use when drawing icons.
	#end
	Property IconColor:Color()
		Return _iconColor
	Setter( color:Color )
		_iconColor=color
	End
	
	#rem monkeydoc Font to use when drawing text.
	
	Deprecated! Just use [[Font]] instead...
	
	#end
	Property DefaultFont:Font()
		Return _font
	Setter( font:Font )
		_font=font
	End
	
	#rem monkeydoc Font to use when drawing text.
	#end
	Property Font:Font()
		Return _font
	Setter( font:Font )
		_font=font
	End
	
	#rem monkeydoc Custom icons.
	#end
	Property Icons:Image[]()
		Return _icons
	Setter( icons:Image[] )
		_icons=icons
	End
	
	#rem monkeydoc Total style bounds.
	#end
	Property Bounds:Recti()
		Local bounds:=_padding
		If _skin bounds+=_skin.Bounds
		bounds+=_border
		bounds+=_margin
		Return bounds
	End

	#rem monkeydoc Measure text.
	#end
	Method MeasureText:Vec2i( text:String )
	
		If Not text Return New Vec2i( 0,0 )
		
		If text.Contains( "~n" )

			Local lines:=text.Split( "~n" ),w:=0

			For Local line:=Eachin lines
				w=Max( w,Int( _font.TextWidth( line ) ) )
			Next
			Return New Vec2i( w,_font.Height * lines.Length )
		Else
			Return New Vec2i( _font.TextWidth( text ),_font.Height )
		Endif
	End
	
	Method DrawText( canvas:Canvas,text:String,x:Int,y:Int,handlex:Float=0,handley:Float=0 )

		Local font:=canvas.Font
		Local color:=canvas.Color
		
		canvas.Font=_font
		canvas.Color=_textColor
		
		canvas.DrawText( text,x,y,handlex,handley )
		
		canvas.Font=font
		canvas.Color=color
	End
	
	Method DrawText( canvas:Canvas,text:String,rect:Recti,gravity:Vec2f )
	
		If Not text Return
	
		Local size:=MeasureText( text )
		
		Local x:=rect.Left + (rect.Width-size.x) * gravity.x
		Local y:=rect.Top + (rect.Height-size.y) * gravity.y
		
		Local font:=canvas.Font
		Local color:=canvas.Color
		
		canvas.Font=_font
		canvas.Color=_textColor
		
		If text.Contains( "~n" )
		
			Local lines:=text.Split( "~n" )
			
			For Local line:=Eachin lines
			
				If line canvas.DrawText( line,x + (size.x-_font.TextWidth( line )) * gravity.x,y )
				y+=_font.Height
			Next
		
		Else If text<>"~n"
		
			canvas.DrawText( text,x,y )
		Endif
		
		canvas.Font=font
		canvas.Color=color
	End
	
	Method DrawIcon( canvas:Canvas,icon:Image,x:Int,y:Int )
	
		Local color:=canvas.Color
		canvas.Color=_iconColor
		
		canvas.DrawImage( icon,x,y )
		
		canvas.Color=color
	End
	
	#rem monkeydoc @hidden 
	#end
	Method Render( canvas:Canvas,bounds:Recti )
	
		bounds-=_margin

		Local border:=Border
		Local bdcolor:=BorderColor
		
		If (border.Width Or border.Height) And bdcolor.a
		
			canvas.Color=bdcolor
			
			Local x:=bounds.X,y:=bounds.Y
			Local w:=bounds.Width,h:=bounds.Height
			Local l:=-border.min.x,r:=border.max.x
			Local t:=-border.min.y,b:=border.max.y
			
			canvas.DrawRect( x,y,l,h-b )
			canvas.DrawRect( x+l,y,w-l,t )
			canvas.DrawRect( x+w-r,y+t,r,h-t )
			canvas.DrawRect( x,y+h-b,w-r,b )

		Endif
		
		bounds-=border
		
		Local bgcolor:=BackgroundColor
		If bgcolor.a
			canvas.Color=bgcolor
			canvas.DrawRect( bounds )
		Endif
		
		Local skin:=Skin
		Local skcolor:=SkinColor
		
		If skin And skcolor.a
			canvas.Color=skcolor
			skin.Draw( canvas,bounds )
		Endif
		
		canvas.Font=_font
		canvas.Color=Color.White
	End
	
	'***** INTERNAL *****

	#rem monkeydoc @hidden
	#end
	Property States:StringMap<Style>()
		If Not _states _states=New StringMap<Style>
		Return _states
	End
	
	Private
	
	Field _name:String
	Field _bgcolor:Color=Color.None
	Field _padding:Recti
	Field _skin:Skin
	Field _skcolor:Color=Color.White
	Field _border:Recti
	Field _bdcolor:Color=Color.None
	Field _margin:Recti
	Field _textColor:Color=Color.Black
	Field _iconColor:Color=Color.White
	Field _icons:Image[]
	Field _font:Font
	Field _states:=New StringMap<Style>

	Method Init( style:Style )
		If Not style Return
		_bgcolor=style._bgcolor
		_padding=style._padding
		_skin=style._skin
		_skcolor=style._skcolor
		_border=style._border
		_bdcolor=style._bdcolor
		_margin=style._margin
		_textColor=style._textColor
		_iconColor=style._iconColor
		_icons=style._icons.Slice( 0 )
		_font=style._font
		_states.Clear()
		If style._states
			For Local it:=Eachin style._states
				_states[it.Key]=New Style( it.Value )
			Next
		Endif
	End
	
End
