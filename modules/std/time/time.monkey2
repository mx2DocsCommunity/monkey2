
#Import "native/time.h"
#Import "native/time.cpp"

Namespace std.time

Private

Function to_ticks:Long( time:libc.time_t )
	
	Local secs:Long
	
	If libc.sizeof( time )=8
		secs=Cast<Long Ptr>( Varptr time )[0]
	Else If libc.sizeof( time )=4 
		secs=Cast<Int Ptr>( Varptr time )[0]
	Else
		RuntimeError( "time_t error" )
	Endif
	
	Return secs*TimeSpan.TicksPerSecond
End

Function to_time:libc.time_t( ticks:Long )
	
	Local secs:=ticks/TimeSpan.TicksPerSecond
	
	Local time:libc.time_t
	
	If libc.sizeof<libc.time_t>()=8 
		time=Cast<libc.time_t Ptr>( Varptr secs )[0]
	Else If libc.sizeof<libc.time_t>()=4
		Local isecs:=Int( secs )
		time=Cast<libc.time_t Ptr>( Varptr isecs )[0]
	Else
		RuntimeError( "time_t error" )
	Endif
	
	Return time
End

Extern

#rem monkeydoc Gets the number of seconds elapsed since the app started.

#end
Function Now:Double()="bbTime::now"

#rem monkeydoc Puts thread to sleep.

Note: this will also cause all fibers to sleep.

#end
Function Sleep( seconds:Double )="bbTime::sleep"

Public

#rem monkeydoc Gets the number of microseconds since the app started.
#end
Function Microsecs:Long()
	Return Now() * 1000000
End

#rem monkeydoc Gets the number of milliseconds since the app started.
#end
Function Millisecs:Int()
	Return Now() * 1000
End

#rem monkeydoc TimeSpan class.

A time span represents the difference between 2 times. A time span can also be thought of as 'duration' or 'interval'.

Time spans are produced by subtracting times, and can be added to times to produce new times that are 'in the future' or 'in the past'.

Internally, a timespan is represented by a single signed 64 bit ticks value. A tick is 1 ten millionth of a second.

#end
Struct TimeSpan
	
	Const TicksPerMillisec:=Long( 10000 )
	Const TicksPerSecond:=TicksPerMillisec*1000
	Const TicksPerMinute:=TicksPerSecond*60
	Const TicksPerHour:=TicksPerMinute*60
	Const TicksPerDay:=TicksPerHour*24

	#rem monkeydoc Creates a new TimeSpan
	#end	
	Method New( days:Int,hours:Int,minutes:Int,seconds:Int,millisecs:Int )
		_ticks=days*TicksPerDay + hours*TicksPerHour + minutes*TicksPerMinute + seconds*TicksPerSecond + millisecs*TicksPerMillisec
	End

	Method New( ticks:Long )
		_ticks=ticks
	End
	
	#rem monkeydoc Converts the time span to a string.
	#end
	Operator To:String()
		Return "TimeSpan("+Days+","+Hours+","+Minutes+","+Seconds+","+Millisecs+")"
	End
	
	#rem monkeydoc Days in the time span.
	#end
	Property Days:Int()
		Return _ticks/TicksPerDay
	End
	
	#rem monkeydoc Hours in the time span.
	#end
	Property Hours:Int()
		Return (_ticks Mod TicksPerDay)/TicksPerHour
	End
	
	#rem monkeydoc Minutes in the time span.
	#end
	Property Minutes:Int()
		Return (_ticks Mod TicksPerHour)/TicksPerMinute
	End
	
	#rem monkeydoc Seconds in the time span.
	#end
	Property Seconds:Int()
		Return (_ticks Mod TicksPerMinute)/TicksPerSecond
	End
	
	#rem monkeydoc Millisecs in the time span.
	#end
	Property Millisecs:Int()
		Return (_ticks Mod TicksPerSecond)/TicksPerMillisec
	End
	
	#rem monkeydoc Ticks in the time span.
	#end
	Property Ticks:Long()
		Return _ticks
	End
	
	#rem monkeydoc Total days in the time span.
	#end
	Property TotalDays:Int()
		Return _ticks/TicksPerDay
	End
	
	#rem monkeydoc Total hours in the time span.
	#end
	Property TotalHours:Int()
		Return _ticks/TicksPerHour
	End
	
	#rem monkeydoc Total minutes in the time span.
	#end
	Property TotalMinutes:Int()
		Return _ticks/TicksPerMinute
	End
	
	#rem monkeydoc Total seconds in the time span.
	#end
	Property TotalSeconds:Int()
		Return _ticks/TicksPerSecond
	End
	
	#rem monkeydoc Total milliseconds in the time span.
	#end
	Property TotalMillisecs:Int()
		Return _ticks/TicksPerMillisec
	End
	
	Private
	
	Field _ticks:Long
End

#rem monkeydoc The Time class.

The Time class represents a point in time.

Note that the current implementation of the time class only has second precision.

