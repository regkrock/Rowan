Class {
	#name : 'RwGsClassExtensionSymbolDictPatch',
	#superclass : 'RwGsClassPatch',
	#instVars : [
		'patchClass'
	],
	#category : 'Rowan-GemStone'
}

{ #category : 'actions' }
RwGsClassExtensionSymbolDictPatch >> installClassExtensionInSystem [

	"The class must already exist.
        Create or update the LoadedClassExtension for the extended class."

	(self projectDefinition
		useSessionMethodsForExtensionsForPackageNamed: self packageName)
		ifTrue: [ 
			(RwGsImage resolveClassNamed: self className)
				ifNil: [ 
					self
						error:
							'The extension class named ' , self className printString , ' cannot be found.' ] ]
		ifFalse: [ 
			self packageSymbolDictionary
				ensureExtensionClassNamed: self className
				existsForPackageNamed: self packageName ]
]