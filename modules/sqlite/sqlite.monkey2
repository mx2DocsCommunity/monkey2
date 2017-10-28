
Namespace sqlite

#Import "sqlite_extern.monkey2"

#Import "sqlite-amalgamation/sqlite3.c"

Const SQLITE_OK:=           0   '/* Successful result */

'/* beginning-of-error-codes */

Const SQLITE_ERROR:=        1   '/* SQL error or missing database */
Const SQLITE_INTERNAL:=     2   '/* Internal logic error in SQLite */
Const SQLITE_PERM:=         3   '/* Access permission denied */
Const SQLITE_ABORT:=        4   '/* Callback routine requested an abort */
Const SQLITE_BUSY:=         5   '/* The database file is locked */
Const SQLITE_LOCKED:=       6   '/* A table in the database is locked */
Const SQLITE_NOMEM:=        7   '/* A malloc() failed */
Const SQLITE_READONLY:=     8   '/* Attempt to write a readonly database */
Const SQLITE_INTERRUPT:=    9   '/* Operation terminated by sqlite3_interrupt()*/
Const SQLITE_IOERR:=       10   '/* Some kind of disk I/O error occurred */
Const SQLITE_CORRUPT:=     11   '/* The database disk image is malformed */
Const SQLITE_NOTFOUND:=    12   '/* Unknown opcode in sqlite3_file_control() */
Const SQLITE_FULL:=        13   '/* Insertion failed because database is full */
Const SQLITE_CANTOPEN:=    14   '/* Unable to open the database file */
Const SQLITE_PROTOCOL:=    15   '/* Database lock protocol error */
Const SQLITE_EMPTY:=       16   '/* Database is empty */
Const SQLITE_SCHEMA:=      17   '/* The database schema changed */
Const SQLITE_TOOBIG:=      18   '/* String or BLOB exceeds size limit */
Const SQLITE_CONSTRAINT:=  19   '/* Abort due to constraint violation */
Const SQLITE_MISMATCH:=    20   '/* Data type mismatch */
Const SQLITE_MISUSE:=      21   '/* Library used incorrectly */
Const SQLITE_NOLFS:=       22   '/* Uses OS features not supported on host */
Const SQLITE_AUTH:=        23   '/* Authorization denied */
Const SQLITE_FORMAT:=      24   '/* Auxiliary database format error */
Const SQLITE_RANGE:=       25   '/* 2nd parameter to sqlite3_bind out of range */
Const SQLITE_NOTADB:=      26   '/* File opened that is not a database file */
Const SQLITE_NOTICE:=      27   '/* Notifications from sqlite3_log() */
Const SQLITE_WARNING:=     28   '/* Warnings from sqlite3_log() */
Const SQLITE_ROW:=         100  '/* sqlite3_step() has another row ready */
Const SQLITE_DONE:=        101  '/* sqlite3_step() has finished executing */
