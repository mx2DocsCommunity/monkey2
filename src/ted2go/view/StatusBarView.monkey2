
Namespace ted2go


Class StatusBarView Extends DockingView
	
	Field Cancelled:Void()
	
	Method New( stopProcessHint:String="Stop process" )
		
		Style=GetStyle( "StatusBar" )
		
		_labelText=New Label()
		_labelText.Style=GetStyle( "StatusBarText" )
		
		_labelIns=New Label( "INS")
		_labelIns.MinSize=New Vec2i( 44,0 )
		_labelIns.Style=GetStyle( "StatusBarIns" )
		AddView( _labelIns,"right" )
		' DoubleClick
		_labelIns.DoubleClicked+=Lambda()
		
			MainWindow.OverwriteTextMode=Not MainWindow.OverwriteTextMode
		End
		
		_labelLineInfo=New Label( "0 : 0")
		_labelLineInfo.MinSize=New Vec2i( 200,0 )
		_labelLineInfo.Style=GetStyle( "StatusBarLineInfo" )
		AddView( _labelLineInfo,"right" )
		' DoubleClick
		_labelLineInfo.DoubleClicked+=Lambda()
		
			MainWindow.GotoLine()
		End
		
		Local act:=New Action( Null,ThemeImages.Get( "cancel.png" ) )
		act.Triggered=OnCancel
		
		_progressCancel=New ToolButtonExt( act,"" )
		_progressCancel.Hint=stopProcessHint
		_progressCancel.Style=GetStyle( "StatusBarButton" )
		AddView( _progressCancel,"right" )
		
		_progress=New ProgressBar
		_progress.MinSize=New Vec2i( 170,0 )
		_progress.MaxSize=New Vec2i( 170,16 )
		_progress.Layout="float"
		_progress.Style=GetStyle( "StatusBarProgress" )
		AddView( _progress,"right" )
		
		ContentView=_labelText
		
		HideProgress()
		UpdateThemeColors()
	End
	
	Method OnThemeChanged() Override
		
		Super.OnThemeChanged()
		UpdateThemeColors()
	End
	
	Method SetText( text:String,append:Bool=False )
		
		If append Then text=_labelText.Text+text
		_labelText.Text=text
	End
	
	Method SetLineInfo( text:String )
		
		_labelLineInfo.Text=text
	End
	
	Method SetInsMode( ins:Bool )
		
		_labelIns.Text=ins ? "INS" else "OVR"
	End
	
	Method ShowProgress( cancelIconOnly:Bool=False )
		
		If Not cancelIconOnly Then _progress.Visible=True
		_progressCancel.Visible=True
	End
	
	Method HideProgress()
		
		_progress.Visible=False
		_progressCancel.Visible=False
	End
	
	Method SetActiveState( active:Bool )
		
		RenderStyle.BackgroundColor=active ? _activeColor Else _defaultColor
	End
	
	Private
	
	Field _labelText:Label
	Field _labelLineInfo:Label
	Field _labelIns:Label
	Field _progress:ProgressBar
	Field _progressCancel:ToolButtonExt
	Field _activeColor:Color,_defaultColor:Color
	
	Method OnCancel()
		
		HideProgress()
		Cancelled()
	End
	
	Method UpdateThemeColors()
		
		_defaultColor=App.Theme.GetColor( "statusbar" )
		_activeColor=App.Theme.GetColor( "statusbar-active" )
	End
	
End
