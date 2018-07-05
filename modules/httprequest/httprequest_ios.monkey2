
Namespace httprequest

#Import "native/httprequest.mm"

#Import "native/httprequest.h"

Extern

Class bbHttpRequest
	
	Field readyState:Int
	Field response:String
	Field status:Int
	Field readyStateChanged:Void()
	
	Method open( req:String,url:String )
	Method setHeader( name:String,value:String )
	Method send( text:String,timeout:float )
	Method cancel()
End

Public

Class HttpRequest Extends HttpRequestBase

	Method New()
	
		_peer=New bbHttpRequest
		
		_peer.readyStateChanged=OnReadyStateChanged
	End
	
	Protected
	
	Method OnReadyStateChanged()
	
		If _peer.readyState=4
			_response=_peer.response
			_status=_peer.status
		Endif
	
		SetReadyState( Cast<ReadyState>( _peer.readyState ) )
	End
	
	Method OnOpen( req:String,url:String ) Override
	
		_peer.open( req,url )
	End
	
	Method OnSetHeader( name:String,value:String ) Override
	
		_peer.setHeader( name,value )
	End
	
	Method OnSend( text:String ) Override
	
		_peer.send( text,_timeout )
	End
	
	Method OnCancel() Override
	
		_peer.cancel()
	End
	
	Private
	
	Field _peer:bbHttpRequest
	
End

