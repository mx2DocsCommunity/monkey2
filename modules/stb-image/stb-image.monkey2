
Namespace stb.image

#Import "native/stb_image.cpp"
#Import "native/stb_image.h"

Extern

Struct stbi_char="char"
End

Struct stbi_io_callbacks
	Field read:Int( Void Ptr,stbi_char Ptr,Int )
	Field skip:Void( Void Ptr,Int )
	Field eof:Int( Void Ptr )
End

Function stbi_load:UByte Ptr( filename:CString,x:Int Ptr,y:Int Ptr,comp:Int Ptr,req_comp:Int )
Function stbi_load_from_memory:UByte Ptr( buffer:UByte Ptr,len:Int,x:Int Ptr,y:Int Ptr,comp:Int Ptr,req_comp:Int )
Function stbi_load_from_callbacks:UByte Ptr( clbk:stbi_io_callbacks Ptr,user:Void Ptr,x:Int Ptr,y:Int Ptr,comp:Int Ptr,req_comp:Int )

Function stbi_image_free( data:Void Ptr )
