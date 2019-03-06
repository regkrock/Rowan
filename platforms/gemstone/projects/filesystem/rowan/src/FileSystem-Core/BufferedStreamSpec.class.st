Class {
	#name : 'BufferedStreamSpec',
	#superclass : 'AbstractStreamSpec',
	#category : 'FileSystem-Core'
}

{ #category : 'configuration' }
BufferedStreamSpec >> childStreamSpec [
	^BinaryStreamSpec
]

{ #category : 'configuration' }
BufferedStreamSpec >> readStreamClass [
	^ZnBufferedReadStream
]

{ #category : 'configuration' }
BufferedStreamSpec >> readWriteStreamClass [
	^ZnBufferedReadWriteStream
]

{ #category : 'configuration' }
BufferedStreamSpec >> writeStreamClass [
	^ZnBufferedWriteStream
]