
Namespace mojo3d

#rem monkeydoc The Entity class.
#end
Class Entity Abstract
	
	#rem monkeydoc Copied signal.
	
	Invoked after an entity is copied.
	
	#end
	Field Copied:Void( copy:Entity )

	#rem monkeydoc Destroyed signal.
	
	Invoked after an entity is destroyed.
	
	#end
	Field Destroyed:Void()
	
	#rem monkeydoc Hidden signal.
	
	Invoked after an entity is hidden.
	
	#end
	Field Hidden:Void()
	
	#rem monkeydoc Shown signal.
	
	Invoked after an entity is shown.
	
	#end
	Field Shown:Void()
	
	#rem monkeydoc Creates a new entity.
	#end
	Method New( parent:Entity=Null )
		
		_parent=parent
		
		If _parent 
			_scene=_parent._scene
			_parent._children.Add( Self )
		Else
			_scene=Scene.GetCurrent()
			_scene.RootEntities.Add( Self )
		Endif
			
		Invalidate()
	End
	
	#rem monkeydoc Creates a copy of the entity.
	#end
	Method Copy:Entity( parent:Entity=Null ) Virtual
		
		Local copy:=OnCopy( parent )
		
		CopyTo( copy )
		
		Return copy
	End
	
	#rem monkeydoc Sequence id
	
	The sequence id is an integer that is incremented whenever the entity's matrix is modified.
	
	#end
	Property Seq:Int()
		
		Return _seq
	End
	
	#rem monkeydoc Name
	#end
	[jsonify=1]
	Property Name:String()
		
		Return _name
	
	Setter( name:String )
		
		_name=name
	End

	#rem monkeydoc Scene
	
	The scene the entity belongs to.
	
	#end
	Property Scene:Scene()
	
		Return _scene
	End
	
	#rem monkeydoc Parent entity.
	#end
	[jsonify=1]
	Property Parent:Entity()
		
		Return _parent
	
	Setter( parent:Entity )
		
		Assert( Not parent Or parent._scene=_scene )
		
		Local matrix:AffineMat4f=parent ? LocalMatrix Else Matrix
		
		If _parent
			_parent._children.Remove( Self )
		Else
			matrix=Matrix
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=parent
		
		If _parent 
			_parent._children.Add( Self )
			LocalMatrix=matrix
		Else
			_scene.RootEntities.Add( Self )
			Matrix=matrix
		Endif
		
		UpdateVisibility()
	End
	
	#rem monkeydoc Number of child entities.
	#end
	Property NumChildren:Int()
		
		Return _children.Length
	End
	
	#rem monkeydoc Array of child entities.
	#end
	Property Children:Entity[]()
		
		Return _children.ToArray()
	End

#rem	
	#rem monkeydoc Number of attached components.
	#end
	Property NumComponents:Int()
		
		Return _components.Length
	End
