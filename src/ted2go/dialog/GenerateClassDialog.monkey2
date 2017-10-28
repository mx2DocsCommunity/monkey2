
Namespace ted2go


#Import "../assets/gen/@/gen"

Class GenerateClassDialog Extends DialogExt
	
	Field Generated:Void( filePath:String,fileContent:String )
	
	Method New( rootPath:String )
		
		_path=rootPath
		
		Title="Generate class"
		
		Local dock:=New DockingView
		
		_codeView=New Ted2CodeTextView
		_codeView.FileType=".monkey2"
		_codeView.MinSize=New Vec2i( 200,200 )
		dock.AddView( _codeView,"bottom" )
		
		_codeTemplate=LoadString( "asset::gen/newClass.txt" )
		
		Local table:=New TableView( 2,5 )
		
		table[0,0]=New Label( "Class name" )
		_editClassName=CreateTextField()
		_editClassName.TextChanged+=Lambda()
			_editFileName.Text=ClassName+".monkey2"
		End
		table[1,0]=_editClassName
		
		table[0,1]=New Label( "SuperClass name" )
		_editSuperClassName=CreateTextField()
		table[1,1]=_editSuperClassName
		
		table[0,2]=New Label( "Interface(s) name" )
		_editInterfacesName=CreateTextField()
		table[1,2]=_editInterfacesName
		
		table[0,3]=New Label( "Namespace" )
		_editNamespace=CreateTextField()
		table[1,3]=_editNamespace
		
		table[0,4]=New Label( "File name" )
		_editFileName=New TextFieldExt
		table[1,4]=_editFileName
		
		dock.AddView( table,"bottom" )
		
		ContentView=dock
		
		Local cancel:=AddAction( "Cancel"  )
		cancel.Triggered=lambda()
			HideWithResult( False )
		End
		SetKeyAction( Key.Escape,cancel )
		
		Local okay:=AddAction( "Generate" )
		okay.Triggered=Lambda()
			OnGenerate()
		End
		SetKeyAction( Key.Enter,okay )
		
		OnShow+=Lambda()
			_editClassName.MakeKeyView()
		End
		
		AdjustTabOrder()
		UpdateCodeView()
		
	End
	
	Property ClassName:String()
	
		Return _editClassName.Text.Trim()
	End
	
	Property SuperClassName:String()
	
		Return _editSuperClassName.Text.Trim()
	End
	
	Property InterfacesName:String()
	
		Return _editInterfacesName.Text.Trim()
	End
	
	Property NamespaceName:String()
	
		Return _editNamespace.Text.Trim()
	End
	
	Property FileName:String()
	
		Local s:=_editFileName.Text.Trim()
		If Not ExtractExt( s ) Then s+=".monkey2"
		Return s
	End
	
	Property GeneratedContent:String()
	
		Local s:=_codeTemplate,n:String
		s=s.Replace( "_NAME_",ClassName )
		n=NamespaceName
		s=s.Replace( "_NAMESPACE_",n ? ("Namespace "+n) Else "" )
		n=SuperClassName
		s=s.Replace( "_SUPERCLASS_",n ? (" Extends "+n) Else "" )
		n=InterfacesName
		s=s.Replace( "_INTERFACES_",n ? (" Implements "+n) Else "" )
		Return s
	End
	
	Private
	
	Field _path:String
	Field _codeTemplate:String
	Field _editNamespace:TextFieldExt
	Field _editClassName:TextFieldExt
	Field _editSuperClassName:TextFieldExt
	Field _editInterfacesName:TextFieldExt
	Field _editFileName:TextFieldExt
	Field _codeView:Ted2CodeTextView
	
	
	Method OnGenerate()
		
		If Not IsIdentStr( ClassName,False )
			Alert( "Class name is invalid or empty!",Title )
			Return
		Endif
		If SuperClassName And Not IsIdentStr( SuperClassName )
			Alert( "SuperClass name is invalid!",Title )
			Return
		Endif
		If NamespaceName And Not IsIdentStr( NamespaceName )
			Alert( "Namespace is invalid!",Title )
			Return
		Endif
		If InterfacesName
			Local arr:=InterfacesName.Split( "," )
			For Local i:=Eachin arr
				i=i.Trim()
				If Not IsIdentStr( i )
					Alert( "Interface name '"+i+"' is invalid!",Title )
					Return
				Endif
			Next
		Endif
		
		Local path:=_path+"/"+FileName
		If FileExists( path )
			Alert( "File with such name already exists!",Title )
			Return
		Endif
		
		HideWithResult( True )
		
		Generated( path,GeneratedContent )
	End
	
	Method UpdateCodeView()
		
		_codeView.Text=GeneratedContent
	End
	
	Method CreateTextField:TextFieldExt()
		
		Local tf:=New TextFieldExt
		tf.TextChanged+=UpdateCodeView
		Return tf
	End
	
	Method AdjustTabOrder()
		
		_editClassName.NextView=_editSuperClassName
		_editSuperClassName.NextView=_editInterfacesName
		_editInterfacesName.NextView=_editNamespace
		_editNamespace.NextView=_editFileName
		'_editFileName.NextView=_codeView
		
	End
	
End
