
Namespace mojo3d.assimp

Struct aiVector3D Extension
	
	Operator To:Vec3f()
		Return New Vec3f( x,y,z )
	End

End

Struct aiQuaternion Extension
	
	Operator To:Quatf()
		Return New Quatf( x,y,z,-w )
	End

End

Struct aiMatrix4x4 Extension
	
	Operator To:Mat4f()
		Return New Mat4f(
			New Vec4f( a1,b1,c1,d1 ),
			New Vec4f( a2,b2,c2,d2 ),
			New Vec4f( a3,b3,c3,d3 ),
			New Vec4f( a4,b4,c4,d4 ) )
	End
	
	Operator To:AffineMat4f()
	
'		If d1<>0 Or d2<>0 Or d3<>0 Or d4<>1 Print "WARNING! Assimp node matrix is not affine! d1="+d1+", d2="+d2+", d3="+d3+", d4="+d4
			
		Return New AffineMat4f(
			New Vec3f( a1,b1,c1 ),
			New Vec3f( a2,b2,c2 ),
			New Vec3f( a3,b3,c3 ),
			New Vec3f( a4,b4,c4 ) )
	End
	
End

Class AssimpLoader
	
	Method New( scene:aiScene,dir:String )
		_scene=scene
		_dir=dir
	End
	
	Method LoadMesh:Mesh()
		
		Local mesh:=New Mesh
		
		Local materials:=New Stack<Material>
		
		For Local i:=0 Until _scene.mNumMeshes
			
			Local aimesh:=_scene.mMeshes[i]
			
			If i=0 mesh.AddMaterials( 1 )
			
			LoadMesh( aimesh,mesh,Null,False )
		Next
		
		mesh.UpdateTangents()
		
		Return mesh
	End
	
	Method LoadModel:Model()
		
		Local mesh:=New Mesh
		
		Local materials:=New Stack<Material>
		
		For Local i:=0 Until _scene.mNumMeshes
			
			Local aimesh:=_scene.mMeshes[i]
			
			mesh.AddMaterials( 1 )
				
			LoadMesh( aimesh,mesh,Null,False )
			
			materials.Push( LoadMaterial( aimesh,false ) )
		
		Next
		
		Local model:=New Model
		
		If materials.Length
			mesh.UpdateTangents()
			model.Mesh=mesh
			model.Materials=materials.ToArray()
		Endif
		
		Return model
	End
	
	Method LoadBonedModel:Model()
		
		Local model:=New Model

		CreateNodes( _scene.mRootNode,model )
		
		LoadNodes( _scene.mRootNode )
		
		LoadAnimator( model )
		
		Return model
	End

	Method LoadAnimation:Animation()
		
		If Not _scene.mNumAnimations Return Null
		
		_nodes["<null>"]=Null
		_entityIds["<null>"]=_entities.Length
		_entities.Add( Null )
		
		EnumEntityIds( _scene.mRootNode )
		
		Local animation:=LoadAnimation( _scene.mAnimations[0] )
		
		Return animation
	End
	
	Private
	
	Field _scene:aiScene
	Field _dir:String
	
	Field _materials:=New Stack<Material>
	
	Field _nodes:=New StringMap<Entity>
	Field _entityIds:=New StringMap<Int>
	Field _entities:=New Stack<Entity>
	
	Method LoadBones( aimesh:aiMesh,model:Model,vertices:Vertex3f[] )
		
		Local bones:=model.Bones,i0:=bones.Length
	
		bones=bones.Resize( i0+aimesh.mNumBones )
		
		For Local i:=0 Until aimesh.mNumBones
	
			Local aibone:=aimesh.mBones[i]
			
			For Local j:=0 Until aibone.mNumWeights
				
				Local aiweight:=aibone.mWeights[j]
				
				If aiweight.mWeight<.00001 Continue
				
				Local wp:=Cast<Float Ptr>( Varptr vertices[aiweight.mVertexId].weights )
				Local bp:=Cast<UByte Ptr>( Varptr vertices[aiweight.mVertexId].bones )
				
				Local k:=0
				For k=0 Until 4
					If wp[k] Continue
					wp[k]=aiweight.mWeight
					bp[k]=i0+i
					Exit
				Next
				
				If k=4 Print "Too many vertex weights"
			Next
			
			bones[i0+i].entity=_entities[ _entityIds[ aibone.mName.data ] ]
			
			bones[i0+i].offset=Cast<AffineMat4f>( aibone.mOffsetMatrix )
		Next
		
		model.Bones=bones
	End
	
	Method LoadMesh( aimesh:aiMesh,mesh:Mesh,model:Model,boned:bool )
		
		Local vertices:=New Vertex3f[ aimesh.mNumVertices ]
		
		Local vp:=aimesh.mVertices
		Local np:=aimesh.mNormals
		Local cp:=aimesh.mColors[0]
		Local tp0:=aimesh.mTextureCoords[0]
		Local tp1:=aimesh.mTextureCoords[1]
		
		For Local i:=0 Until vertices.Length
			
			vertices[i].position=New Vec3f( vp[i].x,vp[i].y,vp[i].z )
			
			If np
				vertices[i].normal=New Vec3f( np[i].x,np[i].y,np[i].z )
			Endif
			
			If cp
				Local color:=cp[i]
				Local a:=color.a * 255.0
				vertices[i].color=UInt(a) Shl 24 | UInt(color.b*a) Shl 16 | UInt(color.g*a) Shl 8 | UInt(color.r*a)
			Endif

			If tp0 
				vertices[i].texCoord0=New Vec2f( tp0[i].x,tp0[i].y )
			Endif
			
			If tp1 
				vertices[i].texCoord1=New Vec2f( tp1[i].x,tp1[i].y )
			Endif
			
		Next
		
		Local indices:=New UInt[ aimesh.mNumFaces*3 ]
		
		Local fp:=aimesh.mFaces,v0:=mesh.NumVertices
		
		For Local i:=0 Until aimesh.mNumFaces
			If fp[i].mNumIndices<>3
				Print "not a triangle! "+fp[i].mNumIndices
			Endif
			indices[i*3+0]=fp[i].mIndices[0]+v0
			indices[i*3+1]=fp[i].mIndices[1]+v0
			indices[i*3+2]=fp[i].mIndices[2]+v0
		Next
		
		If model And boned And aimesh.mNumBones LoadBones( aimesh,model,vertices )
		
		mesh.AddVertices( vertices )
		
		mesh.AddTriangles( indices,mesh.NumMaterials-1 )
	End
	
	Method LoadMaterial:Material( aimesh:aiMesh,boned:bool )
		
		Local index:=aimesh.mMaterialIndex
		
		If index<_materials.Length And _materials[index] Return _materials[index]

		If index>=_materials.Length _materials.Resize( index+1 )
			
		_materials[index]=LoadMaterial( _scene.mMaterials[index],boned )
		
		Return _materials[index]
	End
	
	Method LoadMaterial:Material( aimaterial:aiMaterial,boned:Bool )
		
		Local ainame:aiString,name:String
		aiGetMaterialString( aimaterial,AI_MATKEY_NAME,0,0,Varptr ainame )
		name=ainame.data

		Local diffuseTexture:Texture=Null
		Local aipath:aiString,path:String
		aiGetMaterialTexture( aimaterial,aiTextureType_DIFFUSE,0,Varptr aipath )
		path=aipath.data
		If path
			path=_dir+StripDir( path )
			diffuseTexture=Texture.Load( path,TextureFlags.FilterMipmap|TextureFlags.WrapST )
		Endif
		
		Local diffuseColor:Color=Color.White
		Local aicolor:aiColor4D
		aiGetMaterialColor( aimaterial,AI_MATKEY_COLOR_DIFFUSE,0,0,Varptr aicolor )
		diffuseColor=New Color( Pow( aicolor.r,2.2 ),Pow( aicolor.g,2.2 ),Pow( aicolor.b,2.2 ),aicolor.a )

		Local material:=New PbrMaterial
		material.Boned=boned
		
		material.Name=name
		
		If diffuseTexture material.ColorTexture=diffuseTexture
		material.ColorFactor=diffuseColor
		
		Return material
	End
	
	Method EnumEntityIds( node:aiNode )
		
		_entityIds[ node.mName.data ]=_entityIds.Count()
	
		For Local i:=0 Until node.mNumChildren
			
			EnumEntityIds( node.mChildren[i] )
		Next
	End
	
	Method CreateNodes( node:aiNode,parent:Model )

		Local model:=New Model( parent )
		model.Name=node.mName.data
		model.LocalMatrix=Cast<AffineMat4f>( node.mTransformation )
		
		_nodes[ model.Name ]=model
		_entityIds[ model.Name ]=_entities.Length
		_entities.Push( model )
		
		For Local i:=0 Until node.mNumChildren
			
			CreateNodes( node.mChildren[i],model )
		Next
	End
	
	Method LoadNodes( node:aiNode )
		
		Local model:=Cast<Model>( _nodes[ node.mName.data ] )
		
		Local mesh:=New Mesh
		
		Local materials:=New Stack<Material>
	
		For Local i:=0 Until node.mNumMeshes
			
			Local aimesh:=_scene.mMeshes[ node.mMeshes[i] ]
			
			mesh.AddMaterials( 1 )
			
			Local boned:=aimesh.mNumBones>0
			
			LoadMesh( aimesh,mesh,model,boned )
			
			materials.Push( LoadMaterial( aimesh,boned ) )
		Next
		
		If materials.Length
			mesh.UpdateTangents()
			model.Mesh=mesh
			model.Materials=materials.ToArray()
		Endif
		
		For Local i:=0 Until node.mNumChildren
			
			LoadNodes( node.mChildren[i] )
		Next
		
	End
	
	Method LoadAnimationChannel:AnimationChannel( aichan:aiNodeAnim )
		
		Local posKeys:=New PositionKey[ aichan.mNumPositionKeys ]
		
		For Local i:=0 Until posKeys.Length
			
			Local aikey:=aichan.mPositionKeys[i]
			
			posKeys[i]=New PositionKey( aikey.mTime,aikey.mValue )
		Next
		
		Local rotKeys:=New RotationKey[ aichan.mNumRotationKeys ]
		
		For Local i:=0 Until rotKeys.Length
			
			Local aikey:=aichan.mRotationKeys[i]
			
			rotKeys[i]=New RotationKey( aikey.mTime,aikey.mValue )
		Next
		
		Local sclKeys:=New ScaleKey[ aichan.mNumScalingKeys ]
		
		For Local i:=0 Until sclKeys.Length
			
			Local aikey:=aichan.mScalingKeys[i]
			
			sclKeys[i]=New ScaleKey( aikey.mTime,aikey.mValue )
		Next
		
		Return New AnimationChannel( posKeys,rotKeys,sclKeys )
	End
	
	Method LoadAnimation:Animation( aianim:aiAnimation )
		
