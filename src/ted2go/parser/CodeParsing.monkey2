
Namespace ted2go


Class CodeParsing
	
	Function IsFileBuildable:Bool( path:String )
		
		Return ExtractExt( path )=".monkey2"
	End
	
	Function DeleteTempFiles()
		
		DocWatcher.DeleteTempFiles()
	End
	
	Method New( docs:DocumentManager,projView:ProjectView )
		
		_docsManager=docs
		
		_docsManager.DocumentAdded+=Lambda( doc:Ted2Document )
		
			Local codeDoc:=Cast<CodeDocument>( doc )
			If codeDoc
				StartWatching( codeDoc )
				
				codeDoc.Renamed+=Lambda( newPath:String,oldPath:String )
					
					' maybe now we have no parser for this file
					' so re-starting
					StopWatching( codeDoc )
					StartWatching( codeDoc )
				End
				Return
			Endif
			
'			If ProjectView.IsProjectFile( doc.Path )
'				
'			Endif
			
		End
		_docsManager.DocumentRemoved+=Lambda( doc:Ted2Document )
		
			Local codeDoc:=Cast<CodeDocument>( doc )
			If codeDoc Then StopWatching( codeDoc )
		End
		_docsManager.LockedDocumentChanged+=Lambda()
			
			' have we locked or active path?
			Local mainFile:=PathsProvider.GetActiveMainFilePath( False )
			If mainFile
				FindWatcher( mainFile )?.WakeUp()
			Else
				DocWatcher.WakeUpGlobal()
			Endif
		End
		
		DocWatcher.docsForUpdate=Lambda:CodeDocument[]()
			
			Return _docsManager.OpenCodeDocuments
		End
		
		DocWatcher.Init()
		
		projView.MainFileChanged+=Lambda( path:String,prevPath:String )
			
			DocWatcher.WakeUpGlobal()
		End
		
		projView.ActiveProjectChanged+=Lambda( proj:Monkey2Project )
			
			DocWatcher.WakeUpGlobal()
		End
	End
	
	
	Private
	
	Field _docsManager:DocumentManager
	Field _watchers:=New Stack<DocWatcher>
	
	Method FindWatcher:DocWatcher( doc:CodeDocument )
		
		For Local i:=Eachin _watchers
			If i.doc=doc Return i
		Next
		
		Return Null
	End
	
	Method FindWatcher:DocWatcher( path:String )
	
		For Local i:=Eachin _watchers
			If i.doc.Path=path Return i
		Next
	
		Return Null
	End
	
	Method StartWatching( doc:CodeDocument )
		
		If Not IsFileBuildable( doc.Path ) Return
		
		If FindWatcher( doc ) Return ' already added
		
		Local watcher:=New DocWatcher( doc )
		_watchers.Add( watcher )
		
		watcher.WakeUp()
	End
	
	Method StopWatching( doc:CodeDocument )
	
		For Local i:=Eachin _watchers
			If i.doc=doc
				i.Dispose()
				_watchers.Remove( i )
				Return
			Endif
		Next
	End
	
	Method Dispose()
	
		DocWatcher.enabled=False
	End
	
End


Private

Class DocWatcher
	
	Global enabled:=True
	Field doc:CodeDocument
	Global docsForUpdate:CodeDocument[]()
	
	Method New( doc:CodeDocument )
		
		Self.doc=doc
		_view=doc.CodeView
		_parser=ParsersManager.Get( _view.FileType )
		Local canParse:=Not ParsersManager.IsFake( _parser )
		
		If canParse
			_view.Document.TextChanged+=OnTextChanged
			
			UpdateDocItems( doc,_parser ) ' refresh parser info for just opened document
		Endif
	End
	
	Method Dispose()
		
		_view.Document.TextChanged-=OnTextChanged
	End
	
	Method WakeUp()
	
		OnTextChanged()
	End
	
	Function WakeUpGlobal()
	
		_timeTextChanged=Millisecs()
	End
	
	Function Init()
	
		_timeTextChanged=Millisecs()
	End
	
	Function DeleteTempFiles()
		
		For Local path:=Eachin _tempFiles
			DeleteFile( path )
		Next
	End
	
	Private
	
	Field _view:CodeDocumentView
	Field _parser:ICodeParser
	Global _dirtyCounter:=0,_dirtyCounterLastParse:=0
	Global _timeDocParsed:=0
	Global _timeTextChanged:=0
	Global _timer:Timer
	Global _parsing:Bool
	Global _changed:=New Stack<CodeDocument>
	Global _tempFiles:=New StringStack
	
	Method OnTextChanged()
		
		' skip whitespaces ?
		'
