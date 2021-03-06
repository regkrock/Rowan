Class {
	#name : 'JadeServerTest',
	#superclass : 'TestCase',
	#category : 'Rowan-Services-Tests'
}

{ #category : 'support' }
JadeServerTest >> jadeiteServer [

	^JadeServer theJadeiteServer
]

{ #category : 'tests' }
JadeServerTest >> test_jadeServerCanonicalLocation [
	self assert: (JadeServer theJadeiteServer isKindOf: JadeServer64bit32).
	self assert: (JadeServer theJadeiteServer class canUnderstand: #updateFromSton:).
	self assert: (JadeServer theJadeiteServer == (SessionTemps current at: #jadeiteServer))
]

{ #category : 'tests' }
JadeServerTest >> test_jadeServerExists [

	"at minimum (for now), these classes should always be present:
	Object
		JadeServer
			JadeServer64bit
				JadeServer64bit24
					JadeServer64bit3x
						JadeServer64bit32.

	See RsGsPlatform>>jadeServerClassNamed: for symbol list JadeServer*
	lives in. Note that method will only lookup JadeServer & JadeServer64bit32"

	"if method compiles we're in like flint"
	{JadeServer .
			JadeServer64bit .
				JadeServer64bit24 .
					JadeServer64bit3x .
						JadeServer64bit32}.
]

{ #category : 'tests' }
JadeServerTest >> test_jadeServerHierarchyValid [

	"The hierarchy should be:
	Object
		JadeServer
			JadeServer64bit
				JadeServer64bit24
					JadeServer64bit3x
						JadeServer64bit32.

	See RsGsPlatform>>jadeServerClassNamed: for symbol list JadeServer*
	lives in. Note that method will only lookup JadeServer & JadeServer64bit32"
				
	| jadeServerClass subclasses |
	jadeServerClass := Rowan platform jadeServerClassNamed: #JadeServer. 
	subclasses :=  jadeServerClass subclasses asArray.
	self assert: subclasses size equals: 1. 
	self assert: subclasses first name = #JadeServer64bit.
	jadeServerClass := Rowan globalNamed: subclasses first name. 
	subclasses :=  jadeServerClass subclasses asArray.
	self assert: subclasses size equals: 1. 
	self assert: subclasses asArray first name = #JadeServer64bit24.
	jadeServerClass :=  Rowan globalNamed: subclasses first name. 
	subclasses :=  jadeServerClass subclasses asArray.
	self assert: subclasses size equals: 1. 
	self assert: subclasses asArray first name = #JadeServer64bit3x.
	jadeServerClass :=  Rowan globalNamed: subclasses first name. 
	subclasses :=  jadeServerClass subclasses asArray.
	self assert: subclasses size equals: 1. 
	self assert: subclasses asArray first name = #JadeServer64bit32.
	jadeServerClass := Rowan platform jadeServerClassNamed: #JadeServer64bit32. 
	subclasses :=  jadeServerClass subclasses asArray.
	self assert: subclasses isEmpty
]

{ #category : 'tests' }
JadeServerTest >> test_rowanCanFindJadeServer [

	self assert: (Rowan class canUnderstand: #jadeServerClassNamed:).
	self assert: (RwGsPlatform canUnderstand: #jadeServerClassNamed:).
	self assert: (Rowan jadeServerClassNamed: #JadeServer64bit32) equals: JadeServer64bit32
]

{ #category : 'tests' }
JadeServerTest >> test_serviceUsesCanonicalJadeServer [
	
	self assert: (RowanAnsweringService new jadeiteServer isKindOf: JadeServer64bit32).
	self assert: RowanAnsweringService new jadeiteServer == JadeServer theJadeiteServer
]

{ #category : 'tests' }
JadeServerTest >> test_updateFromSton [
	
	"the entry point for all services call is JadeServer>>updateFromSton:.
	Make sure the method is present and will accept/return ston string"

	| service stonString resultString services |

	self assert: (JadeServer canUnderstand: #updateFromSton:).
	service := RowanQueryService new 
				command: #implementorsOf:; 
				commandArgs: (Array with: #test_updateFromSton).
	stonString := STON toString: (Array with: service).
	resultString := self jadeiteServer updateFromSton: stonString. 
	[services := STON fromString: resultString.
	self assert: services size equals: 1.
	self assert: (services first isKindOf: RowanQueryService).
	self assert: (services first queryResults first isKindOf: RowanMethodService).
	self assert: services first queryResults first selector == #test_updateFromSton]
		ensure: [RowanCommandResult initializeResults.]
]
