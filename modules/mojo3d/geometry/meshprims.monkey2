
Namespace mojo3d

Private

Struct TerrainData
	
	Field heightMap:Pixmap
	Field bounds:Boxf
	Field width:Int
	Field depth:Int
	Field iscale:Float
	Field jscale:Float
	
	Method GetPosition:Vec3f( i:Int,j:Int )
	
		Local x:=i*iscale
		Local z:=j*jscale
	
		Local y:=heightMap.PixelPtr( i,j )[0]/255.0
			
		Return New Vec3f( x,y,z ) * bounds.Size + bounds.min
	End

	Method GetTexCoord0:Vec2f( i:Int,j:Int )
	
		Return New Vec2f( i*iscale,j*jscale )
	End
		
	Method GetNormal:Vec3f( i:Int,j:Int )
	
		Local v0:=GetPosition( i,j )
		Local v1:=GetPosition( i,Min( j+1,depth-1 ) )
		Local v2:=GetPosition( Min( i+1,width-1 ),j )
		Local v3:=GetPosition( i,Max( j-1,0 ) )
		Local v4:=GetPosition( Max( i-1,0 ),j )
				
		Local n0:=(v1-v0).Cross(v2-v0).Normalize()
		Local n1:=(v2-v0).Cross(v3-v0).Normalize()
		Local n2:=(v3-v0).Cross(v4-v0).Normalize()
		Local n3:=(v4-v0).Cross(v1-v0).Normalize()
			
		Local n:=(n0+n1+n2+n3).Normalize()
			
	'		If (i&15)=0 And (j&15)=0 print "n="+v
			
	'		DebugAssert( n.y>0 )
		
		Return n
	End
End

Public

