
Namespace ted2go


Class ProjectView Extends DockingView

	Field openProjectFolder:Action
	Field openProjectFile:Action
	Field setMainFile:Action
	
	Field ProjectOpened:Void( path:String )
	Field ProjectClosed:Void( path:String )
	Field ActiveProjectChanged:Void( proj:Monkey2Project )
	
	Field RequestedFindInFolder:Void( folder:String )
	Field MainFileChanged:Void( path:String,prevPath:String )
	Field FileRenamed:Void( path:String,prevPath:String )
	Field FolderRenamed:Void( path:String,prevPath:String )
	
	Method New( docs:DocumentManager,builder:IModuleBuilder )
	
		_docs=docs
		_builder=builder
		
		_docker=New DockingView
		
		ContentView=_docker
		
		openProjectFolder=New Action( "Open project folder" )
		openProjectFolder.HotKey=Key.O
		openProjectFolder.HotKeyModifiers=Modifier.Menu|Modifier.Shift
		openProjectFolder.Triggered=OnOpenProjectFolder
		
		openProjectFile=New Action( "Open project file" )
		'openProjectFile.HotKey=Key.O
		'openProjectFile.HotKeyModifiers=Modifier.Menu|Modifier.Shift
		openProjectFile.Triggered=OnOpenProjectFile
		
		setMainFile=New Action( "Set as main file" )
		setMainFile.Triggered=Lambda()
			
			Local doc:=_docs.CurrentCodeDocument
			If doc Then SetMainFile( doc.Path )
		End
		
		InitProjBrowser()
		
