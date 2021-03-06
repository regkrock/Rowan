"
RowanBrowserService handles services that fall outside
the scope of other services.
"
Class {
	#name : 'RowanBrowserService',
	#superclass : 'RowanService',
	#instVars : [
		'projects',
		'removedMethods',
		'allClasses',
		'hierarchyServices',
		'testPackages',
		'testCount'
	],
	#category : 'Rowan-Services-Core'
}

{ #category : 'commands' }
RowanBrowserService >> allClasses [

	allClasses := SortedCollection sortBlock: [:x :y | x name < y name].
	allClasses addAll: (organizer classes collect:[:class | 
			| service |
			service := RowanClassService new name: class name. 
			service packageName: class rowanPackageName.
			service projectName: class rowanProjectName.
			service]
			).
	allClasses := allClasses asArray. 
	updateType := #classes. "#classes not used at the moment so no updates will be done"
	RowanCommandResult addResult: self
]

{ #category : 'commands' }
RowanBrowserService >> defaultClassHierarchy [
	hierarchyServices := Dictionary new.   
	organizer hierarchy keysAndValuesDo: [:key :value |
		| classService |
		classService := key == #nil ifTrue:[#nil] ifFalse: [RowanClassService basicForClassNamed: key name].
		hierarchyServices at: classService put: (value collect:[:cls | RowanClassService basicForClassNamed: cls name]) asArray.
	].
	updateType := #classHierarchyUpdate:browser:. 
	RowanCommandResult addResult: self.
]

{ #category : 'commands' }
RowanBrowserService >> packagesWithTests [

	testPackages := Set new. 
	testCount := 0. 
	TestCase allSubclasses do:[:testSubclass |
		testSubclass selectors do:[:selector |
			| packageName |
			(selector size >= 4 and:[
			(selector copyFrom: 1 to: 4) asString = 'test']) ifTrue:[
				packageName := (testSubclass compiledMethodAt: selector) rowanPackageName. 
				packageName = Rowan unpackagedName ifFalse:[
					testCount := testCount + 1. 
					testPackages add: (RowanPackageService forPackageNamed: packageName)]]]]. 
	updateType := #testPackages:. 
	testPackages := testPackages asArray. 
	RowanCommandResult addResult: self.
]

{ #category : 'commands' }
RowanBrowserService >> reloadProjects: projectServices [

	projectServices do:[:projectService |
		projectService reloadProject]
]

{ #category : 'commands' }
RowanBrowserService >> removeMethods: methodServices [

	| notRemoved |
	notRemoved := Array new. 
	removedMethods := Array new. 
	methodServices do: [:methodService |
		| classService |
		classService := RowanClassService forClassNamed: methodService className. 
		classService meta: methodService meta. 
		classService removeSelector: methodService selector ifAbsent:[notRemoved add: methodService selector].
		classService updatePackageProject.
		removedMethods add: methodService].
	notRemoved isEmpty ifFalse:[
		self error: 'These selectors were not removed - ', notRemoved printString].
	updateType := #methodsRemoved:. 
	RowanCommandResult addResult: self.
]

{ #category : 'commands' }
RowanBrowserService >> unloadProjectsNamed: array [
	array do:[:projectName |
		Rowan projectTools delete deleteProjectNamed: projectName]. 
	self updateProjects
]

{ #category : 'update' }
RowanBrowserService >> update [

	self updateProjects
]

{ #category : 'commands' }
RowanBrowserService >> updateProjects [
	| sortedProjects | 
	sortedProjects := SortedCollection sortBlock: [:a :b | a name < b name]. 
	sortedProjects addAll:  Rowan image loadedProjects.
	projects := sortedProjects collect:[:project | RowanProjectService newNamed: project name].
	updateType := #projectsUpdate:.
	RowanCommandResult addResult: self
]
