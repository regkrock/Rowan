Class {
	#name : 'RwGsLoadedSymbolDictClass',
	#superclass : 'RwLoadedClass',
	#category : 'Rowan-GemStone'
}

{ #category : 'instance creation' }
RwGsLoadedSymbolDictClass class >> newForClass: aClass [

	^self new initializeForClass: aClass
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> handleClassDeletion [

	"The class to which I refer has been deleted, so I must unregister myself.
	Normally, I will have a loadedPackage, but if something interrupted my initialization it might be nil."

	loadedPackage ifNotNil: [ loadedPackage removeLoadedClass: self ]
]

{ #category : 'initialization' }
RwGsLoadedSymbolDictClass >> initialize [

	super initialize.
	loadedInstanceMethods := KeyValueDictionary new.
	loadedClassMethods := KeyValueDictionary new
]

{ #category : 'initialization' }
RwGsLoadedSymbolDictClass >> initializeForClass: aClass [

	self initialize.
	self initializeForName: aClass name asString.
	handle := aClass
]

{ #category : 'initialization' }
RwGsLoadedSymbolDictClass >> initializeForName: aClassName [

	super initializeForName: aClassName.
	properties at: 'name' put: aClassName
]

{ #category : 'accessing' }
RwGsLoadedSymbolDictClass >> key [
	"Answer some token that will uniquely identify me relative to any other LoadedClass in the same package."

	^name
]

{ #category : 'removing' }
RwGsLoadedSymbolDictClass >> removeFromLoaded [

	loadedInstanceMethods
		valuesDo: [ :loadedInstanceMethod | 
			self removeLoadedInstanceMethod: loadedInstanceMethod.
			loadedInstanceMethod unregisterYourself ].
	loadedClassMethods
		valuesDo: [ :loadedClassMethod | 
			self removeLoadedClassMethod: loadedClassMethod.
			loadedClassMethod unregisterYourself ].
	self handleClassDeletion
]

{ #category : 'methods' }
RwGsLoadedSymbolDictClass >> removeLoadedClassMethod: aLoadedMethod [

	self markPackageDirty.
	loadedClassMethods removeKey: aLoadedMethod key
		ifAbsent: [self error: 'Method not present in loadedClass']
]

{ #category : 'methods' }
RwGsLoadedSymbolDictClass >> removeLoadedInstanceMethod: aLoadedMethod [

	self markPackageDirty.
	loadedInstanceMethods removeKey: aLoadedMethod key
		ifAbsent: [self error: 'Method not present in loadedClass']
]

{ #category : 'private' }
RwGsLoadedSymbolDictClass >> symbolDictionaryName: aName [

	self propertyAt: 'gs_SymbolDictionary' put: aName asString
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateCategoryFromClass [

	| propertyName oldValue newValue absentToken |
	propertyName := 'category'.
	absentToken := self absentToken.
	oldValue := self propertyAt: propertyName.
	newValue := handle category ifNil: [absentToken].
	(newValue ~~ absentToken and: [newValue isEmpty])
		ifTrue: [newValue := absentToken].

	"Absent token must be compared by identity, because a comment of '<absent>' would be equal to no comment."
	(oldValue == absentToken | (newValue == absentToken)
		ifTrue: [oldValue == newValue]
		ifFalse: [oldValue = newValue])
			ifFalse: 
				[newValue == absentToken
					ifTrue: [self removeProperty: propertyName]
					ifFalse: [self propertyAt: propertyName put: newValue]]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateClassInstvarNamesFromClass [
	"Order of instvars does not matter to Cypress (at least not in GemStone) so we keep the instvar names sorted."

	| propertyName oldNames newNames |
	propertyName := 'classinstvars'.
	oldNames := self propertyAt: propertyName.
	newNames := handle class instVarNames collect: [:each | each asString].
	oldNames = newNames ifFalse: [self propertyAt: propertyName put: newNames]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateClassNameFromClass [

	| oldName newName |
	oldName := name.
	newName := handle name asString.
	oldName = newName
		ifFalse: 
			[self name: newName.
			self propertyAt: 'name' put: name]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateClassTypeFromClass [
	"For GemStone, the valid values are:
	bytes
	variable
	normal for non-indexable pointer object"

	"Must be in-synch with RwGsClassCreationPatch>>basicCreateClassFor:"

	| propertyName oldValue newValue changed |
	propertyName := 'type'.
	oldValue := self propertyAt: propertyName.
	newValue := handle isBytesOrSpecial
				ifTrue: [handle isBytes ifTrue: ['bytes'] ifFalse: ['immediate']]
				ifFalse: 
					[handle isNsc
						ifTrue: [ 'normal' ]
						ifFalse:  [
							handle isVariable
								ifTrue: ['variable']
								ifFalse: [ 'normal'] ] ].

	oldValue = newValue
		ifFalse: 
			[ self propertyAt: propertyName put: newValue ]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateClassVariableNamesFromClass [
	"Order of variable names does not matter to Cypress (at least not for GemStone) so we keep the names sorted."

	| propertyName oldNames newNames |
	propertyName := 'classvars'.
	oldNames := self propertyAt: propertyName.
	newNames := (handle classVarNames collect: [:each | each asString])
				asSortedCollection asArray.
	oldNames = newNames ifFalse: [self propertyAt: propertyName put: newNames]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateCommentFromClass [

	| propertyName oldValue newValue absentToken |
	propertyName := 'comment'.
	absentToken := self absentToken.
	oldValue := self propertyAt: propertyName.
	newValue := (handle _extraDictAt: #comment) ifNil: [absentToken].
	(newValue ~~ absentToken and: [newValue isEmpty])
		ifTrue: [newValue := absentToken].

	"Absent token must be compared by identity, because a comment of '<absent>' would be equal to no comment."
	(oldValue == absentToken | (newValue == absentToken)
		ifTrue: [oldValue == newValue]
		ifFalse: [oldValue = newValue])
			ifFalse: 
				[newValue == absentToken
					ifTrue: [self removeProperty: propertyName]
					ifFalse: [self propertyAt: propertyName put: newValue]]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateInstvarNamesFromClass [
	"Order of instvars does not matter to Cypress (at least not in GemStone) so we keep the instvar names sorted."

	| propertyName oldNames newNames |
	propertyName := 'instvars'.
	oldNames := self propertyAt: propertyName.
	newNames := handle instVarNames collect: [:each | each asString].
	oldNames = newNames ifFalse: [self propertyAt: propertyName put: newNames]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateOptionsFromClass [
	"Options are GemStone-specific. If the class has no options, the property is absent.
	Otherwise, the property is a sorted array of strings. The valid values are:

	dbTransient
	disallowGciStore
	instancesInvariant
	instancesNonPersistent
	modifiable
	subclassesDisallowed
	traverseByCallback

	Not all combinations are legal, but we don't have to worry about that here, since we're getting the values
	from the image, and the image is trusted to only have valid values."

	| propertyName oldValue newValue changed |
	propertyName := 'gs_options'.
	oldValue := self propertyAt: propertyName.
	newValue := (handle _optionsArray collect: [:option | option asString])
				asSortedCollection asArray.
	newValue isEmpty ifTrue: [newValue := self absentToken].

	"Since the absent token is not equal to any other valid value, we can skip the identity check in this case."
	oldValue = newValue
		ifFalse: 
			[newValue == self absentToken
				ifTrue: [self removeProperty: propertyName]
				ifFalse: [self propertyAt: propertyName put: newValue]]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updatePoolDictionaryNamesFromClass [
	"Order of pool dictionaries *does* matter in GemStone, so we keep the names in the order given in the image."

	| propertyName oldNames newNames |
	propertyName := 'pools'.
	oldNames := self propertyAt: propertyName.
	newNames := (handle sharedPools collect: [ :each | each name asString ])
		asArray.
	oldNames = newNames
		ifFalse: [ self propertyAt: propertyName put: newNames ]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updatePropertiesFromClassFor: aSymbolDictionary [

	"Update my properties from the class. Leave unknown properties alone, they may apply to another platform."

	self
		updateSymbolDictionaryFromClassFor: aSymbolDictionary;
		updateClassNameFromClass;
		updateSuperclassNameFromClass;
		updateInstvarNamesFromClass;
		updateClassInstvarNamesFromClass;
		updateClassVariableNamesFromClass;
		updatePoolDictionaryNamesFromClass;
		updateClassTypeFromClass;
		updateOptionsFromClass;
		updateCommentFromClass;
		updateCategoryFromClass
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateSuperclassNameFromClass [
  | oldName newName |
  oldName := self propertyAt: 'superclass'.
  newName := handle superclass
    ifNil: [ 'nil' ]
    ifNotNil: [ :super | super name asString ].
  oldName = newName
    ifFalse: [ self propertyAt: 'superclass' put: newName ]
]

{ #category : 'private-updating' }
RwGsLoadedSymbolDictClass >> updateSymbolDictionaryFromClassFor: aSymbolDictionary [

	| newName oldName |
	newName := aSymbolDictionary name.
	oldName := self propertyAt: 'SymbolDictionary'.
	oldName = newName
		ifFalse: [ self symbolDictionaryName: newName ]
]