#rem monkeydoc Extension methods for creating meshes.
#end
Class Mesh Extension
	
	Function CreateRect:Mesh( rect:Rectf )

		Local data:=New Mesh( 
			New Vertex3f[](
				New Vertex3f( rect.min.x,rect.max.y,0 ),
				New Vertex3f( rect.max.x,rect.max.y,0 ),
				New Vertex3f( rect.max.x,rect.min.y,0 ),
				New Vertex3f( rect.min.x,rect.min.y,0 ) ),
			New UInt[](
				0,1,2,
				0,2,3 ) )
		
		data.UpdateTangents()
		
		Return data
	End

	Function CreateBox:Mesh( box:Boxf,xsegs:Int=1,ysegs:Int=1,zsegs:Int=1 )
		
		Local vertices:=New Vertex3f[ ((ysegs+1)*(xsegs+1) + (zsegs+1)*(xsegs+1) + (ysegs+1)*(zsegs+1))*2 ],vp:=vertices.Data
		
		For Local q:=-1 To 1 Step 2
			For Local y:=0 To ysegs
				For Local x:=0 To xsegs
					Local vx:=box.Width*x/xsegs+box.min.x
					Local vy:=box.Height*y/ysegs+box.min.y
					vp[0]=New Vertex3f( vx,vy,q>0 ? box.max.z Else box.min.z, Float(x)/xsegs,Float(y)/ysegs, 0,0,q )
					vp+=1
				Next
			Next
			For Local z:=0 To zsegs
				For Local x:=0 To xsegs
					Local vx:=box.Width*x/xsegs+box.min.x
					Local vz:=box.Depth*z/zsegs+box.min.z
					vp[0]=New Vertex3f( vx,q>0 ? box.max.y Else box.min.y,vz, Float(x)/xsegs,Float(z)/zsegs, 0,q,0 )
					vp+=1
				Next
			Next
			For Local y:=0 To ysegs
				For Local z:=0 To zsegs
					Local vy:=box.Height*y/ysegs+box.min.y
					Local vz:=box.Depth*z/zsegs+box.min.z
					vp[0]=New Vertex3f( q>0 ? box.max.x Else box.min.x,vy,vz, Float(z)/zsegs,Float(y)/ysegs, q,0,0 )
					vp+=1
				Next
			Next
		Next
		
		Local indices:=New UInt[ (ysegs*xsegs + zsegs*xsegs + ysegs*zsegs) * 12 ],ip:=indices.Data,v0:=0
		
		For Local i:=0 To 1
			For Local y:=0 Until ysegs
				For Local x:=0 Until xsegs
					ip[0]=v0 ; ip[1+i]=v0+xsegs+2 ; ip[2-i]=v0+1
					ip[3]=v0 ; ip[4+i]=v0+xsegs+1 ; ip[5-i]=v0+xsegs+2
					ip+=6
					v0+=1
				Next
				v0+=1
			Next
			v0+=xsegs+1
			For Local z:=0 Until zsegs
				For Local x:=0 Until xsegs
					ip[0]=v0 ; ip[1+i]=v0+1 ; ip[2-i]=v0+xsegs+2
					ip[3]=v0 ; ip[4+i]=v0+xsegs+2 ; ip[5-i]=v0+xsegs+1
					ip+=6
					v0+=1
				Next
				v0+=1
			Next
			v0+=xsegs+1
			For Local y:=0 Until ysegs
				For Local z:=0 Until zsegs
					ip[0]=v0 ; ip[1+i]=v0+1 ; ip[2-i]=v0+zsegs+2
					ip[3]=v0 ; ip[4+i]=v0+zsegs+2 ; ip[5-i]=v0+zsegs+1
					ip+=6
					v0+=1
				Next
				v0+=1
			Next
			v0+=zsegs+1
		Next
		
		Local data:=New Mesh( vertices,indices )
		
		data.UpdateTangents()
		
		Return data
	End

	Function CreateSphere:Mesh( radius:float,hsegs:Int=24,vsegs:Int=12 )
	
		Local vertices:=New Stack<Vertex3f>
	
		For Local i:=0 Until hsegs
			vertices.Push( New Vertex3f( 0,radius,0, (i+.5)/hsegs,0 ) )
		Next
		
		For Local i:=1 Until vsegs
			Local pitch:=i*Pi/vsegs-Pi/2
			For Local j:=0 To hsegs
				Local yaw:=(j Mod hsegs)*TwoPi/hsegs
				Local p:=Mat3f.Rotation( pitch,yaw,0 ).k * radius
				vertices.Push( New Vertex3f( p.x,p.y,p.z, Float(j)/hsegs,Float(i)/vsegs ) )
			Next
		Next
		
		For Local i:=0 Until hsegs
			vertices.Push( New Vertex3f( 0,-radius,0, (i+.5)/hsegs,1 ) )
		Next
		
		Local indices:=New Stack<UInt>
		
		For Local i:=0 Until hsegs
			indices.AddAll( New UInt[]( i,i+hsegs+1,i+hsegs ) )
		Next
		
		For Local i:=1 Until vsegs-1
			For Local j:=0 Until hsegs
				Local v0:=i*(hsegs+1)+j-1
				indices.AddAll( New UInt[]( v0,v0+1,v0+hsegs+2 ) )
				indices.AddAll( New UInt[]( v0,v0+hsegs+2,v0+hsegs+1 ) )
			Next
		Next
		
		For Local i:=0 Until hsegs
			Local v0:=(hsegs+1)*(vsegs-1)+i-1
			indices.AddAll( New UInt[]( v0,v0+1,v0+hsegs+1 ) )
		Next
		
		Local vdata:=vertices.Data
		For Local i:=0 Until vertices.Length
			vdata[i].normal=vdata[i].position.Normalize()
		Next
		
		Local data:=New Mesh( vertices.ToArray(),indices.ToArray() )
		
		data.UpdateTangents()
		
		Return data
	End
	
	Function CreateTorus:Mesh( outerRadius:Float,innerRadius:Float,outerSegs:Int=24,innerSegs:Int=12 )
		
		Local vertices:=New Vertex3f[ (outerSegs+1)*(innerSegs+1) ],vp:=vertices.Data
		
		For Local outer:=0 To outerSegs
			
			Local sweep:=Mat3f.Yaw( outer*TwoPi/outerSegs )
			
			For Local inner:=0 To innerSegs
				
				Local an:=inner*TwoPi/innerSegs
				
				Local cos:=Cos( an ),sin:=Sin( an )
				
				Local p:=sweep * New Vec3f( cos * innerRadius + outerRadius,sin * innerRadius,0 )
				Local t:=New Vec2f( Float(inner)/innerSegs,Float(outer)/outerSegs )
				Local n:=sweep * New Vec3f( cos,sin,0 )
				
				Local v:=New Vertex3f( p,t,n )
				
				vp[0]=v
				vp+=1
			Next
		
		Next
		
		Local indices:=New UInt[ outerSegs*innerSegs*6 ],ip:=indices.Data
		
		For Local outer:=0 Until outerSegs
			
			Local v0:=outer * (innerSegs+1)
			
			For Local inner:=0 Until innerSegs
				
				ip[0]=v0+innerSegs+1
				ip[2]=v0+innerSegs+2
				ip[1]=v0+1
				
				ip[3]=v0+innerSegs+1
				ip[5]=v0+1
				ip[4]=v0
				
				ip+=6
				v0+=1
			
			Next
		Next
		
		Local data:=New Mesh( vertices,indices )
		
		data.UpdateTangents()
		
		Return data
	End
	
	Function CreateCylinder:Mesh( radius:Float,length:Float,axis:Axis,segs:Int )
		
		Local hlength:=length/2
		
		Local vertices:=New Stack<Vertex3f>
		Local triangles:=New Stack<UInt>
		
		'tube
		For Local i:=0 To segs
			Local yaw:=(i Mod segs) * TwoPi / segs
			Local v:=New Vec3f( Cos( yaw ) * radius,hlength,Sin( yaw )* radius )
			Local n:=New Vec3f( v.x,0,v.z ).Normalize()
			Local tc:=New Vec2f( Float(i)/segs,0 )
			vertices.Add( New Vertex3f( v,tc,n ) )
			v.y=-v.y
			tc.y=1
			vertices.Add( New Vertex3f( v,tc,n ) )
		Next
		For Local i:=0 Until segs
			triangles.Add( i*2 ) ; triangles.Add( i*2+2 ) ; triangles.Add( i*2+3 )
			triangles.Add( i*2 ) ; triangles.Add( i*2+3 ) ; triangles.Add( i*2+1 )
		Next
		
		'caps
		Local v0:=vertices.Length
		For Local i:=0 Until segs
			Local yaw:=i * TwoPi / segs
			Local v:=New Vec3f( Cos( yaw ) * radius,hlength,Sin( yaw ) * radius )
			Local n:=New Vec3f( 0,1,0 )
			Local tc:=New Vec2f( v.x*.5+.5,v.z*.5+.5 )
			vertices.Add( New Vertex3f( v,tc,n ) )
			v.y=-v.y
			n.y=-n.y
			vertices.Add( New Vertex3f( v,tc,n ) )
		Next
		For Local i:=1 Until segs-1
			triangles.Add( v0 ) ; triangles.Add( v0+(i+1)*2 ) ; triangles.Add( v0+i*2 )
			triangles.Add( v0+1 ) ; triangles.Add( v0+i*2+1 ) ; triangles.Add( v0+(i+1)*2+1 )
		Next
		
		Local mesh:=New Mesh( vertices.ToArray(),triangles.ToArray() )
		
		Select axis
		Case Axis.X
			mesh.TransformVertices( New AffineMat4f( 0,1,0, 1,0,0, 0,0,1, 0,0,0 ) )
		Case Axis.Z
			mesh.TransformVertices( New AffineMat4f( 1,0,0, 0,0,1, 0,-1,0, 0,0,0 ) )
		End
		
		mesh.UpdateTangents()
		
		Return mesh
	End
	
	Function CreateCapsule:Mesh( radius:Float,length:Float,axis:Axis,segs:Int )
		
		Const HalfPi:=Pi/2
		
		Local vertices:=New Stack<Vertex3f>
		Local triangles:=New Stack<UInt>
		
		Local t0:=HalfPi/radius/(length+HalfPi/radius)
		
		Local hlength:=length/2
		
		'Top hemisphere
		'
		For Local i:=0 Until segs
			vertices.Add( New Vertex3f( 0,hlength+radius,0, (i+.5)/segs,0, 0,1,0 ) )
		Next
		For Local j:=1 To segs
			Local pitch:=j*Pi/(segs*2)-HalfPi
			For Local i:=0 To segs
				Local yaw:=(i Mod segs) * TwoPi / segs
				Local n:=Mat3f.Rotation( pitch,yaw,0 ).k
				Local v:=n*radius
				v.y+=hlength
				vertices.Add( New Vertex3f( v.x,v.y,v.z, Float(i)/Float(segs),Float(j)/Float(segs)*2*t0, n.x,n.y,n.z ) )
			Next
		Next
		For Local i:=0 Until segs
			triangles.Add( i ) ; triangles.Add( i+segs+1 ) ; triangles.Add( i+segs )
		Next
		For Local j:=1 Until segs
			For Local i:=0 Until segs
				Local t:=j*(segs+1)+i-1
				triangles.Add( t ) ; triangles.Add( t+1 ) ; triangles.Add( t+segs+2 )
				triangles.Add( t ) ; triangles.Add( t+segs+2 ) ; triangles.Add( t+segs+1 )
			Next
		Next

		Local v0:=vertices.Length
		
		For Local j:=segs Until segs*2
			Local pitch:=j*Pi/(segs*2)-HalfPi
			For Local i:=0 To segs
				Local yaw:=(i Mod segs) * TwoPi / segs
				Local n:=Mat3f.Rotation( pitch,yaw,0 ).k
				Local v:=n*radius
				v.y-=hlength
				vertices.Add( New Vertex3f( v.x,v.y,v.z, Float(i)/Float(segs),(Float(j)/Float(segs*2)-.5)*2*t0, n.x,n.y,n.z ) )
			Next
		Next
		For Local i:=0 Until segs
			vertices.Add( New Vertex3f( 0,-hlength-radius,0, (i+.5)/segs,1, 0,-1,0 ) )
		Next

		For Local j:=0 Until segs-1
			For Local i:=0 Until segs
				Local t:=j*(segs+1)+i+v0
				triangles.Add( t ) ; triangles.Add( t+1 ) ; triangles.Add( t+segs+2 )
				triangles.Add( t ) ; triangles.Add( t+segs+2 ) ; triangles.Add( t+segs+1 )
			Next
		Next
		
		For Local i:=0 Until segs
			Local t:=(segs+1)*(segs-1)+i+v0
			triangles.Add( t ) ; triangles.Add( t+1 ) ; triangles.Add( t+segs+1 )
		Next
		
		' Join 2 bits together...
		'
		For Local i:=0 Until segs
			Local t:=segs*(segs+1)-1+i
			triangles.Add( t ) ; triangles.Add( t+1 ) ; triangles.Add( t+segs+2 )
			triangles.Add( t ) ; triangles.Add( t+segs+2 ) ; triangles.Add( t+segs+1 )
		Next
		
		Local mesh:=New Mesh( vertices.ToArray(),triangles.ToArray() )
		
		Select axis
		Case Axis.X
			mesh.TransformVertices( New AffineMat4f( 0,1,0, 1,0,0, 0,0,1, 0,0,0 ) )
		Case Axis.Z
			mesh.TransformVertices( New AffineMat4f( 1,0,0, 0,0,1, 0,-1,0, 0,0,0 ) )
		End
		
		mesh.UpdateTangents()
		
		Return mesh
	End
	
	Function CreateCone:Mesh( radius:Float,length:Float,axis:Axis,segs:Int )
		
		Local hlength:=length/2
		
		Local vertices:=New Stack<Vertex3f>
		Local triangles:=New Stack<UInt>
		
		For Local i:=0 Until segs
			vertices.Add( New Vertex3f( 0,hlength,0, (i+.5)/segs,0, 0,1,0 ) )
		Next
		For Local i:=0 To segs
			Local yaw:=(i Mod segs) * TwoPi/segs
			Local n:=New Vec3f( Cos( yaw ),0,Sin( yaw ) )
			Local v:=New Vec3f( n.x*radius,-hlength,n.z*radius )
			Local tc:=New Vec2f( Float(i)/segs,1 )
			vertices.Add( new Vertex3f( v,tc,n ) )
		Next
		For Local i:=0 Until segs
			triangles.Add( i ) ; triangles.Add( i+segs+1 ) ; triangles.Add( i+segs )
		Next
		
		'cap
		Local v0:=vertices.Length
		For Local i:=0 Until segs
			Local yaw:=i * TwoPi / segs
			Local n:=New Vec3f( Cos( yaw ),0,Sin( yaw ) )
			Local v:=New Vec3f( n.x*radius,-hlength,n.z*radius )
			Local tc:=New Vec2f( n.x*.5+.5,n.z*.5+.5 )
			vertices.Add( new Vertex3f( v,tc,n ) )
		Next
		For Local i:=1 Until segs-1
			triangles.Add( v0 ) ; triangles.Add( v0+i ) ; triangles.Add( v0+i+1 )
		Next
		
		Local mesh:=New Mesh( vertices.ToArray(),triangles.ToArray() )
		
		Select axis
		Case Axis.X
			mesh.TransformVertices( New AffineMat4f( 0,1,0, 1,0,0, 0,0,1, 0,0,0 ) )
		Case Axis.Z
			mesh.TransformVertices( New AffineMat4f( 1,0,0, 0,0,1, 0,-1,0, 0,0,0 ) )
		End
		
		mesh.UpdateTangents()
		
		Return mesh
	End
	
	Function CreateTerrain:Mesh( heightMap:Pixmap,bounds:Boxf )

		Local width:=heightMap.Width
		Local depth:=heightMap.Height
		
		Local data:TerrainData
		data.heightMap=heightMap
		data.bounds=bounds
		data.width=width
		data.depth=depth
		data.iscale=1.0/(width-1)
		data.jscale=1.0/(depth-1)
		
		Local vertices:=New Vertex3f[ width*depth ]
		
		For Local j:=0 Until depth
			Local vp:=vertices.Data+j*width
			For Local i:=0 Until width
				vp[i].position=data.GetPosition( i,j )
				vp[i].texCoord0=data.GetTexCoord0( i,j )
				vp[i].normal=data.GetNormal( i,j )
			Next
		Next
		
		Local indices:=New UInt[ (width-1)*(depth-1)*6 ]
		
		local ip:=indices.Data
		
		For Local j:=0 Until depth-1
			Local v0:=j*width
			For Local i:=0 Until width-1
				ip[0]=v0+i ; ip[1]=v0+i+1+width ; ip[2]=v0+i+1
				ip[3]=v0+i ; ip[4]=v0+i+width ; ip[5]=v0+i+1+width
				ip+=6
			Next
		Next
		
		Local mesh:=New Mesh( vertices,indices )
		
		mesh.UpdateTangents()
		
		Return mesh
	End
	
