Class {
	#name : 'RwProjectTest',
	#superclass : 'RwAbstractTest',
	#category : 'Rowan-Tode'
}

{ #category : 'private' }
RwProjectTest >> gsInteractionConfirmationHandler [

	^ GsInteractionHandler new
		defaultBlock: [ :ignored | self assert: false description: 'expected a confirmation' ];
		confirmBlock: [ :interaction | interaction ok ];
		yourself
]

{ #category : 'private' }
RwProjectTest >> gsInteractionInformFailureHandler [

	^ GsInteractionHandler new
		defaultBlock: [ :ignored | self assert: false description: 'unexpected internaction' ];
		informBlock: [ :interaction | self assert: false description: 'unexpected inform' ];
		yourself
]

{ #category : 'private' }
RwProjectTest >> handleConfirmationDuring: aBlock [

	"expect a confirmation"

	aBlock
		on: GsInteractionRequest
		do: [ :ex | 
			ex
				response:
					(ex interaction interactWith: self gsInteractionConfirmationHandler) ]
]

{ #category : 'private' }
RwProjectTest >> handleInformAsFailureDuring: aBlock [

	aBlock
		on: GsInteractionRequest
		do: [ :ex | 
			ex
				response:
					(ex interaction interactWith: self gsInteractionInformFailureHandler) ]
]

{ #category : 'running' }
RwProjectTest >> setUp [

	"Remove the CypressTestData symbol dictionary, if present --- gets persistent and session symbol list"

	| user symList dict index |
	super setUp.
	user := System myUserProfile.
	symList := user symbolList.

	dict := symList objectNamed: self _symbolDictionaryName2.
	dict
		ifNotNil: [ 
			index := symList indexOf: dict.
			index > 0
				ifTrue: [ user removeDictionaryAt: index ] ]
]

{ #category : 'tests' }
RwProjectTest >> testProjectClassExtensions [

	"Build our project in memory without committing to disk until we've created a class with methods, then write to disk."

	| projectName projectSpec projectTools classDefinition packageDefinition1 packageDefinition2 className testClass testInstance classExtensionDefinition |
	projectName := 'Simple'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].

	projectSpec := projectTools spec newPackageSpecNamed: projectName useGit: true.
	projectSpec
		comment:
				'This is a simple project created in memory first, then written to disk.';
		packageNames: #('Simple-Core' 'Simple-Extensions' 'Simple-Tests');
		yourself.
	(projectSpec platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1.

	className := 'Simple'.
	classDefinition := RwClassDefinition
		newForClassNamed: className
		super: 'Object'
		instvars: #('ivar1')
		classinstvars: #(#'civar1')
		classvars: #()
		category: nil
		comment: 'I am a Simple class with extensions'
		pools: #()
		type: 'normal'.
	classDefinition
		addInstanceMethodDefinition:
			(RwMethodDefinition
				newForSelector: #'foo'
				protocol: 'accessing'
				source: 'foo ^ true').

	packageDefinition1 := RwPackageDefinition newNamed: 'Simple-Core'.
	packageDefinition1 addClassDefinition: classDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition1
		specification: projectSpec.

	classExtensionDefinition := RwClassExtensionDefinition
		newForClassNamed: className.
	classExtensionDefinition
		addInstanceMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'ivar1'
						protocol: 'accessing'
						source: 'ivar1 ^ivar1');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'initialize'
						protocol: 'initialization'
						source: 'initialize civar1 := 1.');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'civar1'
						protocol: 'accessing'
						source: 'civar1 ^civar1');
		yourself.

	packageDefinition2 := RwPackageDefinition newNamed: 'Simple-Extensions'.
	packageDefinition2 addClassExtension: classExtensionDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition2
		specification: projectSpec.

	testClass := Rowan globalNamed: className.
	self assert: testClass notNil.
	self assert: testClass civar1 == 1.
	testInstance := testClass new.
	self assert: testInstance ivar1 isNil.

	self
		handleConfirmationDuring: [ 
			projectTools create
				createPackageProjectFor: projectSpec
				format: 'tonel'
				root: '/tmp/rowanSimpleExtensionProject/'
				repoPath: 'src' ].
	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message: 'Added Simple class and extension methods'
]

{ #category : 'tests' }
RwProjectTest >> testProjectClassExtensionsInSeparateSymbolDictionary [

	"This test attempts to add extension methods to a class that is not in the dictionary that the package is being loaded into ... this should actually error out ... all definitions in a package should be applied to a single symbol dictionary ... create separate packages to do cross symbol dictionary updateds ... or possibly use session methods (yet to be determined."

	| projectName1 projectName2 projectSpec1 projectSpec2 projectTools classDefinition packageDefinition1 packageDefinition2 className testClass testInstance classExtensionDefinition |
	projectName1 := 'Simple'.
	projectName2 := 'Simple Extensions'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName1 ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].
	(Rowan projectNamed: projectName2 ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].

	projectSpec1 := projectTools spec
		newPackageSpecNamed: projectName1
		useGit: true.
	projectSpec1
		comment:
				'This is a simple project created in memory first, then written to disk.';
		packageNames: #('Simple-Core' 'Simple-Tests');
		yourself.
	(projectSpec1 platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1.

	className := 'Simple'.
	classDefinition := RwClassDefinition
		newForClassNamed: className
		super: 'Object'
		instvars: #('ivar1')
		classinstvars: #(#'civar1')
		classvars: #()
		category: nil
		comment: 'I am a Simple class with extensions'
		pools: #()
		type: 'normal'.

	packageDefinition1 := RwPackageDefinition newNamed: 'Simple-Core'.
	packageDefinition1 addClassDefinition: classDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition1
		specification: projectSpec1.


	projectSpec2 := projectTools spec
		newPackageSpecNamed: projectName2
		useGit: true.
	projectSpec2
		comment:
				'This is a class extension project created in memory first, then written to disk. Uses a separate symbol dictionary from project 1';
		packageNames: #('Simple-Extensions');
		yourself.
	(projectSpec2 platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName2.

	classExtensionDefinition := RwClassExtensionDefinition
		newForClassNamed: className.
	classExtensionDefinition
		addInstanceMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'ivar1'
						protocol: 'accessing'
						source: 'ivar1 ^ivar1');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'initialize'
						protocol: 'initialization'
						source: 'initialize civar1 := 1.');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'civar1'
						protocol: 'accessing'
						source: 'civar1 ^civar1');
		yourself.

	packageDefinition2 := RwPackageDefinition newNamed: 'Simple-Extensions'.
	packageDefinition2 addClassExtension: classExtensionDefinition.
	self
		should: [ 
			"class extensions need to be made by packages loaded into the symbol dictionary in which the class is defined"
			projectTools load
				loadPackageDefinition: packageDefinition2
				specification: projectSpec2 ]
		raise: Error
]

{ #category : 'tests' }
RwProjectTest >> testProjectClassExtensionsInSeparateSymbolDictionaryTheRightWay [

	"Proper way to add extension methods to a class --- load spec expanded to allow user to specify per package symbol dictionaries ... symbolDictName redefined as defaultSymbolDictName."

	| projectName projectSpec projectTools classDefinition packageDefinition1 packageDefinition2 packageDefinition3 className1 className2 testClass1 testClass2 testInstance1 testInstance2 classExtensionDefinition dictionariesAndSymbols x y |
	projectName := 'Simple'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].

	RwGsImage newOrExistingSymbolDictionaryNamed: self _symbolDictionaryName1.	"ensure that the symbol dictionary exists and has been added the appropriate symbol lists (transient and persistent)"

	projectSpec := projectTools spec newPackageSpecNamed: projectName useGit: true.
	projectSpec
		comment:
				'This is a project created in memory first, then written to disk. There are three packages 21 of which creates classes in a different symbol dictionary.';
		packageNames: #('Simple-Core1' 'Simple-Core2' 'Simple-Extensions1');
		yourself.
	(projectSpec platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1;
		symbolDictName: self _symbolDictionaryName2 forPackageNamed: 'Simple-Core2'.

	className1 := 'Simple1'.
	className2 := 'Simple2'.

	classDefinition := RwClassDefinition
		newForClassNamed: className1
		super: 'Object'
		instvars: #('ivar1')
		classinstvars: #(#'civar1')
		classvars: #()
		category: nil
		comment: 'I am a Simple class with extensions'
		pools: #()
		type: 'normal'.

	packageDefinition1 := RwPackageDefinition newNamed: 'Simple-Core1'.
	packageDefinition1 addClassDefinition: classDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition1
		specification: projectSpec.

	testClass1 := Rowan globalNamed: className1.
	self assert: testClass1 notNil.
	testClass2 := Rowan globalNamed: className2.
	self assert: testClass2 isNil.
	testInstance1 := testClass1 new.
	self should: [ testInstance1 ivar1 ] raise: MessageNotUnderstood.

	dictionariesAndSymbols := GsCurrentSession currentSession symbolList
		dictionariesAndSymbolsOf: testClass1.
	self assert: dictionariesAndSymbols size = 1.
	self
		assert:
			(x := (dictionariesAndSymbols at: 1) at: 1)
				== (y := Rowan globalNamed: self _symbolDictionaryName1).

	classDefinition := RwClassDefinition
		newForClassNamed: className2
		super: 'Object'
		instvars: #('ivar1')
		classinstvars: #(#'civar1')
		classvars: #()
		category: nil
		comment: 'I am a Simple class with extensions'
		pools: #()
		type: 'normal'.

	packageDefinition2 := RwPackageDefinition newNamed: 'Simple-Core2'.
	packageDefinition2 addClassDefinition: classDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition2
		specification: projectSpec.

	testClass2 := Rowan globalNamed: className2.
	self assert: testClass1 notNil.
	testInstance2 := testClass2 new.

	dictionariesAndSymbols := GsCurrentSession currentSession symbolList
		dictionariesAndSymbolsOf: testClass2.
	self assert: dictionariesAndSymbols size = 1.
	self
		assert:
			(x := (dictionariesAndSymbols at: 1) at: 1)
				== (y := Rowan globalNamed: self _symbolDictionaryName2).

	classExtensionDefinition := RwClassExtensionDefinition
		newForClassNamed: className1.
	classExtensionDefinition
		addInstanceMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'ivar1'
						protocol: 'accessing'
						source: 'ivar1 ^ivar1');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'initialize'
						protocol: 'initialization'
						source: 'initialize civar1 := 1.');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'civar1'
						protocol: 'accessing'
						source: 'civar1 ^civar1');
		yourself.

	packageDefinition3 := RwPackageDefinition newNamed: 'Simple-Extensions1'.
	packageDefinition3 addClassExtension: classExtensionDefinition.
	projectTools load
		loadPackageDefinition: packageDefinition3
		specification: projectSpec.

	self assert: testInstance1 civar1 = 1.

	self
		handleConfirmationDuring: [ 
			projectTools create
				createPackageProjectFor: projectSpec
				format: 'tonel'
				root: '/tmp/rowanClassExtensionsProject/'
				repoPath: 'src' ].
	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message:
			'3 packages with extension methods for first package in third package.'
]

