Class {
	#name : 'RwGsMethodDeletionExtensionSymbolDictPatch',
	#superclass : 'RwGsMethodDeletionSymbolDictPatch',
	#instVars : [
		'extendedClassName'
	],
	#category : 'Rowan-GemStone-Loader'
}

{ #category : 'accessing' }
RwGsMethodDeletionExtensionSymbolDictPatch >> className [

	^ self extendedClassName
]

{ #category : 'accessing' }
RwGsMethodDeletionExtensionSymbolDictPatch >> extendedClassName [

   ^extendedClassName

]

{ #category : 'accessing' }
RwGsMethodDeletionExtensionSymbolDictPatch >> extendedClassName: anObject [

	extendedClassName := anObject
]

{ #category : 'private' }
RwGsMethodDeletionExtensionSymbolDictPatch >> primeBehaviorNewClasses: createdClasses andExistingClasses: tempSymbols [

	| className class |
	className := extendedClassName asSymbol.
	class := createdClasses
		at: className
		ifAbsent: [ 
			tempSymbols
				at: className
				ifAbsent: [ 
					"class is being deleted ... we're done"
					^ self] ].
	behavior := isMeta
		ifTrue: [ class class ]
		ifFalse: [ class ]
]
