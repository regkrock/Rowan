Class {
	#name : 'RowanPackageService',
	#superclass : 'RowanService',
	#instVars : [
		'projectDefinition',
		'packageName',
		'name',
		'isDirty',
		'classes',
		'defaultTemplate',
		'projectName',
		'testClasses',
		'hierarchyServices',
		'selectedClass'
	],
	#category : 'Rowan-Services-Core'
}

{ #category : 'instance creation' }
RowanPackageService class >> forPackageNamed: aName [

	| inst |
	inst := self new.  
	inst name: aName.
	aName isNil ifFalse:[
		inst isDirty. "lazy initialize"].
	inst setDefaultTemplate. 
	inst updateProjectName.
	^inst

]

{ #category : 'comparing' }
RowanPackageService >> = packageService [
	(packageService isKindOf: RowanPackageService) ifFalse:[^false].
	^name = packageService name
]

{ #category : 'testing' }
RowanPackageService >> arePackageAndProjectClean [

	^self rowanDirty not and:[self projectIsDirty not]
]

{ #category : 'rowan' }
RowanPackageService >> changes [
   "diffForPackageName: not implemented yet"
 
   ^ (Rowan packageTools diff diffForPackageName: name) asString

]

{ #category : 'commands' }
RowanPackageService >> classHierarchy [
	| superclassChains levels services hierarchies theClasses toExpand |
	self update. 
	theClasses := classes collect:[:classService | classService classFromName].
	superclassChains := self superclassChainsFor: theClasses. 
	hierarchies := self extendHierarchies: superclassChains. 
	levels := self hierarchiesByLevel: hierarchies.
	services := Dictionary new. 
	toExpand := Set new. 
	self services: services from: levels expand: toExpand.
	hierarchyServices := services reject:[:array | array isEmpty].
	hierarchyServices copy keysAndValuesDo:[:key :value | 
		hierarchyServices at: key put: (value asSet asSortedCollection:[:x :y | x name < y name]) asArray].
	RowanCommandResult addResult: self.
]

{ #category : 'commands' }
RowanPackageService >> compileClass: definitionString [

	| theClass classService packageService |
	theClass := definitionString evaluate.
	classService := RowanClassService forClassNamed: theClass name. 
	RowanCommandResult addResult: classService.
	packageService := RowanPackageService forPackageNamed: classService packageName. 
	packageService update. 
	packageService selectedClass: classService.
	classService selectedPackageServices: (Array with: packageService).
]

{ #category : 'rowan' }
RowanPackageService >> createPackage [
	| projectService default |
	default := RowanProjectService defaultProjectName.
	projectService := RowanProjectService new.
	projectService createProjectNamed: default.  
	(Rowan packageNames includes: name) ifFalse:[
		self browserTool addPackageNamed: name toProjectNamed: default].

]

{ #category : 'rowan' }
RowanPackageService >> createPackageNamed: aString inProject: projName [
	| projectService | 
	name := aString.
	projectService := RowanProjectService new.
	projectDefinition := projectService createProjectNamed: projName.  
	projectDefinition addPackageNamed: name.
	self projectTools load loadProjectDefinition: projectDefinition.
]

{ #category : 'Updating' }
RowanPackageService >> defaultTemplate: newValue [
	defaultTemplate := newValue
]

{ #category : 'rowan' }
RowanPackageService >> definition [

	^(Rowan image loadedPackageNamed: name) asDefinition

]

{ #category : 'rowan' }
RowanPackageService >> deletePackage [

	self browserTool removePackageNamed: name.

]

{ #category : 'commands support' }
RowanPackageService >> extendHierarchies: hierarchies [
	
	"extend the hierarchies by one level
	of subclasses"

	| extendedHierarchies |
	extendedHierarchies := Array new. 
	hierarchies do:[:hierarchy |
		| theClass |
		theClass := hierarchy last. 
		theClass subclasses isEmpty 
			ifTrue:[extendedHierarchies add: hierarchy]
			ifFalse:[
				theClass subclasses do:[:sub |
					extendedHierarchies add: (hierarchy copy add: sub; yourself)
				]]].
	^extendedHierarchies
]

{ #category : 'rowan' }
RowanPackageService >> genericClassCreationTemplate [

	^self browserTool classCreationTemplateForSubclassOf: 'Object' category: name packageName: nil

]

{ #category : 'comparing' }
RowanPackageService >> hash [
	^self name hash
]

{ #category : 'commands support' }
RowanPackageService >> hierarchiesByLevel: hierarchies [

	"Return dictionary of classes by level. 
	Example: 
		hierarchies - #(#(Object Collection Array) #(Object AbstractException Exception))
	Return: 
		#(#nil->#(Object) Object->#(Collection AbstractException) Collection->#(Array) AbstractException->#(Exception)
	"
	| levels |
	levels := hierarchies inject: Dictionary new into:[:dict :chain | 
		1 to: chain size do: [:index | 
			| cls theSuper classSet |
			cls := chain at: index.
			classSet := dict at: cls ifAbsentPut: [Array new].
			index = 1 
		ifTrue:[
			classSet := dict at: #'nil' ifAbsentPut: [Array new]. 
			((dict at: #'nil') includes: cls) ifFalse:[(dict at: #'nil') add: cls].
		]
		ifFalse:[
				theSuper := chain at: index - 1.
				((dict at: theSuper) includes: cls) ifFalse:[(dict at: theSuper) add: cls]
				]].
			dict].
	^levels
]

{ #category : 'Accessing' }
RowanPackageService >> hierarchyServices [

	^hierarchyServices
]

{ #category : 'rowan' }
RowanPackageService >> isDirty [

	^isDirty := self rowanDirty

]

{ #category : 'Updating' }
RowanPackageService >> isDirty: boolean [

	isDirty := boolean
]

{ #category : 'rowan' }
RowanPackageService >> loadedClasses [

	| loadedPackage |
	loadedPackage := Rowan image loadedPackageNamed: name ifAbsent:[^KeyValueDictionary new].
	^loadedPackage loadedClasses
]

{ #category : 'rowan' }
RowanPackageService >> loadedClassExtensions [

	| loadedPackage |
	loadedPackage := Rowan image loadedPackageNamed: name ifAbsent:[^KeyValueDictionary new].
	^loadedPackage loadedClassExtensions
]

{ #category : 'rowan' }
RowanPackageService >> loadedClassHandles [
	| loadedClasses |
	loadedClasses := self loadedClasses collect:[:loadedClass | loadedClass handle].
	loadedClasses addAll: (self loadedClassExtensions collect:[:extension | extension handle]).
	^loadedClasses

]

{ #category : 'rowan' }
RowanPackageService >> loadedClassNames [

	^self loadedClasses collect:[:loadedClass | loadedClass name]

]

{ #category : 'Accessing' }
RowanPackageService >> name [
	^name

]

{ #category : 'Updating' }
RowanPackageService >> name: newValue [
	name := newValue

]

{ #category : 'Accessing' }
RowanPackageService >> packageName [
	^name

]

{ #category : 'Updating' }
RowanPackageService >> packageName: newValue [
	name := newValue

]

{ #category : 'printing' }
RowanPackageService >> printOn: aStream [

	super printOn: aStream. 
	aStream nextPut: $:. 
	aStream nextPutAll: (name ifNil: [nil printString])
]

{ #category : 'Accessing' }
RowanPackageService >> projectDefinition [
	^projectDefinition

]

{ #category : 'Updating' }
RowanPackageService >> projectDefinition: newValue [
	projectDefinition := newValue

]

{ #category : 'testing' }
RowanPackageService >> projectIsDirty [

	^(RowanProjectService new name: projectName) rowanDirty
]

{ #category : 'Accessing' }
RowanPackageService >> projectName [
	^projectName
]

{ #category : 'Updating' }
RowanPackageService >> projectName: newValue [
	projectName := newValue
]

{ #category : 'commands' }
RowanPackageService >> removeClass: classService [

	self removeClassNamed: classService name. 
	self update.
	classService updateType: #removedClass:.
	RowanCommandResult addResult: classService
]

{ #category : 'commands' }
RowanPackageService >> removeClassNamed: className [

	self browserTool removeClassNamed: className.

]

{ #category : 'rowan' }
RowanPackageService >> rowanDirty [

	^(RwPackage newNamed: name) isDirty

]

{ #category : 'other' }
RowanPackageService >> selectedClass [
	
	^selectedClass
]

{ #category : 'Accessing' }
RowanPackageService >> selectedClass: classService [

	selectedClass := classService
]

{ #category : 'perform' }
RowanPackageService >> servicePerform: symbol withArguments: collection [
	| wasClean |
	wasClean := self arePackageAndProjectClean.
	super servicePerform: symbol withArguments: collection.
	wasClean ifTrue:[
		self update. 
		self updateProject]
]

{ #category : 'commands support' }
RowanPackageService >> services: services from: levels expand: toExpand [

	(classes collect:[:svc | svc classFromName]) do:[:aClass |
		toExpand addAll: aClass allSuperclasses].
	levels keysAndValuesDo: [:key :value |
		| newKey service  | 
		newKey := key = #'nil' ifTrue:[#'nil'] ifFalse:[
			service := (RowanClassService minimalForClassNamed: key name).
			(toExpand includes: service classFromName) ifTrue:[service expand: true] ifFalse:[service expand: false].
			service].
		services at: newKey put: (value collect:[:cls | 
				service := (RowanClassService minimalForClassNamed: cls name).
				(toExpand includes: service classFromName) ifTrue:[service expand: true] ifFalse:[service expand: false].
				service
				])]
]

{ #category : 'commands' }
RowanPackageService >> setDefaultTemplate [

	defaultTemplate := self genericClassCreationTemplate.
]

{ #category : 'commands support' }
RowanPackageService >> superclassChainsFor: behaviors [

	^behaviors collect:[:behavior | | supers |
			supers := behavior allSuperclasses. 
			supers add: behavior. 
			supers].
]

{ #category : 'commands' }
RowanPackageService >> testClasses [

	testClasses := Set new. 
	TestCase allSubclasses do:[:testSubclass |
		testSubclass selectors do:[:selector |
			| packageName |
			(selector size >= 4 and:[
			(selector copyFrom: 1 to: 4) asString = 'test']) ifTrue:[
				packageName := (testSubclass compiledMethodAt: selector) rowanPackageName. 
				packageName = name ifTrue:[
					testClasses add: (RowanClassService basicForClassNamed: testSubclass name)]]]]. 
	updateType := #testClasses:. 
	testClasses := testClasses asArray. 
	RowanCommandResult addResult: self.
]

{ #category : 'updates' }
RowanPackageService >> update [
	Rowan image loadedPackageNamed: name ifAbsent: [^self]. 
	classes := (self loadedClassNames keys collect:[:string | RowanClassService minimalForClassNamed: string]) asArray.
	classes addAll: (self loadedClassExtensions keys collect:[:string | 
		| classService | 
		classService := (RowanClassService minimalForClassNamed: string) 
			isExtension: true.
		(Rowan image loadedClassForClass: classService classFromName ifAbsent:[]) 
			ifNotNil:[:cls | classService definedPackageName: cls packageName].
		classService]).
	classes do: [:clsService | clsService packageName: self name]. 
	self isDirty. 
	projectName := (Rowan image loadedPackageNamed: name) projectName.
	RowanCommandResult addResult: self
]

{ #category : 'updates' }
RowanPackageService >> updateProject [
	| projectService |

	projectService := RowanProjectService new name: projectName. 
	projectService update.
	RowanCommandResult addResult: projectService.
]

{ #category : 'updates' }
RowanPackageService >> updateProjectName [

	projectName := (Rowan image loadedPackageNamed: name) projectName.
]
