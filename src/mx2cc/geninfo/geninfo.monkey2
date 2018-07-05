
Namespace mx2.geninfo

#rem

Possible optimizations:

* Use semType for functions.

* Erase blocks with no vardecls.

* Remove 'monkey.types.' prefix from primitive sem types.

#end

Class GeninfoGenerator

	Method GenParseInfo:JsonValue( fdecl:FileDecl )
	
		Local node:=GenNode( fdecl )
		
		Return node
	End
	
	Method GenSemantInfo()
		
		For Local fdecl:=Eachin Builder.mainModule.fileDecls
			
			If Not fdecl.gpath Continue
			
'			Print "path="+fdecl.path+" gpath="+fdecl.gpath
			
			Local jobj:=GenParseInfo( fdecl )
			
			Local json:=jobj.ToJson()
			
			CreateDir( ExtractDir( fdecl.gpath ) )
			
			CSaveString( json,fdecl.gpath )
		Next
		
	End
	
	Private

	Method GenNode<T>:JsonArray( args:T[] )
	
		Local jarr:=New JsonArray
		
		For Local arg:=Eachin args
			If Not arg Continue
			
'			Local jval:=GenNode( arg )
'			If jval jarr.Add( jval )

			Local jval:=GenNode( arg )
			If Not jval Continue
			
			Local jarr2:=Cast<JsonArray>( jval )
			
			If jarr2 
				For Local jval:=Eachin jarr2
					jarr.Add( jval )
				Next
			Else
				jarr.Add( jval )
			Endif
		Next
		
		Return jarr
	End
	
	Method GenNode:JsonArray( args:String[] )

		Local jarr:=New JsonArray
			
		For Local arg:=Eachin args
			jarr.Add( New JsonString( arg ) )
		Next
		
		Return jarr
	End
	
	'Decls...
	'
	Method MakeNode:JsonObject( decl:Decl )
	
		Local node:=New JsonObject

		node.SetString( "srcpos",(decl.srcpos Shr 12)+":"+(decl.srcpos & $fff) )
		node.SetString( "endpos",(decl.endpos Shr 12)+":"+(decl.endpos & $fff) )
		node.SetString( "kind",decl.kind )
		node.SetString( "ident",decl.ident )
		node.SetNumber( "flags",decl.flags )
		
		If decl.members node.SetValue( "members",GenNode( decl.members ) )
		
		Return node
	End
	
	Method GenNode:JsonValue( decl:Decl )
	
		Local classDecl:=Cast<ClassDecl>( decl )
		If classDecl Return GenNode( classDecl )
		
		Local funcDecl:=Cast<FuncDecl>( decl )
		If funcDecl Return GenNode( funcDecl )
		
		Local aliasDecl:=Cast<AliasDecl>( decl )
		If aliasDecl Return GenNode( aliasDecl )
		
		Local varDecl:=Cast<VarDecl>( decl )
		If varDecl Return GenNode( varDecl )
		
		Local propertyDecl:=Cast<PropertyDecl>( decl )
		If propertyDecl Return GenNode( propertyDecl )
		
		Return MakeNode( decl )
	End

	Method GenNode:JsonValue( decl:FileDecl )
	
		local node:=MakeNode( decl )
		
		node.SetString( "namespace",decl.nmspace )
		
		If decl.imports node.SetValue( "imports",GenNode( decl.imports ) )
		If decl.usings node.SetValue( "usings",GenNode( decl.usings ) )
		
		Return node
	End
	
	Method GenNode:JsonValue( decl:ClassDecl )
	
		Local node:=MakeNode( decl )
		
		If decl.genArgs node.SetValue( "genArgs",GenNode( decl.genArgs ) )
		
		If decl.superType node.SetValue( "superType",GenNode( decl.superType ) )
		
		If decl.ifaceTypes node.SetValue( "ifaceTypes",GenNode( decl.ifaceTypes ) )
		
		Return node
	End

	Method GenNode:JsonValue( decl:FuncDecl )

		Local node:=MakeNode( decl )
		
		If decl.genArgs node.SetValue( "genArgs",GenNode( decl.genArgs ) )
		
		If decl.type node.SetValue( "type",GenNode( decl.type ) )
		
		If decl.whereExpr node.SetValue( "where",GenNode( decl.whereExpr ) )
			
		If decl.stmts node.SetValue( "stmts",GenNode( decl.stmts ) )
			
		Return node
	End
	
	Method GenNode:JsonValue( decl:AliasDecl )

		Local node:=MakeNode( decl )
		
		If decl.genArgs node.SetValue( "genArgs",GenNode( decl.genArgs ) )
		
		If decl.type node.SetValue( "type",GenNode( decl.type ) )
		
		Return node
	End
	
	Method GenNode:JsonValue( decl:VarDecl )
	
		Local node:=MakeNode( decl )
		
		If decl.type node.SetValue( "type",GenNode( decl.type ) )
		
		If decl.init node.SetValue( "init",GenNode( decl.init ) )
			
		If decl.semtype node.SetString( "semtype",decl.semtype.Name )
			
		Return node
	End
	
	Method GenNode:JsonValue( decl:PropertyDecl )
	
		Local node:=MakeNode( decl )
		
		If decl.getFunc node.SetValue( "getFunc",GenNode( decl.getFunc ) )
		
		If decl.setFunc node.SetValue( "setFunc",GenNode( decl.setFunc ) )
		
		Return node
	
	End
	
	'StmtExprs...
	Method MakeNode:JsonObject( stmt:StmtExpr,kind:String )
	
		Local node:=New JsonObject

		node.SetString( "srcpos",(stmt.srcpos Shr 12)+":"+(stmt.srcpos & $fff) )
		node.SetString( "endpos",(stmt.endpos Shr 12)+":"+(stmt.endpos & $fff) )
		node.SetString( "kind",kind )
		
		Return node
	End
	
	Method GenNode:JsonValue( stmt:StmtExpr )
		
		Local vdeclStmt:=Cast<VarDeclStmtExpr>( stmt )
		If vdeclStmt Return GenNode( vdeclStmt.decl )
		
		Local ifStmt:=Cast<IfStmtExpr>( stmt )
		If ifStmt Return GenNode( ifStmt )
		
		Local whileStmt:=Cast<WhileStmtExpr>( stmt )
		If whileStmt Return GenNode( whileStmt )
		
		Local repeatStmt:=Cast<RepeatStmtExpr>( stmt )
		If repeatStmt Return GenNode( repeatStmt )
		
		Local selectStmt:=Cast<SelectStmtExpr>( stmt )
		If selectStmt Return GenNode( selectStmt )
		
		Local forStmt:=Cast<ForStmtExpr>( stmt )
		If forStmt Return GenNode( forStmt )
		
		Local tryStmt:=Cast<TryStmtExpr>( stmt )
		If tryStmt Return GenNode( tryStmt )
		
		Return Null
	End
	
	Method GenNode:JsonValue( ifStmt:IfStmtExpr )

		Local jarr:=New JsonArray
		While ifStmt
			Local jobj:=MakeNode( ifStmt,"block" )
			jobj.SetValue( "stmts",GenNode( ifStmt.stmts ) )
			jarr.Add( jobj )
			ifStmt=ifStmt.succ
		Wend
		Return jarr
	End
	
	Method GenNode:JsonValue( whileStmt:WhileStmtExpr )
		
		Local jobj:=MakeNode( whileStmt,"block" )
		jobj.SetValue( "stmts",GenNode( whileStmt.stmts ) )
		Return jobj
	End
	
	Method GenNode:JsonValue( repeatStmt:RepeatStmtExpr )

		Local jobj:=MakeNode( repeatStmt,"block" )
		jobj.SetValue( "stmts",GenNode( repeatStmt.stmts ) )
		Return jobj
	End
	
	Method GenNode:JsonValue( selectStmt:SelectStmtExpr )
		
		Local jarr:=New JsonArray
		For Local caseStmt:=Eachin selectStmt.cases
			Local jobj:=MakeNode( caseStmt,"block" )
			jobj.SetValue( "stmts",GenNode( caseStmt.stmts ) )
			jarr.Add( jobj )
		Next
		Return jarr
	End
	
	Method GenNode:JsonValue( forStmt:ForStmtExpr )
		
		Local jobj:=MakeNode( forStmt,"block" )
		
