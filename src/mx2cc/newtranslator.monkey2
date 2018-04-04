
Class NewTranslator
	
	Method TranslateModule( module:Module )
		
		_module=module
		
		For Local fdecl:=Eachin _module.fileDecls
			
			If Builder.opts.verbose>0 Print "Translating "+fdecl.path
		
			Try
				TranslateFile( fdecl )
			Catch ex:TransEx
				Exit
			End
		Next
		
	End
	
	'does type needs to be bbGCMarked?
	'
	Function IsGCType:Bool( type:Type )
		
		If type=Type.VariantType Return true
		
		If TCast<FuncType>( type ) Return True
		
		If TCast<ArrayType>( type ) Return True
		
		Local ctype:=TCast<ClassType>( type )
		If Not ctype Return False
		
		If ctype.ExtendsVoid Return False
		
		If ctype.IsClass Or ctype.IsInterface Return True
		
		If Not ctype.IsStruct Return False
		
		For Local vvar:=Eachin ctype.fields
			If IsGCType( vvar.type ) Return True
		Next
		
		Return False
	End
	
	Private
	
	Field _module:Module
	Field _file:FileDecl
	
	Method SortClassTypes( ctype:ClassType,done:Map<SNode,Bool>,order:Stack<ClassType> )
		
		If Not ctype Or ctype.cdecl.IsExtern Or done[ctype] Return
		
		done[ctype]=True
		
		If ctype.superType SortClassTypes( ctype.superType,done,order )
			
		For Local itype:=Eachin ctype.ifaceTypes
			
			SortClassTypes( itype,done,order )
		End
		
		For Local vvar:=Eachin ctype.fields
			Local ctype:=TCast<ClassType>( vvar.type )
			If ctype And ctype.IsStruct SortClassTypes( ctype,done,order )
		Next
		
		If Not _file Or ctype.transFile=_file order.Add( ctype )
	End
	
	
	'**** TransBuf *****
	
	Field _buf:=New StringStack
	Field _insertStack:=New Stack<StringStack>
	Field _indent:String
	
	Method EmitBr()
		If _buf.Length And Not _buf.Top Return
		_buf.Push( "" )
	End
	
	Method Emit( str:String )
	
		If Not str Return
	
		If str.StartsWith( "}" ) _indent=_indent.Slice( 0,-2 )

		_buf.Push( _indent+str )

		If str.EndsWith( "{" ) _indent+="  "
	End
	
	Property InsertPos:Int()
	
		Return _buf.Length
	End
	
	Method BeginInsert( pos:Int )
	
		Local buf:=_buf.Slice( pos )
	
		_insertStack.Push( buf )
		
		_buf.Resize( pos )
	End
	
	Method EndInsert()
	
		Local buf:=_insertStack.Pop()
		
		_buf.Append( buf )
	End
	
	'***** Dependancies *****
	
	'stuff already emitted
	Field _emittedincs:=New Map<FileDecl,Bool>
	Field _emitted:=New Map<SNode,Bool>

	'stuff already added	
	Field _usesincs:=New Map<FileDecl,Bool>
	Field _usesnames:=New Map<SNode,Bool>
	Field _uses:=New Map<SNode,Bool>

	'stuff to emit...	
	Field _types:=New Stack<Type>
	Field _funcs:=New Stack<FuncValue>
	Field _vars:=New Stack<VarValue>
	Field _incs:=New Stack<FileDecl>
	
	Method EmitInclude( fdecl:FileDecl )
		
		If _emittedincs[fdecl] Return
		
		_emittedincs[fdecl]=True
	End
	
	Method EmitTypeName( type:Type )
		
		If _emitted[type] Return
		
		_emitted[type]=True
		
		Local ctype:=TCast<ClassType>( type )
		If ctype
			If Included( ctype.transFile ) Return
			
			Local cname:=ClassName( ctype )
			Emit( "struct "+cname+";" )
			
			If GenTypeInfo( ctype ) 
				If ctype.IsStruct 
					Emit( "bbTypeInfo *bbGetType("+cname+" const&);" )
				Else
					Emit( "bbTypeInfo *bbGetType("+cname+"* const&);" )
				Endif
			Endif
			
			If _debug
				Local tname:=cname
				If Not ctype.IsStruct tname+="*"
				Emit( "bbString bbDBType("+tname+"*);" )
				Emit( "bbString bbDBValue("+tname+"*);" )
			Endif
				
			Return
		Endif
		
		Local etype:=TCast<EnumType>( type )
		If etype
			If Included( etype.transFile ) Return
			
			Local ename:=EnumName( etype )
			Emit( "enum class "+ename+";" )
			
			If GenTypeInfo( etype ) 
				Emit( "bbTypeInfo *bbGetType("+ename+" const&);" )
			Endif
			
			If _debug
				Emit( "bbString bbDBType("+ename+"*);" )
				Emit( "bbString bbDBValue("+ename+"*);" )
			Endif
			
			Return
		Endif
		
	End
	
	Method EmitFuncName( func:FuncValue )

		If _emitted[func] Return
		
		_emitted[func]=True
		
		Emit( "extern "+FuncProto( func )+";" )
	End
	
	Method EmitVarName( vvar:VarValue )

		If _emitted[vvar] Return
		
		_emitted[vvar]=True
		
		Emit( "extern "+VarProto( vvar )+";" )
	End
	
	Method UsesInclude( fdecl:FileDecl )
		
		If _usesincs[fdecl] Return
		
		_usesincs[fdecl]=True
		
		_incs.Add( fdecl )
	End
	
	Method UsesTypeName( type:Type )
		
		If _usesnames[type] Return
		
		_usesnames[type]=True
		
		Local ctype:=TCast<ClassType>( type )
		If ctype
			If ctype.cdecl.IsExtern 
				UsesInclude( ctype.transFile ) 
			Else
				_types.Add( ctype )
			Endif
			Return
		Endif
		
		Local etype:=TCast<EnumType>( type )
		If etype
			_types.Add( etype )
			Return
		Endif
		
		Local ftype:=TCast<FuncType>( type )
		If ftype
			UsesTypeName( ftype.retType )
			For Local type:=Eachin ftype.argTypes
				UsesTypeName( type )
			Next
			Return
		Endif
		
		Local atype:=TCast<ArrayType>( type )
		If atype
			Local ctype:=TCast<ClassType>( atype.elemType )
			If ctype And ctype.IsStruct
				UsesType( ctype )
			Else
				UsesTypeName( atype.elemType )
			Endif
			Return
		Endif
		
		Local ptype:=TCast<PointerType>( type )
		If ptype
			UsesTypeName( ptype.elemType )
			Return
		Endif
		
		Print "OOPS: Translator confused"
	End
	
	Method UsesFuncName( func:FuncValue )
		
		If _uses[func] Return
		
		_uses[func]=True
		
		If func.fdecl.IsExtern 
			
			UsesInclude( func.transFile )
			
			Return
		Endif
		
		If func.IsStatic _funcs.Add( func )
			
		UsesTypeName( func.ftype )
	End
	
	Method UsesVarName( vvar:VarValue )
		
		If _uses[vvar] Return
		
		_uses[vvar]=True
	
		If vvar.vdecl.IsExtern
			
			UsesInclude( vvar.transFile )
			
			Return
		Endif
		
		If vvar.IsStatic _vars.Add( vvar )
		
		UsesTypeName( vvar.type )
	End
	
	Method UsesType( type:Type )
		
		If _uses[type] Return
		
		_uses[type]=True
		
		Local ctype:=TCast<ClassType>( type )
		If ctype
			UsesInclude( ctype.transFile )
			Return
		Endif
		
		Local etype:=TCast<EnumType>( type )
		If etype
			UsesInclude( etype.transFile )
			Return
		Endif
		
		UsesTypeName( type )
	End
	
	
	Method TransFile( file:FileDecl )
		
		_file=file
		
		'sort classes
		
		Local done:=New Map<SNode,Bool>
		
		Local order:=New Stack<ClassType>
		
		For Local ctype:=Eachin _file.classes
			
			SortClassTypes( ctype,node,order )
		Next
		
		_file.classes=order
		
		'create c header file
		
		_buf.Clear()
		
		EmitHeader()
		
		CSaveString( _buf.Join( "~n" ),_file.hfile )
		
		'create c source file

		_buf.Clear()
		
		EmitSource()
		
		CSaveString( _buf.Join( "~n" ),_file.cfile )
		
	End

	Method EmitCHeader()	
		
		EmitBr()
		Emit( "#ifndef MX2_"+fdecl.ident.ToUpper()+"_H" )
		Emit( "#define MX2_"+fdecl.ident.ToUpper()+"_H" )
		EmitBr()
		Emit( "#include <bbmonkey.h>" )
		
		If fdecl.exhfile
			Emit( "#include ~q"+MakeIncludePath( fdecl.exhfile,ExtractDir( fdecl.hfile ) )+"~q" )
		End

		For Local ipath:=Eachin fdecl.imports
		
			If ipath.Contains( "*." ) Continue
		
			Local imp:=ipath.ToLower()
			
			If imp.EndsWith( ".h" ) Or imp.EndsWith( ".hh" ) Or imp.EndsWith( ".hpp" )
				Local path:=ExtractDir( fdecl.path )+ipath
				Emit( "#include ~q"+MakeIncludePath( path,ExtractDir( fdecl.hfile ) )+"~q" )
				Continue
			Endif
			
			If imp.EndsWith( ".h>" ) Or imp.EndsWith( ".hh>" ) Or imp.EndsWith( ".hpp>" )
				Emit( "#include "+ipath )
				Continue
			Endif
			
		Next
		
		For Local etype:=Eachin _file.enums
			EmitTypeName( etype )
		Next
		
		For Local ctype:=Eachin _file.classes
			EmitTypeName( ctype )
		End
		
		For Local vvar:=Eachin _file.globals
			EmitVarName( vvar )
		End
		
		For Local func:=Eachin _file.functions
			EmitFuncName( func )
		End
		
	End
	
	Method EmitCSource()
	
		EmitBr()
		Emit( "#include ~q"+MakeIncludePath( fdecl.hfile,ExtractDir( fdecl.cfile ) )+"~q" )
		EmitBr()

		For Local vvar:=Eachin fdecl.globals
			Emit( VarProto( vvar )+";" )
		Next
		
		'debug info for enums...
		For Local etype:=Eachin fdecl.enums
			
			Local ename:=EnumName( etype )
			
			Emit( "bbString bbDBType("+ename+"*p){" )
			Emit( "~treturn ~q"+etype.Name+"~q;" )
			Emit( "}" )
			Emit( "bbString bbDBValue("+ename+"*p){" )
			Emit( "~treturn bbString( *(int*)p );" )
			Emit( "}" )
		Next
		
		For Local func:=Eachin fdecl.functions
			EmitFunc( func )
		Next
		
		For Local ctype:=Eachin fdecl.classes
			EmitClassMembers( ctype )
		Next

		If fdecl=_module.fileDecls[0] And Not _module.main
			EmitBr()
			Emit( "void mx2_"+_module.ident+"_main(){" )
			EmitMain()
			Emit( "}" )
		Endif
		
		EmitGlobalInits( fdecl )
		
		EndDeps( ExtractDir( fdecl.cfile ) )
		
		EmitBr()
		
	End
	
	
	Method SortClassTypes( ctype:ClassType,done:Map<SNode,Bool>,order:Stack<ClassType>,fdecl:FileDecl )
		
		If Not ctype Or ctype.cdecl.IsExtern Or done[ctype] Return
		
		done[ctype]=True
		
		If ctype.superType SortClassTypes( ctype.superType,done,order,fdecl )
			
		For Local itype:=Eachin ctype.ifaceTypes
			
			SortClassTypes( itype,done,order,fdecl )
		End
		
		For Local vvar:=Eachin ctype.fields
			Local ctype:=TCast<ClassType>( vvar.type )
			If ctype And ctype.IsStruct SortClassTypes( ctype,done,order,fdecl )
		Next
		
		If ctype.transFile=fdecl order.Add( ctype )
	End
	
	Method SortClasses:Stack<ClassType>( fdecl:FileDecl )
		
		Local done:=New Map<SNode,Bool>
		
		Local order:=New Stack<ClassType>
		
		For Local ctype:=Eachin fdecl.classes
			
			SortClassTypes( ctype,done,order,fdecl )
		Next
		
		Return order
	End

End
