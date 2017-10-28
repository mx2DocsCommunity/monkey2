
Namespace ted2go


Class ProductVar

	Field name:String
	Field value:String
	Field type:String
		
	Method New( name:String,value:String,type:String="string" )
		Self.name=name
		Self.value=value
		Self.type=type
	End
	
	Method CreateFieldView:View()
	
		Local fieldView:View
		
		Select type
		Case "string"
		
			Local view:=New TextFieldExt( value )
			
			view.TextChanged+=Lambda()
				value=view.Text
			End
			
			fieldView=view
			
		Case "directory"
		
			Local view:=New FilePathField( value,FileType.Directory )
			
			view.FilePathChanged=Lambda()
				value=view.FilePath
			End
			
			fieldView=view
			
		Default
		
			If type.StartsWith( "options:" )

				Local opts:=type.Slice( 8 ).Split( "|" )
				
				Local current:=0
				For Local i:=0 Until opts.Length
					If value<>opts[i] Continue
					current=i
					Exit
				Next

				Local view:=New OptionsField( opts,current )

				view.CurrentChanged+=Lambda()

					value=opts[view.Current]
				End
			
				fieldView=view

			Endif
		End
		
		Return fieldView
	End
		
End

Class EditProductDialog Extends Dialog

	Method New( title:String,vars:Stack<ProductVar> )
	
		Title=title
		
		_vars=vars
		
		_table=New TableView
		_table.AddColumn( "Setting" )
		_table.AddColumn( "Value" )
		
		_table.Rows+=_vars.Length
		
		For Local i:=0 Until _vars.Length
			Local pvar:=_vars[i]
			
			_table[0,i]=New Label( pvar.name )
			_table[1,i]=pvar.CreateFieldView()
		End
		
		ContentView=_table
		
		Local okay:=AddAction( "Okay" )
		okay.Triggered=Lambda()
			_result.Set( True )
		End
		SetKeyAction( Key.Enter,okay )

		Local cancel:=AddAction( "Cancel"  )
		cancel.Triggered=lambda()
			_result.Set( False )
		End
		SetKeyAction( Key.Escape,cancel )
	End
	
	Method Run:Bool()
	
		Open()
		
		App.BeginModal( Self )
		
		Local result:=_result.Get()
		
		App.EndModal()
		
		Close()
		
		Return result
	End
	
	Private
	
	Field _table:TableView
	
	Field _vars:Stack<ProductVar>
	
	Field _result:=New Future<Bool>

End