'		Print "_entities.Length="+_entities.Length
'		Print "_entityIds.Count="+_entityIds.Count()
'		Print "mNumChannels="+aianim.mNumChannels

		Local channels:=New AnimationChannel[ _entityIds.Count() ]
		
		For Local i:=0 Until aianim.mNumChannels
			
			Local aichan:=aianim.mChannels[i]
			
			Local id:=_entityIds[ aichan.mNodeName.data ]
			
			Local channel:=LoadAnimationChannel( aichan )
			
			channels[id]=channel
			
'			Print "channel "+id+", numposkeys="+channel.PositionKeys.Length+", numrotkeys="+channel.RotationKeys.Length+", numsclkeys="+channel.ScaleKeys.Length
		Next
		
'		Print "duration="+aianim.mDuration+", mTicksPerSecond="+aianim.mTicksPerSecond
		
		Local animation:=New Animation( aianim.mName.data,channels,aianim.mDuration,aianim.mTicksPerSecond,AnimationMode.Looping )
		
		Return animation
	End
	
	Method LoadAnimator:Animator( entity:Entity )
		
'		Print "mNumAnimations="+_scene.mNumAnimations
		
		If Not _scene.mNumAnimations Return Null
		
		Local animations:=New Animation[_scene.mNumAnimations]
		
		For Local i:=0 Until _scene.mNumAnimations
			
			animations[i]=LoadAnimation( _scene.mAnimations[i] )
		Next
		
		Local animator:=New Animator( entity )
		
		animator.Skeleton=_entities.ToArray()
		
		animator.Animations.AddAll( animations )
		
		Return animator
	End

