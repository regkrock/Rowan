Class {
	#name : 'RwAdoptToolApiTest',
	#superclass : 'RwBrowserToolTest',
	#category : 'Rowan-Tests'
}

{ #category : 'tests' }
RwAdoptToolApiTest >> testAdoptClass [
	| projectName packageNames className packageName theClass symDict symDictName instanceMethod classMethod symbolList |
	projectName := 'AdoptProject'.
	packageName := 'Adopt-Core'.
	packageNames := {packageName}.
	symDictName := self _symbolDictionaryName2.
	className := 'AdoptedClass'.
	symbolList := Rowan image symbolList.

	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: symDictName
		comment: 'project for testing package adopt api'.

	symDict := Rowan globalNamed: symDictName.

	"Use non-Rowan api to create class and methods"
	theClass := Object subclass: className
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().

	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.
	classMethod := theClass class
		compileMethod: 'bar ^''bar'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	self assert: theClass rowanProjectName = Rowan unpackagedName.
	self assert: instanceMethod rowanProjectName = Rowan unpackagedName.
	self assert: classMethod rowanProjectName = Rowan unpackagedName.

	Rowan packageTools adopt 
		adoptClassNamed: className 
		intoPackageNamed: packageName.

	self assert: theClass rowanProjectName = projectName.
	self assert: instanceMethod rowanProjectName = projectName.
	self assert: classMethod rowanProjectName = projectName.

]

{ #category : 'tests' }
RwAdoptToolApiTest >> testAdoptMethod [
	| projectName packageNames className packageName theClass symDict symDictName instanceMethod classMethod symbolList |
	projectName := 'AdoptProject'.
	packageName := 'Adopt-Core'.
	packageNames := {packageName}.
	symDictName := self _symbolDictionaryName2.
	className := 'AdoptedClass'.
	symbolList := Rowan image symbolList.

	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: symDictName
		comment: 'project for testing package adopt api'.

	symDict := Rowan globalNamed: symDictName.

	"Use non-Rowan api to create class and methods"
	theClass := Object subclass: className
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().

	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.
	classMethod := theClass class
		compileMethod: 'bar ^''bar'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	self assert: theClass rowanProjectName = Rowan unpackagedName.
	self assert: instanceMethod rowanProjectName = Rowan unpackagedName.
	self assert: classMethod rowanProjectName = Rowan unpackagedName.

	Rowan packageTools adopt 
		adoptMethod: #foo 
			protocol: '*', packageName 
			inClassNamed: className  
			isMeta: false 
			intoPackageNamed: packageName;
		adoptMethod: #bar 
			protocol: '*', packageName 
			inClassNamed: className  
			isMeta: true 
			intoPackageNamed: packageName;
		yourself.

	self assert: theClass rowanProjectName = Rowan unpackagedName.
	self assert: instanceMethod rowanProjectName = projectName.
	self assert: classMethod rowanProjectName = projectName.

]