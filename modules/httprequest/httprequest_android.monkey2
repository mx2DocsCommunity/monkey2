
Namespace httprequest

#Import "<jni>"
#Import "<std>"
#Import "<mojo>"
#Import "<sdl2>"

#Import "native/Monkey2HttpRequest.java"
#Import "native/httprequest.cpp"
#Import "native/httprequest.h"

Using jni..
Using std..
Using mojo..
Using sdl2..

Extern Private

Global onReadyStateChanged:Void(jobject,Int)="bbHttpRequest::onReadyStateChanged"

Global onResponseReceived:Void(jobject,String,Int,Int)="bbHttpRequest::onResponseReceived"

Public

Class HttpRequest Extends HttpRequestBase
	
	Method New()
		
		Init()

		Local env:=Android_JNI_GetEnv()
		
		Local obj:=env.AllocObject( _class )
		
		_obj=env.NewGlobalRef( obj )
		
		_requests.Add( Self )
	End
	
	Protected
	
	Method OnOpen( req:String,url:String ) Override
		
		If Not _obj Return
	
		Local env:=Android_JNI_GetEnv()
	
		env.CallVoidMethod( _obj,_open,New Variant[]( req,url ) )
	End
	
	Method OnSetHeader( header:String,value:String ) Override
		
		If Not _obj Return
	
		Local env:=Android_JNI_GetEnv()
	
		env.CallVoidMethod( _obj,_setHeader,New Variant[]( header,value ) )
	End
	
	Method OnSend( text:String ) Override
		
		If Not _obj Return
	
		Local env:=Android_JNI_GetEnv()
		
		Local timeout:=Int( _timeout * 1000 )
	
		env.CallVoidMethod( _obj,_send,New Variant[]( text,timeout ) )
	End
	
	Method OnCancel() Override
		
		If Not _obj Return
		
		Local env:=Android_JNI_GetEnv()
		
		env.CallVoidMethod( _obj,_cancel,Null )
	End
	
	Private
	
	Field _obj:jobject
	
	Global _class:jclass
	Global _open:jmethodID
	Global _setHeader:jmethodID
	Global _send:jmethodID
	Global _cancel:jmethodID
	
	Global _requests:=New Stack<HttpRequest>
	
	Method Close()
		
		If Not _obj Return
		
		_requests.Remove( Self )
		
		Local env:=Android_JNI_GetEnv()
		
		env.DeleteGlobalRef( _obj )
		
		_obj=Null
	End
	
	Function OnReadyStateChanged( obj:jobject,state:Int )
		
		Local env:=Android_JNI_GetEnv()
		
		For Local request:=Eachin _requests
			
			If Not env.IsSameObject( obj,request._obj ) Continue
				
			request.SetReadyState( Cast<ReadyState>( state ) )

			If state=4 Or state=5 request.Close()
			
			Exit
		Next
		
	End
	
	Function OnResponseReceived( obj:jobject,response:String,status:Int,state:Int )

		Local env:=Android_JNI_GetEnv()
		
		For Local request:=Eachin _requests
			
			If Not env.IsSameObject( obj,request._obj ) Continue
				
			request._response=response
			
			request._status=status
			
			request.SetReadyState( Cast<ReadyState>( state ) )
			
			Exit
		Next
	End
	
	Function Init()
		
		If _class Return

		Local env:=Android_JNI_GetEnv()
	
		_class=env.FindClass( "com/monkey2/lib/Monkey2HttpRequest" )
		If Not _class RuntimeError( "Can't find com.monkey2.lib.Monkey2HttpRequest class" )
		
		_open=env.GetMethodID( _class,"open","(Ljava/lang/String;Ljava/lang/String;)V" )
		
		_setHeader=env.GetMethodID( _class,"setHeader","(Ljava/lang/String;Ljava/lang/String;)V" )
		
		_send=env.GetMethodID( _class,"send","(Ljava/lang/String;I)V" )

		_cancel=env.GetMethodID( _class,"cancel","()V" )
		
		onReadyStateChanged=OnReadyStateChanged
		
		onResponseReceived=OnResponseReceived
	End
End
