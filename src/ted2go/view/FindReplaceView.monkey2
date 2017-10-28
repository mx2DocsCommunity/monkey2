
Namespace ted2go


Class FindReplaceView Extends DockingView
	
	Enum Kind
		Find,
		Replace
	End
	
	Field RequestedFind:Void( opt:FindOptions )
	Field RequestedReplace:Void( opt:FindOptions )
	
	Method New( actions:FindActions )
		
		Super.New()
		
		Style=GetStyle( "FindReplaceView","DockingView" )
		
		Local mainDock:=New DockingView
		
		' FIND
		'
		Local findDock:=New DockingView
		
		Local what:=New Label( "Find:" )
		what.MinSize=New Vec2i( 60,0 )
		findDock.AddView( what,"left" )
		
		_editFind=New TextFieldExt
		_editFind.MaxSize=New Vec2i( 160,24 )
		_editFind.Entered+=Lambda()
			OnFindNext()
		End
		findDock.AddView( _editFind,"left" )
		
		Local dock:DockingView
		dock=New DockingView
		findDock.AddView( dock,"left" )
		
		_chbCase=New CheckButton( "Case sens." )
		_chbSel=New CheckButton( "Sel. text only" )
		_chbWrap=New CheckButton( "Wrap around" )
		_chbWrap.Checked=True
		
		_chbCase.Clicked+=Lambda()
			_options.caseSensitive=_chbCase.Checked
		End
		
		_chbSel.Clicked+=Lambda()
			Local sel:=_chbSel.Checked
			If Not _tv Or Not _tv.CanCopy Then sel=False ; _chbSel.Checked=False
			_options.selectionOnly=sel
			If _tv
				If sel Then _tv.MarkSelectionAsExtraSelection() Else _tv.ResetExtraSelection()
			Endif
		End
		
		_chbWrap.Clicked+=Lambda()
			_options.wrapAround=_chbWrap.Checked
		End
		
		Local act:=New Action( "Next >" )
		act.Triggered+=Lambda()
			
			OnFindNext()
		End
		_buttonFindNext=New ToolButtonExt( act,GetActionTextWithShortcut( actions.findNext ) )
		
		act=New Action( "< Prev" )
		act.Triggered+=Lambda()
			
			_options.Set( _editFind.Text,"",_chbCase.Checked,_chbWrap.Checked,False,_chbSel.Checked )
			RequestedFind( _options )
		End
		_buttonFindPrev=New ToolButtonExt( act,GetActionTextWithShortcut( actions.findPrevious ) )
		
		dock.AddView( New SpacerView( 16,0 ),"left" )
		dock.AddView( _buttonFindPrev,"left" )
		dock.AddView( New SpacerView( 5,0 ),"left" )
		dock.AddView( _buttonFindNext,"left" )
		dock.AddView( New SpacerView( 5,0 ),"left" )
		dock.AddView( _chbCase,"left" )
		dock.AddView( New SpacerView( 5,0 ),"left" )
		dock.AddView( _chbSel,"left" )
		dock.AddView( New SpacerView( 5,0 ),"left" )
		dock.AddView( _chbWrap,"left" )
		dock.AddView( New SpacerView( 10,0 ),"left" )
		
		' replace switcher
		Local act2:=New Action( "R" )
		act2.Triggered=Lambda()
			Mode = (_mode=Kind.Find) ? Kind.Replace Else Kind.Find
		End
		Local replSwitcher:=New ToolButtonExt( act2,"Show / hide replace panel" )
		dock.AddView( replSwitcher,"left" )
		
		' don't want to fix padding-right for TabClose style
		findDock.AddView( New SpacerView( 6,0 ),"right" )
		
		Local close:=New Button
		close.Style=GetStyle( "TabClose" )
		close.Icon=close.Style.Icons[0]
		close.Clicked=Lambda()
			MainWindow.HideFindPanel() 'dirty
		End
		
		findDock.AddView( close,"right" )
		
		' REPLACE
		'
		_replaceDock=New DockingView
		
		Local with:=New Label( "Replace:" )
		with.MinSize=New Vec2i( 60,0 )
		_replaceDock.AddView( with,"left" )
		
		_editReplace=New TextFieldExt
		_editReplace.MaxSize=New Vec2i( 160,24 )
		_replaceDock.AddView( _editReplace,"left" )
		
		dock=New DockingView
		_replaceDock.AddView( dock,"left" )
		
		act=New Action( "Replace" )
		act.Triggered+=Lambda()
			
			_options.Set( _editFind.Text,_editReplace.Text,_chbCase.Checked,_chbWrap.Checked,True,_chbSel.Checked )
			RequestedReplace( _options )
		End
		_buttonReplace=New ToolButtonExt( act )
		
		act=New Action( "Replace all" )
		act.Triggered+=Lambda()
			
			_options.Set( _editFind.Text,_editReplace.Text,_chbCase.Checked,_chbWrap.Checked,True,_chbSel.Checked,True )
			RequestedReplace( _options )
		End
		_buttonReplaceAll=New ToolButtonExt( act )
		
		dock.AddView( New SpacerView( 16,0 ),"left" )
		dock.AddView( _buttonReplace,"left" )
		dock.AddView( New SpacerView( 5,0 ),"left" )
		dock.AddView( _buttonReplaceAll,"left" )
		
		mainDock.AddView( findDock,"top" )
		mainDock.AddView( _replaceDock,"top" )
		
		_editFind.NextView=_editReplace
		_editReplace.NextView=_editFind
		
		Self.ContentView=mainDock
	End
	
	Property Mode:Kind()
		Return _mode
	Setter( value:Kind )
		_mode=value
		_replaceDock.Visible=(_mode=Kind.Replace)
	End
	
	Property FindText:String()
		Return _editFind.Text
	Setter( value:String )
		_editFind.Text=value
		_editFind.SelectAll()
	End
	
	Property CodeView:CodeTextView()
		Return _tv
	Setter( value:CodeTextView )
		If _tv=value Return
		If _tv Then _tv.ResetExtraSelection()
		_tv=value
		If _tv And _chbSel.Checked
			If _tv.CanCopy
				_tv.MarkSelectionAsExtraSelection()
			Else
				_chbSel.Checked=False
			Endif
		Endif
	End
	
	Method Activate()
		
		MainWindow.UpdateWindow( False ) 'hack
		_editFind.MakeKeyView()
		_editFind.SelectAll()
	End
	
	
	Private
	
	Field _mode:Kind
	Field _editFind:TextFieldExt
	Field _editReplace:TextFieldExt
	Field _chbCase:CheckButton
	Field _chbWrap:CheckButton
	Field _chbSel:CheckButton
	Field _buttonFindNext:ToolButtonExt
	Field _buttonFindPrev:ToolButtonExt
	Field _buttonReplace:ToolButtonExt
	Field _buttonReplaceAll:ToolButtonExt
	Field _replaceDock:DockingView
	Field _tv:CodeTextView
	
	Field _options:=New FindOptions
	
	Method OnFindNext()
		
		_options.Set( _editFind.Text,"",_chbCase.Checked,_chbWrap.Checked,True,_chbSel.Checked )
		RequestedFind( _options )
	End
End


Class FindOptions

	Field findText:String
	Field replaceText:String
	Field caseSensitive:Bool
	Field wrapAround:Bool
	Field goNext:Bool
	Field all:Bool
	Field selectionOnly:Bool
	
	Method New()
	End
	
	Method Set( find:String,replace:String,caseSens:Bool,wrap:Bool,goNext:Bool,selOnly:Bool,all:Bool=False )

		findText=find
		replaceText=replace
		caseSensitive=caseSens
		wrapAround=wrap
		selectionOnly=selOnly
		Self.goNext=goNext
		Self.all=all
	End
End
