
Namespace ted2go


Class ExamplesView Extends DockingView
	
	Method New( docs:DocumentManager )
		
		Super.New()
		
		_docs=docs
		
		_tree=New TreeViewExt
		
		' load projects when first time expanding node
		'
		_tree.NodeExpanded+=Lambda( n:TreeView.Node )
			
			Local node:=GetNodeWithData( n )
			If Not node Or node.data.loaded Return
			node.RemoveAllChildren() ' remove dummy item
			
			FillNode( node,node.data.path )
			UpdateIcons( n )
		End
		
		_tree.NodeClicked+=Lambda( node:TreeView.Node )
			
			If Prefs.MainProjectSingleClickExpanding Then OnOpenDocument( node )
		End
		
		_tree.NodeDoubleClicked+=Lambda( node:TreeView.Node )
			
			If Not Prefs.MainProjectSingleClickExpanding Then OnOpenDocument( node )
		End
		
	End
	
	Method Init()
		
		If _inited Return
		
		_inited=True
		
		Local label:=New Label( "Collecting data..." )
		label.Gravity=New Vec2f( 0,0 )
		
		ContentView=label
		
		LoadData()
		
	End
	
	
	Private
	
	Const VALID_FOLDERS:=New String[]( "bananas","examples","samples","tests" )
	
	Field _tree:TreeViewExt
	Field _dirIcon:Image
	Field _fileIcon:Image
	Field _docs:DocumentManager
	Field _inited:Bool
	
	Method LoadData()
		
		New Fiber( Lambda()
			
			Fiber.Sleep( 1.5 )
			
			Local folders:=New StringStack
			Local path:=Prefs.MonkeyRootPath+"bananas/"
			
			' bananas
			For Local file:=Eachin LoadDir( path )
				If file<>"ted2go-showcase" And GetFileType( path+file )=FileType.Directory
					folders.Add( path+file )
				Endif
			Next
			
			' other
			CollectFolders( Prefs.MonkeyRootPath+"modules/",folders )
			
			For Local section:=Eachin VALID_FOLDERS
				Local node:=New TreeViewExt.Node( section,_tree.RootNode )
				For Local folder:=Eachin folders
					If folder.Contains( "/"+section )
						Local full:=folder+"/"
						folder=folder.Replace( "/"+section,"" )
						folder=folder.Replace( Prefs.MonkeyRootPath,"" )
						Local subNode:=New NodeWithData<FolderData>( folder,node )
						Local data:=New FolderData
						data.path=full
						subNode.data=data
						' create dummy to show that it has children
						New TreeViewExt.Node( "---",subNode )
					Endif
				Next
			Next
			
			_tree.Sort()
			_tree.RootNode.Expanded=True
			_tree.RootNodeVisible=False
			
			UpdateIcons( _tree.RootNode )
			
			ContentView=_tree
		End )
	End
	
	Method GetNodeWithData:NodeWithData<FolderData>( node:TreeView.Node )
		
		Return Cast<NodeWithData<FolderData>>( node )
	End
	
	Method OnOpenDocument( n:TreeView.Node )
		
		Local node:=GetNodeWithData( n )
		If node And FileExists( node.data.path )
			_docs.OpenDocument( node.data.path,True )
			_docs.LockBuildFile()
		Endif
	End
	
	Method OnValidateStyle() Override
	
		Super.OnValidateStyle()
		
		_dirIcon=ProjectBrowserView.GetFileTypeIcon( "._dir" )
		_fileIcon=ProjectBrowserView.GetFileTypeIcon( "._file" )
		
		UpdateIcons( _tree.RootNode )
	End
	
	Method UpdateIcons( n:TreeView.Node )
		
		Local node:=GetNodeWithData( n )
		If node
			Local icon:=ProjectBrowserView.GetFileTypeIcon( node.data.path )
			If Not icon
				icon=(GetFileType( node.data.path )=FileType.Directory) ? _dirIcon Else _fileIcon
			Endif
			n.Icon=icon
		Else
			n.Icon=(n.NumChildren>0) ? _dirIcon Else _fileIcon
		Endif
		
		For Local child:=Eachin n.Children
			UpdateIcons( child )
		Next
	End
	
	Method FillNode( n:TreeView.Node,path:String )
		
		Local node:=GetNodeWithData( n )
		node.data.loaded=True
		
		Local dirs:=New Stack<String>
		Local files:=New Stack<String>
		
		For Local f:=Eachin LoadDir( path )
			
			Local fpath:=path+f
			
			Select GetFileType( fpath )
			Case FileType.Directory
				' some filtering
				If f<>PathsProvider.MX2_TMP And Not (f.Contains( ".product" ) Or f.Contains( ".buildv" ))
					dirs.Add( f )
				Endif
			Default
				files.Add( f )
			End
		Next
		
		dirs.Sort()
		
		If Not files.Empty
			files.Sort()
			dirs.AddAll( files.ToArray() )
		Endif
		
		For Local file:=Eachin dirs
			
			Local full:=path+file
			Local data:=New FolderData
			data.path=full
			
			Local subNode:=New NodeWithData<FolderData>( file,node )
			subNode.data=data
			
			If GetFileType( full )=FileType.Directory
				FillNode( subNode,full+"/" )
			Endif
		Next
	End
	
	Method CollectFolders( folder:String,target:StringStack )
		
		For Local name:=Eachin LoadDir( folder )
			Local lowercasedName:=name.ToLower()
			If Utils.ArrayContains( VALID_FOLDERS,lowercasedName )
				target.Add( folder+name )
				Continue
			Endif
			
			If lowercasedName="src" Or lowercasedName="include" Or lowercasedName="native" Or
				lowercasedName="bin" Or lowercasedName="docs" Or lowercasedName=PathsProvider.MX2_TMP Or
				lowercasedName.Contains( ".product" ) Or lowercasedName.Contains( ".buildv" ) Or
				lowercasedName="module-manager" Or lowercasedName="contrib"
				Continue
			Endif
			Local path:=folder+name
			If GetFileType( path )=FileType.Directory
				CollectFolders( path+"/",target )
			Endif
		Next
	End
	
End



Private

Class FolderData
	
	Field path:String
	Field loaded:Bool
	
End
