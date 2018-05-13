"
No class-specific documentation for CypPackageSetDefinition, hierarchy is: 
Object
  CypDefinition( properties)
    CypPackageSetDefinition( packages)

"
Class {
	#name : 'RwProjectSetDefinition',
	#superclass : 'RwDefinitionSetDefinition',
	#category : 'Rowan-Definitions'
}

{ #category : 'accessing' }
RwProjectSetDefinition >> addProject: aDefinition [

	self addDefinition: aDefinition
]

{ #category : 'comparing' }
RwProjectSetDefinition >> compareAgainstBase: aDefinition [

	| result |
	result := RwProjectSetModification new.
	self
		compareDictionary: definitions
		againstBaseDictionary: aDefinition definitions
		into: result
		elementClass: RwProjectDefinition.
	^ result
]

{ #category : 'deriving' }
RwProjectSetDefinition >> deriveLoadedThings [

	"extract the loaded projects that correspond to the project defintions held by the receiver"

	^ RwEntitySet
		withAll:
			((self definitionNames
				collect: [ :projectName | Rowan loadedProjectNamed: projectName ifAbsent: [  ] ])
				select: [ :each | each notNil ])
]

{ #category : 'accessing' }
RwProjectSetDefinition >> projectNamed: projectName ifAbsent: absentBlock [

	^ self definitionWithKey: projectName ifAbsent: absentBlock

]

{ #category : 'accessing' }
RwProjectSetDefinition >> projectNames [

	^ self definitionNames
]

{ #category : 'accessing' }
RwProjectSetDefinition >> projects [

	^ self definitions
]