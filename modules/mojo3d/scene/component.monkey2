
Namespace mojo3d

Enum ComponentTypeFlags
	
	Singleton=1
End

Class ComponentType
	
	Method New( name:String,priority:int,flags:ComponentTypeFlags )
		
		_name=name
		
		_priority=priority
		
		_flags=flags
	End
	
	Property Name:String()
		
		Return _name
	End
	
	Property Priority:Int()
		
		Return _priority
	End
	
	Property Flags:ComponentTypeFlags()
		
		Return _flags
	End
	
	Private
	
	Field _name:String
	
	Field _priority:Int
	
	Field _flags:ComponentTypeFlags
End

Class Component Abstract
	
	Method New( entity:Entity,type:ComponentType )
		
		_entity=entity
		
		_type=type
		
		_entity.AddComponent( Self )
	End
	
	Property Entity:Entity()
		
		Return _entity
	End
	
	Property Type:ComponentType()
		
		Return _type
	End
	
	#rem monkeydoc Destroys the entity immediately or when update finishes.
	
	If scene is currently being updated, the component will not be destroyed until update finishes.
		
	#end
	Method Destroy()
		
		If _state=State.Destroyed Return
		
		If _entity.Scene.Updating
			If _state=State.Destroying Return
			_state=State.Destroying
			_entity.Scene.UpdateFinished+=Destroy
			Return
		End
		
		_state=State.Destroyed
		
		OnDestroy()
		
		_entity.RemoveComponent( Self )
		
		_entity=Null
		
		_type=Null
	End
	
	Protected
	
	Method AddInstance()
		
		Local scene:=_entity.Scene
		
		If scene.Editing scene.Jsonifier.AddInstance( Self,New Variant[]( _entity ) )
	End
	
	Method AddInstance( component:Component )
		
		Local scene:=_entity.Scene

		If scene.Editing scene.Jsonifier.AddInstance( Self,New Variant[]( _entity,component ) )
	End
	
	Method OnCopy:Component( entity:Entity ) Virtual

		RuntimeError( "Don't know how to copy component of type "+Type.Name )
		
		Return Null
	End
	
	Method OnStart() Virtual
	End
	
	Method OnShow() virtual
	End
	
	Method OnHide() Virtual
	End
	
	Method OnBeginUpdate() Virtual
	End
	
	Method OnUpdate( elapsed:Float ) Virtual
	End
	
	Method OnEndUpdate() Virtual
	End
	
	Method OnDestroy() Virtual
	End
	
	Internal
	
	Method Copy:Component( entity:Entity )
		Return OnCopy( entity )
	End
	
	Method Start()
		If _state<>State.Initial Return
		_state=State.Started
		OnStart()
	End
	
	Method Show()
		Start()
		If _state<>State.Started Return
		OnShow()
	End
	
	Method Hide()
		If _state<>State.Started Return
		OnHide()
	End
	
	Method BeginUpdate()
		Start()
		If _state<>State.Started Return
		OnBeginUpdate()
	End
	
	Method Update( elapsed:Float )
		If _state<>State.Started Return
		OnUpdate( elapsed )
	End
	
	Method EndUpdate()
		If _state<>State.Started Return
		OnEndUpdate()
	End
	
	Private
	
	Enum State
		Initial=0
		Started=1
		Destroyed=2
		Destroying=3
	End
	
	Field _entity:Entity
	Field _type:ComponentType
	Field _state:State=State.Initial
End



