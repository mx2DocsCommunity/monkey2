
Namespace mojo3d

Class ParticleSystem Extends Renderable

	#rem monkeydoc Creates a new particle system.
	#end
	Method New( particleCount:Int=15000,parent:Entity=Null )
		Super.New( parent )
		
		_pbuffer=New ParticleBuffer( particleCount )
		
		_material=New ParticleMaterial
	End

	Method New( particleBuffer:ParticleBuffer,material:ParticleMaterial,parent:Entity=Null )
		Super.New( parent )
		
		_pbuffer=particleBuffer
		
		_material=material
	End

	#rem monkeydoc Copies the particle system.
	#end	
	Method Copy:ParticleSystem( parent:Entity=Null ) Override
		
		Local copy:=New ParticleSystem( Self,parent )
		
		CopyComplete( copy )
		
		Return copy
	End
	
	Property ParticleBuffer:ParticleBuffer()
	
		Return _pbuffer
		
	Setter( pbuffer:ParticleBuffer )
	
		_pbuffer=pbuffer
	End

	#rem monkeydoc Material used to render the particle system.
	
	This must currently be an instance of a SpriteMaterial.
	
	#end	
	Property Material:ParticleMaterial()
		
		Return _material
	
	Setter( material:ParticleMaterial )
	
		_material=material
	End
	
	Protected

	#rem monkeydoc @hidden
	#End		
	Method New( psystem:ParticleSystem,parent:Entity )
		Super.New( psystem,parent )
		
		_pbuffer=psystem._pbuffer
		
		_material=psystem._material
	End
	
	Internal
	
	Method OnRender( rq:RenderQueue ) override
	
		_pbuffer.OnRender( rq,_material,Self )
	End

	Private
	
	Field _pbuffer:ParticleBuffer
	
	Field _material:ParticleMaterial
	
End