'		jobj.SetValue( "stmts",GenNode( forStmt.stmts ) )

		Local jarr:=New JsonArray
		
		If forStmt.semVar jarr.Add( GenNode( forStmt.semVar.vdecl ) )

		For Local stmt:=Eachin forStmt.stmts
			Local jval:=GenNode( stmt )
			If Not jval Continue
			
			Local jarr2:=Cast<JsonArray>( jval )
			If jarr2 
				For Local jval:=Eachin jarr2
					jarr.Add( jval )
				Next
				Continue
			Endif
			jarr.Add( jval )
		Next
		
		jobj.SetValue( "stmts",jarr )
		
		Return jobj
	End
	
	Method GenNode:JsonValue( tryStmt:TryStmtExpr )

		Local jarr:=New JsonArray
		Local jobj:=MakeNode( tryStmt,"block" )
		jobj.SetValue( "stmts",GenNode( tryStmt.stmts ) )
		jarr.Add( jobj )
		For Local catchStmt:=Eachin tryStmt.catches
			Local jobj:=MakeNode( catchStmt,"block" )
			jobj.SetValue( "stmts",GenNode( catchStmt.stmts ) )
			jarr.Add( jobj )
		Next
		Return jarr
	End
	
	'Expressions...
	'
	Method MakeNode:JsonObject( expr:Expr,kind:String )
	
		Local node:=New JsonObject

		node.SetString( "srcpos",(expr.srcpos Shr 12)+":"+(expr.srcpos & $fff) )
		node.SetString( "endpos",(expr.endpos Shr 12)+":"+(expr.endpos & $fff) )
		node.SetString( "kind",kind )
		
		Return node
	End
	
	Method GenNode:JsonValue( expr:Expr )
		
		Local identExpr:=Cast<IdentExpr>( expr )
		If identExpr Return GenNode( identExpr )
		
		Local memberExpr:=Cast<MemberExpr>( expr )
		If memberExpr Return GenNode( memberExpr )
		
		Local genericExpr:=Cast<GenericExpr>( expr )
		If genericExpr Return GenNode( genericExpr )
		
		Local literalExpr:=Cast<LiteralExpr>( expr )
		If literalExpr Return GenNode( literalExpr )

		Local newObjectExpr:=Cast<NewObjectExpr>( expr )
		If newObjectExpr Return GenNode( newObjectExpr )

		Local newArrayExpr:=Cast<NewArrayExpr>( expr )
		If newArrayExpr Return GenNode( newArrayExpr )
				
		Local funcTypeExpr:=Cast<FuncTypeExpr>( expr )
		If funcTypeExpr Return GenNode( funcTypeExpr )
		
		Local arrayTypeExpr:=Cast<ArrayTypeExpr>( expr )
		If arrayTypeExpr Return GenNode( arrayTypeExpr )
		
		Local pointerTypeExpr:=Cast<PointerTypeExpr>( expr )
		If pointerTypeExpr Return GenNode( pointerTypeExpr )
		
		Return MakeNode( expr,"????Expr?????" )
	End
	
	Method GenNode:JsonValue( expr:IdentExpr )
	
		Local node:=MakeNode( expr,"ident" )
		
		node.SetString( "ident",expr.ident )
		
		Return node
	End
	
	Method GenNode:JsonValue( expr:MemberExpr )
	
		Local node:=MakeNode( expr,"member" )
		
		node.SetValue( "expr",GenNode( expr.expr ) )
		
		node.SetString( "ident",expr.ident )
	
		Return node
	End
	
	Method GenNode:JsonValue( expr:GenericExpr )

		Local node:=MakeNode( expr,"generic" )
		
		node.SetValue( "expr",GenNode( expr.expr ) )
		
		node.SetValue( "args",GenNode( expr.args ) )
		
		Return node
	End
	
	Method GenNode:JsonValue( expr:LiteralExpr )
	
		Local node:=MakeNode( expr,"literal" )
		
		node.SetString( "toke",expr.toke )
		
		Return node
	End
	
	Method GenNode:JsonValue( expr:NewObjectExpr )
	
		Local node:=MakeNode( expr,"newobject" )
		
		node.SetValue( "type",GenNode( expr.type ) )
		
		node.SetValue( "args",GenNode( expr.args ) )
		
		Return node
	End
		
	Method GenNode:JsonValue( expr:NewArrayExpr )
	
		Local node:=MakeNode( expr,"newarray" )
		
		node.SetValue( "type",GenNode( expr.type ) )
		
		If expr.sizes node.SetValue( "sizes",GenNode( expr.sizes ) )

		If expr.inits node.SetValue( "inits",GenNode( expr.inits ) )
		
		Return node
	End
		
	Method GenNode:JsonValue( expr:FuncTypeExpr )

		Local node:=MakeNode( expr,"functype" )
		
		node.SetValue( "retType",GenNode( expr.retType ) )
		
		node.SetValue( "params",GenNode( expr.params ) )
		
		Return node
	End

	Method GenNode:JsonValue( expr:ArrayTypeExpr )
	
		Local node:=MakeNode( expr,"arraytype" )
		
		node.SetValue( "type",GenNode( expr.type ) )
		
		node.SetNumber( "rank",expr.rank )
		
		Return node
	End
	
	Method GenNode:JsonValue( expr:PointerTypeExpr )
	
		Local node:=MakeNode( expr,"pointertype" )
		
		node.SetValue( "type",GenNode( expr.type ) )
		
		Return node
	End
	
End
