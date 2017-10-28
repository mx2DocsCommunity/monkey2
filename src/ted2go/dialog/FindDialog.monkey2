
Namespace ted2go


Class FindDialog Extends DialogExt

	Method New( actions:FindActions )
	
		_findField=New TextFieldExt
		
		_replaceField=New TextFieldExt
		
		_findField.Entered+=Lambda()
			actions.findNext.Trigger()
		End
		_findField.TextChanged+=Lambda(  )
			#Rem
			Local t:=_findField.Text
			If t.Length > 1
				If Not Prefs.SiblyMode
					actions.FindByTextChanged( EntireProject )
				Endif
			Endif
			#End
		End

		_findField.Tabbed+=_replaceField.MakeKeyView

		_replaceField.Tabbed+=_findField.MakeKeyView
		
		_caseSensitive=New CheckButton( "Case sensitive" )
		_caseSensitive.Layout="float"
		
		_entireProject=New CheckButton( "Entire project" )
		_entireProject.Layout="float"
		
		Local entireHint:=New Label( "(use 'Find next' button for entire-project-mode)" )
		entireHint.Visible=False
		_entireProject.Clicked+=Lambda()
			entireHint.Visible=_entireProject.Checked
		End
		
		Local table:=New TableView( 2,2 )
		table[0,0]=New Label( "Find" )
		table[1,0]=_findField
		table[0,1]=New Label( "Replace" )
		table[1,1]=_replaceField 
		
		_docker=New DockingView
		_docker.AddView( table,"top" )
		_docker.AddView( _caseSensitive,"top" )
		_docker.AddView( _entireProject,"top" )
		_docker.AddView( entireHint,"top" )
		_docker.AddView( New Label( " " ),"top" )
		
		Title="Find / Replace"
		
		MaxSize=New Vec2i( 512,0 )
		
		ContentView=_docker
		
		AddAction( actions.findNext )
		AddAction( actions.findPrevious )
		AddAction( actions.replace )
		AddAction( actions.replaceAll )
		
		Local close:=AddAction( "Close" )
		SetKeyAction( Key.Escape,close )
		close.Triggered=Hide
		
		_findField.Activated+=_findField.MakeKeyView
		
		Deactivated+=MainWindow.UpdateKeyView
	End
	
	Property FindText:String()
	
		Return _findField.Text
	End
	
	Property ReplaceText:String()
	
		Return _replaceField.Text
	End
	
	Property CaseSensitive:Bool()
	
		Return _caseSensitive.Checked
	End
	
	Property EntireProject:Bool()
	
		Return _entireProject.Checked
	End
	
	Method SetInitialText( find:String )
If Not Prefs.SiblyMode
		_findField.Text=find
Endif
		_findField.SelectAll()
	End
	
	
	Private
	
	Field _findField:TextFieldExt
	Field _replaceField:TextFieldExt
	Field _caseSensitive:CheckButton
	Field _entireProject:CheckButton

	Field _docker:DockingView

End
