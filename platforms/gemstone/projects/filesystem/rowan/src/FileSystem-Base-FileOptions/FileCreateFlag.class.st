"
O_CREAT

If the file doesnt already exist, it is created as a new, empty file.
This flag is effective even if the file is being opened only for reading.
If we specify O_CREAT, then we must supply a mode argument in the open() call;
otherwise, the permissions of the new file will be set to some random value from the stack.
"
Class {
	#name : 'FileCreateFlag',
	#superclass : 'FileOpeningFlag',
	#category : 'FileSystem-Base-FileOptions'
}

{ #category : 'accessing' }
FileCreateFlag class >> defaultPlatformValue [
	^16r00040
]

{ #category : 'accessing' }
FileCreateFlag class >> posixName [
	^'O_CREAT'
]

{ #category : 'accessing' }
FileCreateFlag class >> windowsValue [
	^16r20000
]

{ #category : 'convenience' }
FileCreateFlag >> createRule [
	^self parent fileExclusiveFlag ifNil: [self store class openAlwaysRule] ifNotNil: [:option | self store class createNewRule]
]