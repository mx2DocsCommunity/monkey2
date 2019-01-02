
Namespace ted2go


Class FindInFilesDialog Extends DialogExt
	
	Method New( actions:FindActions,projView:ProjectView )
		
		_findField=New TextFieldExt
		
		_findField.Entered+=Lambda()
			actions.findAllInFiles.Trigger()
		End
		
		_projList=New ListView
		_projList.MaxSize=New Vec2i( 400,120 )
		_filterField=New TextFieldExt( Prefs.FindFilesFilter )
		
		_caseSensitive=New CheckButton( "Case sensitive" )
		_caseSensitive.Layout="float"
		
		Local table:=New TableView( 2,4 )
		table[0,0]=New Label( "Find" )
		table[1,0]=_findField
		table[0,1]=New Label( "Where" )
		table[1,1]=_projList
		table[0,2]=New Label( "Filter" )
		table[1,2]=_filterField
		table[0,3]=New SpacerView( 0,8 )
		
		_docker=New DockingView
		_docker.AddView( table,"top" )
		_docker.AddView( _caseSensitive,"top" )
		'_docker.AddView( New Label( " " ),"top" )
		
		Title="Find in files"
		
		_docker.MinSize=New Vec2i( 440,230 )
		
		ContentView=_docker
		
		Local findAll:=AddAction( actions.findAllInFiles.Text )
		findAll.Triggered=Lambda()
			actions.findAllInFiles.Trigger()
			Prefs.FindFilesFilter=_filterField.Text.Trim()
		End
		
		Local close:=AddAction( "Close" )
		SetKeyAction( Key.Escape,close )
		close.Triggered=Hide
		
		_findField.Activated+=_findField.MakeKeyView
		
		Deactivated+=MainWindow.UpdateKeyView
		
		OnShow+=Lambda()
			
			If CustomFolder Return
			
			Local projs:=projView.OpenProjectsFolders
			If Not projs Return
			
			_projList.RemoveAllItems()
			
			Local sel:ListView.Item=Null
			For Local p:=Eachin projs
				Local it:=_projList.AddItem( p )
				If Not sel Then sel=it
				If p=_selProj Then sel=it
			Next
			_projList.Selected=sel
			
		End
		
	End
	
	Property CustomFolder:String()
		
		Return _customFolder
		
	Setter( value:String )
		
		_customFolder=value
		If Not _customFolder Return
		
		_projList.RemoveAllItems()
		_projList.Selected=_projList.AddItem( _customFolder )
	End
	
	Property FindText:String()
	
		Return _findField.Text
	End
	
	Property FilterText:String()
	
		Return _filterField.Text.Trim()
	End
	
	Property SelectedProject:String()
	
		Return _projList.Selected.Text
	End
	
	Property CaseSensitive:Bool()
	
		Return _caseSensitive.Checked
	End
	
	Method SetInitialText( find:String )
		
		_findField.Text=find
		_findField.SelectAll()
	End
	
	Method SetSelectedProject( proj:String )
	
		_selProj=proj
	End
	
	Private
	
	Field _findField:TextFieldExt
	Field _filterField:TextFieldExt
	Field _caseSensitive:CheckButton
	Field _projList:ListView
	Field _docker:DockingView
	Field _customFolder:String
	Field _selProj:String
	
End
