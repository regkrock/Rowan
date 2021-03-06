"
This class implements the filetree: scheme[1]:

 filetree:///opt/git/shared/repos/rowan/sample/repository

This scheme is supported for backward compatibility. Moving forward the cypress: scheme should be used (see RwCypressUrl).

[1] https://github.com/Metacello/metacello/blob/master/docs/MetacelloScriptingAPI.md#filetree
"
Class {
	#name : 'RwFiletreeUrl',
	#superclass : 'RwFileUrl',
	#category : 'Rowan-Url-Core'
}

{ #category : 'constants' }
RwFiletreeUrl class >> schemeName [
	^'filetree'

]

{ #category : 'converting' }
RwFiletreeUrl >> asRwRepository [
  "return a platform appropriate repository for the repository located in the directory referenced by the receiver"

  ^ self createRwFiletreeRepositoryForPath: self pathForDirectory

]

{ #category : 'printing' }
RwFiletreeUrl >> printOn: aStream [
  aStream
    nextPutAll: self schemeName;
    nextPut: $:.
  aStream nextPutAll: '//'.
  aStream nextPutAll: self pathString
]

{ #category : 'private-initialization' }
RwFiletreeUrl >> privateInitializeFromText: aString [
  "Calculate host and path from a file URL in String format.
	Some malformed formats are allowed and interpreted by guessing."

  | schemeName pathString bare |
  host := ''.
  bare := aString trimSeparators.
  schemeName := RwUrl schemeNameForString: bare.
  (schemeName == nil or: [ schemeName ~= self schemeName ])
    ifTrue: [ pathString := bare ]
    ifFalse: [ 
      "First remove schemeName and colon"
      bare := bare copyFrom: schemeName size + 2 to: bare size.
      (bare beginsWith: '//')
        ifTrue: [ pathString := bare copyFrom: 3 to: bare size ]
        ifFalse: [ pathString := bare ] ].
  self initializeFromPathString: pathString
]
