
Namespace ted2go


Class XmlDocument Extends Ted2Document

	Method New( path:String )
		Super.New( path )
		
		_doc=New TextDocument
		
		_view=New TextView( _doc )
		
		_browser=New XmlTreeView
		
		_doc.TextChanged+=Lambda()
		
			Local xml:=New XMLDocument
			
			If xml.Parse( _doc.Text )<>XMLError.XML_SUCCESS xml=Null
			
			_browser.Data=xml
		
			Dirty=True
		End
	End

	Protected
	
	Method OnLoad:Bool() Override
	
		Local xml:=stringio.LoadString( Path )
		
		_doc.Text=xml
		
		Return True
	End
	
	Method OnSave:Bool() Override
	
		Local xml:=_doc.Text
		
		Return stringio.SaveString( xml,Path )
	End
	
	Method OnCreateView:View() Override
	
		Return _view
	End
	
	Method OnCreateBrowser:View() Override
	
		Return _browser
	End
	
	Private
	
	Field _doc:TextDocument
	
	Field _view:TextView
	
	Field _browser:XmlTreeView
End

Class XmlDocumentType Extends Ted2DocumentType

	Protected
	
	Method New()
		AddPlugin( Self )
		
		Extensions=New String[]( ".xml" )
	End
	
	Method OnCreateDocument:Ted2Document( path:String ) Override
	
		Return New XmlDocument( path )
	End
	
	Private
	
	Global _instance:=New XmlDocumentType
	
End
