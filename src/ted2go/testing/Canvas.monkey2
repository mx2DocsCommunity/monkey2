
Namespace mojo.graphics

#rem monkeydoc @hidden
#end	
Class DrawOp
	Field blendMode:BlendMode
	Field material:Material
	Field order:Int
	Field count:Int
End

#rem monkeydoc The Canvas class.

Canvas objects are used to perform rendering to either a mojo [[app.View]] or an 'off screen' [[mojo.graphics.Image]].

To draw to a canvas, use one of the 'Draw' methods. Drawing is affected by a number of draw states, including:

* [[Color]] - the current drawing color. This is combined with the current alpha to produce the final rendering color and alpha values.
* [[Alpha]] - the current drawing alpha level.
* [[Matrix]] - the current drawing matrix. All drawing coordinates are multiplied by this matrix before rendering.
* [[BlendMode]] - the blending mode for drawing, eg: opaque, alpha, additive, multiply.
* [[Viewport]] - the current viewport. All drawing coordinates are relative to the top-left of the viewport.
* [[Scissor]] - the current scissor rect. All rendering is clipped to the union of the viewport and the scissor rect.
* [[Font]] - The current font to use when drawing text with [[DrawText]].

Drawing does not occur immediately. Drawing commands are 'buffered' to reduce the overhead of sending lots of draw calls to the lower level graphics API. You can force all drawing commands in the buffer to actually render using [[Flush]].