End

Public

#rem monkeydoc @hidden
#End
Class AssimpMojo3dLoader Extends Mojo3dLoader

	Const Instance:=New AssimpMojo3dLoader
	
	Method LoadMesh:Mesh( path:String ) Override

		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
		'flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_FindDegenerates | aiProcess_SortByPType
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_SortByPType
		flags|=aiProcess_GenSmoothNormals |aiProcess_FixInfacingNormals | aiProcess_Triangulate
		flags|=aiProcess_PreTransformVertices
		flags|=aiProcess_FindInvalidData
		flags|=aiProcess_OptimizeMeshes
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null
		
		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		
		Local mesh:=loader.LoadMesh()
		
		Return mesh
	End
	
	Method LoadModel:Model( path:String ) Override
	
		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
		
'		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_FindDegenerates | aiProcess_SortByPType
'		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_SortByPType
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
		
'		flags|=aiProcess_GenSmoothNormals | aiProcess_FixInfacingNormals | aiProcess_Triangulate

		flags|=aiProcess_GenSmoothNormals | aiProcess_Triangulate
		flags|=aiProcess_PreTransformVertices
		flags|=aiProcess_FindInvalidData
		flags|=aiProcess_OptimizeMeshes
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null
		
		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		
		Local model:=loader.LoadModel()
		
		Return model
	End
	
	Method LoadBonedModel:Model( path:String ) Override
	
		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
