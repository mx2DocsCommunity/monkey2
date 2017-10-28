
Namespace ted2go


'Based on code by Shane Raffa!
'
Class XmlTreeView Extends TreeView

	Method New()
		RootNode.Text="[No Data]"
	End

	Property Data:XMLDocument()
	
		Return _data
	
	Setter( data:XMLDocument )
	
		_data=data
		
		RootNode.RemoveAllChildren()
		
		If Not _data
			RootNode.Text="[No Data]"
			Return
		Endif

		RootNode.Text = "XML Document"
 
		AddXMLNodeToTree( _data,RootNode )
	End
	
	Private
	
	Field _data:XMLDocument
	
	Method AddXMLNodeToTree( xmlNode:XMLNode,parent:Node )
	
		Local str := ""
	
		Local xmlElement := xmlNode.ToElement()
		
		If xmlElement
		
			str += "<" + xmlNode.Value()
			
			Local attrib := xmlElement.FirstAttribute()
			While attrib 
				str += " " + attrib.Name() + "=~q" + attrib.Value() + "~q "
				attrib=attrib.NextAttribute()
			wend
			
			str += ">"
		Else
			str += xmlNode.Value()
		Endif
 
		Local treeNode:Node
	
		If str
			treeNode = New Node(str, parent)
		Endif
		
		Local xmlChild := xmlNode.FirstChild()
	
		While xmlChild
		
			If Not xmlChild.NoChildren()
				If treeNode Then parent = treeNode
			Endif
		
			AddXMLNodeToTree(xmlChild, parent)
			
			xmlChild = xmlChild.NextSibling()
	
		Wend
	
	End
End