#end
	
	#rem monkeydoc Array of attached components.
	#end
	Property Components:Component[]()
		
		Return _components.ToArray()
	End

	#rem monkeydoc Visibility flag.
	#end
	[jsonify=1]
	Property Visible:Bool()
		
		Return _visible
	
	Setter( visible:Bool )
		
		If visible=_visible Return
		
		_visible=visible
		
		UpdateVisibility()
	End
	
	#rem monkeydoc True if entity and all parents are visible.
	#end
	Property ReallyVisible:Bool()
		
		Return _rvisible
	End

	#rem monkeydoc Last copy.
	#end
	Property LastCopy:Entity()
		
		Return _lastCopy
	End
	
	#rem monkeydoc Master color.
	#end
	[jsonify=1]
	Property Color:Color()
		
		Return _color
		
	Setter( color:Color )
			
		_color=color
	End
	
	#rem monkeydoc Master alpha.
	#end
	[jsonify=1]
	Property Alpha:Float()
		
		Return _alpha
		
	Setter( alpha:Float )
		
		_alpha=alpha
	End
	
	'***** World space properties *****
	
	#rem monkeydoc World space transformation matrix.
	
	The world matrix combines the world position, basis matrix and scale of the entity into a single affine 3x4 matrix.
	
	#end
	Property Matrix:AffineMat4f()
		
		If _dirty & Dirty.W
			_W=_parent ? _parent.Matrix * LocalMatrix Else LocalMatrix
			_dirty&=~Dirty.W
		Endif
		
		Return _W
	
	Setter( matrix:AffineMat4f )
		
		Local scale:=matrix.m.GetScaling()
		
		Basis=matrix.m.Scale( 1/scale.x,1/scale.y,1/scale.z )
		Position=matrix.t
		Scale=scale
	End
	
	#rem monkeydoc Inverse world space transformation matrix.
	#end
	Property InverseMatrix:AffineMat4f()
		
		If _dirty & Dirty.IW
			_IW=-Matrix
			_dirty&=~Dirty.IW
		Endif
		
		Return _IW
	End
	
	#rem monkeydoc World space position.
	#end
	Property Position:Vec3f()
		
		Return Matrix.t
		
	Setter( position:Vec3f )
		
		_t=_parent ? _parent.InverseMatrix * position Else position
		
		Invalidate()
	End
	
	#rem monkeydoc World space basis matrix.

	A basis matrix is a 3x3 matrix representation of an orientation.
	
	A basis matrix is orthogonal (ie: the i,j,k members are perpendicular to each other) and normalized (ie: the i,j,k members all have unit length).
	
	#end
	Property Basis:Mat3f()
		
		Return _parent ? _parent.Basis * _r Else _r
	
	Setter( basis:Mat3f )
		
		_r=_parent ? ~_parent.Basis * basis Else basis
		
		Invalidate()
	End
	
	#rem monkeydoc World space scale.
	#end	
	Property Scale:Vec3f()
		
		Return _parent ? _s * _parent.Scale Else _s
	
	Setter( scale:Vec3f )
		
		_s=_parent ? scale / _parent.Scale Else scale
		
		Invalidate()
	End
	
	'***** Local space properties *****

	#rem monkeydoc Local space transformation matrix.
	
	The local matrix combines the local position, orientation and scale of the entity into a single affine 4x4 matrix.
	
	#end
	[jsonify=1]
	Property LocalMatrix:AffineMat4f()
		
		If _dirty & Dirty.M
			_M=New AffineMat4f( _r.Scale( _s ),_t )
			_dirty&=~Dirty.M
		Endif
		
		Return _M
		
	Setter( matrix:AffineMat4f )
		
		Local scale:=matrix.m.GetScaling()
		
		LocalBasis=matrix.m.Scale( 1/scale.x,1/scale.y,1/scale.z )
		LocalPosition=matrix.t
		LocalScale=scale
		
		Invalidate()
	End

	#rem monkeydoc Local space position.
	#end
	Property LocalPosition:Vec3f()

		Return _t
		
	Setter( position:Vec3f )
		
		_t=position
		
		Invalidate()
	End
	
	#rem monkeydoc Local space basis matrix.
	
	A basis matrix is a 3x3 matrix representation of an orientation.

	A basis matrix is orthogonal (ie: the i,j,k members are perpendicular to each other) and normalized (ie: the i,j,k members all have unit length).
	
	#end
	Property LocalBasis:Mat3f()
		
		Return _r
	
	Setter( basis:Mat3f )
		
		_r=basis
		
		Invalidate()
	End

	#rem monkeydoc Local space scale.
	#end	
	Property LocalScale:Vec3f()
		
		Return _s
	
	Setter( scale:Vec3f )
		
		_s=scale
		
		Invalidate()
	End

	#rem monkeydoc Finds an entity with the given name.
	#end
	Method Find:Entity( name:String )
		
		If _name=name Return Self
		
		For Local child:=Eachin _children
			Local found:=child.Find( name )
			If found Return found
		Next
		
		Return Null
	End
	
	#rem monkeydoc Destroys the entity and all of its children.
	#end
	Method Destroy()
		
		If _state=State.Destroyed Return
		
		If _scene.Updating
			If _state=State.Destroying Return
			_state=State.Destroying
			_scene.UpdateFinished+=Destroy
			Return
		End
		
		_state=State.Destroyed
		
		While Not _children.Empty
			_children.Top.Destroy()
		Wend
		
		While Not _components.Empty
			_components.Top.Destroy()
		Wend

		_visible=False
		
		UpdateVisibility()
		
		If _parent
			_parent._children.Remove( Self )
		Else
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=Null
		_scene=Null
		
		Destroyed()
	End

	#rem monkeydoc Gets the number of components of a given type attached to the entity.
	#end
	Method NumComponents<T>:Int() Where T Extends Component
		
		Local n:=0
		For Local c:=Eachin _components
			If Cast<T>( c ) n+=1
		Next
		
		Return n
	End
	
	#rem monkeydoc Gets a component of a given type attached to the entity.
	
	If there is more than one component of the given type attached, the first is returned.

	#end	
	Method GetComponent<T>:T() Where T Extends Component
		
		For Local c:=Eachin _components
			Local t:=Cast<T>( c )
			If t Return t
		Next
		
		Return Null
	End
	
	Method GetComponents<T>:T[]() Where T Extends Component
		
		Local cs:=New Component[NumComponents<T>()],i:=0
		
		For Local c:=Eachin _components
			Local t:=Cast<T>( c ) 
			If Not t Continue
			cs[i]=t
			i+=1
		Next
		
		Return cs
	End
	
	#rem monkeydoc Attaches a component to the entity.
	#end
	Method AddComponent<T>:T() Where T Extends Component
		
		Local c:=New T( Self )
		
		Return c
	End
	
	Protected

	#rem monkeydoc Copy constructor
	#end
	Method New( entity:Entity,parent:Entity )
		
		Self.New( parent )
		
		_name="Copy of "+entity._name
		_t=entity._t
		_r=entity._r
		_s=entity._s
		
		Invalidate()
	End
	
	Method OnCopy:Entity( parent:Entity ) Virtual
		
		RuntimeError( "Cannot copy Entity" )
		
		Return Null
	End
		
	#rem monkeydoc Invoked when entity transitions from hidden->visible.
	#end
	Method OnShow() Virtual
	End
	
	#rem monkeydoc Invoked when entity transitions from visible->hidden.
	#end
	Method OnHide() Virtual
	End
	
	#rem monkeydoc Helper method for copying an entity.
	
	1) Recursively copies all child entities.
	
	2) Invokes OnCopy for each component attached to this entity.
	
	3) Copies visibility.
	
	4) Invokes Copied signal.
	
	#end
	Method CopyTo( copy:Entity )
		
		_lastCopy=copy
		
		For Local child:=Eachin _children
			child.CopyTo( child.OnCopy( copy ) )
		Next
		
		'should really be different pass...ie: ALL entities should be copied before ANY components?
		For Local c:=Eachin _components
			c.Copy( copy )
		Next
		
		copy.Visible=Visible
		
		copy.Alpha=Alpha
		
		Copied( copy )
	End
	
	Method AddInstance()
		
		If _scene.Editing _scene.Jsonifier.AddInstance( Self,New Variant[]( _parent ) )
	End
	
	Method AddInstance( entity:Entity )
		
		If _scene.Editing _scene.Jsonifier.AddInstance( Self,New Variant[]( entity,_parent ) )
	End
	
	Method AddInstance( args:Variant[] )
		
		If _scene.Editing _scene.Jsonifier.AddInstance( Self,args )
	End
	
	Internal
	
	Method AddComponent( c:Component )
		
		Local type:=c.Type
			
		For Local i:=0 Until _components.Length
			
			If type.Flags & ComponentTypeFlags.Singleton And _components[i].Type=type
				RuntimeError( "Duplicate component" )
			Endif
			
			If type.Priority>_components[i].Type.Priority
				_components.Insert( i,c )
				Return
			Endif
		Next

		_components.Add( c )
	End
	
	Method RemoveComponent( c:Component )
		
		_components.Remove( c )
	End

	Method Start()
		
		For Local c:=Eachin _components
			c.Start()
		Next
		
		For Local e:=Eachin _children
			e.Start()
		End
	End
	
	Method BeginUpdate()

		For Local c:=Eachin _components
			c.BeginUpdate()
		Next

		For Local e:=Eachin _children
			e.BeginUpdate()
		Next
	End
	
	Method Update( elapsed:Float )
		
		For Local c:=Eachin _components
			c.Update( elapsed )
		End
		
		For Local e:=Eachin _children
			e.Update( elapsed )
		Next
	End

	Method EndUpdate()
		
		For Local c:=Eachin _components
			c.EndUpdate()
		Next

		For Local e:=Eachin _children
			e.EndUpdate()
		Next
	End
	
