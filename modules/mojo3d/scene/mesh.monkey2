
Namespace mojo3d

#rem monkeydoc The Mesh class.
#end
Class Mesh Extends Resource
	
	#rem monkeydoc Creates a new mesh.
	
	Creates a new empty mesh.
	
	Meshes don't actual contain instances of materials. Instead, mesh triangles are added to 'logical' materials which are effectively just integer indices.
	
	Actual materials are stored in models, and can be accessed via the [[Model.Materials]] property.
	
	#end
	Method New()
		_dirty=Null
		_bounds=Boxf.EmptyBounds
		_vertices=New Stack<Vertex3f>
		_materials=New Stack<MaterialID>
	End
	
	Method New( vertices:Vertex3f[],indices:UInt[] )
		Self.New()
		AddVertices( vertices )
		AddTriangles( indices )
	End
		
	#rem monkeydoc Number of vertices.
	#end
	Property NumVertices:Int()
		
		Return _vertices.Length
	End
	
	#rem monkeydoc Total number of indices.
	#end
	Property NumIndices:int()
		
		Local n:=0
	
		For Local material:=Eachin _materials
			n+=material.indices.Length
		Next
		
		Return n
	End
		
	#rem monkeydoc Number of materials.
	
	This will always be at least one.
	
	#end
	Property NumMaterials:Int()
		
		Return _materials.Length
	End

	#rem monkeydoc Mesh bounding box.
	#end
	Property Bounds:Boxf()
		
		If _dirty & Dirty.Bounds
			
			_bounds=Boxf.EmptyBounds
			
			For Local i:=0 Until _vertices.Length
				_bounds|=_vertices[i].position
			Next
			
			_dirty&=~Dirty.Bounds
		Endif
		
		Return _bounds
	End
	
	#rem monkeydoc Compacts the mesh.
	
	Compacts all internal data used by the mesh so they occupy as little memory as possible.
	
	#end
	Method Compact()
		
		_vertices.Compact()
		_materials.Compact()
		
		For Local material:=Eachin _materials
			material.indices.Compact()
		Next
	End
	
	#rem monkeydoc Clears the mesh.
	
	Removes all vertices and primitives from the mesh, and resets the number of logical materials to '1'.
	
	#end
	Method Clear()
		
		_dirty=Null
		_bounds=Boxf.EmptyBounds
		_vertices.Clear()
		_materials.Clear()
		
		InvalidateVertices()
	End
	
	#rem monkeydoc Clear the mesh vertices.
	#end
	Method ClearVertices()
		
		ResizeVertices( 0 )
	End
	
	Method ResizeVertices( length:Int )
		
		_vertices.Resize( length )

		InvalidateVertices()
	End

	#rem monkeydoc Sets a range of vertices.
	#end
	Method SetVertices( vertices:Vertex3f Ptr,first:Int,count:Int )
		
		DebugAssert( first>=0 And count>=0 And first<=_vertices.Length And first+count<=_vertices.Length,"Invalid vertex range" )
		
		libc.memcpy( _vertices.Data.Data+first,vertices,count*Vertex3f.Pitch )

		InvalidateVertices( first,count )
	End
	
	Method SetVertices( vertices:Vertex3f[] )
		
		_vertices.Resize( vertices.Length )
		
		SetVertices( vertices.Data,0,vertices.Length )
	End
	
	#rem monkeydoc Sets a single vertex.
	#end
	Method SetVertex( index:Int,vertex:Vertex3f )
		
		DebugAssert( index>=0 And index<_vertices.Length,"Vertex index out of range" )
		
		_vertices[index]=vertex
		
		InvalidateVertices( index,1 )
	End
	
	#rem monkeydoc Adds vertices.
	#end
	Method AddVertices( vertices:Vertex3f Ptr,count:Int )
		
		Local first:=_vertices.Length
		
		_vertices.Resize( first+count )
		
		libc.memcpy( _vertices.Data.Data+first,vertices,count*Vertex3f.Pitch )
		
		InvalidateVertices( first,count )
	End

	Method AddVertices( vertices:Vertex3f[] )
	
		AddVertices( vertices.Data,vertices.Length )
	End
	
	#rem monkeydoc Adds a single vertex.
	#end
	Method AddVertex( vertex:Vertex3f )
		
		AddVertices( Varptr vertex,1 )
	End
	
	#rem monkeydoc Gets all vertices as an array.
	#end	
	Method GetVertices:Vertex3f[]()
		
		Return _vertices.ToArray()
	End
	
	#rem monkeydoc Gets a single vertex.
	#end
	Method GetVertex:Vertex3f( index:Int )
		
		DebugAssert( index>=0 And index<_vertices.Length,"Vertex index out of range" )
		
		Return _vertices[index]
	End		
	
	#rem monkeydoc Sets tthe triangles for a material in the mesh.
	
	`materialid` must be a valid material id in the range 0 to [[NumMaterials]] inclusive.
	
	#end
	Method SetTriangles( indices:UInt Ptr,first:Int,count:Int,materialid:Int=0 )
		
		DebugAssert( first Mod 3=0,"First must be a multiple of 3" )

		DebugAssert( count Mod 3=0,"Count must be a multiple of 3" )
		
		Local mindices:=GetMaterial( materialid ).indices

		DebugAssert( first>=0 And count>=0 And first<=mindices.Length And first+count<=mindices.Length,"Invalid range" )
		
		libc.memcpy( mindices.Data.Data+first,indices,count*IndexPitch )
	End
	
	Method SetTriangles( indices:UInt[],materialid:Int=0 )
		
		SetTriangles( indices.Data,indices.Length,materialid )
	End
	
	Method SetTriangle( index:Int,i0:Int,i1:Int,i2:Int,materialid:Int=0 )
		
		DebugAssert( index Mod 3=0,"Index must be a multiple of 3" )
		
		Local mindices:=GetMaterial( materialid ).indices
		
		DebugAssert( index>=0 And index+3<=mindices.Length,"Triangle index out of range" )
		
		mindices[index]=i0;mindices[index+1]=i1;mindices[index+2]=i2
	End
	
	#rem monkeydoc Adds triangles to the mesh.

	`count` is the number of indices to add and must be a multiple of 3.
	
	`materialid` must be a valid material id in the range 0 to [[NumMaterials]] inclusive.
	
	If `materialid` is equal to NumMaterials, a new material is automatically added first.
	
	#end
	Method AddTriangles( indices:UInt Ptr,count:Int,materialid:Int=0 )
		
		DebugAssert( count Mod 3=0,"Count must be a multiple of 3" )
		
		Local mindices:=GetMaterial( materialid ).indices
		
		Local first:=mindices.Length
		
		mindices.Resize( mindices.Length+count )
		
		libc.memcpy( mindices.Data.Data+first,indices,count*IndexPitch )
	End
	
	Method AddTriangles( indices:UInt[],materialid:Int=0 )
		
		AddTriangles( indices.Data,indices.Length,materialid )
	End

	#rem monkeydoc Adds a single triangle the mesh.
	#end	
	Method AddTriangle( i0:UInt,i1:UInt,i2:UInt,materialid:Int=0 )
		
		Local indices:=GetMaterial( materialid ).indices
		
		indices.Add( i0 )
		indices.Add( i1 )
		indices.Add( i2 )
	End
	
	#rem monkeydoc Get indices for a material id.
	#end
	Method GetIndices:UInt[]( materialid:Int=0 )
		
		DebugAssert( materialid>=0 And materialid<_materials.Length,"Material id out of range" )
		
		Return _materials[materialid].indices.ToArray()
	End
	
	Method GetAllIndices:Uint[]()
		
		Local indices:=New Uint[NumIndices],ip:=indices.Data
		
		For Local material:=Eachin _materials
			Local mindices:=material.indices
			libc.memcpy( ip,mindices.Data.Data,mindices.Length*IndexPitch )
			ip+=mindices.Length
		Next
		
		Return indices
	End

	#rem monkeydoc Adds materials to the mesh.
	
	Adds `count` logical materials to the mesh.
	
	Returns the first material id of the newly added materials.
	
	#end
	Method AddMaterials:Int( count:Int )
		
		Local first:=_materials.Length
		
		For Local i:=0 Until count
			_materials.Push( New MaterialID )
		Next
		
		Return first
	End
	
	#rem monkeydoc Adds a mesh to this mesh.
	#end
	Method AddMesh( mesh:Mesh,materialid:Int=0 )
		
		Local v0:=_vertices.Length
		
		AddVertices( mesh._vertices.Data.Data,mesh._vertices.Length )
		
		For Local material:=Eachin mesh._materials
			
			Local count:=material.indices.Length
			
			Local mindices:=material.indices.Data
			
			If v0
				Local indices:=New UInt[count]
				For Local i:=0 Until count
					indices[i]=mindices[i]+v0
				Next
				mindices=indices
			Endif
			
			AddTriangles( mindices.Data,count,materialid )
			
			materialid+=1
		Next
	
	End
	
	#rem monkeydoc Transforms all vertices in the mesh.
	#end
	Method TransformVertices( matrix:AffineMat4f )
		
		Local vertices:=_vertices.Data
		
		Local cofactor:=matrix.m.Cofactor()
		
		For Local i:=0 Until _vertices.Length
		
			vertices[i].position=matrix * vertices[i].position
			
			vertices[i].normal=(cofactor * vertices[i].normal).Normalize()
			
			vertices[i].tangent.XYZ=(cofactor * vertices[i].tangent.XYZ).Normalize()
		Next
		
		InvalidateVertices()
	End
	
	#rem monkeydoc Fits all vertices in the mesh to a box.
	#end
	Method FitVertices( box:Boxf,uniform:Bool=True )

		Local bounds:=Bounds
		
		Local scale:=box.Size/bounds.Size
		
		If uniform scale=New Vec3f( Min( scale.x,Min( scale.y,scale.z ) ) )
			
		Local m:=Mat3f.Scaling( scale )
		
		Local t:=box.Center - m * bounds.Center
		
		TransformVertices( New AffineMat4f( m,t ) )			
	End
	
	#rem monkeydoc Updates mesh normals.
	
	Recalculates all vertex normals based on triangle and vertex positions.
	
	#end
	Method UpdateNormals()

		Local vertices:=_vertices.Data
		
		For Local i:=0 Until _vertices.Length
			
			vertices[i].normal=New Vec3f(0)
		Next
		
		For Local material:=Eachin _materials
			
			Local indices:=material.indices.Data
		
			For Local i:=0 Until material.indices.Length Step 3
				
				Local i1:=indices[i+0]
				Local i2:=indices[i+1]
				Local i3:=indices[i+2]
				
				Local v1:=vertices[i1].position
				Local v2:=vertices[i2].position
				Local v3:=vertices[i3].position
				
				Local n:=(v2-v1).Cross(v3-v1).Normalize()
				
				vertices[i1].normal+=n
				vertices[i2].normal+=n
				vertices[i3].normal+=n
			
			Next
		
		Next
		
		For Local i:=0 Until _vertices.Length
			
			vertices[i].normal=vertices[i].normal.Normalize()
		Next

		InvalidateVertices()
	End

	#rem monkeydoc Updates mesh tangents.
	
	Recalculates all vertex tangents based on triangles, vertex normals and vertex texcoord0.
	
	#end
	Method UpdateTangents()
		
		Local vertices:=_vertices.Data.Data
		
		Local tan1:=New Vec3f[_vertices.Length]
		Local tan2:=New Vec3f[_vertices.Length]
		
		For Local material:=Eachin _materials
			
			Local indices:=material.indices.Data
		
			For Local i:=0 Until material.indices.Length Step 3
				
				Local i1:=indices[i+0]
				Local i2:=indices[i+1]
				Local i3:=indices[i+2]
				
				Local v1:=vertices+i1
				Local v2:=vertices+i2
				Local v3:=vertices+i3
				
				Local x1:=v2->Tx-v1->Tx
				Local x2:=v3->Tx-v1->Tx
				Local y1:=v2->Ty-v1->Ty
				Local y2:=v3->Ty-v1->Ty
				Local z1:=v2->Tz-v1->Tz
				Local z2:=v3->Tz-v1->Tz
				
				Local s1:=v2->Sx-v1->Sx
				Local s2:=v3->Sx-v1->Sx
				Local t1:=v2->Sy-v1->Sy
				Local t2:=v3->Sy-v1->Sy
				
				Local r:=1.0/(s1*t2-s2*t1)
				
				Local sdir:=New Vec3f( (t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r )
				Local tdir:=New Vec3f( (s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r )
				
				tan1[i1]+=sdir
				tan1[i2]+=sdir
				tan1[i3]+=sdir
		
				tan2[i1]+=tdir
				tan2[i2]+=tdir
				tan2[i3]+=tdir
			Next
			
		Next
	
		For Local i:=0 Until _vertices.Length
			
			Local v:=vertices+i
	
			Local n:=v->normal,t:=tan1[i]
			
			v->tangent.XYZ=( t - n * n.Dot( t ) ).Normalize()
			
			v->tangent.w=n.Cross( t ).Dot( tan2[i] ) < 0 ? -1 Else 1
		Next
		
		InvalidateVertices()
	End
	
	#rem monkeydoc Flips all triangles.
	#end
	Method FlipTriangles()
		
		For Local material:=Eachin _materials
			
			Local indices:=material.indices.Data
		
			For Local i:=0 Until material.indices.Length Step 3
				Local t:=indices[i]
				indices[i]=indices[i+1]
				indices[i+1]=t
			Next
			
			material.dirty|=Dirty.IndexBuffer
		Next
		
	End
	
	#rem monkeydoc Scales texture coordinates.
	#end
	Method ScaleTexCoords( scale:Vec2f )
		
		Local vertices:=_vertices.Data
		
		For Local i:=0 Until _vertices.Length
		
			vertices[i].texCoord0*=scale
		Next
		
		InvalidateVertices()
	End

	#rem monkeydoc Loads a mesh from a file.
	
	On its own, mojo3d can only load gltf2 format mesh and model files.
	
	To add more formats, #import the mojo3d-assimp module into your app, eg:
	
	```
	#Import "<mojo3d>"
	#Import "<mojo3d-assimp>"
	```
	
	This will allow you to load any format supported by the assimp module.
	
	However, importing the assimp module into your app will also increase its size.
	
	#end
	Function Load:Mesh( path:String )
	
		For Local loader:=Eachin Mojo3dLoader.Instances
		
			Local mesh:=loader.LoadMesh( path )
			If mesh Return mesh
		
		Next
		
		Return Null
	End
	
	Internal
	
	Method GetVertexBuffer:VertexBuffer()
		
		If _dirty & Dirty.VertexBuffer
			
			_vbuffer=New VertexBuffer( Vertex3f.Format,_vertices.Length )
			
			_vbuffer.SetVertices( _vertices.Data.Data,0,_vertices.Length )
			
			_dirty&=~Dirty.VertexBuffer
		End
		
		Return _vbuffer
	End
	
	Method GetIndexBuffer:IndexBuffer( materialid:Int )
		
		Local material:=_materials[materialid]
		
		If material.dirty & Dirty.IndexBuffer
			
			Local indices:=material.indices
			
			material.ibuffer=New IndexBuffer( IndexFormat.UINT32,indices.Length )
			
			material.ibuffer.SetIndices( indices.Data.Data,0,indices.Length )
			
			material.dirty&=~Dirty.IndexBuffer
		End
		
		Return material.ibuffer
	End
	
	Private
	
	Enum Dirty
		Bounds=1
		VertexBuffer=2
		IndexBuffer=4
	End
	
	class MaterialID
		Field indices:=New Stack<UInt>
		Field dirty:Dirty=Dirty.IndexBuffer
		Field ibuffer:IndexBuffer
	End
	
	Const IndexPitch:=4
	
	Field _vertices:=New Stack<Vertex3f>
	Field _materials:=New Stack<MaterialID>
	
	Field _dirty:Dirty=Null
	Field _bounds:Boxf=Boxf.EmptyBounds
	Field _vbuffer:VertexBuffer
	Field _minDirty:Int
	Field _maxDirty:Int
	
	Method InvalidateVertices( first:Int,count:Int )
		
		_minDirty=Min( _minDirty,first )
		_maxDirty=Max( _maxDirty,first+count )
		
		_dirty|=Dirty.Bounds|Dirty.VertexBuffer
	End
	
	Method InvalidateVertices()
		
		InvalidateVertices( 0,_vertices.Length )
	End
	
	Method GetMaterial:MaterialID( materialid:Int,dirty:Dirty=Dirty.IndexBuffer )
		
		DebugAssert( materialid>=0 And materialid<=_materials.Length,"Materialid out of range" )
		
		If materialid=_materials.Length AddMaterials( 1 )
			
		Local material:=_materials[materialid]
		
		material.dirty|=dirty

		Return material
	End
	
End
