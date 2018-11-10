Class {
	#name : 'RwClsExtensionAuditTool',
	#superclass : 'RwClsAuditTool',
	#category : 'Rowan-Tools-Core'
}

{ #category : 'other' }
RwClsExtensionAuditTool >> _auditCategory: anExtentionCategory forBehavior: aClassOrMeta loadedClass: aLoadedClassExtension [
"if we have loaded methods but no compiled methods add error to result"
| res |
	res := super _auditCategory: anExtentionCategory forBehavior: aClassOrMeta loadedClass: aLoadedClassExtension.
	aClassOrMeta isMeta 
		ifTrue: [
			(aLoadedClassExtension loadedClassMethods notEmpty and: [(aClassOrMeta selectorsIn: anExtentionCategory) isEmpty])
				ifTrue: [ self errorLog: res  add: ((anExtentionCategory asString -> 'expected class methods in the category are missing'))   ].
	] 	ifFalse: [
			(aLoadedClassExtension loadedInstanceMethods notEmpty and: [(aClassOrMeta selectorsIn: anExtentionCategory) isEmpty])
				ifTrue: [ self errorLog: res  add: (anExtentionCategory asString -> ('expected instances methods in the category are missing'))   ].
	].
	^res

]

{ #category : 'other' }
RwClsExtensionAuditTool >> auditLoadedClassExtenstion: aLoadedClassExtension [
"look for methods compiled into class without Rowan API"
| res   extensionCategoryName|

	res := StringKeyValueDictionary new.
	extensionCategoryName := aLoadedClassExtension loadedPackage asExtensionName.
	(Rowan globalNamed: aLoadedClassExtension name) 
		ifNil: [self errorLog: res  add: aLoadedClassExtension name -> 'Matching compiled class does not exists '] 
		ifNotNil: [:aBehavior | 
			
false ifTrue: [ 
			self errorLog: res addAll:  ((aBehavior includesCategory: extensionCategoryName)
				ifTrue: [(self _auditCategory: extensionCategoryName forBehavior: aBehavior loadedClass: aLoadedClassExtension)]
				ifFalse: [
					(aBehavior class includesCategory: extensionCategoryName)
						ifTrue: [(self _auditCategory: extensionCategoryName forBehavior: aBehavior class loadedClass: aLoadedClassExtension)]
						ifFalse: [ { extensionCategoryName -> ('Missing extension category in class  ', aBehavior name printString)} ]
			]).
].

			
			aLoadedClassExtension 
				loadedInstanceMethodsDo: [:loadedProject :loadedPackage :loadedClass :aLoadedMethod | 
					(self _auditLoadedInstanceMethod: aLoadedMethod forBehavior: aBehavior loadedClass: loadedClass) ifNotNil: [:x | self errorLog: res add: x]
				] 
				loadedClassMethodsDo: [:loadedProject :loadedPackage :loadedClass :aLoadedMethod |
					(self _auditLoadedClassMethod: aLoadedMethod forBehavior: aBehavior class loadedClass: loadedClass) ifNotNil: [:x | self errorLog: res add: x]
				]
		].
		^res
]