#end
Class Canvas

	#rem monkeydoc Creates a new canvas.

	@param image Canvas render target image.

	#end
	Method New( image:Image )
	
		Init( image.Texture,image.Texture.Rect.Size,image.Rect )
		
		BeginRender( New Recti( 0,0,image.Rect.Size ),New AffineMat3f )
	End
	
	#rem monkeydoc @hidden
	#End
	Method New( texture:Texture )
	
		Init( texture,texture.Rect.Size,texture.Rect )
		
		BeginRender( texture.Rect,New AffineMat3f )
	End

	#rem monkeydoc @hidden
	#end
	Method New( width:Int,height:Int )
	
		Init( Null,New Vec2i( width,height ),New Recti( 0,0,width,height ) )
	End

	#rem monkeydoc The current viewport.
	
	The viewport describes the rect within the render target that rendering occurs in.
	
	All rendering is relative to the top-left of the viewport, and is clipped to the intersection of the current viewport and scissor rects.
		
	#end
	Property Viewport:Recti()
	
		Return _viewport
		
	Setter( viewport:Recti )
	
		Flush()
		
		_viewport=viewport
		
		_dirty|=Dirty.EnvParams|Dirty.Scissor
	End

	#rem monkeydoc The current scissor rect.
	
	The scissor rect is rect within the viewport that can be used for additional clipping.
	
	Scissor rect coorindates are relative to the current viewport viewport.
	
	#end
	Property Scissor:Recti()
	
		Return _scissor
	
	Setter( scissor:Recti )
	
		Flush()
		
		_scissor=scissor
		
		_dirty|=Dirty.Scissor
	End
	
	#rem monkeydoc @hidden
	#end	
	Property ViewMatrix:Mat4f()
	
		Return _viewMatrix
	
	Setter( viewMatrix:Mat4f )
	
		Flush()
	
		_viewMatrix=viewMatrix
		
		_dirty|=Dirty.EnvParams
	End
	
	#rem monkeydoc @hidden
	#end	
	Property ModelMatrix:Mat4f()
	
		Return _modelMatrix
	
	Setter( modelMatrix:Mat4f )
	
		Flush()
	
		_modelMatrix=modelMatrix
		
		_dirty|=Dirty.EnvParams
	End
	
	#rem monkeydoc @hidden
	#end	
	Property AmbientLight:Color()
	
		Return _ambientLight

	Setter( ambientLight:Color )
	
		Flush()
	
		_ambientLight=ambientLight
		
		_dirty|=Dirty.EnvParams
	End
	
	#rem monkeydoc @hidden
	#end	
	Property RenderColor:Color()
	
		Return _renderColor
	
	Setter( renderColor:Color )

		Flush()
			
		_renderColor=renderColor
		
		_dirty|=Dirty.EnvParams
	End
	
	#rem monkeydoc Texture filtering control.
	
	Set this to false to render cool 'pixel art' style graphics.
	
	#end
	Property TextureFilteringEnabled:Bool()
	
		Return _filter
	
	Setter( enabled:Bool )
	
		Flush()
		
		_filter=enabled
	End
	
	#rem monkeydoc @hidden
	#end	
	Method Resize( size:Vec2i )
	
		Flush()
		
		_targetSize=size
		_targetRect=New Recti( 0,0,size )
		
		_dirty|=Dirty.Target
	End
	
	#rem monkeydoc Clears the viewport.
	
	Clears the viewport to `color`.

	@param color Color to clear the viewport to.
	
	#end
	Method Clear( color:Color )

		Flush()
		
		Validate()
		
		_device.Clear( color )
	End
	
	#rem monkeydoc Copies a pixmap from the rendertarget.

	@param rect The rect to copy.

	#end
	Method CopyPixmap:Pixmap( rect:Recti )
	
		Flush()
		
		Validate()
		
		rect=TransformRecti( rect,_renderMatrix )
			
		rect=(rect & _renderBounds)+_targetRect.Origin
		
		Local pixmap:=_device.CopyPixmap( rect )
		
		Return pixmap
	End
	
	#rem monkeydoc @hidden
	#end	
	Method BeginRender( bounds:Recti,matrix:AffineMat3f )
	
		Flush()
		
		_device.ShaderEnv=_ambientEnv
		
		_renderMatrixStack.Push( _renderMatrix )
		_renderBoundsStack.Push( _renderBounds )
		
		_renderMatrix*=matrix
		_renderBounds&=TransformRecti( bounds,_renderMatrix )

		_dirty|=Dirty.EnvParams|Dirty.Scissor
		
		Viewport=bounds
		Scissor=New Recti( 0,0,bounds.Size )
		PointSize=1
		LineWidth=1
		BlendMode=BlendMode.Alpha
		TextureFilteringEnabled=True
		ClearMatrix()
	End
	
	#rem monkeydoc @hidden
	#end	
	Method EndRender()
	
		Flush()
		
		_renderBounds=_renderBoundsStack.Pop()
		_renderMatrix=_renderMatrixStack.Pop()
	End
	
		
	#rem monkeydoc Flushes drawing commands.
	
	Flushes any outstanding drawing commands in the draw buffer.
	
	#end
	Method Flush()
	
		Validate()
		
		RenderDrawOps()
		
		ClearDrawOps()
	End
	
	'***** DrawList *****

	#rem monkeydoc The current font for use with DrawText.
	
	Set font to null to use the default mojo font.
	
	#end	
	Property Font:Font()
	
		Return _font
	
	Setter( font:Font )
	
		If Not font font=_defaultFont
	
		_font=font
	End

	#rem monkeydoc The current drawing alpha level.
	
	Note that [[Alpha]] and the alpha component of [[Color]] are multiplied together to produce the final alpha value for rendering. This allows you to use [[Alpha]] as a 'master' alpha level.

	#end	
	Property Alpha:Float()
	
		Return _alpha
		
	Setter( alpha:Float )
	
		_alpha=alpha
		
		Local a:=_color.a * _alpha * 255.0
		_pmcolor=UInt(a) Shl 24 | UInt(_color.b*a) Shl 16 | UInt(_color.g*a) Shl 8 | UInt(_color.r*a)
	End
	
	#rem monkeydoc The current drawing color.
	
	Note that [[Alpha]] and the alpha component of [[Color]] are multiplied together to produce the final alpha value for rendering. This allows you to use [[Alpha]] as a 'master' alpha level.

	#end
	Property Color:Color()
	
		Return _color
	
	Setter( color:Color )
	
		_color=color
		
		Local a:=_color.a * _alpha * 255.0
		_pmcolor=UInt(a) Shl 24 | UInt(_color.b*a) Shl 16 | UInt(_color.g*a) Shl 8 | UInt(_color.r*a)
	End
	
	#rem monkeydoc The current drawing matrix.
	
	All coordinates passed to draw methods are multiplied by this matrix for rendering.
	
	#end
	Property Matrix:AffineMat3f()
	
		Return _matrix
	
	Setter( matrix:AffineMat3f )
	
		_matrix=matrix
	End

	#rem monkeydoc The current blend mode.

	#end	
	Property BlendMode:BlendMode()
	
		Return _blendMode
	
	Setter( blendMode:BlendMode )
	
		_blendMode=blendMode
	End
	
	#rem monkeydoc The current point size for use with DrawPoint.
	#end
	Property PointSize:Float()
	
		Return _pointSize
	
	Setter( pointSize:Float )
	
		_pointSize=pointSize
	End

	#rem monkeydoc The current line width for use with DrawLine.
	
	#end	
	Property LineWidth:Float()

		Return _lineWidth
	
	Setter( lineWidth:Float )
	
		_lineWidth=lineWidth
	End

	#rem monkeydoc @hidden The materials used to render primitives.
	#end	
	Property PrimitiveMaterials:Material[]()
	
		Return _materials
	End
	
	#rem monkeydoc Pushes the drawing matrix onto the internal matrix stack.
	
	#end
	Method PushMatrix()
	
		_matrixStack.Push( Matrix )
	End
	
	#rem monkeydoc Pops the drawing matrix off the internal matrix stack.
	
	#end
	Method PopMatrix()
	
		Matrix=_matrixStack.Pop()
	End
	
	
	#rem monkeydoc Clears the internal matrix stack and sets matrix to the identitity matrix.
	
	#end
	Method ClearMatrix()
	
		_matrixStack.Clear()
		
		Matrix=New AffineMat3f
	End
	
	#rem monkeydoc Translates the drawing matrix.
	
	Translates the drawing matrix. This has the effect of translating all drawing coordinates by `tx` and `ty`.
	
	#end
	Method Translate( tx:Float,ty:Float )
	
		Matrix=Matrix.Translate( tx,ty )
	End
	
	#rem monkeydoc Rotates the drawing matrix.
	
	Rotates the drawing matrix. This has the effect of rotating all drawing coordinates by the angle `rz'.
	
	@param rz Rotation angle in radians.
	
	#end
	Method Rotate( rz:Float )
	
		Matrix=Matrix.Rotate( rz )
	End
	
	#rem monkeydoc Scales the drawing matrix.
	
	Scales the drawing matrix. This has the effect of scaling all drawing coordinates by `sx` and `sy`.
	
	@param sx X scale factor.
	
	@param sy Y scale factor.
	
	#end
	Method Scale( sx:Float,sy:Float )
	
		Matrix=Matrix.Scale( sx,sy )
	End
	
	#rem monkeydoc Draws a point.
	
	Draws a point in the current [[Color]] using the current [[BlendMode]].
	
	The point coordinates are also transform by the current [[Matrix]].
	
	The 
	
	@param v Point coordinates.
	
	@param x Point x coordinate.
	
	@param y Point y coordinate.
	
	#end
	Method DrawPoint( x:Float,y:Float )
		If _pointSize<=1
			AddDrawOp( _materials[1],1,1 )
			AddVertex( x+.5,y+.5,0,0 )
			Return
		Endif
		
		Local d:=_pointSize/2
		AddDrawOp( _materials[1],4,1 )
		AddVertex( x-d,y-d,0,0 )
		AddVertex( x+d,y-d,1,0 )
		AddVertex( x+d,y+d,1,1 )
		AddVertex( x-d,y+d,0,1 )
		
	End

	Method DrawPoint( v:Vec2f )
		AddDrawOp( _materials[1],1,1 )
		AddVertex( v.x+.5,v.y+.5,0,0 )
	End
	
	#rem monkeydoc Draws a line.

	Draws a line in the current [[Color]] using the current [[BlendMode]].
	
	The line end coordinates are transform by the current [[Matrix]] and clipped to the current [[Viewport]] and [[Scissor]].
	
	@param v0 First endpoint of the line.
	
	@param v1 Second endpoint of the line.
	
	@param x0 X coordinate of first endpoint of the line.
	
	@param y0 Y coordinate of first endpoint of the line.
	
	@param x1 X coordinate of first endpoint of the line.
	
	@param y1 Y coordinate of first endpoint of the line.
	
	#end
	Method DrawLine( x0:Float,y0:Float,x1:Float,y1:Float )

		If _lineWidth<=1
			AddDrawOp( _materials[2],2,1 )
			AddVertex( x0+.5,y0+.5,0,0 )
			AddVertex( x1+.5,y1+.5,1,1 )
			Return
		Endif
		
		Local dx:=y0-y1,dy:=x1-x0
		Local sc:=0.5/Sqrt( dx*dx+dy*dy )*_lineWidth
		dx*=sc;dy*=sc
		
		If _blendMode=BlendMode.Opaque
			AddDrawOp( _materials[2],4,1 )
			AddVertex( x0-dx,y0-dy,0,0 )
			AddVertex( x0+dx,y0+dy,0,0 )
			AddVertex( x1+dx,y1+dy,0,0 )
			AddVertex( x1-dx,y1-dy,0,0 )
			Return
		End
		
		Local pmcolor:=_pmcolor
		
		AddDrawOp( _materials[2],4,2 )

		AddVertex( x0,y0,0,0 )
		AddVertex( x1,y1,0,0 )
		_pmcolor=0
		AddVertex( x1-dx,y1-dy,0,0 )
		AddVertex( x0-dx,y0-dy,0,0 )

		AddVertex( x0+dx,y0+dy,0,0 )
		AddVertex( x1+dx,y1+dy,0,0 )
		_pmcolor=pmcolor
		AddVertex( x1,y1,0,0 )
		AddVertex( x0,y0,0,0 )
		
	End
	
	Method DrawLine( v0:Vec2f,v1:Vec2f )
		DrawLine( v0.x,v0.y,v1.x,v1.y )
	End
	
	#rem monkeydoc Draws a triangle.

	Draws a triangle in the current [[Color]] using the current [[BlendMode]].
	
	The triangle vertex coordinates are also transform by the current [[Matrix]].

	#End
	Method DrawTriangle( v0:Vec2f,v1:Vec2f,v2:Vec2f )
		AddDrawOp( _materials[3],3,1 )
		AddVertex( v0.x,v0.y,.5,0 )
		AddVertex( v1.x,v1.y,1,1 )
		AddVertex( v2.x,v2.y,0,1 )
	End
	
	Method DrawTriangle( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float )
		AddDrawOp( _materials[3],3,1 )
		AddVertex( x0,y0,0,0 )
		AddVertex( x1,y1,1,0 )
		AddVertex( x2,y2,1,1 )
	End
	
	#rem monkeydoc Draws a quad.

	Draws a quad in the current [[Color]] using the current [[BlendMode]].
	
	The quad vertex coordinates are also transform by the current [[Matrix]].

	#end
	Method DrawQuad( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float,x3:Float,y3:Float )
		AddDrawOp( _materials[4],4,1 )
		AddVertex( x0,y0,0,0 )
		AddVertex( x1,y1,1,0 )
		AddVertex( x2,y2,1,1 )
		AddVertex( x3,y3,0,1 )
	End
	
	#rem monkeydoc Draws a rectangle.

	Draws a rectangle in the current [[Color]] using the current [[BlendMode]].
	
	The rectangle vertex coordinates are also transform by the current [[Matrix]].

	#end
	Method DrawRect( rect:Rectf )
		AddDrawOp( _materials[4],4,1 )
		AddVertex( rect.min.x,rect.min.y,0,0 )
		AddVertex( rect.max.x,rect.min.y,1,0 )
		AddVertex( rect.max.x,rect.max.y,1,1 )
		AddVertex( rect.min.x,rect.max.y,0,1 )
	End

	Method DrawRect( x:Float,y:Float,width:Float,height:Float )
		DrawRect( New Rectf( x,y,x+width,y+height ) )
	End
	
	Method DrawRect( rect:Rectf,srcImage:Image )
		Local tc:=srcImage.TexCoords
		AddDrawOp( srcImage.Material,4,1 )
		AddVertex( rect.min.x,rect.min.y,tc.min.x,tc.min.y )
		AddVertex( rect.max.x,rect.min.y,tc.max.x,tc.min.y )
		AddVertex( rect.max.x,rect.max.y,tc.max.x,tc.max.y )
		AddVertex( rect.min.x,rect.max.y,tc.min.x,tc.max.y )
	End
	
	Method DrawRect( x:Float,y:Float,width:Float,height:Float,srcImage:Image )
		DrawRect( New Rectf( x,y,x+width,y+height ),srcImage )
	End
	
	Method DrawRect( rect:Rectf,srcImage:Image,srcRect:Recti )
		Local s0:=Float(srcImage.Rect.min.x+srcRect.min.x)/srcImage.Texture.Width
		Local t0:=Float(srcImage.Rect.min.y+srcRect.min.y)/srcImage.Texture.Height
		Local s1:=Float(srcImage.Rect.min.x+srcRect.max.x)/srcImage.Texture.Width
		Local t1:=Float(srcImage.Rect.min.y+srcRect.max.y)/srcImage.Texture.Height
		AddDrawOp( srcImage.Material,4,1 )
		AddVertex( rect.min.x,rect.min.y,s0,t0 )
		AddVertex( rect.max.x,rect.min.y,s1,t0 )
		AddVertex( rect.max.x,rect.max.y,s1,t1 )
		AddVertex( rect.min.x,rect.max.y,s0,t1 )
	End
	
	Method DrawRect( x:Float,y:Float,width:Float,height:Float,srcImage:Image,srcX:Int,srcY:Int )

		DrawRect( New Rectf( x,y,x+width,y+height ),srcImage,New Recti( srcX,srcY,srcX+width,srcY+height ) )
	End
	
	Method DrawRect( x:Float,y:Float,width:Float,height:Float,srcImage:Image,srcX:Int,srcY:Int,srcWidth:Int,srcHeight:Int )

		DrawRect( New Rectf( x,y,x+width,y+height ),srcImage,New Recti( srcX,srcY,srcX+srcWidth,srcY+srcHeight ) )
	End
	
	#rem monkeydoc Draws an oval.

	Draws an oval in the current [[Color]] using the current [[BlendMode]].
	
	The oval vertex coordinates are also transform by the current [[Matrix]].

	@param x Top left x coordinate for the oval.

	@param y Top left y coordinate for the oval.

	@param width Width of the oval.

	@param height Height of the oval.

	#end
	Method DrawOval( x:Float,y:Float,width:Float,height:Float )
		Local xr:=width/2.0,yr:=height/2.0
		
		Local dx_x:=xr*_matrix.i.x
		Local dx_y:=xr*_matrix.i.y
		Local dy_x:=yr*_matrix.j.x
		Local dy_y:=yr*_matrix.j.y
		Local dx:=Sqrt( dx_x*dx_x+dx_y*dx_y )
		Local dy:=Sqrt( dy_x*dy_x+dy_y*dy_y )

		Local n:=Max( Int( dx+dy ),12 ) & ~3
		
		Local x0:=x+xr,y0:=y+yr
		
		AddDrawOp( _materials[5],n,1 )
		
		For Local i:=0 Until n
			Local th:=i*Pi*2/n
			Local px:=x0+Cos( th ) * xr
			Local py:=y0+Sin( th ) * yr
			AddVertex( px,py,0,0 )
		Next
	End
	
	#rem monkeydoc Draws an ellipse.

	Draws an ellipse in the current [[Color]] using the current [[BlendMode]].
	
	The ellipse is also transformed by the current [[Matrix]].

	@param x Center x coordinate for the ellipse.

	@param y Center y coordinate for the ellipse.

	@param xRadius X axis radius for the ellipse.

	@param yRadius Y axis radius for the ellipse.

	#end
	Method DrawEllipse( x:Float,y:Float,xRadius:Float,yRadius:Float )
		DrawOval( x-xRadius,y-yRadius,xRadius*2,yRadius*2 )
	End
	
	#rem monkeydoc Draws a circle.

	Draws a circle in the current [[Color]] using the current [[BlendMode]] and transformed by the current [[Matrix]].

	@param x Center x coordinate for the circle.

	@param y Center y coordinate for the circle.

	@param radius The circle radius.

	#end
	Method DrawCircle( x:Float,y:Float,radius:Float )
		DrawOval( x-radius,y-radius,radius*2,radius*2 )
	End
	
	#rem monkeydoc Draws a polygon.

	Draws a polygon using the current [[Color]], [[BlendMode]] and [[Matrix]].

	@param vertices Array of x/y vertex coordinate pairs.

	#end
	Method DrawPoly( vertices:Float[] )
		DebugAssert( vertices.Length>=6 And vertices.Length&1=0 )
		
		Local n:=vertices.Length/2
		
		AddDrawOp( _materials[5],n,1 )
		
		For Local i:=0 Until n*2 Step 2
			AddVertex( vertices[i],vertices[i+1],0,0 )
		Next
	End
	
	#rem monkeydoc Draws a sequence of primtives.

	Draws a sequence of convex primtives using the current [[Color]], [[BlendMode]] and [[Matrix]].
	
	@param order The type of primitive: 1=points, 2=lines, 3=triangles, 4=quads, >4=n-gons.
	
	@param count The number of primitives to draw.
	
	@param vertices Pointer to the first vertex x,y pair.
	
	@param verticesPitch Number of bytes from one vertex x,y pair to the next - set to 8 for 'tightly packed' vertices.
	
	@param texCoords Pointer to the first texCoord s,t pair. This can be null.
	
	@param texCoordsPitch Number of bytes from one texCoord s,y to the next.
	
	@param indices Pointer to sequence of integer indices for indexed drawing. This can by null for non-indexed drawing.
	
	#end
	Method DrawPrimitives( order:Int,count:Int,vertices:Float Ptr,verticesPitch:Int,texCoords:Float Ptr,texCoordsPitch:Int,indices:Int Ptr )
		DebugAssert( order>0,"Illegal primtive type" )
			
		If Not texCoords
			Global _texCoords:=New Stack<Float>
			If _texCoords.Length<>order*2
				_texCoords.Resize( order*2 )
				For Local i:=0 Until order*2 Step 2
					_texCoords[i]=0
					_texCoords[i=1]=0
				Next
			Endif
			texCoords=_texCoords.Data.Data
			texCoordsPitch=8
		Endif
		
		AddDrawOp( _materials[ Min( order,5 ) ],order,count )
		
		If indices
		
			For Local i:=0 Until count
				For Local j:=0 Until order
					Local k:=indices[j]
					Local vp:=Cast<Float Ptr>( Cast<UByte Ptr>( vertices )+k*verticesPitch )
					Local tp:=Cast<Float Ptr>( Cast<UByte Ptr>( texCoords )+k*texCoordsPitch )
					AddVertex( vp[0],vp[1],tp[0],tp[1] )
				Next
				indices=indices+order
			Next
		
		Else
		
			For Local i:=0 Until count
				For Local j:=0 Until order
					AddVertex( vertices[0],vertices[1],texCoords[0],texCoords[1] )
					vertices=Cast<Float Ptr>( Cast<UByte Ptr>( vertices )+verticesPitch )
					texCoords=Cast<Float Ptr>( Cast<UByte Ptr>( texCoords )+texCoordsPitch )
				Next
			Next
		End
	End

	#rem monkeydoc Draws an image.

	Draws an image using the current [[Color]], [[BlendMode]] and [[Matrix]].

	@param tx X coordinate to draw image at.

	@param ty Y coordinate to draw image at.

	@param translation X/Y coordinates to draw image at.

	@param rz Rotation angle, in radians, for drawing.

	@param sx X axis scale factor for drawing.

	@param sy Y axis scale factor for drawing.

	@param scale X/Y scale factor for drawing.
 
	#end	
	Method DrawImage( image:Image,tx:Float,ty:Float )
		Local vs:=image.Vertices
		Local tc:=image.TexCoords
		AddDrawOp( image.Material,4,1 )
		AddVertex( vs.min.x+tx,vs.min.y+ty,tc.min.x,tc.min.y )
		AddVertex( vs.max.x+tx,vs.min.y+ty,tc.max.x,tc.min.y )
		AddVertex( vs.max.x+tx,vs.max.y+ty,tc.max.x,tc.max.y )
		AddVertex( vs.min.x+tx,vs.max.y+ty,tc.min.x,tc.max.y )
	End
	
	Method DrawImage( image:Image,translation:Vec2f )
		DrawImage( image,translation.x,translation.y )
	End

	Method DrawImage( image:Image,tx:Float,ty:Float,rz:Float )
		Local matrix:=_matrix
		Translate( tx,ty )
		Rotate( rz )
		DrawImage( image,0,0 )
		_matrix=matrix
	End

	Method DrawImage( image:Image,translation:Vec2f,rz:Float )
		DrawImage( image,translation.x,translation.y,rz )
	End

	Method DrawImage( image:Image,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		Local matrix:=_matrix
		Translate( tx,ty )
		Rotate( rz )
		Scale( sx,sy )
		DrawImage( image,0,0 )
		_matrix=matrix
	End

	Method DrawImage( image:Image,translation:Vec2f,rz:Float,scale:Vec2f )
		DrawImage( image,translation.x,translation.y,rz,scale.x,scale.y )
	End
	
	#rem monkeydoc Draws text.

	Draws text using the current [[Color]], [[BlendMode]] and [[Matrix]].

	@param text The text to draw.

	@param tx X coordinate to draw text at.

	@param ty Y coordinate to draw text at.

	@param handleX X handle for drawing.

	@param handleY Y handle for drawing.

	#end
	Method DrawText( text:String,tx:Float,ty:Float,handleX:Float=0,handleY:Float=0 )
	
		tx-=_font.TextWidth( text ) * handleX
		ty-=_font.Height * handleY
		
		Local image:=_font.Image
		Local sx:=image.Rect.min.x,sy:=image.Rect.min.y
		Local tw:=image.Texture.Width,th:=image.Texture.Height
		
		AddDrawOp( image.Material,4,text.Length )
		
		For Local char:=Eachin text
		
			Local g:=_font.GetGlyph( char )
			
			Local s0:=Float(g.rect.min.x+sx)/tw
			Local t0:=Float(g.rect.min.y+sy)/th
			Local s1:=Float(g.rect.max.x+sx)/tw
			Local t1:=Float(g.rect.max.y+sy)/th
			
			Local x0:=Round( tx+g.offset.x )
			Local y0:=Round( ty+g.offset.y )
			Local x1:=x0+g.rect.Width
			Local y1:=y0+g.rect.Height

			AddVertex( x0,y0,s0,t0 )
			AddVertex( x1,y0,s1,t0 )
			AddVertex( x1,y1,s1,t1 )
			AddVertex( x0,y1,s0,t1 )
			
			tx+=g.advance
		Next
	End
	
	#rem
	Method AddLight( tx:Float,ty:Float,radius:Radius )
		Local x:=_matrix.i.x * tx + _matrix.j.x * ty + _matrix.t.x
		Local y:=_matrix.i.y * tx + _matrix.j.y * ty + _matrix.t.y
		Local inst:=New LightInst
		inst.position=New Vec2f( x,y )
		inst.radius=radius
		inst.color=_color
		'_lights.Push( inst )
	End
	#end
	
	Private
	
	Struct LightInst
		Field position:Vec2f
		Field radius:Float
		Field color:Color
	End
	
	Enum Dirty
		Target=1
		Scissor=2
		EnvParams=4
		All=7
	End
	
	Global _inited:Bool
	Global _ambientEnv:ShaderEnv
	Global _nullShader:Shader
	Global _defaultFont:Font

	Field _dirty:Dirty
	Field _target:Texture
	Field _targetSize:Vec2i
	Field _targetRect:Recti
	Field _envParams:ParamBuffer
	Field _device:GraphicsDevice
	
	Field _viewport:Recti
	Field _scissor:Recti
	Field _viewMatrix:Mat4f
	Field _modelMatrix:Mat4f
	Field _ambientLight:Color
	Field _filter:Bool=True

	Field _renderColor:Color
	Field _renderMatrix:AffineMat3f
	Field _renderMatrixStack:=New Stack<AffineMat3f>

	Field _renderBounds:Recti
	Field _renderBoundsStack:=New Stack<Recti>
	
	Field _font:Font
	Field _alpha:Float
	Field _color:Color
	Field _pmcolor:UInt
	Field _matrix:AffineMat3f
	Field _blendMode:BlendMode
	Field _pointSize:Float
	Field _lineWidth:Float
	Field _matrixStack:=New Stack<AffineMat3f>
	
	Field _ops:=New Stack<DrawOp>
	Field _op:=New DrawOp
	
	Field _vertices:=New Stack<Vertex2f>
	Field _vertexData:Vertex2f[]
	Field _vertex:Int
	
	Field _materials:=New Material[6]
	
	Method Init( target:Texture,size:Vec2i,viewport:Recti )
	
		If Not _inited
			_inited=True
			Local env:=stringio.LoadString( "asset::mojo/shader_env.glsl" )
			_ambientEnv=New ShaderEnv( "#define RENDERPASS_AMBIENT~n"+env )
'			_ambientEnv=New ShaderEnv( "#define RENDERPASS_NORMAL~n"+env )
			_defaultFont=Font.Load( "font::DejaVuSans.ttf",16 )
			_nullShader=Shader.GetShader( "null" )
		Endif

		_target=target
		_targetSize=size
		_targetRect=viewport
		
		_envParams=New ParamBuffer
		_device=New GraphicsDevice
		
		_viewport=New Recti( 0,0,_targetRect.Width,_targetRect.Height )
		_scissor=_viewport
		_viewMatrix=New Mat4f
		_modelMatrix=New Mat4f
		_ambientLight=Color.Black
		_filter=True
		
		_renderColor=Color.White
		_renderMatrix=New AffineMat3f
		_renderBounds=New Recti( 0,0,$40000000,$40000000 )
		
		_dirty=Dirty.All
		
		Font=Null
		Alpha=1
		Color=Color.White
		Matrix=New AffineMat3f
		BlendMode=BlendMode.Alpha
		PointSize=1
		LineWidth=1
		For Local i:=0 Until _materials.Length
			_materials[i]=New Material( _nullShader )
		Next
	End
	
	Method Validate()

		If Not _dirty Return
		
		If _dirty & Dirty.Target

			Local projMatrix:Mat4f
			Local viewport:=_targetRect
	
			If _target
				projMatrix=Mat4f.Ortho( 0,viewport.Width,0,viewport.Height,-1,1 )
			Else
				viewport.min.y=_targetSize.y-viewport.max.y
				viewport.max.y=viewport.min.y+viewport.Height
				projMatrix=Mat4f.Ortho( 0,viewport.Width,viewport.Height,0,-1,1 )
			Endif
		
			_device.RenderTarget=_target
			_device.Viewport=_targetRect
			_envParams.SetMatrix( "mx2_ProjectionMatrix",projMatrix )
			
			_dirty|=Dirty.EnvParams
			
		Endif
		
		If _dirty & Dirty.EnvParams
		
			Local renderMatrix:=_renderMatrix.Translate( New Vec2f( _viewport.X,_viewport.Y ) )

			Local modelViewMatrix:=_viewMatrix * _modelMatrix * New Mat4f( renderMatrix )
			
			_envParams.SetMatrix( "mx2_ModelViewMatrix",modelViewMatrix )
			_envParams.SetColor( "mx2_AmbientLight",_ambientLight )
			_envParams.SetColor( "mx2_RenderColor",_renderColor )

			_device.EnvParams=_envParams

		Endif
		
		If _dirty & Dirty.Scissor
		
			Local scissor:=TransformRecti( _viewport & (_scissor+_viewport.Origin),_renderMatrix )
			
			scissor=(scissor & _renderBounds)+_targetRect.Origin
			
			If Not _target
				Local h:=scissor.Height
				scissor.min.y=_targetSize.y-scissor.max.y
				scissor.max.y=scissor.min.y+h
			Endif

			_device.Scissor=scissor
		Endif
		
		_dirty=Null
	End
	
	Method RenderDrawOps()
	
		Local p:=_vertexData.Data
		
		_device.FilteringEnabled=_filter
	
		For Local op:=Eachin _ops
			_device.BlendMode=op.blendMode
			_device.Shader=op.material.Shader
			_device.Params=op.material.Params
			_device.Render( p,op.order,op.count )
			p=p+op.order*op.count
		Next
	
	End
	
	Method ClearDrawOps()
		_ops.Clear()
		_vertices.Clear()
		_vertexData=_vertices.Data
		_op=New DrawOp
		_vertex=0
	End
	
	Method AddDrawOp( material:Material,order:Int,count:Int )
	
		_vertices.Resize( _vertex+order*count )
		_vertexData=_vertices.Data
		
		If _blendMode=_op.blendMode And material=_op.material And order=_op.order
			_op.count+=count
			Return
		End
		
		_op=New DrawOp
		_op.blendMode=_blendMode
		_op.material=material
		_op.order=order
		_op.count=count
		_ops.Add( _op )
	End
	
	Method AddVertex( tx:Float,ty:Float,s0:Float,t0:Float )
	
		_vertexData[_vertex].x=_matrix.i.x * tx + _matrix.j.x * ty + _matrix.t.x
		_vertexData[_vertex].y=_matrix.i.y * tx + _matrix.j.y * ty + _matrix.t.y
		_vertexData[_vertex].s0=s0
		_vertexData[_vertex].t0=t0
		_vertexData[_vertex].ix=_matrix.i.x
		_vertexData[_vertex].iy=_matrix.i.y
		_vertexData[_vertex].color=_pmcolor

		_vertex+=1
	End

End