'		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_FindDegenerates | aiProcess_SortByPType
'		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_SortByPType
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
		
		
'		flags|=aiProcess_GenSmoothNormals | aiProcess_FixInfacingNormals | aiProcess_Triangulate
		flags|=aiProcess_GenSmoothNormals |aiProcess_Triangulate
'		flags|=aiProcess_SplitByBoneCount

'		flags|=aiProcess_LimitBoneWeights
'		flags|=aiProcess_FindInvalidData
'		flags|=aiProcess_OptimizeMeshes

'		flags|=aiProcess_OptimizeGraph	'fails quite spectacularly!
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null
		
		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		
		Local model:=loader.LoadBonedModel()
		
		Return model
	End
	
	Method LoadAnimation:Animation( path:String ) Override

		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
		'flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_FindDegenerates | aiProcess_SortByPType
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_RemoveRedundantMaterials | aiProcess_SortByPType
		
'		flags|=aiProcess_GenSmoothNormals | aiProcess_FixInfacingNormals | aiProcess_Triangulate

		flags|=aiProcess_GenSmoothNormals |aiProcess_Triangulate

'		flags|=aiProcess_SplitByBoneCount

		flags|=aiProcess_LimitBoneWeights
		flags|=aiProcess_FindInvalidData
		flags|=aiProcess_OptimizeMeshes
'		flags|=aiProcess_OptimizeGraph	'fails quite spectacularly!
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null

		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		
		Local animation:=loader.LoadAnimation()
		
		Return animation
	End
		
	Private

	Function LoadScene:aiScene( path:String,flags:UInt )
		
		Local props:=aiCreatePropertyStore()
		
		aiSetImportPropertyInteger( props,AI_CONFIG_PP_SBP_REMOVE,aiPrimitiveType_POINT | aiPrimitiveType_LINE )
		
		aiSetImportPropertyInteger( props,AI_CONFIG_PP_FD_REMOVE,1 )
		
		aiSetImportPropertyInteger( props,AI_CONFIG_PP_SBBC_MAX_BONES,64 )
			
		path=RealPath( path )
		
		Local scene:=aiImportFileExWithProperties( path,flags,Null,props )
		
		aiReleasePropertyStore( props )
		
		If Not scene 
			Print "aiImportFile failed: path="+path
			Print "error="+aiGetErrorString()
			Return Null
		Endif
		
		Return scene
	End
	
End
