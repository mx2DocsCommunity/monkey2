
Namespace miniz

#Import "<libc.monkey2>"

#Import "native/miniz.c"
#Import "native/miniz.h"

Using libc

Extern

Enum mz_zip_mode
End

Const MZ_ZIP_MODE_INVALID:mz_zip_mode
Const MZ_ZIP_MODE_READING:mz_zip_mode
Const MZ_ZIP_MODE_WRITING:mz_zip_mode
Const MZ_ZIP_MODE_WRITING_HAS_BEEN_FINALIZED:mz_zip_mode

'Alias mz_alloc_func:Void Ptr( opaque:Void Ptr,items:size_t,size:size_t )
'Alias mz_free_func:Void( opaque:Void Ptr,address:Void Ptr )
'Alias mz_realloc_func:Void Ptr( opaque:Void Ptr,address:Void Ptr,items:size_t,size:size_t )

'Alias mz_file_read_func:size_t( pOpaque:Void Ptr,file_ofs:ULong,buf:Void Ptr,n:size_t )
'Alias mz_file_write_func:size_t( pOpaque:Byte Ptr,file_ofs:ULong,buf:Void Ptr,n:size_t )

Alias mz_alloc_func:Void Ptr
Alias mz_free_func:Void Ptr
Alias mz_realloc_func:Void Ptr

Alias mz_file_read_func:Void Ptr
Alias mz_file_write_func:Void Ptr

Struct mz_zip_archive

	Field m_archive_size:ULong
	Field m_central_directory_file_ofs:ULong
	Field m_total_files:UInt
	
	Field m_file_offset_alignment:UInt
	
	Field m_pAlloc:mz_alloc_func
	Field m_pFree:mz_free_func
	Field m_pRealloc:mz_realloc_func
	Field m_pAlloc_opaque:Void Ptr
	
	Field m_pRead:mz_file_read_func
	Field m_pWrite:mz_file_write_func
	Field m_pIO_opaque:Void Ptr
	
	Field m_pState:Void Ptr
End

Struct mz_zip_archive_file_stat
	Field m_file_index:UInt
	Field m_central_dir_ofs:UInt
	Field m_version_made_by:UShort
	Field m_version_needed:UShort
	Field m_bit_flag:UShort
	Field m_method:UShort
	Field m_crc32:UInt
	Field m_comp_size:ULong
	Field m_uncomp_size:ULong
	Field m_internal_attr:UShort
	Field m_external_attr:UInt
	Field m_local_header_ofs:ULong
	Field m_comment_size:UInt
	Field m_filename:char_t Ptr
	Field m_comment:char_t Ptr
End

Function mz_free:Void( address:Void Ptr )

'Inits a ZIP archive reader.
'These functions read and validate the archive's central directory.
Function mz_zip_reader_init:Int( pZip:mz_zip_archive Ptr,size:Int,flags:Int )
Function mz_zip_reader_init_mem:Int( pZip:mz_zip_archive Ptr,pMem:Void Ptr,size:Int,flags:Int )

'Ends archive reading, freeing all allocations, and closing the input archive file If mz_zip_reader_init_file() was used.
Function mz_zip_reader_end:Int( pZip:mz_zip_archive Ptr )

'Returns the total number of files in the archive.
Function mz_zip_reader_get_num_files:Int( pZip:mz_zip_archive Ptr )

'Attempts to locates a file in the archive's central directory.
'Valid flags: MZ_ZIP_FLAG_CASE_SENSITIVE, MZ_ZIP_FLAG_IGNORE_PATH
'Returns -1 If the file cannot be found.
Function mz_zip_reader_locate_file:Int( pZip:mz_zip_archive Ptr,pName:CString,pComment:CString,flags:Int )

'Returns detailed information about an archive file entry.
Function mz_zip_reader_file_stat:Int( pZip:mz_zip_archive Ptr,file_index:Int,pStat:mz_zip_archive_file_stat Ptr )

'Determines if an archive file entry is a directory entry.
Function mz_zip_reader_is_file_a_directory:Int( pZip:mz_zip_archive Ptr,file_index:Int )
Function mz_zip_reader_is_file_encrypted:Int( pZip:mz_zip_archive Ptr,file_index:Int )

'Extracts a archive file to a memory buffer.
Function mz_zip_reader_extract_to_mem:Int( pZip:mz_zip_archive Ptr,file_index:Int,pBuf:Void Ptr,buf_size:Int,flags:Int )
Function mz_zip_reader_extract_file_to_mem:Int( pZip:mz_zip_archive Ptr,pFilename:CString,pBuf:Void Ptr,buf_size:Int,flags:Int )

'Extracts a archive file to a dynamically allocated heap buffer.
Function mz_zip_reader_extract_to_heap:Void Ptr( pZip:mz_zip_archive Ptr,file_index:Int,pSize:size_t Ptr,flags:Int )
Function mz_zip_reader_extract_file_to_heap:Void Ptr( pZip:mz_zip_archive Ptr,pFilename:CString,pSize:size_t Ptr,flags:Int )

