	
Namespace mojo.app

#rem monkeydoc Window creation flags.

| WindowFlags	| Description
|:--------------|:-----------
| CenterX		| Center window horizontally.
| CenterY		| Center window vertically.
| Center		| Center window.
| Hidden		| Window is initally hidden.
| Resizable		| Window is resizable.
| Fullscreen	| Window is a fullscreen window.
| Maximized     | Window is maximized.
| Minimized     | Window is minimized.

#end
Enum WindowFlags
	CenterX=1
	CenterY=2
	Hidden=4
	Resizable=8
	Borderless=16
	Fullscreen=32
	HighDPI=64
	Maximized=128
	Minimized=256
	Center=CenterX|CenterY
End

#rem monkeydoc The Window class.
#end
Class Window Extends View

	Method New( title:String="Window",width:Int=640,height:Int=480,flags:WindowFlags=Null )
		Init( title,New Recti( 0,0,width,height ),flags|WindowFlags.Center )
	End

	Method New( title:String,rect:Recti,flags:WindowFlags=Null )
		Init( title,rect,flags )
	End
	
	#rem monkeydoc The window title text.
	#end
	Property Title:String()
	
		Return String.FromCString( SDL_GetWindowTitle( _sdlWindow ) )
	
	Setter( title:String )
	
		SDL_SetWindowTitle( _sdlWindow,title )
	End
	
	#rem monkeydoc The window clear color.
	#end
	Property ClearColor:Color()

		Return _clearColor

	Setter( clearColor:Color )

		_clearColor=clearColor
	End
	
	#rem monkeydoc True if window clearing is enabled.
	#end
	Property ClearEnabled:Bool()
	
		Return _clearEnabled
		
	Setter( clearEnabled:Bool )
	
		_clearEnabled=clearEnabled
	End
	
	#rem monkeydoc The window swap interval.
	#end
	Property SwapInterval:Int()
	
		Return _swapInterval
	
	Setter( swapInterval:Int )
	
		_swapInterval=swapInterval
	End
	
	#rem monkeydoc Window fullscreen state.
	
	Note: The setter for this property deprecated! Please use BeginFullscreen/EndFullscreen instead.
	
	#end
	Property Fullscreen:Bool()
	
		Return Cast<SDL_WindowFlags>( SDL_GetWindowFlags( _sdlWindow ) ) & SDL_WINDOW_FULLSCREEN
		
	Setter( fullscreen:Bool )
		If fullscreen=Fullscreen Return
	
		If fullscreen BeginFullscreen() Else EndFullscreen()
	End

	#rem monkeydoc Window maximized state.
	#end	
	Property Maximized:Bool()
	
		Return Cast<SDL_WindowFlags>( SDL_GetWindowFlags( _sdlWindow ) ) & SDL_WINDOW_MAXIMIZED
	End
	
	#rem monkeydoc Window minimized state.
	#end	
	Property Minimized:Bool()
	
		Return Cast<SDL_WindowFlags>( SDL_GetWindowFlags( _sdlWindow ) ) & SDL_WINDOW_MINIMIZED
	End

	#rem monkeydoc Window content view.
	
	During layout, the window's content view is resized to fill the window.
	
	#end	
	Property ContentView:View()
	
		Return _contentView
	
	Setter( contentView:View )
	
		If _contentView RemoveChildView( _contentView )
		
		_contentView=contentView
		
		If _contentView AddChildView( _contentView )
		
	End

	#rem monkeydoc Switches to 'desktop' fullscreen mode.
	
	Switches to 'desktop' fullscreen mode. 
	
	The window is resized to cover the entire desktop and any window decorations are hidden.
	
	The display resolution does not actually change.
	
	#end	
	Method BeginFullscreen()
		
		SDL_SetWindowFullscreen( _sdlWindow,SDL_WINDOW_FULLSCREEN_DESKTOP )
	End
	
	#rem monkeydoc Changes display mode and switches to fullscreen mode.
	
	The display resolution is changed, the window is resized and any window decorations are hidden.
	
	#end
	Method BeginFullscreen( width:Int,height:Int,hertz:Int )
		
		Local mode:SDL_DisplayMode
		mode.w=width
		mode.h=height
		mode.refresh_rate=hertz
		Local closest:SDL_DisplayMode
		SDL_GetClosestDisplayMode( 0,Varptr mode,Varptr closest )
		SDL_SetWindowDisplayMode( _sdlWindow,Varptr closest )
		SDL_SetWindowFullscreen( _sdlWindow,SDL_WINDOW_FULLSCREEN )
	End
	
	#rem monkeydoc Ends fullscreen mode.
	#end
	Method EndFullscreen()
		
		SDL_SetWindowFullscreen( _sdlWindow,0 )
	End

	#rem monkeydoc Maximizes the window.
	#end	
	Method Maximize()
		
		SDL_MaximizeWindow( _sdlWindow )
	End
	
	#rem monkeydoc Minimizes the window.
	#end	
	Method Minimize()
		
		SDL_MinimizeWindow( _sdlWindow )
	End
	
	#rem monkeydoc Restores the window.
	#end	
	Method Restore()
		
		SDL_RestoreWindow( _sdlWindow )
	End
	
	'***** INTERNAL *****

	#rem monkeydoc @hidden
	#End
	Method UpdateWindow( render:Bool )
	
		LayoutWindow()
		
		If render RenderWindow()
	End
	
	#rem monkeydoc @hidden Mouse scale for ios retina devices. Should prob. be in App so @2.png can use it etc.
	#end
	Property MouseScale:Vec2f()
	
		Return _mouseScale
	End
	
	#rem monkeydoc @hidden The internal SDL_Window used by this window.
	#end
	Property SDLWindow:SDL_Window Ptr()
	
		Return _sdlWindow
	End

	#rem monkeydoc @hidden The internal SDL_GLContext used by this window.
	#end	
	Property SDLGLContext:SDL_GLContext()
		
		Return _sdlGLContext
	End

	#rem monkeydoc @hidden
	#end
	Function AllWindows:Window[]()
	
		Return _allWindows.ToArray()
	End

	#rem monkeydoc @hidden
	#end
	Function VisibleWindows:Window[]()
	
		Return _visibleWindows.ToArray()
	End
	
	#rem monkeydoc @hidden
	#end
	Function WindowForID:Window( id:UInt )
	
		Return _windowsByID[id]
	End
	
	#rem monkeydoc @hidden
	#end
	Method SendTouchEvent( event:TouchEvent )
	
		OnTouchEvent( event )
	End

	#rem monkeydoc @hidden
	#end
	Method SendWindowEvent( event:WindowEvent )
	
		Select event.Type
		Case EventType.WindowMaximized
		Case EventType.WindowMinimized
		Case EventType.WindowRestored
		Case EventType.WindowMoved,EventType.WindowResized
			_frame=GetFrame()
			Frame=_frame
			_weirdHack=True
		End
		
		OnWindowEvent( event )
	End
	
	Protected
	
	#rem monkeydoc Theme changed handler.
	
	Called when the App theme changes.
	#end
	Method OnThemeChanged() override
	
		_clearColor=App.Theme.GetColor( "windowClearColor" )
	End
	
	#rem monkeydoc Touch event handler.
	
	Called when the user touches the window on a touch compatible device.
	
	#end
	Method OnTouchEvent( event:TouchEvent ) Virtual
	
	End
	
	#rem monkeydoc Window event handler.
	
	Called when the window is sent a window event.
	
	#end
	Method OnWindowEvent( event:WindowEvent ) Virtual
	
		Select event.Type
		Case EventType.WindowClose
		
			App.Terminate()
			
		Case EventType.WindowResized
		
			App.RequestRender()		'Should maybe do this regardless?
			
		Case EventType.WindowGainedFocus
		
			App.RequestRender()		'Need to do this for KDE on linux?
		End
		
	End
	
	Method OnLayout() Override
	
		If _contentView _contentView.Frame=Rect
	End
	
	Private
	
	Field _sdlWindow:SDL_Window Ptr
	Field _sdlGLContext:SDL_GLContext
	
	Field _flags:WindowFlags
	Field _maxfudge:Int
	Field _swapInterval:=1
	
	Field _canvas:Canvas

	Field _clearColor:=Color.Grey
	Field _clearEnabled:=True
	
	Field _contentView:View

	Field _minSize:Vec2i
	Field _maxSize:Vec2i
	Field _frame:Recti
	
	Field _mouseScale:=New Vec2f( 1,1 )

	'Ok, angles glViewport appears To be 'lagging' by one frame, causing weirdness when resizing.
	Field _weirdHack:Bool
	
	Global _allWindows:=New Stack<Window>
	Global _visibleWindows:=New Stack<Window>
	Global _windowsByID:=New Map<UInt,Window>
	
	Method SetMinSize( size:Vec2i )
		size/=_mouseScale
		SDL_SetWindowMinimumSize( _sdlWindow,size.x,size.y )
	End

	Method SetMaxSize( size:Vec2i )
		size/=_mouseScale
		SDL_SetWindowMaximumSize( _sdlWindow,size.x,size.y )
	End
	
	Method SetFrame( rect:Recti )
		rect/=_mouseScale
		SDL_SetWindowPosition( _sdlWindow,rect.X,rect.Y )
		SDL_SetWindowSize( _sdlWindow,rect.Width,rect.Height )
	End
	
	Method GetMinSize:Vec2i()
		Local w:Int,h:Int
		SDL_GetWindowMinimumSize( _sdlWindow,Varptr w,Varptr h )
		Return New Vec2i( w,h ) * _mouseScale
	End
	
	Method GetMaxSize:Vec2i()
		Local w:Int,h:Int
		SDL_GetWindowMaximumSize( _sdlWindow,Varptr w,Varptr h )
		Return New Vec2i( w,h ) * _mouseScale
	End

	Method GetFrame:Recti()
		Local x:Int,y:Int,w:Int,h:Int
		SDL_GetWindowPosition( _sdlWindow,Varptr x,Varptr y )
		SDL_GetWindowSize( _sdlWindow,Varptr w,Varptr h )
		Return New Recti( x,y,x+w,y+h ) * _mouseScale
	End
	
	Method UpdateMouseScale()
	
		Local w:Int,h:Int,dw:Int,dh:Int
		
		SDL_GetWindowSize( _sdlWindow,Varptr w,Varptr h )
		
