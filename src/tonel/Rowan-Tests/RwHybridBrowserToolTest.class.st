Class {
	#name : 'RwHybridBrowserToolTest',
	#superclass : 'RwBrowserToolTest',
	#category : 'Rowan-Tests'
}

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridClassCreation [

	| byteClass indexableClass normalClass projectName packageNames packageName1 packageName2 |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.

	byteClass := Object
		rwByteSubclass: 'SimpleHybridByte1'
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: byteClass rowanPackageName = packageName1.

	indexableClass := Object
		rwIndexableSubclass: 'SimpleHybridIndexable1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: indexableClass rowanPackageName = packageName1.

	normalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridClassCreationWithClassCreationTemplateA [

	"https://github.com/dalehenrich/Rowan/issues/17"

	"make sure that we actually evaluate the class creation templates"

	| category normalClass projectName packageNames packageName1 packageName2 browserTool template |
	category := 'Category'.
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	browserTool := Rowan projectTools browser.

	template := browserTool
		classCreationTemplateForSubclassOf: 'Object'
		className: 'SimpleHybridNormal1'
		category: packageName1.
	normalClass := template evaluate.
	self assert: normalClass rowanPackageName = packageName1.
	self assert: normalClass category = packageName1.

	template := browserTool
		classCreationTemplateForSubclassOf: 'Object'
		className: 'SimpleHybridNormal1'
		category: category
		packageName: packageName1.
	normalClass := template evaluate.
	self assert: normalClass rowanPackageName = packageName1.
	self assert: normalClass category = category.

	template := browserTool
		classCreationTemplateForClass: normalClass
		hybridBrowser: false.
	normalClass := template evaluate.
	self assert: normalClass rowanPackageName = packageName1.
	self assert: normalClass category = category.

	template := browserTool
		classCreationTemplateForClass: normalClass
		hybridBrowser: true.	" packageName does not equal category, so hyrbridBrowser form cannot be used"
	normalClass := template evaluate.
	self assert: normalClass rowanPackageName = packageName1.
	self assert: normalClass category = category.

	normalClass category: packageName1.	"now we can use hybridBrowser form again"
	template := browserTool
		classCreationTemplateForClass: normalClass
		hybridBrowser: true.
	normalClass := template evaluate.
	self assert: normalClass rowanPackageName = packageName1.
	self assert: normalClass category = packageName1
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridClassCreationWithClassCreationTemplateB [

	"https://github.com/dalehenrich/Rowan/issues/17"

	"make sure that we actually evaluate the class creation templates"

	| category byteClass variableClass projectName packageNames packageName1 packageName2 browserTool template |
	category := 'Category'.
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	browserTool := Rowan projectTools browser.

	template := browserTool
		classCreationTemplateForSubclassOf: 'Object'
		className: 'SimpleHybridByte1'
		type: 'bytes'
		category: packageName1
		packageName: nil.
	byteClass := template evaluate.
	self assert: byteClass rowanPackageName = packageName1.
	self assert: byteClass category = packageName1.

	template := browserTool
		classCreationTemplateForSubclassOf: 'Object'
		className: 'SimpleHybridIndexable1'
		type: 'variable'
		category: category
		packageName: packageName1.
	variableClass := template evaluate.
	self assert: variableClass rowanPackageName = packageName1.
	self assert: variableClass category = category
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridCompileMethod [

	| normalClass projectName packageNames packageName1 packageName2 movedNormalClass fooMethod barMethod normalInstance |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	normalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1.

	fooMethod := normalClass
		rwCompileMethod: 'foo ^''foo'''
		category: '*' , packageName1 asLowercase.
	barMethod := normalClass class
		rwCompileMethod: 'bar ^''bar'''
		category: 'accessing'
		packageName: packageName2.

	self assert: normalClass bar = 'bar'.
	normalInstance := normalClass new.
	self assert: normalInstance foo = 'foo'.

	self assert: fooMethod rowanPackageName = packageName1.
	self assert: barMethod rowanPackageName = packageName2
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridMoveClassToPackage [

	| normalClass projectName packageNames packageName1 packageName2 movedNormalClass |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	normalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1.

	movedNormalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName2
		options: #().
	self assert: movedNormalClass == normalClass.
	self assert: movedNormalClass rowanPackageName = packageName2
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridMoveClassToPackageWithClassModifications [

	| normalClass projectName packageNames packageName1 packageName2 movedNormalClass |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageName2 := 'HybridA-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	normalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1.

	movedNormalClass := Object
		rwSubclass: 'SimpleHybridNormal1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName2
		options: #().
	self assert: movedNormalClass ~= normalClass.
	self assert: movedNormalClass rowanPackageName = packageName2
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridNewClassVersionWithSubclassesA [

	| class subclass projectName packageNames packageName1 newClassVersion newSubclassVersion |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageNames := {packageName1}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	class := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	subclass := class
		rwSubclass: 'SimpleHybridSubclass1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: subclass superClass == class.

	newClassVersion := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	self assert: newClassVersion ~~ class.
	newSubclassVersion := Rowan image objectNamed: subclass name.
	self assert: newSubclassVersion ~~ subclass.
	self assert: newSubclassVersion superClass == newClassVersion
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridNewClassVersionWithSubclassesAndMethodsA [

	| class subclass projectName packageNames packageName1 newClassVersion newSubclassVersion |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageNames := {packageName1}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	class := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	class rwCompileMethod: 'foo ^''foo''' category: '*' , packageName1 asLowercase.
	class class
		rwCompileMethod: 'foo ^''foo'''
		category: '*' , packageName1 asLowercase.

	subclass := class
		rwSubclass: 'SimpleHybridSubclass1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	subclass
		rwCompileMethod: 'foo1 ^''foo'''
		category: '*' , packageName1 asLowercase.
	subclass class
		rwCompileMethod: 'foo1 ^''foo'''
		category: '*' , packageName1 asLowercase.

	self assert: subclass superClass == class.

	newClassVersion := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	self assert: newClassVersion ~~ class.
	newSubclassVersion := Rowan image objectNamed: subclass name.
	self assert: newSubclassVersion ~~ subclass.
	self assert: newSubclassVersion superClass == newClassVersion.
	self assert: newSubclassVersion foo = 'foo'.
	self assert: newSubclassVersion foo1 = 'foo'.
	self assert: newSubclassVersion new foo = 'foo'.
	self assert: newSubclassVersion new foo1 = 'foo'
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridNewClassVersionWithSubclassesAndMethodsB [

	| class subclass projectName packageNames packageName1 newClassVersion newSubclassVersion |
	projectName := 'Hybrid Project B'.
	packageName1 := 'HybridB-Core'.
	packageNames := {packageName1}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	class := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	class rwCompileMethod: 'foo ^''foo''' category: 'accessing'.
	class class rwCompileMethod: 'foo ^''foo''' category: 'accessing'.

	subclass := class
		rwSubclass: 'SimpleHybridSubclass1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	subclass rwCompileMethod: 'foo1 ^''foo''' category: 'accessing'.
	subclass class rwCompileMethod: 'foo1 ^''foo''' category: 'accessing'.

	self assert: subclass superClass == class.

	newClassVersion := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	self assert: newClassVersion ~~ class.
	newSubclassVersion := Rowan image objectNamed: subclass name.
	self assert: newSubclassVersion ~~ subclass.
	self assert: newSubclassVersion superClass == newClassVersion.
	self assert: newSubclassVersion foo = 'foo'.
	self assert: newSubclassVersion foo1 = 'foo'.
	self assert: newSubclassVersion new foo = 'foo'.
	self assert: newSubclassVersion new foo1 = 'foo'
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridNewClassVersionWithSubclassesAndMethodsC [

	| class subclass projectName packageNames packageName1 packageName2 newClassVersion newSubclassVersion |
	projectName := 'Hybrid Project C'.
	packageName1 := 'HybridC-Core'.
	packageName2 := 'HybridC-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	class := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	class rwCompileMethod: 'foo ^''foo''' category: '*' , packageName2 asLowercase.
	class class rwCompileMethod: 'foo ^''foo''' category: 'accessing'.

	subclass := class
		rwSubclass: 'SimpleHybridSubclass1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	subclass rwCompileMethod: 'foo1 ^''foo''' category: 'accessing'.
	subclass class
		rwCompileMethod: 'foo1 ^''foo'''
		category: '*' , packageName2 asLowercase.

	self assert: subclass superClass == class.

	newClassVersion := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	self assert: newClassVersion ~~ class.
	newSubclassVersion := Rowan image objectNamed: subclass name.
	self assert: newSubclassVersion ~~ subclass.
	self assert: newSubclassVersion superClass == newClassVersion.
	self assert: newSubclassVersion foo = 'foo'.
	self assert: newSubclassVersion foo1 = 'foo'.
	self assert: newSubclassVersion new foo = 'foo'.
	self assert: newSubclassVersion new foo1 = 'foo'
]

{ #category : 'tests' }
RwHybridBrowserToolTest >> testHybridNewClassVersionWithSubclassesB [

	| class subclass1 subclass2 subclass3 subclass4 projectName packageNames packageName1 newClassVersion newSubclassVersion1 newSubclassVersion2 newSubclassVersion3 newSubclassVersion4 |
	projectName := 'Hybrid Project A'.
	packageName1 := 'HybridA-Core'.
	packageNames := {packageName1}.
	self
		_loadProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project'.
	class := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	subclass1 := class
		rwSubclass: 'SimpleHybridSubclass1'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: subclass1 superClass == class.

	subclass2 := subclass1
		rwSubclass: 'SimpleHybridSubclass2'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: subclass2 superClass == subclass1.

	subclass3 := subclass2
		rwSubclass: 'SimpleHybridSubclass3'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: subclass3 superClass == subclass2.

	subclass4 := subclass3
		rwSubclass: 'SimpleHybridSubclass4'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: subclass4 superClass == subclass3.

	newClassVersion := Object
		rwSubclass: 'SimpleHybrid1'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().

	self assert: newClassVersion ~~ class.
	newSubclassVersion1 := Rowan image objectNamed: subclass1 name.
	self assert: newSubclassVersion1 ~~ subclass1.
	self assert: newSubclassVersion1 superClass == newClassVersion.

	newSubclassVersion2 := Rowan image objectNamed: subclass2 name.
	self assert: newSubclassVersion2 ~~ subclass2.
	self assert: newSubclassVersion2 superClass == newSubclassVersion1.

	newSubclassVersion3 := Rowan image objectNamed: subclass3 name.
	self assert: newSubclassVersion3 ~~ subclass3.
	self assert: newSubclassVersion3 superClass == newSubclassVersion2.

	newSubclassVersion4 := Rowan image objectNamed: subclass4 name.
	self assert: newSubclassVersion4 ~~ subclass4.
	self assert: newSubclassVersion4 superClass == newSubclassVersion3
]

{ #category : 'tests - packages' }
RwHybridBrowserToolTest >> testHybridPackagePatch [

	"Write project to disk, make a few modifications and then check patch for correctness"

	| normalClass projectName packageNames packageName1 packageName2 fooMethod barMethod normalInstance projectTools bazMethod ivar1Method packageTools patch1 patch2 operations |
	projectName := 'HybridPatchProjectA'.
	packageName1 := 'Hybrid-Patch-Core'.
	packageName2 := 'Hybrid-Patch-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadDiskProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project package patch test'
		format: 'tonel'
		root: '/tmp/rowanHybridPatchProject/'
		repoPath: 'src'.

	normalClass := Object
		rwSubclass: 'SimpleHybridNormalPatch'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1.

	fooMethod := normalClass rwCompileMethod: 'foo ^''foo''' category: 'accessing'.
	barMethod := normalClass class
		rwCompileMethod: 'bar ^''bar'''
		category: '*' , packageName2 asLowercase.

	self assert: normalClass bar = 'bar'.
	normalInstance := normalClass new.
	self assert: normalInstance foo = 'foo'.

	projectTools := Rowan projectTools.
	projectTools spec exportProjectNamed: projectName.
	projectTools write writeProjectNamed: projectName.
	projectTools commit
		commitProjectNamed: projectName
		message: 'Added Simple class and extension methods'.

	normalClass := Object
		rwSubclass: 'SimpleHybridNormalPatch'
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().	"add new instance variable to class"

	normalInstance := normalClass new.

	fooMethod := normalClass
		rwCompileMethod: 'foo "comment" ^''foo'''
		category: 'accessing'.	"change method"
	ivar1Method := normalClass
		rwCompileMethod: 'ivar1 ^ivar1'
		category: 'accessing'.	"add new instance method"
	bazMethod := normalClass class
		rwCompileMethod: 'baz ^''baz'''
		category: '*' , packageName2 asLowercase.	"add new class-side method"
	normalClass class rwRemoveSelector: #'bar'.	"remove existing method"

	self assert: normalInstance foo = 'foo'.
	self assert: normalInstance ivar1 = nil.
	self assert: normalClass baz = 'baz'.
	self should: [ normalClass bar ] raise: MessageNotUnderstood.

	packageTools := Rowan packageTools.
	patch1 := packageTools diff patchForPackageName: packageName1.
	patch2 := packageTools diff patchForPackageName: packageName2.

	operations := patch1 operations.
	self assert: operations size = 3.
	self assert: (operations select: [ :each | each isAddition ]) size = 1.
	self assert: (operations select: [ :each | each isModification ]) size = 2.
	self assert: (operations select: [ :each | each isRemoval ]) size = 0.
	operations
		do: [ :patchOperation | 
			patchOperation isAddition
				ifTrue: [ 
					patchOperation definition class == RwCypressMethodDefinition.
					patchOperation definition source = 'ivar1 ^ivar1' ].
			patchOperation isModification
				ifTrue: [ 
					self
						assert:
							(patchOperation definition class == RwCypressMethodDefinition
								or: [ patchOperation definition class == CypressClassDefinition ]).
					patchOperation definition class == RwCypressMethodDefinition
						ifTrue: [ patchOperation definition source = 'foo "comment" ^''foo''' ].
					patchOperation definition class == CypressClassDefinition
						ifTrue: [ 
							self assert: patchOperation modification className = 'SimpleHybridNormalPatch'.
							self assert: patchOperation obsoletion instVarNames = #().
							self assert: patchOperation modification instVarNames = #('ivar1') ] ].
			patchOperation isRemoval
				ifTrue: [ self assert: false description: 'no removal expected' ] ].

	operations := patch2 operations.
	self assert: operations size = 2.
	self assert: (operations select: [ :each | each isAddition ]) size = 1.
	self assert: (operations select: [ :each | each isModification ]) size = 0.
	self assert: (operations select: [ :each | each isRemoval ]) size = 1.
	operations
		do: [ :patchOperation | 
			patchOperation isAddition
				ifTrue: [ 
					patchOperation definition class == RwCypressMethodDefinition.
					patchOperation definition source = 'baz ^''baz''' ].
			patchOperation isModification
				ifTrue: [ self assert: false description: 'no modification expected' ].
			patchOperation isRemoval
				ifTrue: [ self assert: patchOperation definition class == CypressMethodDefinition ] ]
]

{ #category : 'tests - packages' }
RwHybridBrowserToolTest >> testHybridProjectLoad [

	"Write project to disk, make a few modifications and then reload the project from disk"

	| normalClass projectName packageNames packageName1 packageName2 fooMethod barMethod normalInstance projectTools bazMethod ivar1Method className theLoadedProject theLoadedPackage theLoadedClassOrClassExtension writtenStateValidationBlock |
	projectName := 'HybridPatchProjectA'.
	packageName1 := 'Hybrid-Patch-Core'.
	packageName2 := 'Hybrid-Patch-Extensions'.
	packageNames := {packageName1.
	packageName2}.
	self
		_loadDiskProjectDefinition: projectName
		packageNames: packageNames
		defaultSymbolDictName: self _symbolDictionaryName1
		comment: 'hybrid browser project package patch test'
		format: 'tonel'
		root: '/tmp/rowanHybridPatchProject/'
		repoPath: 'src'.
	className := 'SimpleHybridNormalReload'.

	normalClass := Object
		rwSubclass: className
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().
	self assert: normalClass rowanPackageName = packageName1.

	fooMethod := normalClass rwCompileMethod: 'foo ^''foo''' category: 'accessing'.
	barMethod := normalClass class
		rwCompileMethod: 'bar ^''bar'''
		category: '*' , packageName2 asLowercase.

	self assert: normalClass bar = 'bar'.
	normalInstance := normalClass new.
	self assert: normalInstance foo = 'foo'.

	projectTools := Rowan projectTools.
	projectTools spec exportProjectNamed: projectName.
	projectTools write writeProjectNamed: projectName.
	projectTools commit
		commitProjectNamed: projectName
		message: 'Added Simple class and extension methods'.

	writtenStateValidationBlock := [ 
	theLoadedProject := Rowan image loadedProjectNamed: projectName.	"Traverse the loaded package structure and verify that it matches the original expected structure"

	theLoadedProject
		loadedPackagesDo: [ :loadedProject :loadedPackage | 
			self assert: theLoadedProject == loadedProject.
			theLoadedPackage := loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			self assert: (packageNames includes: loadedPackage name) ]
		loadedClassedDo: [ :loadedProject :loadedPackage :loadedClass | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			theLoadedClassOrClassExtension := loadedClass.

			loadedPackage name = packageName1
				ifTrue: [ 
					self assert: loadedClass name = className.
					self assert: (loadedClass propertyAt: 'instvars') isEmpty ]
				ifFalse: [ self assert: false description: 'No class expected in ' , packageName2 ] ]
		loadedClassExtenstionsDo: [ :loadedProject :loadedPackage :loadedClassExtension | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			theLoadedClassOrClassExtension := loadedClassExtension.

			loadedPackage name = packageName1
				ifTrue: [ 
					self
						assert: false
						description: 'no classes expected in ' , packageName1 printString ].
			loadedPackage name = packageName2
				ifTrue: [ self assert: loadedClassExtension name = className ] ]
		loadedInstanceMethodsDo: [ :loadedProject :loadedPackage :loadedClassOrClassExtension :loadedMethod | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			self assert: theLoadedClassOrClassExtension == loadedClassOrClassExtension.

			loadedPackage name = packageName1
				ifTrue: [ self assert: (#(#'foo') includes: loadedMethod selector) ].
			loadedPackage name = packageName2
				ifTrue: [ 
					self assert: false description: 'no instance methods expected in '.
					packageName2 ] ]
		loadedClassMethodsDo: [ :loadedProject :loadedPackage :loadedClassOrClassExtension :loadedMethod | 
			loadedPackage name = packageName1
				ifTrue: [ 
					self assert: false description: 'no instance methods expected in '.
					packageName1 ].
			loadedPackage name = packageName2
				ifTrue: [ self assert: (#(#'bar') includes: loadedMethod selector) ] ] ].

	writtenStateValidationBlock value.

	normalClass := Object
		rwSubclass: className
		instVarNames: #('ivar1')
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		category: packageName1
		options: #().	"add new instance variable to class"

	normalInstance := normalClass new.

	fooMethod := normalClass
		rwCompileMethod: 'foo "comment" ^''foo'''
		category: 'accessing'.	"change method"
	ivar1Method := normalClass
		rwCompileMethod: 'ivar1 ^ivar1'
		category: 'accessing'.	"add new instance method"
	bazMethod := normalClass class
		rwCompileMethod: 'baz ^''baz'''
		category: '*' , packageName2 asLowercase.	"add new class-side method"
	normalClass class rwRemoveSelector: #'bar'.	"remove existing method"

	self assert: normalInstance foo = 'foo'.
	self assert: normalInstance ivar1 = nil.
	self assert: normalClass baz = 'baz'.
	self should: [ normalClass bar ] raise: MessageNotUnderstood.

	theLoadedProject := Rowan image loadedProjectNamed: projectName.	"Traverse the loaded package structure and verify that it matches the expected structure"

	theLoadedProject
		loadedPackagesDo: [ :loadedProject :loadedPackage | 
			self assert: theLoadedProject == loadedProject.
			theLoadedPackage := loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			self assert: (packageNames includes: loadedPackage name) ]
		loadedClassedDo: [ :loadedProject :loadedPackage :loadedClass | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			theLoadedClassOrClassExtension := loadedClass.

			loadedPackage name = packageName1
				ifTrue: [ 
					self assert: loadedClass name = className.
					self assert: (loadedClass propertyAt: 'instvars') = #('ivar1') ]
				ifFalse: [ self assert: false description: 'No class expected in ' , packageName2 ] ]
		loadedClassExtenstionsDo: [ :loadedProject :loadedPackage :loadedClassExtension | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			theLoadedClassOrClassExtension := loadedClassExtension.

			loadedPackage name = packageName1
				ifTrue: [ 
					self
						assert: false
						description: 'no classes expected in ' , packageName1 printString ].
			loadedPackage name = packageName2
				ifTrue: [ self assert: loadedClassExtension name = className ] ]
		loadedInstanceMethodsDo: [ :loadedProject :loadedPackage :loadedClassOrClassExtension :loadedMethod | 
			self assert: theLoadedProject == loadedProject.
			self assert: theLoadedPackage == loadedPackage.
			self
				assert:
					(Rowan image loadedPackageNamed: loadedPackage name) == loadedPackage.
			self assert: theLoadedClassOrClassExtension == loadedClassOrClassExtension.

			loadedPackage name = packageName1
				ifTrue: [ self assert: (#(#'foo' #'ivar1') includes: loadedMethod selector) ].
			loadedPackage name = packageName2
				ifTrue: [ 
					self assert: false description: 'no instance methods expected in '.
					packageName2 ] ]
		loadedClassMethodsDo: [ :loadedProject :loadedPackage :loadedClassOrClassExtension :loadedMethod | 
			loadedPackage name = packageName1
				ifTrue: [ 
					self assert: false description: 'no instance methods expected in '.
					packageName1 ].
			loadedPackage name = packageName2
				ifTrue: [ self assert: (#(#'baz') includes: loadedMethod selector) ] ].

	projectTools load loadProjectNamed: projectName.	"restore original state of project"

	normalClass := Rowan image objectNamed: className.
	normalInstance := normalClass new.

	self assert: normalClass bar = 'bar'.
	self assert: normalInstance foo = 'foo'.
	self should: [ normalInstance ivar1 ] raise: MessageNotUnderstood.
	self should: [ normalClass baz = 'baz' ] raise: MessageNotUnderstood.

	writtenStateValidationBlock value	"verify that original state is restored"
]