{ #category : 'tests' }
RwProjectTest >> testSimpleProject1 [

	"Create project and build disk-based artifacts first, then create create a class and write changes to disk."

	| projectName projectSpec projectTools classDefinition packageSymbolDictionary packageDefinition packageSet |
	projectName := 'Simple'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].
	self
		handleConfirmationDuring: [ 
			projectSpec := projectTools create
				createPackageProject: projectName
				format: 'tonel'
				root: '/tmp/rowanSimpleProject/'
				repoPath: 'src'
				useGit: true ].
	projectSpec
		comment:
				'This is a simple project to demonstrate the smalltalk API used for a project lifecycle';
		packageNames: #('Simple-Core' 'Simple-Tests');
		yourself.
	(projectSpec platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1.
	packageSymbolDictionary := RwGsImage
		newOrExistingSymbolDictionaryNamed: self _symbolDictionaryName1.
	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message: 'Initial commit'.
	self
		handleInformAsFailureDuring: [ projectTools load loadSpecification: projectSpec ].

	classDefinition := RwClassDefinition
		newForClassNamed: 'Simple'
		super: 'Object'
		instvars: #()
		classinstvars: #()
		classvars: #()
		category: nil
		comment: 'I am a Simple class'
		pools: #()
		type: 'normal'.

	packageDefinition := packageSymbolDictionary
		loadedPackageDefinitionNamed: 'Simple-Core'
		ifAbsent: [ self assert: false description: 'expected to find loaded package' ].
	packageDefinition addClassDefinition: classDefinition.

	self
		handleInformAsFailureDuring: [ 
			projectTools load
				loadPackageDefinition: packageDefinition
				specification: projectSpec ].

	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message: 'Added Simple class'
]

{ #category : 'tests' }
RwProjectTest >> testSimpleProject2 [

	"Build our project in memory without committing to disk until we've created a class, then write to disk."

	| projectName projectSpec projectTools classDefinition packageDefinition packageSet |
	projectName := 'Simple'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].

	projectSpec := projectTools spec newPackageSpecNamed: projectName useGit: true.
	projectSpec
		comment:
				'This is a simple project created in memory first, then written to disk.';
		packageNames: #('Simple-Core' 'Simple-Tests');
		yourself.
	(projectSpec platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1.

	classDefinition := RwClassDefinition
		newForClassNamed: 'Simple2'
		super: 'Object'
		instvars: #()
		classinstvars: #()
		classvars: #()
		category: nil
		comment: 'I am a Simple2 class'
		pools: #()
		type: 'normal'.

	packageDefinition := RwPackageDefinition newNamed: 'Simple-Core'.
	packageDefinition addClassDefinition: classDefinition.

	projectTools load
		loadPackageDefinition: packageDefinition
		specification: projectSpec.

	self
		handleConfirmationDuring: [ 
			projectTools create
				createPackageProjectFor: projectSpec
				format: 'tonel'
				root: '/tmp/rowanSimpleProject2/'
				repoPath: 'src' ].
	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message: 'Added Simple class'
]

{ #category : 'tests' }
RwProjectTest >> testSimpleProject3 [

	"Build our project in memory without committing to disk until we've created a class with methods, then write to disk."

	| projectName projectSpec projectTools classDefinition packageDefinition packageSet className testClass testInstance |
	projectName := 'Simple'.
	projectTools := Rowan projectTools.
	(Rowan projectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :spec | projectTools unregister unregisterSpecification: spec ].

	projectSpec := projectTools spec newPackageSpecNamed: projectName useGit: true.
	projectSpec
		comment:
				'This is a simple project created in memory first, then written to disk.';
		packageNames: #('Simple-Core' 'Simple-Tests');
		yourself.
	(projectSpec platformSpec at: 'gemstone')
		defaultSymbolDictName: self _symbolDictionaryName1.

	className := 'Simple3'.
	classDefinition := RwClassDefinition
		newForClassNamed: className
		super: 'Object'
		instvars: #('ivar1')
		classinstvars: #(#'civar1')
		classvars: #()
		category: nil
		comment: 'I am a Simple3 class'
		pools: #()
		type: 'normal'.

	classDefinition
		addInstanceMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'ivar1'
						protocol: 'accessing'
						source: 'ivar1 ^ivar1');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'initialize'
						protocol: 'initialization'
						source: 'initialize civar1 := 1.');
		addClassMethodDefinition:
				(RwMethodDefinition
						newForSelector: #'civar1'
						protocol: 'accessing'
						source: 'civar1 ^civar1');
		yourself.

	packageDefinition := RwPackageDefinition newNamed: 'Simple-Core'.
	packageDefinition addClassDefinition: classDefinition.

	projectTools load
		loadPackageDefinition: packageDefinition
		specification: projectSpec.

	testClass := Rowan globalNamed: className.
	self assert: testClass notNil.
	self assert: testClass civar1 == 1.
	testInstance := testClass new.
	self assert: testInstance ivar1 isNil.

	self
		handleConfirmationDuring: [ 
			projectTools create
				createPackageProjectFor: projectSpec
				format: 'tonel'
				root: '/tmp/rowanSimpleProject3/'
				repoPath: 'src' ].
	projectTools spec exportSpecification: projectSpec.
	projectTools write writePackagesForSpecification: projectSpec.
	projectTools commit
		commitPackagesForSpecification: projectSpec
		message: 'Added Simple3 class and methods'
]