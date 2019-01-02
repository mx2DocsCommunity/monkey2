
Namespace mx2cc

#If __TARGET__="windows"

Function FindMSVC:Bool()

	Local msvcs:=GetEnv( "ProgramFiles(x86)" )+"\Microsoft Visual Studio\2017"
	If GetFileType( msvcs )<>FileType.Directory Return False
	
	Local wkits:=GetEnv( "ProgramFiles(x86)" )+"\Windows Kits\10"
	If GetFileType( wkits )<>FileType.Directory Return False
	
	Local toolsDir:="",maxver:=0
	
	For Local f:=Eachin LoadDir( msvcs )
		
		Local dir:=msvcs+"\"+f+"\VC\Tools\MSVC"
		If GetFileType( dir )<>FileType.Directory Continue
		
		For Local f:=Eachin LoadDir( dir )
			Local verDir:=dir+"\"+f
			If GetFileType( verDir )<>FileType.Directory Continue
			Local ver:=Int( f.Replace( ".","" ) )
			If ver>maxver
				toolsDir=verDir
				maxver=ver
			Endif
		Next
	Next

	Local incsDir:=FindMaxVerDir( wkits+"\Include" )
	If Not incsDir Return False

	Local libsDir:=FindMaxVerDir( wkits+"\Lib" )
	If Not libsDir Return False
	
'	Print toolsDir
'	Print incsDir
'	Print libsDir
	Print "~nMSVC installation auto-detected:"
	Print "Tools='"+toolsDir+"'"
	Print "Include='"+incsDir+"'"
	Print "Lib='"+libsDir+"'"
	
	SetEnv( "MX2_MSVC_PATH_X86",toolsDir+"\bin\Hostx86\x86" )
	SetEnv( "MX2_MSVC_INCLUDE_X86",toolsDir+"\include;"+incsDir+"\ucrt;"+incsDir+"\shared;"+incsDir+"\um" )
	SetEnv( "MX2_MSVC_LIB_X86",toolsDir+"\lib\x86;"+libsDir+"\ucrt\x86;"+libsDir+"\um\x86" )
	
	SetEnv( "MX2_MSVC_PATH_X64",toolsDir+"\bin\Hostx64\x64" )
	SetEnv( "MX2_MSVC_INCLUDE_X64",toolsDir+"\include;"+incsDir+"\ucrt;"+incsDir+"\shared;"+incsDir+"\um" )
	SetEnv( "MX2_MSVC_LIB_X64",toolsDir+"\lib\x64;"+libsDir+"\ucrt\x64;"+libsDir+"\um\x64" )
	
	Return True
End

Function FindMaxVerDir:String( dir:String )
	
	Local maxver:Long=0,maxverDir:=""
	
	For Local f:=Eachin LoadDir( dir )
		
		Local verDir:=dir+"\"+f
		If GetFileType( verDir )<>FileType.Directory Continue
		
		Local ver:Long=Int( f.Replace( ".","" ) )
		
		If ver>maxver
			maxver=ver
			maxverDir=verDir
		Endif
	Next
	
	Return maxverDir
End

#else

Function FindMSVC:Bool()
	Return False
End

#endif
