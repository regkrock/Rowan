Class {
	#name : 'FileSynchronizedIONotSupportedError',
	#superclass : 'FilePosixError',
	#category : 'FileSystem-Disk-Errors'
}

{ #category : 'accessing' }
FileSynchronizedIONotSupportedError class >> defaultErrorNumber [
	^4
]

{ #category : 'accessing' }
FileSynchronizedIONotSupportedError class >> errorDescription [
	^'Interrupted system call'
]

{ #category : 'accessing' }
FileSynchronizedIONotSupportedError class >> posixName [
	^'EINTR'
]