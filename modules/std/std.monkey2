
Namespace std

#Import "<libc>"
#Import "<zlib>"
#Import "<miniz>"
#Import "<stb-image>"
#Import "<stb-image-write>"
#import "<stb-vorbis>"

#If __TARGET__="emscripten"
#Import "<emscripten>"
#ElseIf __TARGET__="android"
#Import "<android>"
#ElseIf __TARGET__="ios"
'#Import "<ios>"
#Endif

#Import "collections/container"
#Import "collections/stack"
#Import "collections/list"
#Import "collections/map"
#Import "collections/deque"

#Import "resource/resource"

#Import "stream/stream"
#Import "stream/filestream"

'#If __MOBILE_TARGET__
'#Import "stream/sdl_rwstream.monkey2"
'#Endif

#Import "memory/byteorder"
#Import "memory/databuffer"
#Import "memory/datastream"

#Import "geom/affinemat3"
#Import "geom/affinemat4"
#Import "geom/axis"
#Import "geom/box"
#Import "geom/line"
#Import "geom/mat3"
#Import "geom/mat4"
#Import "geom/plane"
#Import "geom/quat"
#Import "geom/rect"
#Import "geom/vec2"
#Import "geom/vec3"
#Import "geom/vec4"

#Import "geom/plane"
#Import "geom/box"
#Import "geom/line"

#Import "graphics/pixelformat"
#Import "graphics/pixmap"
#Import "graphics/pixmaploader"
#Import "graphics/pixmapsaver"
#Import "graphics/color"

#import "audio/audioformat"
#import "audio/audiodata"
#import "audio/load_wav"
#import "audio/load_vorbis"

#Import "async/async"
#Import "time/time"
#Import "time/time-parser"
#Import "time/timer"
#Import "fiber/fiber"
#Import "fiber/future"
#Import "process/process"
#Import "process/processstream"
#Import "filesystem/filesystem"

#Import "misc/random"
#Import "misc/chartype"
#Import "misc/stringio"
#Import "misc/json"
#Import "misc/jsonify"
#Import "misc/zipfile"
#Import "misc/base64"
#Import "misc/digest"

#Import "socket/socket"
#Import "socket/socketstream"

#Import "requesters/requesters"

#Import "permissions/permissions"

Private

Function Main()

	'Capture app start time
	'
	std.time.Now()

	'Add stream handlers
	'
	Stream.OpenFuncs["file"]=Lambda:Stream( proto:String,path:String,mode:String )

		Return FileStream.Open( path,mode )
	End
	
	Stream.OpenFuncs["asset"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.AssetsDir()+path,mode )
	End
	
#If __MOBILE_TARGET__
	
	Stream.OpenFuncs["internal"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.InternalDir()+path,mode )
	End

	Stream.OpenFuncs["external"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.ExternalDir()+path,mode )
	End

#endif
	
	Stream.OpenFuncs["memory"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return DataStream.Open( path,mode )
	End
	
#If __DESKTOP_TARGET__

	Stream.OpenFuncs["process"]=Lambda:Stream( proto:String,path:String,mode:String )

		Return std.process.ProcessStream.Open( path,mode )
	End
	
#Endif
	
End