End

#rem monkeydoc Extension methods for creating models.
#end
Class Model Extension
	
	Function CreateBox:Model( box:Boxf,xsegs:Int,ysegs:Int,zsegs:Int,material:Material,parent:Entity=Null )
		
		Local mesh:=mojo3d.Mesh.CreateBox( box,xsegs,ysegs,zsegs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateSphere:Model( radius:Float,hsegs:Int,vsegs:Int,material:Material,parent:Entity=Null )
		
		Local mesh:=mojo3d.Mesh.CreateSphere( radius,hsegs,vsegs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateTorus:Model( outerRadius:Float,innerRadius:Float,outerSegs:Int,innerSegs:Int,material:Material,parent:Entity=Null )
		
		Local mesh:=mojo3d.Mesh.CreateTorus( outerRadius,innerRadius,outerSegs,innerSegs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateCylinder:Model( radius:Float,length:Float,axis:Axis,segs:Int,material:Material,parent:Entity=null )
		
		Local mesh:=mojo3d.Mesh.CreateCylinder( radius,length,axis,segs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateCapsule:Model( radius:Float,length:Float,axis:Axis,segs:Int,material:Material,parent:Entity=null )
		
		Local mesh:=mojo3d.Mesh.CreateCapsule( radius,length,axis,segs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateCone:Model( radius:Float,length:Float,axis:Axis,segs:Int,material:Material,parent:Entity=null )
		
		Local mesh:=mojo3d.Mesh.CreateCone( radius,length,axis,segs )
		
		Return New Model( mesh,material,parent )
	End
	
	Function CreateTerrain:Model( heightMap:Pixmap,bounds:Boxf,material:Material,parent:Entity=Null )
		
		Local mesh:=mojo3d.Mesh.CreateTerrain( heightMap,bounds )
		
		Return New Model( mesh,material,parent )
	End
	
End