'		Local char:=doc.CodeView?.LastTypedChar
'		Print "char: '"+char+"'"

		TryToParse( doc,_parser )
	End
	
	Function TryToParse( doc:CodeDocument,parser:ICodeParser )
		
		_timeTextChanged=Millisecs()
		
		If Not _changed.Contains( doc ) Then _changed.Add( doc )
		
		If _parsing Return
		
		' timer that watching for changed docs
		'
		If Not _timer Then _timer=New Timer( 1,Lambda()
			
			If _parsing Or Not enabled Or _changed.Empty Return
			
			Local msec:=Millisecs()
			If msec<_timeDocParsed+1000 Return
			If _timeTextChanged=0 Or msec<_timeTextChanged+1000 Return
			_timeTextChanged=0
			
			_parsing=True
			
			' copy docs and free list to collect new 'changes'
			'
			Global _docsToParse:=New Stack<CodeDocument>
			_docsToParse.AddAll( _changed.ToArray() )
			_changed.Clear()
			
			Global _paramsToParse:=New Stack<ParseFileParams>
			
			For Local changedDoc:=Eachin _docsToParse
				
				' collect all different files to be parsed
				'
				Local path:=PathsProvider.GetMainFileOfDocument( changedDoc.Path )
				Local exists:=False
				For Local p:=Eachin _paramsToParse
					If path=p.filePath
						exists=True
						Exit
					Endif
				Next
				If Not exists
					Local params:=New ParseFileParams
					params.filePath=path
					_paramsToParse.Add( params )
				Endif
				' always save all dirty files in temp before parsing
				' check changescounter here to avoid unnecessarily re-savings
				'
				Local tmpPath:=PathsProvider.GetTempFilePathForParsing( changedDoc.Path )
				If changedDoc.CheckChangesCounter() 'Or Not FileExists( tmpPath )
					SaveString( changedDoc.TextView.Text,tmpPath )
					changedDoc.StoreChangesCounter()
					CollectTempFile( tmpPath )
				Endif
			Next
			
			Global _results:=New StringStack
			
			' parse all docs
			'
			For Local params:=Eachin _paramsToParse
				Local errorStr:=parser.ParseFile( params )
				_results.Add( errorStr )
			Next
			
			' maybe app is in shutdown state
			'
			If Not enabled Return
			
			Global _errors:=New Stack<BuildError>
			
			' and collect all errors
			'
			Local tmpFolder:=PathsProvider.MX2_TMP+"/"
			For Local str:=Eachin _results
				
				If Not str Or str="#" Continue
				
				Local arr:=str.Split( "~n" )
				For Local s:=Eachin arr
					Local i:=s.Find( "] : Error : " )
					If i<>-1
						Local j:=s.Find( " [" )
						If j<>-1
							Local path:=s.Slice( 0,j )
							Local line:=Int( s.Slice( j+2,i ) )-1
							Local msg:=s.Slice( i+12 )
							path=path.Replace( tmpFolder,"" )
							Local err:=New BuildError( path,line,msg )
							_errors.Add( err )
						Endif
					Endif
				Next
			Next
			
			OnParseCompleted( parser,_errors )
			
			' don't remove tmp files to avoid unnecessarily re-savings
			'
'			For Local changedDoc:=Eachin _docsToParse
'				Local tmpPath:=Monkey2Parser.GetTempFilePathForParsing( changedDoc.Path )
'				DeleteFile( tmpPath )
'			Next
			
			_docsToParse.Clear()
			_paramsToParse.Clear()
			_errors.Clear()
			_results.Clear()
			
			_parsing=False
			
			_timeDocParsed=Millisecs()
			
		End )
		
	End
	
	Function CollectTempFile( path:String )
	
		If Not _tempFiles.Contains( path )
			_tempFiles.Add( path )
		Endif
	End
	
	Function UpdateDocItems( doc:CodeDocument,parser:ICodeParser )
	
		Local items:=GetCodeItems( doc.Path,parser )
		doc.OnDocumentParsed( items,Null )
	End
	
	Function OnParseCompleted( parser:ICodeParser,errors:Stack<BuildError> )
		
		Local docs:=docsForUpdate()
		If docs
			For Local doc:=Eachin docs
				Local items:=GetCodeItems( doc.Path,parser )
				doc.OnDocumentParsed( items,GetErrors( doc.Path,errors ) )
			Next
		Endif
	End
	
	Function GetErrors:Stack<BuildError>( path:String,errors:Stack<BuildError>)
		
		If errors.Empty Return errors
		
		Local st:=New Stack<BuildError>
		For Local i:=Eachin errors
			If i.path=path Then st.Add( i )
		Next
		Return st
	End
	
	Function GetCodeItems:Stack<CodeItem>( path:String,parser:ICodeParser )
		
		Local items:=New Stack<CodeItem>
		
		' extract all items in file
		Local list:=parser.ItemsMap[path]
		If list Then items.AddAll( list )
		
		' extensions are here too
		For Local lst:=Eachin parser.ExtraItemsMap.Values
			For Local i:=Eachin lst
				If i.FilePath=path
					If Not items.Contains( i.Parent ) Then items.Add( i.Parent )
				Endif
			Next
		Next
		
		Return items
	End
	
End
