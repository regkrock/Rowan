"
O_CREAT is not set and the named file does not exist; or O_CREAT is set and either the path prefix does not exist or the path argument points to an empty string.
"
Class {
	#name : 'FileNoEntryError',
	#superclass : 'FilePosixError',
	#category : 'FileSystem-Base-Errors'
}

{ #category : 'accessing' }
FileNoEntryError class >> defaultErrorNumber [
	^2
]

{ #category : 'accessing' }
FileNoEntryError class >> errorDescription [
	^'No such file or directory'
]

{ #category : 'accessing' }
FileNoEntryError class >> posixName [
	^'ENOENT'
]