#If __TARGET__="emscripten"
		emscripten_get_canvas_size( Varptr dw,Varptr dh,Null )
#Else
		SDL_GL_GetDrawableSize( _sdlWindow,Varptr dw,Varptr dh )
#Endif
		_mouseScale=New Vec2f( Float(dw)/w,Float(dh)/h )
	End
	
	Method LayoutWindow()
		
		'All this polling is a bit ugly...fixme.
		'		
#If __DESKTOP_TARGET__

		If MinSize<>_minSize
			SetMinSize( MinSize )
			MinSize=GetMinSize()
			_minSize=MinSize
		Endif
		
		If MaxSize<>_maxSize
			SetMaxSize( MaxSize )
			MaxSize=GetMaxSize()
			_maxSize=MaxSize
		Endif

		If Frame<>_frame
			SetFrame( Frame )
			Frame=GetFrame()
			_frame=Frame
			_weirdHack=True
		Endif
		
#Else if __WEB_TARGET__

		Local dw:Int,dh:Int
		emscripten_get_canvas_size( Varptr dw,Varptr dh,Null )
		Frame=New Recti( 0,0,dw,dh )
#Else
		_frame=GetFrame()
		Frame=_frame
#Endif
		Measure()
		
		UpdateLayout()
	End
	
	#rem monkeydoc @hidden
	#end
	Method RenderWindow()
		
		If _maxfudge
			_maxfudge-=1
			App.RequestRender()
		Endif

		SDL_GL_MakeCurrent( _sdlWindow,_sdlGLContext )

		SDL_GL_SetSwapInterval( _swapInterval )
	
