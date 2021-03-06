Class {
	#name : 'RwGsClassConstraintsSymDictPatch',
	#superclass : 'RwGsClassPatch',
	#category : 'Rowan-GemStone-Loader'
}

{ #category : 'actions' }
RwGsClassConstraintsSymDictPatch >> addToNewClassesByName: aDictionary [

	"noop"

	
]

{ #category : 'installing' }
RwGsClassConstraintsSymDictPatch >> installPropertiesPatchFor: aPatchSet [

	self installPropertiesPatchFor: aPatchSet registry: self symbolDictionaryRegistry

]

{ #category : 'installing' }
RwGsClassConstraintsSymDictPatch >> installPropertiesPatchFor: aPatchSet registry: aSymbolDictionaryRegistry [

	" update class and update loadedClass with new constraints"

	| className existingClass theConstraints existingConstraintsMap existingVaryingConstraint theConstraintsMap theVaryingConstraint keys 
		existingConstraints instVarNames |
	className := classDefinition key asSymbol.
	existingClass := aPatchSet createdClasses
		at: className
		ifAbsent: [ 
			aPatchSet tempSymbols
				at: className
				ifAbsent: [ self error: 'Cannot find class to update constraints for.' ] ].
	existingConstraintsMap := Dictionary new.
	existingVaryingConstraint := existingClass _varyingConstraint.
	instVarNames := existingClass allInstVarNames.
	existingConstraints := [ existingClass _constraints ] on: Deprecated do: [:ex | ex resume ].
	1 to: existingConstraints size do: [:index |
		existingConstraintsMap at: (instVarNames at: index) put: (existingConstraints at: index ) ].
	theConstraints := self _gemStoneConstraintsFrom:	classDefinition gs_constraints.
	theConstraintsMap := Dictionary new.
	theVaryingConstraint := Object.
	theConstraints do: [:arrayOrVaryingConstraintClass |
		arrayOrVaryingConstraintClass _isArray
			ifTrue: [ theConstraintsMap at: (arrayOrVaryingConstraintClass at: 1) put: (arrayOrVaryingConstraintClass at: 2) ]
			ifFalse: [ theVaryingConstraint := arrayOrVaryingConstraintClass ] ].
	keys := existingConstraintsMap keys copy.
	keys addAll: theConstraintsMap keys.
	keys do: [:key | 
		| existingConstraint theConstraint |
		existingConstraint := existingConstraintsMap at: key ifAbsent: [].
		theConstraint := theConstraintsMap at: key ifAbsent: [].
		existingConstraint == theConstraint
			ifFalse: [ 
				| instVarString |
				instVarString := key asString.
				existingConstraint == nil
					ifTrue: [ 
						"add theConstraint" 
						existingClass _rwInstVar: instVarString constrainTo: theConstraint ]
					ifFalse: [ 
						theConstraint == nil
							ifTrue: [ 
								"remove the constraint" 
								existingClass _rwInstVar: instVarString constrainTo: Object ]
							ifFalse: [
								"change the value of the constraint"
                                existingClass _rwInstVar: instVarString constrainTo: theConstraint ] ] ] ].
	existingVaryingConstraint == theVaryingConstraint
		ifFalse: [
			"change the varying constraint"
			[ existingClass _setVaryingConstraint: theVaryingConstraint] on: Deprecated do: [:ex | ex resume ] ].
	aSymbolDictionaryRegistry updateClassProperties: existingClass implementationClass: RwGsSymbolDictionaryRegistry_Implementation.
]
