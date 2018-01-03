"
RwPackageLoadSpecification new
    specName: 'rowanLoadSpec';
    packageNames:
        #('Cypress-Core' 'Rowan-Core' 'Rowan-GemStone' 'Rowan-Tests' 'Rowan-Tode');
    packageNamesToLoad:
        #('Cypress-Core' 'Rowan-Core' 'Rowan-GemStone' 'Rowan-Tests');
    repositoryUrl:
        'tonel:/export/foos1/users/dhenrich/dev/_home/shared/repos/rowan/CypressReferenceImplementation/tonel/';
    exportToUrl:
        'file:/export/foos1/users/dhenrich/dev/_home/shared/repos/rowan/CypressReferenceImplementation/'
"
Class {
	#name : 'RwPackageLoadSpecification',
	#superclass : 'RwLoadSpecification',
	#instVars : [
		'packageNames',
		'packageNamesToLoad'
	],
	#category : 'Rowan-Tode'
}

{ #category : 'loading' }
RwPackageLoadSpecification >> loadUsingLibrarian: aRwLibrarian [

	aRwLibrarian loadPackageSpecification: self
]

{ #category : 'accessing' }
RwPackageLoadSpecification >> packageNames [

   ^packageNames ifNil: [ packageNames := #() ]

]

{ #category : 'accessing' }
RwPackageLoadSpecification >> packageNames: anObject [

   packageNames := anObject

]

{ #category : 'accessing' }
RwPackageLoadSpecification >> packageNamesToLoad [

   ^packageNamesToLoad ifNil: [ self packageNames ]

]

{ #category : 'accessing' }
RwPackageLoadSpecification >> packageNamesToLoad: anObject [

   packageNamesToLoad := anObject

]

{ #category : 'accessing' }
RwPackageLoadSpecification >> packageOrGroupNamesToLoad: packageOrGroupNames [

   packageNames := packageOrGroupNames

]