On some 32 bit targets, it may also be suject to the year 2038 problem:

https://en.wikipedia.org/wiki/Year_2038_problem

#end
Class Time
	
	Const DayNames:=New String[]( "Sun","Mon","Tue","Wed","Thu","Fri","Sat" )
	
	Const MonthNames:=New String[]( "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" )
	
	#rem monkeydoc Creates a new time.
	
	Creating a time with no parameters creates a time representing 'now' in local time.
	
	#end
	Method New()
		Local ticks:=to_ticks( libc.time( Null ) )
		Init( ticks )
	End
	
	Method New( day:Int,month:Int,year:Int,hours:Int,minutes:Int,seconds:Int )
		
		Local tm:libc.tm_t
		
		tm.tm_mday=day
		tm.tm_mon=month
		tm.tm_year=year-1900
		tm.tm_hour=hours
		tm.tm_min=minutes
		tm.tm_sec=seconds
		
		Local ticks:=to_ticks( libc.mktime( Varptr tm ) )
		
		Init( ticks )
	End

	#rem monkeydoc Seconds (0-61)
	
	May include 'leap' seconds.
	
	#end
	Property Seconds:Int()
		Return _tm.tm_sec
	End
	
	#rem monkeydoc Minutes (0-59)
	#end
	Property Minutes:Int()
		Return _tm.tm_min
	End
	
	#rem monkeydoc Hours since midnight (0-23)
	#end
	Property Hours:Int()
		Return _tm.tm_hour
	End
	
	#rem monkeydoc Day of the month (1-31)
	#end
	Property Day:Int()
		Return _tm.tm_mday
	End
	
	#rem monkeydoc Week day since Sunday (0-6)
	#end
	Property WeekDay:Int()
		Return _tm.tm_wday
	End
	
	#rem monkeydoc Days since January 1 (0-365)
	#end
	Property YearDay:Int()
		Return _tm.tm_yday
	End
	
	#rem monkeydoc Month since January (0-11)
	#end
	Property Month:Int()
		Return _tm.tm_mon
	End
	
	#rem monkeydoc Year
	#end
	Property Year:Int()
		Return _tm.tm_year+1900
	End
	
	#rem monkeydoc True if daylight savings is in effect.
	#end
	Property DaylightSavings:Bool()
		Return _tm.tm_isdst
	End
	
	#rem monkeydoc Converts time to a string.
	#end
	Operator To:String()
		Return ToString()
	End
	
	#rem monkeydoc Converts time to a string.
	
	The string format is: WeekDay Day Month Year Hours:Minutes:Seconds
	
	#end
	Method ToString:String()
		Return DayNames[ WeekDay ]+" "+Day+" "+MonthNames[ Month ]+" "+Year+" "+ Hours+":"+Minutes+":"+Seconds
	End

	#rem monkeydoc Overloaded comparison operator.
	
	Time x is 'less than' time y if time x represents a time 'earlier' than time y.
	
	#end	
	Operator<=>:Int( time:Time )
		Return _ticks<=>time._ticks
	End
	
	#rem monkeydoc Overloaded subtraction operator.
	
	Subtracts `time` from self and return a new [[TimeSpan]].
	
	#end
	Operator-:TimeSpan( time:Time )
		Return New TimeSpan( _ticks-time._ticks )
	End
	
	#rem monkeydoc Overloaded addition operator.
	
	Adds `timeSpan` to self and returns a new Time.
	
	#end
	Operator+:Time( timeSpan:TimeSpan )
		Return New Time( _ticks+timeSpan.Ticks )
	End
	
	#rem monkeydoc Gets current time.
	#end
	Function Now:Time()
		Local ticks:=to_ticks( libc.time( Null ) )
		Return New Time( ticks )
	End
	
	#rem monkeydoc Parses a time from a string.
	
	The string format is: 'WeekDay' Day 'Month' Year Hours:Minutes:Seconds.
	
	WeekDay may be omitted.
	
	#end
	Function Parse:Time( str:String )
		
		Local p:=New TimeParser
		
		If Not p.Parse( str ) Return Null
		
		Return New Time( p.day,p.month,p.year,p.hours,p.minutes,p.seconds )
	End
	
	#rem monkeydoc Converts a file time to a time.
	
	Converts a file time as returned by [[GetFileTime]] to a time.
	
	#end
	Function FromFileTime:Time( fileTime:Long )
		
		Return New Time( fileTime * TimeSpan.TicksPerSecond )
	End
	

	Private
	
	Const _days:=New String[]( "Sun","Mon","Tue","Wed","Thu","Fri","Sat" )
	Const _months:=New String[]( "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec" )
	
	Field _ticks:Long
	Field _tm:libc.tm_t
	
	Method New( ticks:Long )
		Init( ticks )
	End
	
	Method Init( ticks:Long )
		_ticks=ticks
		Local time:=to_time( _ticks )
		Local p:=libc.localtime( Varptr time )
		If Not p RuntimeError( "time_t error" )
		_tm=p[0]
	End
	
End

