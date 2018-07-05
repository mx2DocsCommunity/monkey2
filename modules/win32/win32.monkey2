
#rem

This is just enough to create a window and get a simply message loop running. More to come once I get c2mx2 running again...

Notes:

WndProc function MUST be a plain static functions.

The LRESULT_WINAPI hack is for forcing functions to be 'stdcall'. Will probably add calling convention support later...

Haven't converted any types with same name as mx2 types, eg: BYTE, UBYTE etc.

Haven't converted any pointer types, eg: LPDWORD. Should I?

Data types source:

https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751

#end

Namespace win32

#If __TARGET__="windows"

#Import "<libc>"

#Import "<kernel32.lib>"
#Import "<user32.lib>"

#import "<windows.h>"

Extern

Alias CHAR:UByte	'signedness?
Alias WCHAR:UShort	'signedness?
Alias WORD:UShort
Alias DWORD:UInt
Alias ATOM:WORD

Alias BOOL_:Int="BOOL"
Alias LONG_:Int="LONG"

Alias LONG_PTR:Int	'long on 64 bit?
Alias UINT_PTR:UInt	'ulong on 64bit?

Alias LRESULT:LONG_PTR
Alias LPARAM:LONG_PTR
Alias WPARAM:UINT_PTR

Alias HANDLE:Void Ptr

Alias HWND:HANDLE
Alias HMENU:HANDLE
Alias HMODULE:HANDLE
Alias HINSTANCE:HANDLE
Alias HBITMAP:HANDLE
Alias HBRUSH:HANDLE
Alias HCURSOR:HANDLE
Alias HDC:HANDLE
Alias HICON:HANDLE

Alias LRESULT_WINAPI:LRESULT="LRESULT WINAPI"	'cheezy as hell!

Alias WNDPROC:LRESULT_WINAPI( hwnd:HWND,uMsg:UInt,wParam:WPARAM,lParam:LPARAM )

Struct WNDCLASSW
	Field style:UInt
	Field lpfnWndProc:WNDPROC
	Field cbClsExtra:Int
	Field cbWndExtra:Int
	Field hInstance:HINSTANCE
	Field hIcon:HICON
	Field hCursor:HCURSOR
	Field hbrBackground:HBRUSH
	Field lpszMenuName:WCHAR Ptr
	Field lpszClassName:WCHAR Ptr
End

Struct POINT
	Field x:LONG_
	Field y:LONG_
End

Struct RECT
	Field left:LONG_
	Field top:LONG_
	Field right:LONG_
	Field bottom:LONG_
End

Struct MSG
	Field hwnd:HWND
	Field message:UInt
	Field wParam:WPARAM
	Field lParam:LPARAM
	Field time:DWORD
	Field pt:POINT
End

Const MB_OK:UInt
Const MB_OKCANCEL:UInt
Const MB_RETRYCANCEL:UInt
Const MB_YESNO:UInt
Const MB_YESNOCANCEL:UInt

Const IDNO:Int
Const IDOK:Int
Const IDRETRY:Int
Const IDTRYAGAIN:Int
Const IDYES:Int

Const WS_OVERLAPPEDWINDOW:DWORD
Const WS_POPUPWINDOW:DWORD
Const WS_VISIBLE:DWORD
Const WS_CHILD:DWORD
Const WS_CLIPCHILDREN:DWORD
Const WS_CLIPSIBLINGS:DWORD

Const SM_CYVIRTUALSCREEN:Int
Const SM_CXVIRTUALSCREEN:Int
 
Const GWL_EXSTYLE:LONG_
Const GWL_HINSTANCE:LONG_
Const GWL_HWNDPARENT:LONG_
Const GWL_ID:LONG_
Const GWL_STYLE:LONG_
Const GWL_USERDATA:LONG_
Const GWL_WNDPROC:LONG_
 
Const HWND_BOTTOM:HWND
Const HWND_NOTOPMOST:HWND
Const HWND_TOP:HWND
Const HWND_TOPMOST:HWND

Const SWP_ASYNCWINDOWPOS:UInt
Const SWP_DEFERERASE:UInt
Const SWP_DRAWFRAME:UInt
Const SWP_FRAMECHANGED:UInt
Const SWP_HIDEWINDOW:UInt
Const SWP_NOACTIVATE:UInt
Const SWP_NOCOPYBITS:UInt
Const SWP_NOMOVE:UInt
Const SWP_NOOWNERZORDER:UInt
Const SWP_NOREDRAW:UInt
Const SWP_NOREPOSITION:UInt
Const SWP_NOSENDCHANGING:UInt
Const SWP_NOSIZE:UInt
Const SWP_NOZORDER:UInt
Const SWP_SHOWWINDOW:UInt

Const DELETE_:DWORD
Const READ_CONTROL:DWORD
Const SYNCHRONIZE:DWORD
Const WRITE_DAC:DWORD
Const WRITE_OWNER:DWORD

Const STANDARD_RIGHTS_ALL:DWORD
Const STANDARD_RIGHTS_EXECUTE:DWORD
Const STANDARD_RIGHTS_READ:DWORD
Const STANDARD_RIGHTS_REQUIRED:DWORD
Const STANDARD_RIGHTS_WRITE:DWORD

'kernel32

Function GetModuleHandleW:HMODULE( lpModuleName:WCHAR Ptr )
	
Function OpenProcess:HANDLE( dwDesiredAccess:DWORD,bInheritHandle:BOOL_,dwProcessId:DWORD )
	
Function GetCurrentProcess:HANDLE()
	
Function CloseHandle:BOOL_( hObject:HANDLE )
	
'user32

Function MessageBoxW:Int( hWnd:HWND,lpText:WString,lpCaption:WString,uType:UInt )

Function RegisterClassW:ATOM( lpWndClass:WNDCLASSW Ptr )	
Function CreateWindowW:HWND( lpClassName:WString,lpWindowName:WString,dwStyle:DWORD,x:Int,y:Int,nWidth:Int,nHeight:Int,hWndParent:HWND,hMenu:HMENU,hInstance:HINSTANCE,lpParam:Void Ptr )
Function DefWindowProcW:LRESULT_WINAPI( hwnd:HWND,uMsg:UInt,wParam:WPARAM,lParam:LPARAM )
Function GetClientRect:BOOL_( hWnd:HWND,lpRect:RECT Ptr )
Function SetParent:HWND( child:HWND,parent:HWND )
Function FindWindowW:HWND( lpClassName:WString,lpWindowName:WString )
Function SetWindowPos:BOOL_( hWnd:HWND,hWndInsertAfter:HWND,x:Int,y:Int,cx:Int,cy:Int,flags:UInt )
Function SetWindowLong:LONG_( hWnd:HWND,nIndex:Int,dwNewLong:LONG_ )
Function GetWindowLong:LONG_( hWnd:HWND,nIndex:Int )
			
Function GetMessage:BOOL_( lpMsg:MSG Ptr,hWnd:HWND,wMsgFilterMin:UInt,wMsgFilterMax:UInt )
Function TranslateMessage:BOOL_( lpMsg:MSG Ptr )
Function DispatchMessage:LRESULT( lpMsg:MSG Ptr )
	
Function GetCommandLineW:WString()
	
Function GetSystemMetrics:Int( nIndex:Int )
	
Function GetWindowThreadProcessId:DWORD( hWnd:HWND,lpdwProcessId:DWORD Ptr )

#End
