
Namespace ted2go


#Rem monkeydoc Container class that stores bindings of type <-> realization_of_type.
Type can be interface or class type.
#End
Class Di Final
	
	#Rem monkeydoc This function add new binding.
	
	You can add the only type of T function.
	
	@param bindFunc a function that provide realization of T type
	@param singleton if true - we want to have the only instance of T (singleton), if false - we want to instantiate new T every call of Resolve()
	#End
	Function Bind<T>( bindFunc:T(),singleton:Bool=True )
		
		Local type:=Typeof<T>
		If singleton
			Assert( Not BINDERS_SINGLE.Contains( type ),"Di-container : type "+type+" already exists!" )
			BINDERS_SINGLE[type]=bindFunc
		Else
			Assert( Not BINDERS_NEW_INST.Contains( type ),"Di-container : type "+type+" already exists!" )
			BINDERS_NEW_INST[type]=bindFunc
		Endif
		
	End
	
	#Rem monkeydoc Binding with parameterless constructor of T.
	#End
	Function Bind<T>( singleton:Bool=True )
		
		Bind( Lambda:T()
			Return New T
		End, 
		singleton )
	End
	
	#Rem monkeydoc This function return instance of T.
	
	If type was added as singleton - we always will get the same instance.
	Otherwise - we always will get new instance.
	#End
	Function Resolve<T>:T()
		
		Local type:=Typeof<T>
		Local binder:=BINDERS_NEW_INST[type]
		If binder<>Null
			Return Cast<T()>( binder )()
		Endif
		
		Local result:=SINGLETONS[type]
		If result=Null
			
			binder=BINDERS_SINGLE[type]
			If binder
				Local result2:=Cast<T()>( binder )()
				Assert( result2<>Null,"Di-container: realization for "+type+" not found!" )
				SINGLETONS[type]=result2
				
				Return result2
			Endif
			
		Endif
		
		Assert( result<>Null,"Di-container: realization for "+type+" not found!" )
		
		Return Cast<T>( result )
	End
	
	Private
	
	Const SINGLETONS:=New Map<TypeInfo,Variant>
	Const BINDERS_NEW_INST:=New Map<TypeInfo,Variant>
	Const BINDERS_SINGLE:=New Map<TypeInfo,Variant>
	
End
