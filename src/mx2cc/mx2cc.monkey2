
Namespace mx2cc

#Import "<std>"

#Import "mx2"

'Use newdocs
#Import "newdocs/docsnode"
#Import "newdocs/docsbuffer"
#Import "newdocs/docsmaker"
#Import "newdocs/markdown"

Using mx2.newdocs

'Use olddocs
'#Import "docs/docsmaker"
'#Import "docs/jsonbuffer"
'#Import "docs/minimarkdown"
'#Import "docs/markdownbuffer"
'#Import "docs/manpage"
'
'Using mx2.docs

#Import "geninfo/geninfo"

Using libc..
Using std..
Using mx2..

Const MX2CC_VERSION_EXT:=""

Global StartDir:String

'Const TestArgs:="mx2cc makemods"

'Const TestArgs:="mx2cc makedocs mojo"
'Const TestArgs:="pyro-framework pyro-gui pyro-scenegraph pyro-tiled"
'Const TestArgs:="mx2cc makedocs"

Const TestArgs:="mx2cc makeapp src/mx2cc/test.monkey2"

'To build with old mx2cc...
'
'Creates: src/mx2cc/mx2cc.buildv.VERSION/windows_release/mx2cc.exe
'
'Const TestArgs:="mx2cc makemods -clean -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std"
'Const TestArgs:="mx2cc makeapp -run -apptype=console -clean -config=release src/mx2cc/mx2cc.monkey2"

'To build rasbian mx2cc...
'
'Const TestArgs:="mx2cc makemods -clean -config=release -target=raspbian monkey libc miniz stb-image stb-image-write stb-vorbis std"
'Const TestArgs:="mx2cc makeapp -build -clean -config=release -target=raspbian src/mx2cc/mx2cc.monkey2"

Function Main()

	'Set aside 64M for GC!
	GCSetTrigger( 64*1024*1024 )

	Print ""
	Print "Mx2cc version "+MX2CC_VERSION+MX2CC_VERSION_EXT
	
	StartDir=CurrentDir()
	
	ChangeDir( AppDir() )
		
	Local env:="bin/env_"+HostOS+".txt"
	
	While Not IsRootDir( CurrentDir() ) And GetFileType( env )<>FILETYPE_FILE
	
		ChangeDir( ExtractDir( CurrentDir() ) )
	Wend
	
	If GetFileType( env )<>FILETYPE_FILE Fail( "Unable to locate mx2cc 'bin' directory" )

	LoadEnv( env )
	
	Local args:=AppArgs()
	
	If args.Length<2

		Print ""
		Print "Mx2cc usage: mx2cc action options sources"
		Print ""
		Print "Actions:"
		print "  makeapp      - make an application"
		print "  makemods     - make modules"
		print "  makedocs     - make docs"
		Print ""
		Print "Options:"
		Print "  -quiet       - emit less info when building"
		Print "  -verbose     - emit more info when building"
		Print "  -parse       - parse only"
		Print "  -semant      - parse and semant"
		Print "  -translate   - parse, semant and translate"
		Print "  -build       - parse, semant, translate and build"
		Print "  -run         - the works! The default."
		Print "  -apptype=    - app type to make, one of : gui, console. Defaults to gui."
		print "  -target=     - build target, one of: windows, macos, linux, emscripten, wasm, android, ios, desktop. Desktop is an alias for current host. Defaults to desktop."
		Print "  -config=     - build config, one of: debug, release. Defaults to debug."
		Print ""
		Print "Sources:"
		Print "  for makeapp  - single monkey2 source file."
		Print "  for makemods - list of modules, or nothing to make all modules."
		Print "  for makedocs - list of modules, or nothing to make all docs."

#If __DESKTOP_TARGET__
		CreateDir( "tmp" )
		system( "g++ --version >tmp/_v.txt" )
		Print ""
		Print "Mx2cc g++ version:"
		Print ""
		Print LoadString( "tmp/_v.txt" )
#Endif

#If __CONFIG__="release"
		exit_(0)
