
Namespace ted2go


Class RecentFiles
	
	Method New( docs:DocumentManager )
		
		docs.CurrentDocumentChanged+=Lambda()
			
			Local path:=docs.CurrentDocument?.Path
			If path Then Add( path )
		End
	End
	
	Method ShowDialog:String()
		
		Local dialog:=New RecentFilesDialog( Files )
		Local ok:=dialog.ShowModal()
		
		Return ok ? dialog.SelPath Else ""
	End
	
	Private
	
	Field _files:=New StringStack
	
	Method Add( path:String )
	
		_files.Remove( path )
		_files.Insert( 0,path )
	End
	
	Property Files:String[]()
	
		Return _files.ToArray()
	End
	
End


Class RecentFilesDialog Extends DialogExt

	Method New( files:String[] )
		
		_labelFilter=New Label
		'_labelFilter.MinSize=New Vec2i( 50,24 )
		
		' convert texts into items
		For Local i:=Eachin files
			_listItems.Add( New FileListViewItem( GetShortPath( i ),i ) )
		Next
		
		_listView=New AutocompleteListView( 20,100 )
		_listView.Layout="fill-x"
		_listView.MinSize=New Vec2i( 300,400 )
		SelectRelevantItem()
		_listView.OnItemChoosenDblClick+=Lambda()
			HideWithResult( True )
		End
		
		_docker=New DockingView
		_docker.AddView( _labelFilter,"top" )
		_docker.AddView( _listView,"top" )
		_docker.AddView( New Label( " " ),"top" )
		
		Title="Recently viewed files"
		
		MinSize=New Vec2i( 300,400 )
		
		ContentView=_docker
		
		Local close:=AddAction( "Close" )
		SetKeyAction( Key.Escape,close )
		close.Triggered=Lambda()
			HideWithResult( False )
		End
		
		Local ok:=AddAction( "Open" )
		SetKeyAction( Key.Enter,ok )
		ok.Triggered=Lambda()
			HideWithResult( True )
		End
		
		Activated+=Lambda()
			_listView.MakeKeyView()
			App.KeyEventFilter+=OnKeyFilter
		End
		
		Deactivated+=Lambda()
			MainWindow.UpdateKeyView()
			App.KeyEventFilter-=OnKeyFilter
		End
		
	End
	
	Property SelPath:String()
		
		Return Cast<FileListViewItem>( _listView.CurrentItem )?.Path
	End
	
	Private
	
	Field _listView:AutocompleteListView
	Field _labelFilter:Label
	Field _filter:String
	Field _docker:DockingView
	Field _listItems:=New Stack<ListViewItem>
	
	Method OnFilterChanged()
		
		_labelFilter.Text=_filter
		_listView.word=_filter
		SelectRelevantItem()
		RequestRender()
	End
	
	Method OnKeyFilter( event:KeyEvent )
		
		Select event.Type
			
			Case EventType.KeyDown,EventType.KeyRepeat
				
				Local key:=event.Key
				Select key
				
				Case Key.Escape
					Hide()
					event.Eat()
				
				Case Key.Up
					_listView.SelectPrev()
					event.Eat()
				
				Case Key.Down
					_listView.SelectNext()
					event.Eat()
				
				Case Key.PageUp
					_listView.PageUp()
					event.Eat()
				
				Case Key.PageDown
					_listView.PageDown()
					event.Eat()
				
				Case Key.Enter,Key.KeypadEnter
					'OnItemChoosen( curItem,key )
					
				Case Key.Backspace
					If _filter
						_filter=_filter.Slice( 0,_filter.Length-1 )
						OnFilterChanged()
					Endif
			
				End
				
			Case EventType.KeyChar
				_filter+=event.Text
				OnFilterChanged()
			
		End
		
	End
	
	Method SelectRelevantItem()
		
		If _listItems.Empty Return
		
		_listView.SetItems( _listItems )
		
		Local found:=0
		If _filter
			Local forDel:=New Stack<ListViewItem>
			_listView.Sort( Lambda:Int( lhs:ListViewItem,rhs:ListViewItem )
				
				Local lp:=CodeItemsSorter.GetIdentPower( lhs.Text,_filter,False )
				Local rp:=CodeItemsSorter.GetIdentPower( rhs.Text,_filter,False )
				
				If lp=0 Then forDel.Add( lhs )
				If rp=0 Then forDel.Add( rhs )
				
				Local r:=(rp<=>lp)
				If r=0 Return CodeItemsSorter.GetIdentLength( lhs )<=>CodeItemsSorter.GetIdentLength( rhs ) 'brings up shorter idents
				
				Return r
			End )
			' remove 'bad' variants
			For Local del:=Eachin forDel
				_listView.RemoveItem( del )
			Next
		Endif
		
		_listView.SelectByIndex( found )
	End
	
	Function GetShortPath:String( path:String )
		
		' TODO - show parent folder?
'		path=path.Replace( "/","\" )
'		Local i:=path.FindLast( "\" )
'		If i<>-1
'			Local s:=path.Slice( 0,i-1 )
'			Local i2:=s.FindLast( "\" )
'			If i2<>-1 Then i=i2
'			
'			Return path.Slice( i+1,path.Length ).Replace( "\"," \ " )
'		Endif
		
		Return StripDir( path )
	End
End

Class FileListViewItem Extends ListViewItem
	
	Method New( text:String,path:String )
		
		Super.New( text )
		_path=path
	End
	
	Property Path:String()
		Return _path
	End
	
	Private
	
	Field _path:String
	
End
