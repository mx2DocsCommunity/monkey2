
Namespace iap

#Import "<sdl2>"
#Import "<jni>"

#Import "native/Monkey2IAP.java"

Using jni..

Class Product
	
	Method New( identifier:String,type:ProductType )
		Init()
		
		_instance=Env.NewObject( _class,_ctor,New Variant[]( identifier,Cast<Int>( type ) ) )
		
		_globalref=Env.NewGlobalRef( _instance )
	End
	
	Property Identifier:String()
		
		Return Env.GetStringField( _instance,_identifier )
	End
	
	Property Type:ProductType()
		
		Return Cast<ProductType>( Env.GetIntField( _instance,_type ) )
	End

	Property Valid:Bool()
		
		Return Env.GetBooleanField( _instance,_valid )
	End
	
	Property Title:String()
		
		Return Env.GetStringField( _instance,_title )
	End
	
	Property Description:String()
		
		Return Env.GetStringField( _instance,_description )
	End
	
	Property Price:String()
		
		Return Env.GetStringField( _instance,_price )
	End
	
	Internal
	
	Property Owned:Bool()
		
		Return Env.GetBooleanField( _instance,_owned )
	End
	
	Property Interrupted:Bool()
		
		Return Env.GetBooleanField( _instance,_interrupted )
	End
	
	Private
	
	Global _class:jclass
	Global _ctor:jmethodID
	
	Global _valid:jfieldID
	Global _title:jfieldID
	Global _description:jfieldID
	Global _price:jfieldID
	Global _identifier:jfieldID
	Global _type:jfieldID
	Global _owned:jfieldID
	Global _interrupted:jfieldID

	Function Init()
		
		If _class Return

		Local env:=sdl2.Android_JNI_GetEnv()

		_class=env.FindClass( "com/monkey2/lib/Monkey2IAP$Product" )
		_ctor=env.GetMethodID( _class,"<init>","(Ljava/lang/String;I)V" )
		
		_valid=env.GetFieldID( _class,"valid","Z" )
		_title=env.GetFieldID( _class,"title","Ljava/lang/String;" )
		_description=env.GetFieldID( _class,"description","Ljava/lang/String;" )
		_price=env.GetFieldID( _class,"price","Ljava/lang/String;" )
		_identifier=env.GetFieldID( _class,"identifier","Ljava/lang/String;" )
		_type=env.GetFieldID( _class,"type","I" )
		_owned=env.GetFieldID( _class,"owned","Z" )
		_interrupted=env.GetFieldID( _class,"interrupted","Z" )
	End
	
	Field _instance:jobject
	Field _globalref:jobject

	Property Env:JNIEnv()
		
		Return sdl2.Android_JNI_GetEnv()
	End
	
End

Internal

Class IAPStoreRep
	
	Method New()
		
		Init()
		
		_instance=Env.NewObject( _class,_ctor,Null )
	End
	
	Method OpenStoreAsync:Bool( products:Product[] )
		
		Local jarray:jobjectArray=Env.NewObjectArray( products.Length,Product._class,Null )
		
		For Local i:=0 Until products.Length
			
			Env.SetObjectArrayElement( jarray,i,products[i]._instance )
		Next
		
		Return Env.CallBooleanMethod( _instance,_openstoreasync,New Variant[]( Cast<jobject>( jarray ) ) )
	End
	
	Method BuyProductAsync:Bool( product:Product )
		
		Return Env.CallBooleanMethod( _instance,_buyproductasync,New Variant[]( product._instance ) )
	End
			
	Method GetOwnedProductsAsync:Bool()
		
		Return Env.CallBooleanMethod( _instance,_getownedproductsasync,Null )
	End
	
	Method CloseStore:Void()
	End
	
	Method IsRunning:Bool()
		
		Return Env.CallBooleanMethod( _instance,_isrunning,Null )
	End
	
	Method GetResult:Int()
		
		Return Env.CallIntMethod( _instance,_getresult,Null )
	End
	
	Function CanMakePayments:Bool()
		
		Return True
	End
	
	Private
	
	Global _class:jclass
	Global _ctor:jmethodID

	Global _openstoreasync:jmethodID
	Global _buyproductasync:jmethodID
	Global _getownedproductsasync:jmethodID
	Global _isrunning:jmethodID
	Global _getresult:jmethodID
	
	Method Init()
		
		If _class Return

		Local env:=sdl2.Android_JNI_GetEnv()

		_class=env.FindClass( "com/monkey2/lib/Monkey2IAP" )
		_ctor=env.GetMethodID( _class,"<init>","()V" )
		
		_openstoreasync=env.GetMethodID( _class,"OpenStoreAsync","([Lcom/monkey2/lib/Monkey2IAP$Product;)Z" )
		_buyproductasync=env.GetMethodID( _class,"BuyProductAsync","(Lcom/monkey2/lib/Monkey2IAP$Product;)Z" )
		_getownedproductsasync=env.GetMethodID( _class,"GetOwnedProductsAsync","()Z" )
		_isrunning=env.GetMethodID( _class,"IsRunning","()Z" )
		_getresult=env.GetMethodID( _class,"GetResult","()I" )
		
	End
	
	Field _instance:jobject
	
	Property Env:JNIEnv()
		
		Return sdl2.Android_JNI_GetEnv()
	End
	
End
