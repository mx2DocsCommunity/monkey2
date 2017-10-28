
Namespace ted2go


Class NoTitleDialog Extends View
	
	Field OnShow:Void()
	Field OnHide:Void()
	
	Method New()
		
		Style=GetStyle( "CompletionDialog" )
		
		_content=New DockingView
		_content.Style=GetStyle( "CompletionDialogContent" )
		
		AddChildView( _content )
	End
	
	Property ContentView:View()
	
		Return _content.ContentView
	
	Setter( contentView:View )
	
		_content.ContentView=contentView
	End
	
	Method Open()
		
		Assert( Not _window,"Dialog is already open" )
	
		_window=App.ActiveWindow
	
		Local size:=MeasureLayoutSize()
	
		Local origin:=(_window.Rect.Size-size)/2
	
		Frame=New Recti( origin,origin+size )
	
		_window.AddChildView( Self )
	End
	
	Method Close()
		
		Assert( _window,"Dialog is not open" )
	
		_window.RemoveChildView( Self )
	
		_window=Null
	End
	
	Property IsOpened:Bool()
		
		Return _opened
	End
	
	Method Show()
		
		If _opened Return
		_opened = True
		Open()
		OnShow()
	End
	
	Method Hide()
		
		If Not _opened Return
		_opened = False
		Close()
		OnHide()
	End
	
	
	Protected
	
	Method OnMeasure:Vec2i() Override
		
		Return _content.LayoutSize
	End
	
	Method OnLayout() Override
		
		_content.Frame=Rect
	End
	
	
	Private
	
	Field _opened:Bool
	Field _content:DockingView
	Field _window:Window
	
End
