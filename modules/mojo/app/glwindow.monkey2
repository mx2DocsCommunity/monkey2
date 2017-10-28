
Namespace mojo.app

Class GLWindow Extends Window

	Method New( title:String="Window",width:Int=640,height:Int=480,flags:WindowFlags=Null )
		Super.New( title,width,height,flags )
		Init()
	End

	Method New( title:String,rect:Recti,flags:WindowFlags=Null )
		Super.New( title,rect,flags )
		Init()
	End

	#rem monkeydoc Switches from shared GL context to private GL context.
	#end
	Method BeginGL()
	
#If __HOSTOS__="macos"
		glFlush()
#Endif		

		SDL_GL_MakeCurrent( SDLWindow,_sdlGLContext )
	End
	
	#rem monkeydoc Switches from private GL back to shared GL context.
	#end
	Method EndGL()

#If __HOSTOS__="macos"
		glFlush()
#Endif		

		SDL_GL_MakeCurrent( Super.SDLWindow,Super.SDLGLContext )
	End
	
	Protected

	#rem monkeydoc Override this method with your mojo rendering code.
	
	Note: If you override this method, you must call Super.OnRender() at some point for [[OnRenderGL]] to be called.

	#end
	Method OnRender( canvas:Canvas ) Override
	
		BeginGL()
		
		OnRenderGL()
		
		EndGL()
	End
	
	#rem monkeydoc Override this method with your custom GL rendering code.
	#end
	Method OnRenderGL() Virtual
	End
	
	Private
	
	Field _sdlGLContext:SDL_GLContext
	
	Method Init()
		_sdlGLContext=SDL_GL_CreateContext( SDLWindow )
		Assert( _sdlGLContext,"FATAL ERROR: SDL_GL_CreateContext failed" )
	End

End
