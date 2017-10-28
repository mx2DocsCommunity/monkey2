
Namespace ted2go


Class LiveTemplateDialog
	
	Method New()
	
		Title="Live templates"
	
		Local dock:=New DockingView
		_tree=New TreeViewExt
		_tree.NodeClicked=Lambda( node:Node )
			
			If node.Parent=_tree.RootNode Return
			
			ShowTemplate( node.Parent.Text,node.Text )
		End
		FillTree( _tree )
	
		dock.AddView( _tree,"left","150",True)
		
		_codeView=New Ted2CodeTextView
		dock.ContentView=_codeView
		
		ContentView=dock
	
		Local cancel:=AddAction( "Cancel"  )
		cancel.Triggered=lambda()
			_result.Set( False )
		End
		SetKeyAction( Key.Escape,cancel )
	
		Local okay:=AddAction( "Save" )
		okay.Triggered=Lambda()
			_result.Set( True )
		End
		SetKeyAction( Key.Enter,okay )
		
	End
	
	
	Private
	
	Field _tree:TreeViewExt
	Field _codeView:Ted2CodeTextView
	
	Method ShowTemplate( lang:String,name:String )
		
		If _codeView.FileType<>lang Then _codeView.FileType=lang
		_codeView.Text=LiveTemplates[lang,name]
		_codeView.SelectText( 0,0 )
	End
	
	Method FillTree( tree:TreeView )
		
		For Local map:=Eachin LiveTemplates.All()
			Local node:=New TreeView.Node( map.Key,tree.RootNode )
			For Local i:=Eachin map.Value.All()
				New TreeView.Node( i.Key,node )
			Next
		Next
	End
	
End

