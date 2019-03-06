"
Set the file descriptor flags to the value specified by arg
"
Class {
	#name : 'FileSetDescriptorFlag',
	#superclass : 'FileControlFlag',
	#category : 'FileSystem-Base-FileOptions'
}

{ #category : 'accessing' }
FileSetDescriptorFlag class >> defaultPlatformValue [
	^2
]

{ #category : 'accessing' }
FileSetDescriptorFlag class >> posixName [
	^'F_SETFD'
]