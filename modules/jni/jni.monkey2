
Namespace jni

#If __TARGET__="android"

#Import "native/jni_glue.cpp"
#Import "native/jni_glue.h"

Extern

Struct _jclass
End
Alias jclass:_jclass Ptr

Struct _jobject
End
Alias jobject:_jobject Ptr

Struct _jstring
End
Alias jstring:_jstring Ptr

Struct _jarray
End
Alias jarray:_jarray Ptr

Struct _jobjectArray
End
Alias jobjectArray:_jobjectArray Ptr

Struct _jfieldID
End
Alias jfieldID:_jfieldID Ptr

Struct _jmethodID
End
Alias jmethodID:_jmethodID Ptr

Class JNIEnv Extends Void

	'utils
	'
	Method JStringToString:String( jstr:jstring ) Extension="bbJNI::JStringToString"
	
	Method StringToJString:jstring( str:String ) Extension="bbJNI::StringToJString"
		
	'classes
	'
	Method FindClass:jclass( name:CString )

	'fields...
	'
	Method GetFieldID:jfieldID( clazz:jclass,name:CString,sig:CString )
		
	Method GetBooleanField:Bool( obj:jobject,fieldID:jfieldID )
		
	Method GetIntField:Int( obj:jobject,fieldID:jfieldID )

	Method GetFloatField:Float( obj:jobject,fieldID:jfieldID )

	Method GetDoubleField:Double( obj:jobject,fieldID:jfieldID )

	Method GetStringField:String( obj:jobject,fieldID:jfieldID ) Extension="bbJNI::GetStringField"

	Method GetObjectField:jobject( obj:jobject,fieldID:jfieldID )
		
	'static fields...
	
	Method GetStaticFieldID:jfieldID( clazz:jclass,name:CString,sig:CString )
	
	Method GetStaticBooleanField:Bool( obj:jobject,fieldID:jfieldID )
		
	Method GetStaticIntField:Int( obj:jobject,fieldID:jfieldID )

	Method GetStaticFloatField:Float( obj:jobject,fieldID:jfieldID )

	Method GetStaticDoubleField:Double( obj:jobject,fieldID:jfieldID )

	Method GetStaticStringField:String( clazz:jclass,fieldID:jfieldID ) Extension="bbJNI::GetStaticStringField"

	Method GetStaticObjectField:jobject( clazz:jclass,fieldID:jfieldID )
		
	'methods...
	'
	Method GetMethodID:jmethodID( clazz:jclass,name:CString,sig:CString )

	Method CallVoidMethod:Void( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallVoidMethod"
	
	Method CallBooleanMethod:Bool( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallBooleanMethod"

	Method CallIntMethod:Int( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallIntMethod"
		
	Method CallFloatMethod:Float( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallFloatMethod"

	Method CallDoubleMethod:Double( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallDoubleMethod"
	
	Method CallStringMethod:String( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStringMethod"

	Method CallObjectMethod:jobject( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallObjectMethod"

	'static methods...
	'
	Method GetStaticMethodID:jmethodID( clazz:jclass,name:CString,sig:CString )
	
	Method CallStaticVoidMethod:Void( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticVoidMethod"

	Method CallStaticBooleanMethod:Bool( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticBooleanMethod"

	Method CallStaticIntMethod:int( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticIntMethod"
		
	Method CallStaticFloatMethod:Float( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticFloatMethod"

	Method CallStaticDoubleMethod:Double( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticDoubleMethod"

	Method CallStaticStringMethod:String( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticStringMethod"

	Method CallStaticObjectMethod:jobject( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticObjectMethod"
	
	'ctors...
	'
	Method AllocObject:jobject( clazz:jclass )
		
	Method NewObject:jobject( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::NewObject"
		
	Method NewObjectArray:jobjectArray( length:Int,clazz:jclass,init:jobject )
		
	Method SetObjectArrayElement( jarray:jobjectArray,index:Int,value:jobject )
		
	'refs...
	'
	Method NewGlobalRef:jobject( obj:jobject )
		
	Method DeleteGlobalRef( obj:jobject )
		
	Method DeleteLocalRef( obj:jobject )
		
	Method IsSameObject:Bool( obj1:jobject,obj2:jobject )
		
End

#End
