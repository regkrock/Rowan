"
STONTestDomainObject is used to support unit tests.

Instance Variables
	boolean:		<Boolean>
	bytes:			<ByteArray>
	color:			<Symbol>
	created:		<DateAndTime>
	description:	<String>
	float:			<Float>
	integer:		<Integer>
	modified:	<DateAndTime>
	tags:			<Array of: Symbol>
"
Class {
	#name : 'STONTestDomainObject',
	#superclass : 'Object',
	#instVars : [
		'created',
		'modified',
		'integer',
		'float',
		'description',
		'color',
		'tags',
		'bytes',
		'boolean'
	],
	#category : 'STON-Tests'
}

{ #category : 'instance creation' }
STONTestDomainObject class >> dummy [
	| random atRandom atRandomIndex |
	random :=  HostRandom new.
	atRandom := [:anInt | (random next * anInt) truncated + 1 ].
	atRandomIndex := [:coll | coll at: (atRandom value: coll size) ].
	^ self new
		integer: (atRandom value: 999999);
		float: (atRandom value: 999) / Float pi;
		boolean: (atRandomIndex value: #(true false));
		bytes: (ByteArray streamContents: [ :out | 32 timesRepeat: [ out nextPut: (atRandom value: 255) ] ]);
		description: (String streamContents: [ :out | (atRandom value: 16) timesRepeat: [ out nextPutAll: 'Blah' ] ]);
		color: (atRandomIndex value: #(#red #green #blue));
		tags: (Array 
			with: (atRandomIndex value: #(#one #two #three))
 			with: (atRandomIndex value: #(#alpha #beta #gamma)) 
			with: (atRandomIndex value: #(#low #medium #high)));
		yourself

]

{ #category : 'ston-core' }
STONTestDomainObject class >> stonName [
	^ #TestDomainObject
]

{ #category : 'comparing' }
STONTestDomainObject >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ color = anObject color
		and: [ 
			modified = anObject modified
				and: [ 
					created = anObject created
						and: [ 
							description = anObject description
								and: [ 
									boolean = anObject boolean
										and: [ 
											(float closeTo: anObject float) 		"Use #closeTo: instead of #= to increase portability"
												and: [ 
													bytes = anObject bytes 
														and: [ 
															integer = anObject integer 
																and: [ tags = anObject tags ] ] ] ] ] ] ] ]

]

{ #category : 'accessing' }
STONTestDomainObject >> boolean [
	^ boolean
]

{ #category : 'accessing' }
STONTestDomainObject >> boolean: anObject [
	boolean := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> bytes [
	^ bytes
]

{ #category : 'accessing' }
STONTestDomainObject >> bytes: anObject [
	bytes := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> color [
	^ color
]

{ #category : 'accessing' }
STONTestDomainObject >> color: anObject [
	color := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> created [
	^ created
]

{ #category : 'accessing' }
STONTestDomainObject >> created: anObject [
	created := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> description [
	^ description
]

{ #category : 'accessing' }
STONTestDomainObject >> description: anObject [
	description := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> float [
	^ float
]

{ #category : 'accessing' }
STONTestDomainObject >> float: anObject [
	float := anObject
]

{ #category : 'comparing' }
STONTestDomainObject >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ color hash
		bitXor:
			(modified hash
				bitXor:
					(created hash
						bitXor:
							(description hash
								bitXor: (boolean hash bitXor: (float hash bitXor: (bytes hash bitXor: (integer hash bitXor: tags hash)))))))
]

{ #category : 'initialize-release' }
STONTestDomainObject >> initialize [
  "GemStone DateAndTime uses a float for seconds so serialize/materialize of floats is problematic ... this technique causes a ScaledDecimal to be used which does suffer from Float problems"

  created := modified := DateAndTime fromString: DateAndTime now asString
]

{ #category : 'accessing' }
STONTestDomainObject >> integer [
	^ integer
]

{ #category : 'accessing' }
STONTestDomainObject >> integer: anObject [
	integer := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> modified [
	^ modified
]

{ #category : 'accessing' }
STONTestDomainObject >> modified: anObject [
	modified := anObject
]

{ #category : 'accessing' }
STONTestDomainObject >> tags [
	^ tags
]

{ #category : 'accessing' }
STONTestDomainObject >> tags: anObject [
	tags := anObject
]
