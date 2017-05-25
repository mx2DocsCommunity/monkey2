
Namespace mojo.graphics

#rem monkeydoc The UniformBlock class.
#end
Class UniformBlock Extends Resource

	Method New( name:Int )
		_name=name
	End
	
	Method New( uniforms:UniformBlock )
		_name=uniforms._name
		For Local i:=0 Until _uniforms.Length
			_uniforms[i]=uniforms._uniforms[i]
		Next
	End
	
	Property Name:Int()
		Return _name
	End
	
	Function GetUniformId:Int( name:String,block:Int )
		Local ids:=_ids[block]
		If Not ids
			ids=New StringMap<Int>
			_ids[block]=ids
		Endif
		Local id:=ids[name]
		If Not id
			id=ids.Count()+1
			ids[name]=id
		Endif
		Return id
	End
	
	Method GetUniformId:Int( name:String )
		Return GetUniformId( name,_name )
	End
	
	Method GetUniformId:Int( name:String,type:Type )
		Local id:=GetUniformId( name,_name )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return id
	End

	'***** Float *****
	'	
	Method SetFloat( uniform:String,value:Float )
		SetFloatData( uniform,value,Type.Scalar )
	End
	
	Method GetFloat:Float( uniform:String )
		Return GetFloatData<Float>( uniform,Type.Scalar )
	End
	
	Method GetFloat:Float( id:Int )
		Return GetFloatPtr( id,Type.Scalar )[0]
	End
	
	'***** Vec2f *****
	'
	Method SetVec2f( uniform:String,value:Vec2f )
		SetFloatData( uniform,value,Type.Vec2f )
	End
	
	method GetVec2f:Vec2f( uniform:String )
		Return GetFloatData<Vec2f>( uniform,Type.Vec2f )
	End
	
	Method GetVec2fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec2f )
	End
	
	'***** Vec3f *****
	'
	Method SetVec3f( uniform:String,value:Vec3f )
		SetFloatData( uniform,value,Type.Vec3f )
	End

	Method GetVec3f:Vec3f( uniform:String )
		Return GetFloatData<Vec3f>( uniform,Type.Vec3f )
	End
	
	Method GetVec3fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec3f )
	End

	'***** Vec4f *****
	'	
	Method SetVec4f( uniform:String,value:Vec4f )
		SetFloatData( uniform,value,Type.Vec4f )
	End

	Method GetVec4f:Vec4f( uniform:String )
		Return GetFloatData<Vec4f>( uniform,Type.Vec4f )
	End
	
	Method GetVec4fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec4f )
	End
	
	'***** Mat3f *****
	'
	Method SetMat3f( uniform:String,value:Mat3f )
		SetFloatData( uniform,value,Type.Mat3f )
	End

	Method GetMat3f:Mat3f( uniform:String )
		Return GetFloatData<Mat3f>( uniform,Type.Mat3f )
	End
	
	Method GetMat3fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Mat3f )
	End
	
	'***** Mat4f *****
	'
	Method SetMat4f( uniform:String,value:Mat4f )
		SetFloatData( uniform,value,Type.Mat4f )
	End

	Method SetMat4f( uniform:String,value:AffineMat4f )
		SetFloatData( uniform,New Mat4f( value ),Type.Mat4f )
	End

	Method GetMat4f:Mat4f( uniform:String )
		Return GetFloatData<Mat4f>( uniform,Type.Mat4f )
	End
	
	Method GetMat4fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Mat4f )
	End

	'***** Mat4f array *****
	'
	Method SetMat4fArray( uniform:String,value:Mat4f[] )
		Local id:=GetUniformId( uniform )
		_uniforms[id].mat4fArray=value
		_uniforms[id].type=Type.Mat4fArray
		_seq=_gseq
		_gseq+=1
	End
	
	Method GetMat4fArray:Mat4f[]( uniform:String )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=Type.Mat4fArray,"Invalid uniform type" )
		Return _uniforms[id].mat4fArray
	End

	Method GetMat4fArrayv:Float Ptr( id:Int )
		DebugAssert( _uniforms[id].type=Type.Mat4fArray,"Invalid uniform type" )
		Return Varptr _uniforms[id].mat4fArray[0].i.x
	End
	
	'***** Texture *****
	'
	Method SetTexture( uniform:String,value:Texture )
		Local id:=GetUniformId( uniform )
		_uniforms[id].texture=value
		_uniforms[id].type=Type.Texture
		_seq=_gseq
		_gseq+=1
	End

	Method GetTexture:Texture( uniform:String )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=Type.Texture,"Invalid uniform type" )
		Return _uniforms[id].texture
	End
	
	Method GetTexture:Texture( id:Int )
		DebugAssert( _uniforms[id].type=Type.Texture,"Invalid uniform type" )
		Return _uniforms[id].texture
	End
	
	#rem monkeydoc @hidden
	#end	
	Property Seq:Int()
		Return _seq
	End
	
	Private
	
	Global _gseq:Int
	Global _ids:=New StringMap<Int>[8]
	
	Enum Type
		None=0
		Scalar=1
		Vec2f=2
		Vec3f=3
		Vec4f=4
		Mat3f=5
		Mat4f=6
		Texture=7
		Mat4fArray=8
	End
	
	Struct Uniform
		Field type:Type

		Field mat4fArray:Mat4f[]
		Field texture:Texture
		
		'yuck...		
		Field fdata0:Mat4f
		Field fdata1:Mat4f
		Field fdata2:Mat4f
		Field fdata3:Mat4f
		Field fdata4:Mat4f
		Field fdata5:Mat4f
		Field fdata6:Mat4f
		Field fdata7:Mat4f
		
		Method SetFloatData<T>( t:T,type:Type )
			Cast<T Ptr>(Varptr fdata0.i.x)[0]=t
			Self.type=type
		End
		
		Method GetFloatData<T>:T()
			Return Cast<T Ptr>(Varptr fdata0.i.x)[0]
		End
		
		Method GetFloatPtr:Float Ptr()
			Return Cast<Float Ptr>(Varptr fdata0.i.x)
		End
		
	End
	
	Field _name:Int
	Field _seq:Int
	Field _uniforms:=New Uniform[64]
	
	Method SetFloatData<T>( uniform:String,data:T,type:Type )
		Local id:=GetUniformId( uniform )
		_uniforms[id].SetFloatData( data,type )
		_seq=_gseq
		_gseq+=1
	End
	
	Method GetFloatData<T>:T( uniform:String,type:Type )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return _uniforms[id].GetFloatData<T>()
	End
	
	Method GetFloatPtr:Float Ptr( id:Int,type:Type )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return _uniforms[id].GetFloatPtr()
	End
	
End
