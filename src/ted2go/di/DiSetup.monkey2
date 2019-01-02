
Namespace ted2go

' place where all our types are created
'
Function SetupDiContainer()
	
	Di.Bind( Lambda:ExamplesView()
		Return New ExamplesView(
			Di.Resolve<DocumentManager>() )
	End )
	
	Di.Bind( Lambda:DocsTabView()
		Return New DocsTabView( TabViewFlags.DraggableTabs|TabViewFlags.ClosableTabs )
	End )
	
	Di.Bind<DocBrowserView>()
	Di.Bind<OutputConsole>()
	Di.Bind<BuildConsole>()
	
	Di.Bind( Lambda:DocumentManager()
		Return New DocumentManager(
			Di.Resolve<DocsTabView>(), ' views shouldn't be here!
			Di.Resolve<DocBrowserView>() )
	End )
	
	Di.Bind( Lambda:ProjectView()
		Return New ProjectView(
			Di.Resolve<DocumentManager>(),
			Di.Resolve<BuildActions>() )
	End )
	
	Di.Bind( Lambda:DebugView()
		Return New DebugView( 
			Di.Resolve<DocumentManager>(),
			Di.Resolve<OutputConsole>() )
	End )
	
	Di.Bind( Lambda:BuildActions()
		Return New BuildActions( 
			Di.Resolve<DocumentManager>(),
			Di.Resolve<BuildConsole>(),
			Di.Resolve<DebugView>() )
	End )
	
	Di.Bind<HelpView>()
	
	Di.Bind( Lambda:HelpTreeView()
		Local view:=New HelpTreeView(
			Di.Resolve<HelpView>() )
		view.Init()
		Return view
	End )
	
	Di.Bind( Lambda:CodeParsing()
		Return New CodeParsing(
			Di.Resolve<DocumentManager>(),
			Di.Resolve<ProjectView>() )
	End )
End


' some necessarily overhead
'
' ideally all classes with business logic must have interfaces
' and we must works with interfaces
'
Class DocsTabView Extends TabViewExt
	Method New( flags:TabViewFlags=TabViewFlags.DraggableTabs )
		Super.New( flags )
	End
End

Class DocBrowserView Extends DockingView
	
	Method New()
		
		Super.New()
		
		_propView=New DockingView
		AddView( _propView,"bottom",200,True )
	End
	
	Property PropertiesViewHeight:Int()
		Return Int(GetViewSize( _propView ))
	Setter( value:Int )
		SetViewSize( _propView,value )
	End
	
	Property PropertiesView:DockingView()
		Return _propView
	End
	
	Private
	
	Field _propView:DockingView
	
End


Class BuildConsole Extends ConsoleExt
End

Class OutputConsole Extends ConsoleExt
End

Class HelpView Extends HtmlViewExt
End