'		_docs.LockedDocumentChanged+=Lambda:Void()
'			Local path:=_docs.LockedDocument?.Path
'			If path Then SetActiveProject( path )
'		End
		
		App.Activated+=Lambda()
			
			For Local proj:=Eachin _projects
				Local changed:=proj.Reload()
				If changed
					_projBrowser?.RefreshProject( proj )
				Endif
			Next
		End
		
		ActiveProjectChanged+=Lambda( proj:Monkey2Project )
		
			_projBrowser?.SetActiveProject( proj )
		End
		
		MainFileChanged+=Lambda( path:String,prevPath:String )
			
			_projBrowser?.SetMainFile( prevPath,False )
			_projBrowser?.SetMainFile( path,True )
		End
	End
	
	Property SelectedItem:ProjectBrowserView.Node()
	
		Return Cast<ProjectBrowserView.Node>( _projBrowser.Selected )
	End
	
	Property OpenProjects:Stack<Monkey2Project>()
		
		Return _projects
	End
	
	Property OpenProjectsFolders:String[]()
	
		Local folders:=New String[_projects.Length]
		For Local i:=0 Until _projects.Length
			folders[i]=_projects[i].Folder
		Next
	
		Return folders
	End
	
	Property ActiveProject:Monkey2Project()
	
		Return _activeProject
	End
	
	Property SingleClickExpanding:Bool()
	
		Return _projBrowser.SingleClickExpanding
	
	Setter( value:Bool )
		
		_projBrowser.SingleClickExpanding=value
	End
	
	Function FindProject:Monkey2Project( filePath:String )
	
		If Not filePath Return Null
		
		For Local proj:=Eachin _projects
			If filePath.StartsWith( proj.Folder )
				Return proj
			Endif
		Next
		
		Return Null
	End
	
	Function IsProjectFile:Bool( filePath:String )
	
		Return ExtractExt( filePath )=".mx2proj"
	End
	
	Function IsValidProject:Bool( path:String )
	
		Return IsProjectFile( path ) Or GetFileType( path )=FileType.Directory
	End
	
	Function ActiveProjectName:String()
	
		Return _activeProject?.Name
	End
	
	Function CheckMainFilePath( proj:Monkey2Project,showAlert:Bool )
		
		If Not proj.MainFilePath
			If showAlert
				Alert( "Main file of ~q"+proj.Name+"~q project is not specified.~n~nRight click on file in Project tree~nand choose 'Set as main file'.","Build error" )
			Else
				MainWindow.ShowStatusBarText( "Main file of ~q"+proj.Name+"~q project is not specified!" )
			Endif
		Endif
	
	End
	
	Method OnFileDropped:Bool( path:String )
		
		Local ok:=_projBrowser.OnFileDropped( path )
		If Not ok
			If IsValidProject( path )
				ok=True
				OpenProject( path )
			Endif
		Endif
		Return ok
	End
	
	Method SetActiveProject( path:String,prompt:Bool=True )
		
		Local proj:=FindProject( path )
		If proj
			If proj.IsFolderBased
				If Not prompt Return
				proj=ShowCreateProjectFilePrompt( "Can't set folder-based project as active.",proj )
				If Not proj Return
			Endif
			OnActiveProjectChanged( proj )
		Endif
	End
	
	Method SetMainFile( path:String,prompt:Bool=True )
	
		Local proj:=FindProject( path )
		If proj
			If proj.IsFolderBased
				If Not prompt Return
				proj=ShowCreateProjectFilePrompt( "Can't set main file of folder-based project.",proj )
				If Not proj Return
			Endif
			Local prev:=proj.MainFilePath
			proj.MainFilePath=path
			MainFileChanged( path,prev )
		Endif
	End
	
	Method OpenProject:Bool( path:String )
		
		Local proj:=FindProject( path )
		Local isProjExists:=(proj<>Null)
		
		Local projIndex:=_projects.FindIndex( proj )
		Local wasActive:=(proj=_activeProject)
		
		proj=New Monkey2Project( path )
		
		If isProjExists
			_projects.Set( projIndex,proj )
			_projBrowser.RefreshProject( proj )
			If wasActive Then OnActiveProjectChanged( proj )
		Else
			_projects+=proj
			_projBrowser.AddProject( proj )
		Endif
		
		ProjectOpened( proj.Path )
		
		Return True
	End
	
	Method CloseProject( dir:String )
		
		Local proj:=FindProject( dir )
		If Not proj Return
		
		_projBrowser.RemoveProject( proj )
		
		_projects-=proj
		
		If proj=_activeProject Then OnActiveProjectChanged( Null )
		
		ProjectClosed( dir )
	End
	
	Method SaveState( jobj:JsonObject )
		
		Local j:=New JsonObject
		jobj["projectsExplorer"]=j
		
		Local jarr:=New JsonArray
		For Local p:=Eachin _projects
			jarr.Add( New JsonString( p.Path ) )
		Next
		j["openProjects"]=jarr
		
		_projBrowser.SaveState( j,"expanded" )
		
		Local selPath:=GetNodePath( _projBrowser.Selected )
		j["selected"]=New JsonString( selPath )
		
		If _activeProject Then j["active"]=New JsonString( _activeProject.Path )
	End
	
	Property HasOpenedProjects:Bool()
		
		Return _projects.Length>0
	End
	
	Method LoadState( jobj:JsonObject )
		
		If Not jobj.Contains( "projectsExplorer" ) Return
		
		jobj=new JsonObject( jobj["projectsExplorer"].ToObject() )
		
		_projBrowser.LoadState( jobj,"expanded" )
		
		If jobj.Contains( "openProjects" )
			Local arr:=jobj["openProjects"].ToArray()
			For Local path:=Eachin arr
				OpenProject( path.ToString() )
			Next
			If arr.Length=1
				jobj["active"]=New JsonString( _projects[0].Path )
			Endif
		Endif
		
		Local selPath:=Json_GetString( jobj.Data,"selected","" )
		If selPath Then _projBrowser.SelectByPath( selPath )
		
		Local activePath:=Json_GetString( jobj.Data,"active","" )
		If activePath Then SetActiveProject( activePath,False )
	End
	
	
	Protected
	
	
	Private
	
	Field _docs:DocumentManager
	Field _docker:=New DockingView
	'Global _projectFolders:=New StringStack
	Global _projects:=New Stack<Monkey2Project>
	Field _builder:IModuleBuilder
	Field _projBrowser:ProjectBrowserView
	Global _activeProject:Monkey2Project
	Field _cutPath:String,_copyPath:String
	
	Method ShowCreateProjectFilePrompt:Monkey2Project( prompt:String,proj:Monkey2Project )
		
		Local yes:=RequestOkay( prompt+"~n~nDo you want create project file for the project?","Projects","Yes","No" )
		If Not yes Return Null
		
		Local path:String
		Repeat 
			Local name:=RequestString( "Project filename:","Projects",StripDir( proj.Folder ) ).Trim()
			If Not name
				Alert( "Name wasn't entered, so do nothing.","Projects" )
				Return Null
			Endif
			If ExtractExt( name )<>".mx2proj"
				name+=".mx2proj"
			Endif
			path=proj.Folder+"/"+name
			
			If FileExists( path )
				Local yes:=RequestOkay( "Such project file already exists.~nDo you want use it for the project?","Projects","Use it","Create another" )
				If Not yes Continue
			Else
				' don't overwrite existing files
				Monkey2Project.SaveEmptyProject( path )
			Endif
			
			Exit
			
		Forever
		
		OpenProject( path )
		
		Return FindProject( path )
	End
	
	Method OnCut( path:String )
		
		_copyPath=""
		_cutPath=path
	End
	
	Method OnCopy( path:String )
		
		_cutPath=""
		_copyPath=path
	End
	
	Method OnPaste:Bool( path:String )
		
		Local ok:=True
		
		If Not path.EndsWith( "/" ) Then path+="/"
		
		Local cut:=(_cutPath<>"")
		Local srcPath:=cut ? _cutPath Else _copyPath
		
		Local isFolder:=(GetFileType( srcPath )=FileType.Directory)
		
		If isFolder And path.StartsWith( srcPath )
			
			Alert( "Can't paste into the same or nested folder!","Paste element" )
			Return False
		Endif
		
		Local name:=StripDir( srcPath )
		
		Local dest:=path+name
		Local exists:=(GetFileType( dest )<>FileType.None)
		
		If exists
			Local s:=RequestString( "New name:","Element already exists",name )
			If Not s Or s=name Return False
			name=s
			dest=path+name
		Endif
		
		If isFolder
			ok=CopyDir( srcPath,dest )
			If ok And cut Then DeleteDir( srcPath,True )
		Else
			ok=CopyFile( srcPath,dest )
			If ok And cut Then DeleteFile( srcPath )
		Endif
		
		If Not ok Then Alert( "Can't copy~n"+srcPath+"~ninto~n"+dest,"Paste element" )
		
		_cutPath=""
		
		Return ok
	End
	
	Method DeleteItem( browser:ProjectBrowserView,path:String,node:TreeView.Node )
		
		Local nodeToRefresh:=Cast<ProjectBrowserView.Node>( node.Parent )
		
		Local work:=Lambda()
			
			If DirectoryExists( path )
			
				If Not RequestOkay( "Really delete folder '"+path+"'?" ) Return
				
				If DeleteDir( path,True )
					browser.Refresh( nodeToRefresh )
					Return
				Endif
				
				Alert( "Failed to delete folder '"+path+"'" )
				
			Else
				
				If Not RequestOkay( "Really delete file '"+path+"'?" ) Return
				
				If DeleteFile( path )
				
					Local doc:=_docs.FindDocument( path )
				
					If doc doc.Close()
				
					browser.Refresh( nodeToRefresh )
					Return
				Endif
				
				Alert( "Failed to delete file: '"+path+"'" )
				
			Endif
			
		End
		
		New Fiber( work )
	End
	
	Method OnOpenProjectFolder()
	
		Local dir:=MainWindow.RequestDir( "Select project folder...","" )
		If Not dir Return
	
		OpenProject( dir )
		