#Endif
		args=TestArgs.Split( " " )
		If args.Length<2 exit_(0)
		
	Endif
	
	Local ok:=False

	Try
	
		Local cmd:=args[1]
		args=args.Slice( 2 )
		
		Select cmd
		Case "makeapp"
			ok=MakeApp( args )
		Case "makemods"
			ok=MakeMods( args )
		Case "makedocs"
			ok=MakeDocs( args )
		Default
			Fail( "Unrecognized mx2cc command: '"+cmd+"'" )
		End
		
	Catch ex:BuildEx
	
		Fail( "Internal mx2cc build error" )
	End
	
	If Not ok libc.exit_( 1 )
End

Function MakeApp:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="app"
	opts.appType="gui"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=5
	
	args=ParseOpts( opts,args )
	
	If args.Length<>1 Fail( "Invalid app source file" )
	
	Local cd:=CurrentDir()
	ChangeDir( StartDir )
	
	'DebugStop()
	
	Local srcPath:=RealPath( args[0].Replace( "\","/" ) )
	
	ChangeDir( cd )
	
	opts.mainSource=srcPath
	
	Print ""
	Print "***** Building app '"+opts.mainSource+"' *****"
	Print ""

	New BuilderInstance( opts )
	
	Builder.Parse()
	If opts.passes=1 
		If opts.geninfo
			Local gen:=New ParseInfoGenerator
			Local jobj:=gen.GenParseInfo( Builder.mainModule.fileDecls[0] )
			Print jobj.ToJson()
		Endif
		Return True
	Endif
	If Builder.errors.Length Return False
	
	Builder.Semant()
	If Builder.errors.Length Return False
	If opts.passes=2
		Return True
	Endif
	
	Builder.Translate()
	If Builder.errors.Length Return False
	If opts.passes=3 
		Return True
	Endif
	
	Builder.product.Build()
	If Builder.errors.Length Return False
	If opts.passes=4
		Print "Application built:"+Builder.product.outputFile
		Return True
	Endif
	
	Builder.product.Run()
	Return True
End

Function MakeMods:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=4
	
	args=ParseOpts( opts,args )

	If Not args args=EnumModules()
	
	Local errs:=0
	
	Local target:=opts.target
	
	For Local modid:=Eachin args
	
		Local path:="modules/"+modid+"/"+modid+".monkey2"
		
		If GetFileType( path )<>FILETYPE_FILE Fail( "Module file '"+path+"' not found" )
	
		Print ""
		Print "***** Making module '"+modid+"' *****"
		Print ""
		
		opts.mainSource=RealPath( path )
		opts.target=target
		
		New BuilderInstance( opts )
		
		Builder.Parse()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=1 Continue

		Builder.Semant()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=2 Continue
		
		Builder.Translate()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=3 Continue
		
		Builder.product.Build()
		If Builder.errors.Length errs+=1;Continue
	Next
	
	Return errs=0
End

'olddocs...
#rem
Function MakeDocs:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=2
	opts.makedocs=true
	
	args=ParseOpts( opts,args )
	
	opts.clean=False
	
	If Not args args=EnumModules()

	Local docsMaker:=New DocsMaker
	
	Local errs:=0
	
	For Local modid:=Eachin args

		Local path:="modules/"+modid+"/"+modid+".monkey2"
		If GetFileType( path )<>FILETYPE_FILE Fail( "Module file '"+path+"' not found" )
	
		Print ""
		Print "***** Doccing module '"+modid+"' *****"
		Print ""
		
		opts.mainSource=RealPath( path )
		
		New BuilderInstance( opts )

		Builder.Parse()
		If Builder.errors.Length errs+=1;Continue
		
		Builder.Semant()
		If Builder.errors.Length errs+=1;Continue

		docsMaker.MakeDocs( Builder.modules.Top )

	Next
	
	Local api_indices:=New StringStack
	Local man_indices:=New StringStack
	
	For Local modid:=Eachin EnumModules()
	
		Local index:=LoadString( "modules/"+modid+"/docs/__MANPAGES__/index.js" )
		If index man_indices.Push( index )
		
		index=LoadString( "modules/"+modid+"/docs/__PAGES__/index.js" )
		If index api_indices.Push( index )
		
	Next
	
	Local tree:=man_indices.Join( "," )
	If tree tree+=","
	tree+="{ text:'Modules reference',children:["+api_indices.Join( "," )+"] }"
	
	Local page:=LoadString( "docs/docs_template.html" )
	page=page.Replace( "${DOCS_TREE}",tree )
	SaveString( page,"docs/docs.html" )
	
	Return True
End
#end


'newdocs...
Function MakeDocs:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=2
	opts.makedocs=true
	
	args=ParseOpts( opts,args )
	
	opts.clean=False
	
	If Not args args=EnumModules()

	Local docsDir:=RealPath( "docs" )+"/"
	
	Local pageTemplate:=LoadString( "docs/new_docs_page_template.html" )
	
	Local docsMaker:=New DocsMaker( docsDir,pageTemplate )

	Local errs:=0
	
	For Local modid:=Eachin args
		
		Local path:="modules/"+modid+"/"+modid+".monkey2"
		If GetFileType( path )<>FILETYPE_FILE Fail( "Module file '"+path+"' not found" )
	
		Print ""
		Print "***** Doccing module '"+modid+"' *****"
		Print ""
		
		opts.mainSource=RealPath( path )
		
		New BuilderInstance( opts )

		Builder.Parse()
		If Builder.errors.Length errs+=1;Continue
		
		Builder.Semant()
		If Builder.errors.Length errs+=1;Continue

		Local module:=Builder.modules.Top
		
		docsMaker.CreateModuleDocs( module )
		
	Next
	
	Local buf:=New StringStack
	Local modsbuf:=New StringStack
	
	For Local modid:=Eachin EnumModules()

		Local index:=LoadString( "docs/modules/"+modid+"/manual/index.js" )
		If index and Not index.Trim() Print "module OOPS modid="+modid
		If index buf.Push( index )
		
		index=LoadString( "docs/modules/"+modid+"/module/index.js" )
		If index and Not index.Trim() Print "manual OOPS modid="+modid
		If index modsbuf.Push( index )
	Next
	
	buf.Add( "{text:'Modules reference',children:[~n"+modsbuf.Join( "," )+"]}~n" )
	
	Local tree:=buf.Join( "," )
	
	Local page:=LoadString( "docs/new_docs_template.html" )
	page=page.Replace( "${DOCS_TREE}",tree )
	SaveString( page,"docs/newdocs.html" )
	
	Return True
End

Function ParseOpts:String[]( opts:BuildOpts,args:String[] )

	opts.verbose=Int( GetEnv( "MX2_VERBOSE" ) )

	For Local i:=0 Until args.Length
	
		Local arg:=args[i]
	
		Local j:=arg.Find( "=" )
		If j=-1 
			Select arg
			Case "-run"
				opts.passes=5
			Case "-build"
				opts.passes=4
			Case "-translate"
				opts.passes=3
			Case "-semant"
				opts.passes=2
			Case "-parse"
				opts.passes=1
			Case "-clean"
				opts.clean=True
			Case "-quiet"
				opts.verbose=-1
			Case "-verbose"
				opts.verbose=1
			Case "-geninfo"
				opts.geninfo=True
			Default
				Return args.Slice( i )
			End
			Continue
		Endif
		
		Local opt:=arg.Slice( 0,j ),val:=arg.Slice( j+1 )
		
		Local path:=val.Replace( "\","/" )
		If path.StartsWith( "~q" ) And path.EndsWith( "~q" ) path=path.Slice( 1,-1 )
		
		val=val.ToLower()
		
		Select opt
		Case "-product"
			opts.product=path
		Case "-apptype"
			opts.appType=val
		Case "-target"
			Select val
			Case "desktop","windows","macos","linux","raspbian","emscripten","android","ios"
				opts.target=val
			Default
				Fail( "Invalid value for 'target' option: '"+val+"' - must be 'desktop', 'raspbian', 'emscripten', 'android' or 'ios'" )
			End
		Case "-config"
			Select val
			Case "debug","release"
				opts.config=val
			Default
				Fail( "Invalid value for 'config' option: '"+val+"' - must be 'debug' or 'release'" )
			End
		Case "-verbose"
			Select val
			Case "0","1","2","3","-1"
				opts.verbose=Int( val )
			Default
				Fail( "Invalid value for 'verbose' option: '"+val+"' - must be '0', '1', '2', '3' or '-1'" )
			End
		Default
			Fail( "Invalid option: '"+opt+"'" )
		End
	
	Next
	
	Select opts.appType
	Case "console","gui"
		Select opts.target
		Case "desktop","windows","macos","linux","raspbian"
		Default
			Fail( "apptype '"+opts.appType+"' may ponly be used with desktop targets" )
		End
	case "wasm","asmjs","wasm+asmjs"
		If opts.target<>"emscripten" Fail( "apptype '"+opts.appType+"' is only valid for emscripten target" )
	case ""
	Default
		Fail( "Unrecognized apptype '"+opts.appType+"'" )
	End
		
	Return Null
End

Function EnumModules( out:StringStack,cur:String,deps:StringMap<StringStack> )
	If out.Contains( cur ) Return
	
	For Local dep:=Eachin deps[cur]
		EnumModules( out,dep,deps )
	Next
	
	out.Push( cur )
End

Function EnumModules:String[]()

	Local mods:=New StringMap<StringStack>

	For Local f:=Eachin LoadDir( "modules" )
	
		Local dir:="modules/"+f+"/"
		If GetFileType( dir )<>FileType.Directory Continue
		
		Local str:=LoadString( dir+"module.json" )
		If Not str Continue
		
		Local obj:=JsonObject.Parse( str )
		If Not obj 
			Print "Error parsing json:"+dir+"module.json"
			Continue
		Endif
		
		Local name:=obj["module"].ToString()
		If name<>f Continue
		
		Local deps:=New StringStack
		If name<>"monkey" deps.Push( "monkey" )
		
		Local jdeps:=obj["depends"]
		If jdeps
			For Local dep:=Eachin jdeps.ToArray()
				deps.Push( dep.ToString() )
			Next
		Endif
		
		mods[name]=deps
	Next
	
	Local out:=New StringStack
	For Local cur:=Eachin mods.Keys
		EnumModules( out,cur,mods )
	Next
	
	Return out.ToArray()
End

Function LoadEnv:Bool( path:String )

	SetEnv( "MX2_HOME",CurrentDir() )
	SetEnv( "MX2_MODULES",CurrentDir()+"modules" )

	Local lineid:=0
	
	For Local line:=Eachin stringio.LoadString( path ).Split( "~n" )
		lineid+=1
	
		Local i:=line.Find( "'" )
		If i<>-1 line=line.Slice( 0,i )
		
		line=line.Trim()
		If Not line Continue
		
		i=line.Find( "=" )
		If i=-1 Fail( "Env config file error at line "+lineid )
		
		Local name:=line.Slice( 0,i ).Trim()
		Local value:=line.Slice( i+1 ).Trim()
		
		value=ReplaceEnv( value,lineid )
		
		SetEnv( name,value )

	Next
	
	Return True
End

Function ReplaceEnv:String( str:String,lineid:Int )
	Local i0:=0
	Repeat
		Local i1:=str.Find( "${",i0 )
		If i1=-1 Return str
		
		Local i2:=str.Find( "}",i1+2 )
		If i2=-1 Fail( "Env config file error at line "+lineid )
		
		Local name:=str.Slice( i1+2,i2 ).Trim()
		Local value:=GetEnv( name )
		
		str=str.Slice( 0,i1 )+value+str.Slice( i2+1 )
		i0=i1+value.Length
	Forever
	Return ""
End

Function Fail( msg:String )

	Print ""
	Print "***** Fatal mx2cc error *****"
	Print ""
	Print msg
		
	exit_( 1 )
End
