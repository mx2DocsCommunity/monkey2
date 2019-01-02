
Namespace ted2go


Class FindActions

	Field find:Action
	Field findNext:Action
	field findPrevious:Action
	Field replace:Action
	Field replaceNext:Action
	Field replaceAll:Action
	Field findInFiles:Action
	Field findAllInFiles:Action
	
	Field options:FindOptions
	Field lastFindResults:FindResults
	
	Method New( docs:DocumentManager,projView:ProjectView,findConsole:TreeViewExt )
		
		_docs=docs
		_findConsole=findConsole
		
		find=New Action( "Find..." )
		find.Triggered=OnFind
		find.HotKey=Key.F
		find.HotKeyModifiers=Modifier.Menu
		
		findNext=New Action( "Find next" )
		findNext.Triggered=OnFindNext
		findNext.HotKey=Key.F3
		
		findPrevious=New Action( "Find previous" )
		findPrevious.Triggered=OnFindPrevious
		findPrevious.HotKey=Key.F3
		findPrevious.HotKeyModifiers=Modifier.Shift
		
		replace=New Action( "Replace..." )
		replace.Triggered=OnReplace
		#If __TARGET__="macos"
		replace.HotKey=Key.F
		replace.HotKeyModifiers=Modifier.Alt|Modifier.Menu
		#Else
		replace.HotKey=Key.H
		replace.HotKeyModifiers=Modifier.Menu
		#Endif
		replaceNext=New Action( "Replace next" )
		replaceNext.Triggered=OnReplaceNext
		
		replaceAll=New Action( "Replace all" )
		replaceAll.Triggered=OnReplaceAll
		
		findInFiles=New Action( "Find in files..." )
		findInFiles.Triggered=Lambda()
			
			Local path:=docs.CurrentDocument?.Path
			If Not path Then path=projView.SelectedItem?.Path
			
			Local proj:=ProjectView.FindProject( path )?.Folder
			OnFindInFiles( "",proj )
			
		End
		findInFiles.HotKey=Key.F
		findInFiles.HotKeyModifiers=Modifier.Menu|Modifier.Shift
		
		findAllInFiles=New Action( "Find all" )
		findAllInFiles.Triggered=OnFindAllInFiles
		
		_findDialog=New FindDialog( Self )
		_findInFilesDialog=New FindInFilesDialog( Self,projView )
	End
	
	Method Update()
	
		Local tv:=_docs.CurrentTextView
		findNext.Enabled=tv
		findPrevious.Enabled=tv
		replace.Enabled=tv
		replaceAll.Enabled=tv
	End
	#Rem
	Method FindByTextChanged( entireProject:Bool )
		
		If Not entireProject Then OnFindNext( False )
	End
	#End
	
	Method FindInFiles( folder:String )
	
		OnFindInFiles( folder )
	End
	
	
	Private
	
	Const NXT:=1
	Const PREV:=-1
	
	Field _docs:DocumentManager
	
	Field _findDialog:FindDialog
	Field _findInFilesDialog:FindInFilesDialog
	Field _findConsole:TreeViewExt
	Field _cursorPos:=0
	
	Method OnFind()
		
		Local s:=GetInitialText()
		MainWindow.ShowFind( s )
	End
	
	Method GetInitialText:String()
		
		Local tv:=_docs.CurrentTextView
		If Not tv Return ""
		
		_cursorPos=Min( tv.Cursor,tv.Anchor )
		
		If tv.CanCopy And Not Prefs.SiblyMode
			Local min:=Min( tv.Cursor,tv.Anchor )
			Local max:=Max( tv.Cursor,tv.Anchor )
			Return tv.Text.Slice( min,max )
		Endif
		Return ""
	End
	
	Method GetRange:Vec2i( tv:TextView )
		
		If options.selectionOnly
			Local code:=Cast<CodeTextView>( tv )
			If code And code.HasExtraSelection
				Return New Vec2i( code.ExtraSelectionStart,code.ExtraSelectionEnd )
			Endif
		Endif
		
		Return New Vec2i( 0,tv.Text.Length )
	End
	
	Method OnFindInFiles( folder:String=Null,selProj:String=Null )
	
		Local s:=GetInitialText()
		If s Then _findInFilesDialog.SetInitialText( s )
		_findInFilesDialog.SetSelectedProject( selProj )
		_findInFilesDialog.CustomFolder=folder
		_findInFilesDialog.Show()
	End
	
	Method OnFindNext()
		
		Local tv:=_docs.CurrentTextView
		If Not tv Return
		
		If Not options Return
		
		Local doc:=_docs.CurrentDocument
		
		Local what:=options.findText
		If Not what Return
		
		Local text:=tv.Text
		Local sens:=options.caseSensitive
		
		If Not sens
			what=what.ToLower()
			text=text.ToLower()
		Endif
		
		Local range:=GetRange( tv )
		
		Local cursor:=Max( tv.Anchor,tv.Cursor )
		
		If cursor<range.x Or cursor>range.y Then cursor=range.x
		
		Local i:=text.Find( what,cursor )
		
		If i=-1 Or i+what.Length>range.y
			If Not options.wrapAround Return
			
			i=text.Find( what,range.x )
			If i=-1 Or i+what.Length>range.y Return
		Endif
		
		OnSelectText( tv,i,i+what.Length )
		
	End
	
	Method OnFindPrevious()
		
		Local tv:=_docs.CurrentTextView
		If Not tv Return
		
		If Not options Return
		
		Local doc:=_docs.CurrentDocument
		
		Local what:=options.findText
		If Not what Return
		
		Local text:=tv.Text
		Local sens:=options.caseSensitive
		
		If Not sens
			what=what.ToLower()
			text=text.ToLower()
		Endif
		
		Local range:=GetRange( tv )
		
		Local i:=text.Find( what,range.x )
		If i=-1 Or i+what.Length>range.y Return
		
		Local cursor:=Min( tv.Anchor,tv.Cursor )
		
		If cursor<range.x Or cursor>range.y Then cursor=range.y
		
		If i>=cursor
			If Not options.wrapAround Return
			Repeat
				Local n:=text.Find( what,i+what.Length )
				If n=-1 Or n>=range.y Exit
				i=n
			Forever
		Else
			Repeat
				Local n:=text.Find( what,i+what.Length )
				If n=-1 Or n>=cursor Exit
				i=n
			Forever
		End
		
		OnSelectText( tv,i,i+what.Length )
	End
	
	Method OnSelectText( tv:TextView,anchor:Int,cursor:Int )
		
		tv.SelectText( anchor,cursor )
		
		Local code:=Cast<CodeTextView>( tv )
		If code Then code.MakeCentered()
	End
	
	Method OnFindAllInFiles()
	
		If Not _findInFilesDialog.FindText
			ShowMessage( "","Please, enter text to find what." )
			Return
		Endif
		
		If Not _findInFilesDialog.SelectedProject
			ShowMessage( "","Please, select project in the list." )
			Return
		Endif
		
		'_findInFilesDialog.Hide()
		MainWindow.ShowFindResults()
		
		New Fiber( Lambda()
		
			Local what:=_findInFilesDialog.FindText
			Local proj:=_findInFilesDialog.SelectedProject
			Local sens:=_findInFilesDialog.CaseSensitive
			Local filter:=_findInFilesDialog.FilterText
			
			Local result:=FindInProject( what,proj,sens,filter )
			lastFindResults=result
			
			If result Then CreateResultTree( _findConsole.RootNode,result,what,proj )
		End)
		
	End
	
	Const DEFAULT_FILES_FILTER:="monkey2" ',txt,htm,html,h,cpp,json,xml,ini"
	
	Method FindInProject:FindResults( what:String,projectPath:String,caseSensitive:Bool,filesFilter:String=DEFAULT_FILES_FILTER )
		
		If Not filesFilter Then filesFilter=DEFAULT_FILES_FILTER
		
		Local exts:=filesFilter.Split( "," )
		
		projectPath+="/"
		
		If Not caseSensitive Then what=what.ToLower()
		
		Local files:=New Stack<String>
		Utils.GetAllFiles( projectPath,exts,files )
		Local len:=what.Length
		
		Local result:=New FindResults
		
		Local tmpFolder:=PathsProvider.MX2_TMP+"/"
		Local doc:=New TextDocument 'use it to get line number
		For Local f:=Eachin files
			
			' skip temp-folders
			If f.Find( tmpFolder )<>-1 Continue
			
			Local text:=LoadString( f )
		
			If Not caseSensitive Then text=text.ToLower()
		
			doc.Text=text 'any needed replacing is here (\r\n -> \n)
			text=doc.Text
		
			Local i:=0
			Local items:=New Stack<FileJumpData>
			
			Repeat
				i=text.Find( what,i )
				If i=-1 Exit
				
				Local data:=New FileJumpData
				data.path=f
				data.pos=i
				data.len=len
				data.line=doc.FindLine( i )+1
				data.posInLine=i-doc.StartOfLine( data.line )
				
				items.Add( data )
				
				i+=len
			Forever
			
			If Not items.Empty Then result[f]=items
			
			'If counter Mod 10 = 0
			'	' process 10 files per frame to save app responsibility
			'	App.WaitIdle()
			'Endif
			
		Next
		
		Return result
	End
	
	#Rem
	Method FindInFile:Stack<FileJumpData>( filePath:String,what:String,caseSensitive:Bool,doc:TextDocument=Null )
	
		Local len:=what.Length
		Local text:String
		
		If Not doc
			doc=New TextDocument
			text=LoadString( filePath )
			doc.Text=text 'any needed replacing is here (\r\n -> \n)
		Endif
		text=doc.Text
		If Not caseSensitive Then text=text.ToLower()
		
		Local i:=0
		Local result:=New Stack<FileJumpData>
		
		Repeat
			i=text.Find( what,i )
			If i=-1 Exit

			Local data:=New FileJumpData
			data.path=filePath
			data.pos=i
			data.len=len
			data.line=doc.FindLine( i )+1

			result.Add( data )

			i+=len
		Forever

		Return result
	End
	#End
	
	Method CreateResultTree( root:TreeView.Node,results:FindResults,what:String,projectPath:String )
		
		root.RemoveAllChildren()
		
		root.Text="Results for '"+what+"'"
		
		Local subRoot:TreeView.Node
		
		For Local file:=Eachin results.Files
			
			Local items:=results[file]
			
			subRoot=New TreeView.Node( file.Replace( projectPath+"/","" )+" ("+items.Length+")",root )
	
			For Local d:=Eachin items
				Local node:=New NodeWithData<FileJumpData>( " at line "+d.line,subRoot )
				node.data=d
			Next
		
		Next
		
		If root.NumChildren=0 Then New TreeView.Node( "not found :(",root )
		
		root.Expanded=True
		
	End
	
	Method OnReplace()
		
		Local s:=GetInitialText()
		MainWindow.ShowReplace( s )
	End
	
	Method OnReplaceNext()
	
		Local tv:=_docs.CurrentTextView
		If Not tv Return
		
		Local min:=Min( tv.Anchor,tv.Cursor )
		Local max:=Max( tv.Anchor,tv.Cursor )
		
		Local text:=tv.Text.Slice( min,max )
		Local what:=options.findText
		
		If Not text Return

		If Not options.caseSensitive
			text=text.ToLower()
			what=what.ToLower()
		Endif
		
		If text<>what Return
		
		Local with:=options.replaceText
		
		tv.ReplaceText( with )
		
		' temp solution
		If options.selectionOnly
			Local code:=Cast<CodeTextView>( tv )
			If code Then code.ExtraSelectionEnd+=(with.Length-what.Length)
		Endif
		
		OnFindNext()

	End
	
	Method OnReplaceAll()
	
		Local tv:=_docs.CurrentTextView
		If Not tv Return
		
		Local what:=options.findText
		If Not what Return
		
		Local with:=options.replaceText
		
		Local text:=tv.Text

		If Not options.caseSensitive
			text=text.ToLower()
			what=what.ToLower()
		Endif
		
		Local anchor:=tv.Anchor
		Local cursor:=tv.Cursor
		
		Local range:=GetRange( tv )
		
		Local lenWhat:=what.Length
		Local lenWith:=with.Length
		
		Local i:=range.x,t:=0
		Repeat
		
			i=text.Find( what,i )
			If i=-1 Or i+lenWhat>range.y Exit
			
			tv.SelectText( i+t,i+lenWhat+t )
			tv.ReplaceText( with )
			
			' select last replacement
			cursor=tv.Cursor
			anchor=tv.Cursor-lenWith
			
			Local dlen:=lenWith-lenWhat
			
			' temp solution
			If options.selectionOnly
				Local code:=Cast<CodeTextView>( tv )
				If code Then code.ExtraSelectionEnd+=dlen
			Endif
			
			t+=dlen
			i+=lenWhat
			
		Forever
		
		OnSelectText( tv,anchor,cursor )
		
	End
	
End


Class FindResults
	
	Operator[]:Stack<FileJumpData>( filePath:String )
		
		Return _map[filePath]
	End
	
	Operator[]=( filePath:String,results:Stack<FileJumpData> )
	
		_map[filePath]=results
	End
	
	Property Files:StringMap<Stack<FileJumpData>>.KeyIterator()
		
		Return _map.Keys.All()
	End
	
	Method ProcessLinesModified( filePath:String,first:Int,removed:Int,inserted:Int )
		
		Local list:=_map[filePath]
		If Not list Return
		
		For Local d:=Eachin list
			If d.line>first Then d.line+=(inserted-removed)
		Next
	End
	
	Method Empty:Bool()
		
		Return _map.Empty
	End
	
	
	Private
	
	Field _map:=New StringMap<Stack<FileJumpData>>
End

