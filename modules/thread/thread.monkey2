
Namespace std.thread

#If __THREADS__

#Import "<std>"

#Import "native/bbthread.cpp"
#Import "native/bbthread.h"

Using std..

Extern Private

Struct bbThread="bbThread"

	Global current_id:Int

	Field running:Bool
	
	Method start:Int( entry:Void() )
	Method detach()
	Method join()
End

Struct bbMutex="bbMutex"

	Method try_lock:Bool()
	Method lock()
	Method unlock()
End

Struct bbCondvar="bbCondvar"	'condition_variable_any"
	
	Method wait( mutex:bbMutex )
	Method notify_one()
	Method notify_all()
End

Public

Class Thread
	
	Method New( entry:Void() )
		FlushZombies()
		_entry=entry
		_id=_thread.start( Lambda()
			_mutex.lock()
			_threads[bbThread.current_id]=Self
			_mutex.unlock()
			_entry()
		End )
	End
	
	Property Id:Int()
		Return _id
	End
	
	Property Running:Bool()
		Return _thread.running
	End
	
	Method Detach()
		If Not _id Return
		_mutex.lock()
		_zombies.Add( Self )
		_threads.Remove( _id )
		_mutex.unlock()
		_thread.detach()
		_id=0
	End
	
	Method Join()
		If Not _id Return
		_thread.join()
		_mutex.lock()
		_threads.Remove( _id )
		_mutex.unlock()
		_id=0
	End
	
	Function Current:Thread()
		_mutex.lock()
		Local thread:=_threads[bbThread.current_id]
		_mutex.unlock()
		Return thread
	End

	Function CurrentId:Int()
		Return bbThread.current_id
	End
	
	Function Main:Thread()
		_mutex.lock()
		If Not _threads.Contains( 1 ) _threads[1]=New Thread( 1 )
		Local thread:=_threads[1]
		_mutex.unlock()
		Return thread
	End
	
	Private
	
	Global _mutex:bbMutex
	Global _zombies:=New Stack<Thread>
	Global _threads:=New IntMap<Thread>
	
	Field _thread:bbThread
	Field _entry:Void()
	Field _id:Int
	
	Method New( id:Int )
		_id=id
	End
	
	Function FlushZombies()
		If _zombies.Empty Return
		_mutex.lock()
		Local put:=0
		For Local thread:=Eachin _zombies
			If Not thread.Running Continue
			_zombies[put]=thread
			put+=1
		Next
		_zombies.Resize( put )
		_mutex.unlock()
	End
	
End

Class Mutex
	
	Method TryLock:Bool()
		Return _mutex.try_lock()
	End
	
	Method Lock()
		_mutex.lock()
	End
	
	Method Unlock()
		_mutex.unlock()
	End
	
	Private
	
	Field _mutex:bbMutex
End

Class Condvar
	
	Method Wait( mutex:Mutex )
		_condvar.wait( mutex._mutex )
	End
	
	Method Notify()
		_condvar.notify_one()
	End
	
	Method NotifyAll()
		_condvar.notify_all()
	End
	
	Private
	
	Field _condvar:bbCondvar
End

Class Semaphore
	
	Method New( count:Int=0 )
		_count=count
	End
	
	Method Wait()
		_mutex.lock()
		While( _count<=0 )
			_condvar.wait( _mutex )
		Wend
		_count-=1
		_mutex.unlock()
	End
	
	Method Signal()
		_mutex.lock()
		_count+=1
		_condvar.notify_one()
		_mutex.unlock()
	End
	
	Private
	
	Field _count:Int
	Field _mutex:bbMutex
	Field _condvar:bbCondvar
End

#endif
