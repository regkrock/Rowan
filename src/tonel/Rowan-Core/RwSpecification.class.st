Class {
	#name : 'RwSpecification',
	#superclass : 'Object',
	#category : 'Rowan-Core'
}

{ #category : 'instance creation' }
RwSpecification class >> fromUrl: specNameOrUrl [

	"self fromUrl: 'file:/export/foos1/users/dhenrich/dev/_home/shared/repos/rowan/CypressReferenceImplementation/rowanLoadSpec.ston'"

	"self fromUrl: 'sampleLoadSpec'"

	"self fromUrl: 'https://raw.githubusercontent.com/dalehenrich/CypressReferenceImplementation/rowan/rowanLoadSpec.ston'"

	| url |
	url := specNameOrUrl asRwUrl.
	url schemeName isNil
		ifTrue: [ 
			^ Rowan
				projectNamed: specNameOrUrl
				ifAbsent: [ self error: 'No project named ' , specNameOrUrl printString , ' found' ] ].
	url schemeName = 'file'
		ifTrue: [ 
			CypressFileUtilities current
				readStreamFor: url fileName
				in: url pathForDirectory
				do: [ :stream | 
					^ (STON fromStream: stream)
						initializeForImport;
						projectUrl: specNameOrUrl;
						yourself ] ].
	url schemeName = 'https'
		ifTrue: [ 
			| contents client response |
			GsSecureSocket disableCertificateVerificationOnClient.
			client := (System myUserProfile symbolList objectNamed: 'ZnClient') new.
			response := client
				beOneShot;
				enforceHttpSuccess: true;
				get: url.
			^ (STON fromString: response decodeFromUTF8)
				initializeForImport;
				projectUrl: specNameOrUrl;
				yourself ].
	self error: 'Unknown scheme: ' , url scheme printString
]

{ #category : 'initialization' }
RwSpecification class >> initialize [
  "self initialize"

  
]

{ #category : 'instance creation' }
RwSpecification class >> new [

	^self basicNew initialize
]

{ #category : 'initialization' }
RwSpecification >> initialize [
  
]

{ #category : 'initialization' }
RwSpecification >> initializeForExport [
  "if spec has been exported, clear out any of the fields that represent local disk state"

  ^ self initializeForImport
]

{ #category : 'initialization' }
RwSpecification >> initializeForImport [
  "if spec has been imported, clear out any of the fields that represent local disk state"

  
]

{ #category : 'actions' }
RwSpecification >> packageNamesForTool: aRwTool [
  self subclassResponsibility: #'packageNamesForTool:'
]

{ #category : 'copying' }
RwSpecification >> postCopy [
  "don't forget to copy any compound state objects"

  
]

{ #category : 'accessing' }
RwSpecification >> projectUrl: ignored [
  
]

{ #category : 'registering' }
RwSpecification >> register [
  Rowan addProject: self
]

{ #category : 'registering' }
RwSpecification >> registerForced [

	(Rowan projectNamed: self specName ifAbsent: [  ])
		ifNotNil: [ :anotherProject | Rowan removeProject: self ].
	^ Rowan addProject: self
]

{ #category : 'registering' }
RwSpecification >> unregister [

	Rowan removeProject: self
]