
Namespace mojo3d

#rem monkeydoc @hidden
#end
Class SpriteBuffer
	
	Method New()
		
		_vbuffer=New VertexBuffer( Vertex3f.Format,0 )
		
		_ibuffer=New IndexBuffer( IndexFormat.UINT32,0 )
	End
	
	Method InsertRenderOps( rq:RenderQueue,invViewMatrix:AffineMat4f )
		
		Local spriteOps:=rq.SpriteOps
		If spriteOps.Empty Return
		
		Local n:=spriteOps.Length
		
		If n*4>_vbuffer.Length
			Local len:=_vbuffer.Length
			_vbuffer.Resize( Max( _vbuffer.Length*3/2,n*4 ) )
		Endif
		
		If n*6>_ibuffer.Length
			Local i0:=_ibuffer.Length/6
			n=Max(n,i0*3/2)
			_ibuffer.Resize(n*6)
			Local ip:=Cast<UInt Ptr>( _ibuffer.Lock() )+i0*6
			For Local i:=i0 Until n
				ip[0]=i*4
				ip[1]=i*4+1
				ip[2]=i*4+2
				ip[3]=i*4
				ip[4]=i*4+2
				ip[5]=i*4+3
				ip+=6
			Next
			_ibuffer.Invalidate( i0*6,(n-i0)*6 )
			_ibuffer.Unlock()
		Endif
		
		Local vp:=Cast<Vertex3f Ptr>( _vbuffer.Lock() )
		
		Local renderOps:=rq.TransparentOps
		
		_renderOps.Clear()
		
		Local spritei:=0,renderi:=0
	
		_material=spriteOps[0].sprite.Material
		_distance=spriteOps[0].distance
		_i0=0
		_i=0
		
		Local r_bb:=invViewMatrix.m
		
		Local r_up:=r_bb
		r_up.j=New Vec3f(0,1,0)
		r_up.i=r_up.j.Cross(r_up.k).Normalize()
		r_up.k=r_up.i.Cross(r_up.j)
		
		Repeat
			
			'out of sprites?
			If spritei=spriteOps.Length
				
				'flush sprites
				Flush()

				'copy remaining renderops
				For Local i:=renderi Until renderOps.Length
					_renderOps.Add( renderOps[i] )
				Next
				
				'done!
				Exit
			Endif
			
			'more renderops?
			If renderi<renderOps.Length
				
				'sprite closer than next renderop?
				If spriteOps[spritei].distance<renderOps[renderi].distance

					'flush sprites
					Flush()
				
					'add renderop before any more sprites
					_renderOps.Add( renderOps[renderi] )
					renderi+=1
					
					'next!
					Continue
				Endif
			
			Endif

			Local sprite:=spriteOps[spritei].sprite
			
			Local rgba:=(sprite.Color*sprite.Alpha).ToABGR()
			
			Local material:=sprite.Material
			
			If material<>_material
				
				'flush sprites
				Flush()
				
				_material=material
				_distance=spriteOps[spritei].distance
			Endif
	
			'done with spriteOp
			spritei+=1
			
			'construct vertices...
			Local matrix:AffineMat4f
			
			Select sprite.Mode
			Case SpriteMode.Billboard
				matrix.m=r_bb.Scale( sprite.Scale )
				matrix.t=sprite.Position
			Case SpriteMode.Upright
				matrix.m=r_up.Scale( sprite.Scale )
				matrix.t=sprite.Position
			Default	'Fixed
				matrix=sprite.Matrix
			End
			
			Local texrect:=sprite.TextureRect,handle:=sprite.Handle
			
			vp[0].position=matrix * New Vec3f( -handle.x,1-handle.y,0 )
			vp[0].texCoord0=New Vec2f( texrect.min.x,texrect.min.y )
			vp[0].color=rgba
			
			vp[1].position=matrix * New Vec3f( 1-handle.x,1-handle.y,0 )
			vp[1].texCoord0=New Vec2f( texrect.max.x,texrect.min.y )
			vp[1].color=rgba

			vp[2].position=matrix * New Vec3f( 1-handle.x,-handle.y,0 )
			vp[2].texCoord0=New Vec2f( texrect.max.x,texrect.max.y )
			vp[2].color=rgba
			
			vp[3].position=matrix * New Vec3f( -handle.x,-handle.y,0 )
			vp[3].texCoord0=New Vec2f( texrect.min.x,texrect.max.y )
			vp[3].color=rgba
			
			'bump vertex/index
			vp+=4
			_i+=1

		Forever
		
		_vbuffer.Invalidate()
		
		_vbuffer.Unlock()
		
		renderOps.Swap( _renderOps )
		
		_renderOps.Clear()
	End

	Private
	
	Field _vbuffer:VertexBuffer
	Field _ibuffer:IndexBuffer
	Field _renderOps:=New Stack<RenderOp>
	Field _material:Material
	Field _distance:Float
	Field _i0:Int
	Field _i:Int
	
	Method Flush()
		
		If _i=_i0 Return
		
		Local op:=New RenderOp
		op.material=_material
		op.vbuffer=_vbuffer
		op.ibuffer=_ibuffer
		op.order=3
		op.count=(_i-_i0)*2
		op.first=_i0*6
		
		_i0=_i
		
		op.blendMode=_material.BlendMode
		op.distance=_distance
		op.shader=_material.GetRenderShader()
		
		_renderOps.Add( op )
	End
	
End
