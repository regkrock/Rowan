Extension { #name : 'Object' }

{ #category : '*ston-core' }
Object >> fromSton: stonReader [
  "Decode non-variable classes from a map of their instance variables and values.
	Override to customize and add a matching #toSton: (see implementors)."

  self class isVariable
    ifTrue: [ self subclassResponsibility ]
    ifFalse: [ | instanceVariableNames |
      instanceVariableNames := self class allInstVarNames.
      stonReader
        parseMapDo: [ :instVarName :value | self instVarAt: (instanceVariableNames indexOf: instVarName asSymbol) put: value ] ]

]

{ #category : '*ston-core' }
Object >> isStonReference [
	^ false

]

{ #category : '*ston-core' }
Object >> stonContainSubObjects [
	"Return true if I contain subObjects that should be processed, false otherwise.
	Overwrite when necessary. See also #stonProcessSubObjects:"
	
	^ true

]

{ #category : '*ston-core' }
Object >> stonOn: stonWriter [
	"Encode non-variable classes with a map of their instance variable and values.
	Override to customize and add a matching #fromSton: (see implementors)."

	self class isVariable 
		ifTrue: [
			self subclassResponsibility ]
		ifFalse: [
			stonWriter writeObject: self ]

]

{ #category : '*ston-core' }
Object >> stonShouldWriteNilInstVars [
	"Return true if my instance variables that are nil should be written out, 
	false otherwise. Overwrite when necessary. By default, return false."
	
	^ false

]

{ #category : '*ston-core' }
Object class >> fromSton: stonReader [
	"Create a new instance and delegate decoding to instance side.
	Override only when new instance should be created directly (see implementors). "
	
	^ self new
		fromSton: stonReader;
		yourself

]
