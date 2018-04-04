
Namespace mojo3d

#rem monkeydoc @hidden
#end
Function UpdateTangents( vertices:Vertex3f Ptr,vcount:Int,indices:UInt Ptr,icount:Int )
	
	Local tan1:=New Vec3f[vcount]
	Local tan2:=New Vec3f[vcount]

	For Local i:=0 Until icount Step 3

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

	For Local i:=0 Until vcount
	
		Local v:=vertices+i
	
		Local n:=v->normal,t:=tan1[i]
	
		v->tangent.XYZ=( t - n * n.Dot( t ) ).Normalize()
	
		v->tangent.w=n.Cross( t ).Dot( tan2[i] ) < 0 ? -1 Else 1
	Next

End
	
