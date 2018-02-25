"
Abstract. A patch is a single operation to be performed on a GemStone image (repository).
"
Class {
	#name : 'RwGsPatch',
	#superclass : 'Object',
	#instVars : [
		'packageDefinition',
		'projectDefinition'
	],
	#category : 'Rowan-GemStone'
}

{ #category : 'packages' }
RwGsPatch >> markNotDirtyPackageNamed: packageName [

	| loadedPackage source |
	source := Rowan configuration packageInfoSource.
	loadedPackage := source == #'SymbolDictionary'
		ifTrue: [ self packageSymbolDictionary loadedPackageNamed: packageName ifAbsent: [  ] ]
		ifFalse: [ Rowan loadedPackageNamed: packageName ifAbsent: [  ] ].
	loadedPackage
		ifNil: [ self error: 'Internal error -- attempt to manipulate nonexistent package.' ].
	loadedPackage markNotDirty
]

{ #category : 'accessing' }
RwGsPatch >> packageDefinition [
	^packageDefinition

]

{ #category : 'accessing' }
RwGsPatch >> packageDefinition: newValue [
	packageDefinition := newValue

]

{ #category : 'accessing' }
RwGsPatch >> packageName [

	^packageDefinition key
]

{ #category : 'accessing' }
RwGsPatch >> packageSymbolDictionary [

	| symDictName symDict |
	symDictName := self projectDefinition
		symbolDictNameForPackageNamed: self packageName.
	symDict := RwGsImage objectNamed: symDictName asSymbol.
	(symDict isKindOf: RwGsPackageSymbolDictionary)
		ifTrue: [ ^ symDict ].
	^ RwGsImage newOrExistingSymbolDictionaryNamed: 'UnmanagedPackages'
]

{ #category : 'accessing' }
RwGsPatch >> projectDefinition [

	^ projectDefinition ifNil: [ RwUnmanagedProjectDefinition new ]
]

{ #category : 'accessing' }
RwGsPatch >> projectDefinition: newValue [
	projectDefinition := newValue

]

{ #category : 'accessing' }
RwGsPatch >> projectName [

	^projectDefinition key
]

{ #category : 'utility' }
RwGsPatch >> resolveName: aName [

	"Answer a SymbolAssociation for the given name."

	^ RwGsImage resolveName: aName
]