
Namespace ted2go


Class DebugView Extends DockingView

	Method New( docs:DocumentManager,console:ConsoleExt )
	
		_docs=docs
		_console=console
		
		'FIXME: this will never get removed...
		_console.Finished+=Lambda( exitCode:Int )
			If Not _debugging Return
			
			If _stopped Resume()
		End

		_toolBar=New ToolBar
		_toolBar.Style=GetStyle( "DebugToolBar" )
		Local icons:=_toolBar.Style.Icons
		
		'run/pause
		_run=_toolBar.AddAction( "",icons[2] )
		_run.Triggered=Lambda()
			If Not _debugging Return
		
			If _stopped
				_console.WriteStdin( "r~n" )
				Resume()
				ResetDebugLines()
			Else
				_console.Process.SendBreak()
			Endif
		
		End

		'step over
		_step=_toolBar.AddAction( "",icons[3] )
		_step.Triggered=Lambda()
			If Not _debugging Return
			
			If _stopped
				_console.WriteStdin( "s~n" )
				Resume()
			Endif
			
		End
		
		'step into
		_enter=_toolBar.AddAction( "",icons[4] )
		_enter.Triggered=Lambda()
			If Not _debugging Return
		
			If _stopped
				_console.WriteStdin( "e~n" )
				Resume()
			Endif
			
		End

		'step out
		_leave=_toolBar.AddAction( "",icons[5] )
		_leave.Triggered=Lambda()
			If Not _debugging Return
		
			If _stopped
				_console.WriteStdin( "l~n" )
				Resume()
			Endif
			
		End
		
		'kill
		_kill=_toolBar.AddAction( "",icons[1] )
		_kill.Triggered=Lambda()
			If Not _debugging Return
		
			If _stopped
				_console.WriteStdin( "q~n" )
				Resume()
			Else
				_console.Process.SendBreak()
				_killme=True
			Endif
		
		End
		
		AddView( _toolBar,"top" )
		
		_tree=New TreeViewExt
		_tree.RootNodeVisible=False
		_tree.RootNode.Expanded=True
		
		_tree.NodeClicked += Lambda( tnode:TreeView.Node )
		
			Local node:=Cast<Node>( tnode )
			If Not node Return
			
			If node.srcFile
			
				Local doc:=Cast<CodeDocument>( _docs.OpenDocument( node.srcFile,True ) )
				If Not doc Return
				
				MainWindow.UpdateWindow( False )

				doc.DebugLine=node.srcLine-1
			Endif
		
		End
		
		_tree.NodeExpanded=Lambda( tnode:TreeView.Node )
			If Not _stopped Return
			
			Local node:=Cast<Node>( tnode )
			If Not node Or Not node.scope Return
			
			New Fiber( Lambda()
				UpdateExpanded( node )
			End )
		End
		
		ContentView=New ScrollView( _tree )
		
		UpdateActions()
	End
	
	Method DebugApp( appFile:String,config:String )
		
		If _console.Running Return
		
		_console.Clear()
		
		MainWindow.ShowOutputConsole()
	
		Local cmd:="~q"+RealPath( appFile )+"~q"
		
		If config<>"debug"
		
			_console.Run( cmd )
			
			_console.Write( "~nFinished running app.~n" )
			
			OnStopRunning( "Finished running app." )
			
			Return
		End
		
		If Not _console.Start( cmd )
			
			Alert( "Failed to start process: '"+cmd+"'" )
			OnStopRunning( "Failed to start process: '"+cmd+"'" )
			Return
		Endif
		
		DebugBegin()
		
		Repeat
			
			Local stdout:=_console.ReadStdout()
			If Not stdout Exit
			
			If stdout="{{!DEBUG!}}~n"
				DebugStop()
				Continue
			End
			
			_console.Write( stdout )
		
		Forever
		
		DebugEnd()
		
		ResetDebugLines()
		
		_console.Write( "~nFinished debugging app.~n" )
		
		OnStopRunning( "Finished debugging app." )
	End
	
	Method KillApp()
		
		_kill.Trigger()
	End
	
	Private
	
	Method OnStopRunning( info:String )
		
		MainWindow.UpdateKeyView()
		MainWindow.SetStatusBarActive( False )
		MainWindow.ShowStatusBarText( info )
		MainWindow.RestoreConsoleVisibility()
		MainWindow.HideStatusBarProgress()
		
	End
	
	Method ResetDebugLines()
	
		For Local doc:=Eachin _docs.OpenDocuments
			Local mx2Doc:=Cast<CodeDocument>( doc )
			If mx2Doc mx2Doc.DebugLine=-1
		Next
	End
	
	
	Class Node Extends TreeView.Node

		Field srcFile:String
		Field srcLine:Int
		Field seq:Int
		
		Field name:String
		Field type:String
		Field value:String
		Field scope:Bool
	
		Method New( label:String,parent:TreeView.Node=Null,seq:Int=0,index:Int=-1 )
			Super.New( "",parent,index )
			Self.seq=seq
			
			Update( label )
		End
		
		Method Update( label:String )
		
			Local tname:=name
			Local ttype:=type
			Local tvalue:=value
		
			name=""
			type=""
			value=""
			scope=False
			
			Local i0:=label.Find( ":" )
			If i0<>-1
				name=label.Slice( 0,i0 )
				Local i1:=label.Find( "=",i0+1 )
				If i1=-1
					type=label.Slice( i0+1 )
				Else
					type=label.Slice( i0+1,i1 )
					value=label.Slice( i1+1 )
					
					If value.StartsWith( "@" )
					
						label=name+":"+type
						
						If value.Contains( ":" )
							scope=True
						Else
							Local p:ULong
							If value.StartsWith( "@0x" )
								p=StringToULong( value.Slice( 3 ),16 )
							Else
								p=StringToULong( value.Slice( 1 ),16 )
							Endif
							If p
								label+="="+value
								scope=True
							Else
								label+="=Null"
							Endif
						Endif
					Endif					
				Endif
			Endif
			
			Text=label
			
			If name=tname And type=ttype And value=tvalue Return
			
			RemoveAllChildren()
			
			If scope New Node( "",Self )
		End
	
	End
	
	Field _tree:TreeView
	
	Field _toolBar:ToolBar

	Field _docs:DocumentManager	
	Field _console:ConsoleExt

	Field _debugging:Bool
	Field _stopped:Bool
	Field _killme:Bool
	Field _resume:Future<Bool>
	
	Field _run:Action
	Field _step:Action
	Field _enter:Action
	Field _leave:Action
	Field _kill:Action
	
	Method UpdateExpanded( node:Node )
	
		If Not node.scope Return

		Local lines:=New StringStack
		
		_console.WriteStdin( node.value+"~n" )
		
		Repeat
			Local line:=_console.ReadStdout().Trim()
			If Not line Exit
			
			lines.Push( line )
		Forever
		
		For Local i:=0 Until lines.Length
		
			Local line:=lines[i]
			Local child:=Cast<Node>( node.GetChild( i ) )
			
			If child
				child.Update( line )
				If child.Expanded UpdateExpanded( child )
			Else
				New Node( line,node )
			Endif
		
		Next
		
		node.RemoveChildren( lines.Length )
		
		RequestRender()
	End
	
	Method UpdateTree()
	
		Local root:=_tree.RootNode
		
		Local funcIndex:=0
		
		Local func:Node
		Local varIndex:=0
		
		Local first:Node
		
		Local expanded:=New Stack<Node>
		
		Repeat
		
			Local line:=_console.ReadStdout().Trim()
			If Not line Exit
			
			If line.StartsWith( ">" )
			
				If func func.RemoveChildren( varIndex )
			
				Local bits:=line.Split( ";" )
				Local label:=bits[0].Slice( 1 )
				Local seq:=Int( bits[3] )
				
				func=Null
				For Local i:=funcIndex Until root.NumChildren
					Local tfunc:=Cast<Node>( root.GetChild( i ) )
					If Not tfunc Or tfunc.seq<>seq Continue
					root.RemoveChildren( funcIndex,i )
					func=tfunc
					Exit
				Next
				
				If func
					func.Text=label
					func.srcLine=Int( bits[2] )
				Else
					func=New Node( label+"*",root,seq,funcIndex )
					func.srcFile=bits[1]
					func.srcLine=Int( bits[2] )
					func.seq=seq
					
					If Not first func.Expanded=True
				Endif
				
				If Not first
					_docs.CurrentCodeDocument?.JumpToDebugLine( func.srcFile,func.srcLine-1 )
					first=func
				Endif
				
				funcIndex+=1
				
				varIndex=0
			
				Continue
				
			Endif
			
			Local node:=Cast<Node>( func.GetChild( varIndex ) )
			
			If node
				node.Update( line )
				If node.Expanded expanded.Push( node )
			Else
				New Node( line,func )
			Endif
			
			varIndex+=1

		Forever
		
		For Local node:=Eachin expanded
			UpdateExpanded( node )
		Next
		
		If func func.RemoveChildren( varIndex )
		
		root.RemoveChildren( funcIndex )
		
		RequestRender()
	End
	
	Method DebugBegin()
	
		Assert( Not _stopped )
		
		_tree.RootNode.RemoveAllChildren()
		
		_killme=False
		_debugging=True
		
		UpdateActions()
	End
	
	Method DebugEnd()
	
		Assert( Not _stopped )
		
		_debugging=False
		UpdateActions()
	End
	
	Method DebugStop()
	
		Assert( Not _stopped )
		
		MainWindow.ShowDebugView()
	
		UpdateTree()
		
		If _killme
			_console.WriteStdin( "q~n" )
			Return
		Endif
		
		_resume=New Future<Bool>
		_stopped=True
		
		UpdateActions()
		
		_resume.Get()
	End
	
	Method Resume()
	
		Assert( _stopped )
		
		_stopped=False
		
		UpdateActions()
		
		_resume.Set( True )
		_resume=Null
	End
	
	Method UpdateActions()
		Local icons:=_toolBar.Style.Icons
		_run.Icon=_stopped ? icons[0] Else icons[2]
		_run.Enabled=_debugging
		_step.Enabled=_stopped And _debugging
		_enter.Enabled=_stopped And _debugging
		_leave.Enabled=_stopped And _debugging
		_kill.Enabled=_debugging
	End
	
End
