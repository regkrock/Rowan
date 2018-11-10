Class {
	#name : 'RwPkgAuditTool',
	#superclass : 'RwAbstractTool',
	#category : 'Rowan-Tools-Core'
}

{ #category : 'other' }
RwPkgAuditTool >> _addAll: aColl to: aDict for: aName [

	aDict at: aName ifAbsentPut: [aColl].

]

{ #category : 'other' }
RwPkgAuditTool >> auditForPackage: loadedPackage [
"audit dirty packages"
	|  res|
	res := KeyValueDictionary new.
	true ifTrue: [
	"(loadedPackage isDirty or: [self checkAll]) ifTrue: ["
		loadedPackage 
				loadedClassesDo: [:aLoadedClass |  (self auditLoadedClass: aLoadedClass) 
					ifNotEmpty: [:aColl | res at: aLoadedClass name put: aColl]]				
				loadedClassExtensionsDo: [:aLoadedClass | (self auditLoadedClassExtenstion: aLoadedClass) 
					ifNotEmpty: [:aColl | res at: aLoadedClass name put: aColl] ] .
	].
	^res
]

{ #category : 'other' }
RwPkgAuditTool >> auditForPackageNamed: packageName [
	
	^self auditForPackage: (Rowan image loadedPackageNamed: packageName).

]

{ #category : 'other' }
RwPkgAuditTool >> auditLoadedClass: aLoadedClass [
"look for methods compiled into class without Rowan API"

	^RwClsAuditTool new auditLoadedClass: aLoadedClass.

]

{ #category : 'other' }
RwPkgAuditTool >> auditLoadedClassExtenstion: aLoadedClass [
"look for methods compiled into class without Rowan API"

	^RwClsExtensionAuditTool new auditLoadedClassExtenstion: aLoadedClass

]

{ #category : 'other' }
RwPkgAuditTool >> checkAll [
"check all packages regardless dirty or not"
	^(SessionTemps current at: #RwDirtyOnly otherwise: false) not

]