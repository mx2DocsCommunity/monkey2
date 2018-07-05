
Namespace httprequest

#Import "<std>"

Using std..

#If __TARGET__="windows" Or __TARGET__="linux"

#Import "httprequest_desktop"

#Import "bin/wget.exe"

#Else If __TARGET__="macos" Or  __TARGET__="ios"

#Import "httprequest_ios"

#Elseif __TARGET__="emscripten"

#Import "httprequest_emscripten"

#Elseif __TARGET__="android"

#Import "httprequest_android"

#Endif

Enum ReadyState
	Unsent=0
	Opened=1
	HeadersReceived=2
	Loading=3
	Done=4
	Error=5
End

Class HttpRequestBase
	
	Field ReadyStateChanged:Void()
	
	Property Timeout:Float()
		
		Return _timeout
		
	Setter( timeout:Float )
		
		_timeout=timeout
	End
	
	Property ReadyState:ReadyState()
		
		Return _readyState
	End
	
	Property ResponseText:String()
		
		Return _response
	End
	
	Property Status:Int()
		
		Return _status
	End
	
	Method Open( req:String,url:String )
		
		OnOpen( req,url )
	End
	
	Method SetHeader( header:String,value:String )
		
		OnSetHeader( header,value )
	End
	
	Method Send( text:String="" )
		
		OnSend( text )
	End
	
	Method Cancel()
		
		OnCancel()
	End
	
	Protected
	
	Field _readyState:ReadyState
	Field _timeout:Float=60.0
	Field _response:String
	Field _status:Int=-1
	Field _req:String
	Field _url:String
	
	Method New()
		
		_readyState=ReadyState.Unsent
		_timeout=10
		_status=-1
	End
	
	Method OnOpen( req:String,url:String ) Virtual
		_req=req
		_url=url
		SetReadyState( ReadyState.Opened )
	End

	Method OnSetHeader( header:String,value:String ) Virtual
	End
	
	Method OnSend( text:String ) Abstract
	
	Method OnCancel() Virtual
	End
	
	Method SetReadyState( readyState:ReadyState )
		
		If readyState=_readyState Return
		
		_readyState=readyState
		
		ReadyStateChanged()
	End
	
End