#If __TARGET__="windows"

		If _weirdHack
			_weirdHack=False
			SDL_GL_SwapWindow( _sdlWindow )
		Endif
#Endif
		Local bounds:=New Recti( 0,0,Frame.Size )
		
		_canvas.Resize( bounds.Size )
		
		_canvas.BeginRender( bounds,New AffineMat3f )
		
		If _clearEnabled _canvas.Clear( _clearColor )
		
		Render( _canvas )
		
		_canvas.EndRender()
		
		SDL_GL_SwapWindow( _sdlWindow )
		
	End
	
	Method Init( title:String,rect:Recti,flags:WindowFlags )
		Style=GetStyle( "Window" )
		
		If flags & WindowFlags.Hidden Visible=False
	
		Local x:=(flags & WindowFlags.CenterX) ? SDL_WINDOWPOS_CENTERED Else rect.X
		Local y:=(flags & WindowFlags.CenterY) ? SDL_WINDOWPOS_CENTERED Else rect.Y
		Local w:=rect.Width,h:=rect.Height
		
		Local sdlFlags:SDL_WindowFlags=SDL_WINDOW_OPENGL
		
		If flags & WindowFlags.Fullscreen
		
			 sdlFlags|=SDL_WINDOW_FULLSCREEN
			
		Else If flags & WindowFlags.Maximized

			sdlFlags|=SDL_WINDOW_MAXIMIZED
			_maxfudge=2
		
		Else If flags & WindowFlags.Minimized
		
			sdlFlags|=SDL_WINDOW_MINIMIZED
			
		Endif
		
		If flags & WindowFlags.Hidden sdlFlags|=SDL_WINDOW_HIDDEN
			
		If flags & WindowFlags.Resizable sdlFlags|=SDL_WINDOW_RESIZABLE
		
		If flags & WindowFlags.Borderless sdlFlags|=SDL_WINDOW_BORDERLESS
		
		If flags & WindowFlags.HighDPI sdlFlags|=SDL_WINDOW_ALLOW_HIGHDPI
		
		_flags=flags
		
		'Create Window
		_sdlWindow=SDL_CreateWindow( title,x,y,w,h,sdlFlags )
		If Not _sdlWindow
			Print "SDL_GetError="+String.FromCString( SDL_GetError() )
			Assert( _sdlWindow,"FATAL ERROR: SDL_CreateWindow failed" )
		Endif
		
		'Create GL context
		_sdlGLContext=SDL_GL_CreateContext( _sdlWindow )
		If Not _sdlGLContext
			Print "SDL_GetError="+String.FromCString( SDL_GetError() )
			Assert( _sdlGLContext,"FATAL ERROR: SDL_GL_CreateContext failed" )
		Endif
		SDL_GL_MakeCurrent( _sdlWindow,_sdlGLContext )
		
		InitGLexts()
		
		_allWindows.Push( Self )
		_windowsByID[SDL_GetWindowID( _sdlWindow )]=Self
		If Not (flags & WindowFlags.Hidden) _visibleWindows.Push( Self )
		
		'Would much rather know this *before* we open the window!
		UpdateMouseScale()

		'UGLY!!!!!
		If _mouseScale.x<>1 Or _mouseScale.y<>1
			Local x:=(flags & WindowFlags.CenterX) ? SDL_WINDOWPOS_CENTERED Else rect.X/_mouseScale.x
			Local y:=(flags & WindowFlags.CenterY) ? SDL_WINDOWPOS_CENTERED Else rect.Y/_mouseScale.y
			Local w:=rect.Width/_mouseScale.x
			Local h:=rect.Height/_mouseScale.y
			SDL_SetWindowPosition( _sdlWindow,x,y )
			SDL_SetWindowSize( _sdlWindow,w,h )
		Endif
		
		MinSize=GetMinSize()
		_minSize=MinSize
		
		MaxSize=GetMaxSize()
		_maxSize=MaxSize
		
		Frame=GetFrame()
		_frame=Frame
		
		_clearColor=App.Theme.GetColor( "windowClearColor" )
		
		_canvas=New Canvas( _frame.Width,_frame.Height )
		
		SetWindow( Self )
		
		UpdateActive()

		LayoutWindow()

		Activated+=Lambda()
			Local flags:=Cast<SDL_WindowFlags>( SDL_GetWindowFlags( _sdlWindow ) )
			If (flags & SDL_WINDOW_HIDDEN)
				SDL_ShowWindow( _sdlWindow )
				SDL_RaiseWindow( _sdlWindow )
				_visibleWindows.Push( Self )
			Endif
		End
		
		Deactivated+=Lambda()
			RuntimeError( "Windows cannot be deactivated" )
		End

	End
End
