Class {
	#name : 'FileReadOnlyFileSystemError',
	#superclass : 'FilePosixError',
	#category : 'FileSystem-Disk-Errors'
}

{ #category : 'accessing' }
FileReadOnlyFileSystemError class >> defaultErrorNumber [
	^30
]

{ #category : 'accessing' }
FileReadOnlyFileSystemError class >> errorDescription [
	^'Read only file system'
]

{ #category : 'accessing' }
FileReadOnlyFileSystemError class >> posixName [
	^'EROFS'
]