Private

	Enum State
		Active=1
		Destroying=2
		Destroyed=3
	End
	
	Enum Dirty
		M=1
		W=2
		IW=4
		All=7
	End
	
	Field _name:String
	Field _scene:Scene
	Field _parent:Entity
	Field _children:=New Stack<Entity>
	Field _components:=New Stack<Component>
	Field _lastCopy:Entity
	Field _rvisible:Bool
	Field _visible:Bool
	Field _color:Color=std.graphics.Color.White
	Field _alpha:Float=1
	
	Field _t:Vec3f=New Vec3f
	Field _r:Mat3f=New Mat3f
	Field _s:Vec3f=New Vec3f(1)
	
	Field _dirty:Dirty=Dirty.All
	Field _M:AffineMat4f
	Field _W:AffineMat4f
	Field _IW:AffineMat4f
	
	Field _state:State=State.Active
	Field _seq:Int=1
	
	Method InvalidateWorld()
		
		If _dirty & Dirty.W Return
		
		_dirty|=Dirty.W|Dirty.IW
		
		For Local child:=Eachin _children
			
			child.InvalidateWorld()
		Next
		
		_seq+=1
	End
		
	Method Invalidate()
		
		_dirty|=Dirty.M
		
		InvalidateWorld()
	End
	
	Method UpdateVisibility()
		
		Local rvisible:=_visible And (Not _parent Or _parent._rvisible)
		
		If rvisible=_rvisible Return
		
		_rvisible=rvisible
		
		If _rvisible
			
			OnShow()
			
			For Local c:=Eachin _components
				c.Show()
			Next
		
		Else
			
			OnHide()
			
			For Local c:=Eachin _components
				c.Hide()
			Next
		Endif
		
		For Local child:=Eachin _children
			
			child.UpdateVisibility()
		Next
	
	End
End