'		If _projects.Length=1
'			OnActiveProjectChanged( _projects[0] )
'		Endif
	End
	
	Method OnActiveProjectChanged( proj:Monkey2Project )
		
		_activeProject=proj
		ActiveProjectChanged( _activeProject )
	End
	
	Method OnOpenProjectFile()
	
		Local file:=MainWindow.RequestFile( "Select project file...","",False,"Monkey2 projects:mx2proj" )
		If Not file Return
	
		OpenProject( file )
		
		If _projects.Length=1
			OnActiveProjectChanged( _projects[0] )
		Endif
	End
	
	Method OnOpenDocument( path:String,makeFocused:Bool,runExec:Bool=True )
		
		If GetFileType( path )<>FileType.File Return
		
		New Fiber( Lambda()
			
			Local ext:=ExtractExt( path )
			Local exe:=(ext=".exe")
			If runExec
				If exe Or ext=".bat" Or ext=".sh"
					Local s:="Do you want to execute this file?"
					If Not exe s+="~nPress 'Cancel' to open file in editor."
					If RequestOkay( s,StripDir( path ) )
						OpenUrl( path )
						Return
					Endif
				Endif
			Endif
			
			If exe Return 'never open .exe
			
			_docs.OpenDocument( path,True )
			
			If Not makeFocused Then Self.MakeKeyView()
			
		End )
	End
	
	' Return True if there was an actual folder deletion
	Method CleanFolder:Bool( folder:String )
		
		Local succ:=0,err:=0
		For Local i:=Eachin LoadDir( folder )
			Local path:=folder+"/"+i
			If GetFileType( path )=FileType.Directory
				If i.Contains( ".buildv" ) Or i=PathsProvider.MX2_TMP
					Local ok:=DeleteDir( path,True )
					If ok Then succ+=1 Else err+=1
				Else
					CleanFolder( path )
				Endif
			Endif
		Next
	
		Local s:= err=0 ? "Project was successfully cleaned." Else "Clean project error! Some files are busy or you have no privileges."
		MainWindow.ShowStatusBarText( s )
		
		Return succ>0
	End
	
	Method CreateFileInternal:Bool( path:String,content:String=Null )
		
		If ExtractExt(path)="" Then path+=".monkey2"
		
		If GetFileType( path )<>FileType.None
			Alert( "A file or directory already exists at '"+path+"'" )
			Return False
		End
		
		If Not CreateFile( path )
			Alert( "Failed to create file '"+StripDir( path )+"'" )
			Return False
		Endif
		
		If content Then SaveString( content,path )
		
		Return True
	End
	
	Method InitProjBrowser()
		
		Local browser:=New ProjectBrowserView()
		browser.SingleClickExpanding=Prefs.MainProjectSingleClickExpanding
		_projBrowser=browser
		_docker.ContentView=browser
		
		browser.RequestedDelete+=Lambda( node:ProjectBrowserView.Node )
			
			DeleteItem( browser,node.Path,node )
		End
		
		browser.FileClicked+=Lambda( node:ProjectBrowserView.Node )
			
			If browser.SingleClickExpanding Then OnOpenDocument( node.Path,False )
		End
		
		browser.FileDoubleClicked+=Lambda( node:ProjectBrowserView.Node )
			
			If Not browser.SingleClickExpanding Then OnOpenDocument( node.Path,True )
		End
		
		browser.FileRightClicked+=Lambda( node:ProjectBrowserView.Node )
			
			Local menu:=New MenuExt
			Local path:=node.Path
			Local pasteAction:Action
			Local isFolder:=False
			Local fileType:=GetFileType( path )
			
			menu.AddAction( GetShowInExplorerTitle() ).Triggered=Lambda()
				
				Local p:=(fileType=FileType.File) ? ExtractDir( path ) Else path
				OpenInExplorer( p )
			End
			menu.AddAction( "Copy path" ).Triggered=Lambda()
				
				App.ClipboardText=path
			End
			
			menu.AddSeparator()
			
			
			Select fileType
			Case FileType.Directory
				
				isFolder=True
				
				menu.AddAction( "Find..." ).Triggered=Lambda()
					
					RequestedFindInFolder( path )
				End
				
				menu.AddSeparator()
				
				menu.AddAction( "New class..." ).Triggered=Lambda()
					
					Local d:=New GenerateClassDialog( path )
					d.Generated+=Lambda( filePath:String,fileContent:String )
						
						If CreateFileInternal( filePath,fileContent )
							
							MainWindow.OpenDocument( filePath )
							browser.Refresh( node )
						Endif
					End
					d.ShowModal()
				End
				
				menu.AddAction( "New file" ).Triggered=Lambda()
					
					Local file:=RequestString( "New file name:","New file",".monkey2" )
					If Not file Return
					
					Local tpath:=path+"/"+file
					
					CreateFileInternal( tpath )
					
					browser.Refresh( node )
				End
				
				menu.AddAction( "New folder" ).Triggered=Lambda()
					
					Local dir:=RequestString( "New folder name:" )
					If Not dir Return
					
					Local tpath:=path+"/"+dir
					
					If GetFileType( tpath )<>FileType.None
						Alert( "A file or directory already exists at '"+tpath+"'" )
						Return
					End
					
					If Not CreateDir( tpath )
						Alert( "Failed to create folder '"+dir+"'" )
						Return
					Endif
					
					browser.Refresh( node )
				End
				
				menu.AddSeparator()
				
				menu.AddAction( "Rename folder" ).Triggered=Lambda()
				
					Local oldName:=StripDir( path )
					Local name:=RequestString( "Enter new name:","Ranaming '"+oldName+"'",oldName )
					If Not name Or name=oldName Return
					
					Local i:=path.Slice( 0,path.Length-1 ).FindLast( "/" )
					If i<>-1
						
						Local newPath:=path.Slice( 0,i+1 )+name
						
						If DirectoryExists( newPath )
							Alert( "Folder already exists! Path: '"+newPath+"'" )
							Return
						Endif
						
						Local code:=libc.rename( path,newPath )
						If code=0
							browser.Refresh( node.Parent )
							FolderRenamed( newPath,path )
							Return
						Endif
					
						Alert( "Failed to rename folder: '"+path+"'. Error code: "+code )
					Endif
				End
				
				menu.AddAction( "Delete" ).Triggered=Lambda()
					
					DeleteItem( browser,path,node )
				End
				
				menu.AddSeparator()
				
				If browser.IsProjectNode( node ) ' root node
					
					menu.AddAction( "Build & Run" ).Triggered=Lambda()
						PathsProvider.SetCustomBuildProject( node.Project )
						Local buildActions:=Di.Resolve<BuildActions>()
						buildActions.buildAndRun.Triggered()
						PathsProvider.SetCustomBuildProject( Null )
					End
					
					menu.AddAction( "Set as active project" ).Triggered=Lambda()
					
						SetActiveProject( path )
					End
					
					menu.AddAction( "Close project" ).Triggered=Lambda()
					
						If Not RequestOkay( "Really close project?" ) Return
					
						CloseProject( path )
					End
					
					menu.AddAction( "Clean (delete .buildv & .mx2)" ).Triggered=Lambda()
						
						If Not RequestOkay( "Really delete all '.buildv' and '.mx2' folders?" ) Return
						
						Local changed:=CleanFolder( path )
						If changed Then browser.Refresh( node )
					End
				Else
					
					menu.AddAction( "Open as a project" ).Triggered=Lambda()
					
						OpenProject( path )
					End
				Endif
				
				' update / rebuild module
				path=path.Replace( "\","/" )
				Local name := path.Slice( path.FindLast( "/")+1 )
				Local file:=path+"/module.json"
				
				If path.Contains( "/modules/") And GetFileType( file )=FileType.File
					
					menu.AddSeparator()
					
					menu.AddAction( "Update / Rebuild "+name ).Triggered=Lambda()
						
						_builder.BuildModules( name )
					End
					
				Endif
				
				' update all modules
				Local path2:=MainWindow.ModsPath
				If path2.EndsWith( "/" ) Then path2=path2.Slice( 0,path2.Length-1 )
				
				If path = path2
					
					menu.AddSeparator()
					
					menu.AddAction( "Update / Rebuild modules" ).Triggered=Lambda()
						
						_builder.BuildModules()
					End
					
				Endif
				
				' bananas showcase
				If IsBananasShowcaseAvailable()
					path2=Prefs.MonkeyRootPath+"bananas"
					If path = path2
						
						menu.AddSeparator()
						
						menu.AddAction( "Open bananas showcase" ).Triggered=Lambda()
							
							MainWindow.ShowBananasShowcase()
						End
						
					Endif
				Endif
				
			
			Case FileType.File
				
				menu.AddAction( "Set as main file" ).Triggered=Lambda()
				
					SetMainFile( path )
				End
				menu.AddSeparator()
				
				menu.AddAction( "Rename file" ).Triggered=Lambda()
					
					Local oldName:=StripDir( path )
					Local name:=RequestString( "Enter new name:","Ranaming '"+oldName+"'",oldName )
					If Not name Or name=oldName Return
					
					Local dir:=ExtractDir( path )
					Local newPath:=dir+name
					
					' if just case is different
					'
					If name.ToLower()=oldName.ToLower()
						Local tmpPath:=dir+Int(Rnd( 1000000,9999999 ))+name
						' rename to temp
						Local ok:=(libc.rename( path,tmpPath )=0)
						If ok
							' rename to desired
							ok=(libc.rename( tmpPath,newPath )=0)
							If ok
								browser.Refresh( node.Parent )
								Return
							Endif
						Endif
					Endif
					
					If FileExists( newPath )
						Alert( "File already exists! Path: '"+newPath+"'" )
						Return
					Endif
					
					Local ok:=(libc.rename( path,newPath )=0)
					If ok
						browser.Refresh( node.Parent )
						Return
					Endif
					
					Alert( "Failed to rename file: '"+path+"'" )
				End
				
				menu.AddSeparator()
				
				menu.AddAction( "Delete" ).Triggered=Lambda()
					
					DeleteItem( browser,path,node )
				End
			
			Default
				
				Return
			End
			
			' cut / copy / paste
			menu.AddSeparator()
			
			menu.AddAction( "Cut" ).Triggered=Lambda()
			
				OnCut( path )
			End
			
			menu.AddAction( "Copy" ).Triggered=Lambda()
			
				OnCopy( path )
			End
			
			pasteAction=menu.AddAction( "Paste" )
			pasteAction.Triggered=Lambda()
				
				New Fiber( Lambda()
					
					Local ok:=OnPaste( path )
					If ok
						Local n:=browser.IsProjectNode( node ) ? node Else node.Parent
						browser.Refresh( n )
					Endif
				End )
				
			End
			pasteAction.Enabled=(_cutPath Or _copyPath) And isFolder
			
			' collapse all
			'
			If isFolder
				
				menu.AddSeparator()
				
				menu.AddAction( "Collapse all" ).Triggered=Lambda()
				
					_projBrowser.CollapseAll( node )
				End
			Endif
				
			menu.Open()
		End
		
	End
	
End


Class Monkey2Project
	
	Const KEY_MAIN_FILE:="mainFile"
	Const KEY_HIDDEN:="hidden"
	
	Function SaveEmptyProject( path:String )
		
		Local jobj:=New JsonObject
		jobj[KEY_MAIN_FILE]=New JsonString
		jobj[KEY_HIDDEN]=New JsonArray( New JsonValue[]( New JsonString( ".mx2" ) ) )
		
		SaveString( jobj.ToJson(),path )
	End
	
	Method New( path:String )
		
		Local isFolder:=(GetFileType( path )=FileType.Directory)
		
		' try to load project file if it's presented
		'
		If isFolder
			Local dirName:=StripDir( path )
			Local projPath:=StripSlashes( path )+"/"+dirName+".mx2proj"
			If FileExists( projPath )
				path = projPath
			Endif
		Endif
		
		_path=path
		
		If GetFileType( path )=FileType.File
			_data=JsonObject.Load( path )
			_modified=GetFileTime( path )
			path=ExtractDir( path )
		Else
			_data=New JsonObject
			_isFolderBased=True
		Endif
		
		_folder=StripSlashes( path )
	End
	
	Property MainFile:String()
		Return _data.GetString( KEY_MAIN_FILE )
	End
	
	Property MainFilePath:String()
		Local main:=MainFile
		Return main ? Folder+"/"+main Else ""
	Setter( value:String )
		_data.SetString( KEY_MAIN_FILE,value.Replace(Folder+"/","" ) )
		OnChanged()
	End
	
	Property Folder:String()
		Return _folder
	End
	
	Property Name:String()
		Return StripDir( _folder )
	End
	
	Property IsFolderBased:Bool()
		Return _isFolderBased
	End
	
	Property Path:String()
		Return _path
	End
	
	Property Modified:Int()
		Return _modified
	End
	
	Property Hidden:String[]()
		
		If _modified=0 Or Not _data Return New String[0]
		If _modified=_hiddenTime Return _hidden
		
		Local jarr:=_data.GetArray( KEY_HIDDEN )
		If Not jarr Or jarr.Empty Return New String[0]
		
		_hidden=New String[jarr.Length]
		For Local i:=0 Until jarr.Length
			_hidden[i]=jarr[i].ToString()
		Next
		
		_hiddenTime=_modified
		Return _hidden
	End
	
	Method Save()
		
		If Not _isFolderBased Then SaveString( _data.ToJson(),_path )
	End
	
	Method Reload:Bool()
	
		If _isFolderBased Return False
		
		Local t:=GetFileTime( _path )
		If t>_modified
			_data=JsonObject.Load( _path )
			_modified=t
			Return True
		Endif
		
		Return False
	End
	
	Private
	
	Field _path:String,_folder:String
	Field _data:JsonObject
	Field _isFolderBased:Bool
	Field _modified:Int
	Field _hidden:String[],_hiddenTime:Int
	
	Method OnChanged()
		
		Save()
	End
	
End
