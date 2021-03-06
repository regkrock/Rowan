Extension { #name : 'CypressClassStructure' }

{ #category : '*Cypress-MesssageDigest' }
CypressClassStructure >> addToDigest: aMessageDigestStream [

	aMessageDigestStream
		tab;
		tab;
		nextPutAll: self class name;
		cr;
		tab;
		tab;
		tab;
		nextPutAll: 'extension:';
		nextPutAll: self isClassExtension printString;
		cr;
		tab;
		tab;
		tab;
		nextPutAll: 'comment:';
		nextPutAll: self comment;
		cr;
		tab;
		tab;
		tab;
		nextPutAll: 'properties:';
		cr;
		tab;
		tab;
		tab;
		tab.
	self properties _writeCypressJsonOn: aMessageDigestStream indent: 4.
	aMessageDigestStream
		cr;
		tab;
		tab;
		tab;
		nextPutAll: 'class methods:';
		cr.
	(self classMethods asSortedCollection: 
			[:a :b |
			(a isMetaclass printString , a selector)
				< (b isMetaclass printString , b selector)])
		do: [:each | each addToDigest: aMessageDigestStream].
	aMessageDigestStream
		tab;
		tab;
		tab;
		nextPutAll: 'instance methods:';
		cr.
	(self instanceMethods asSortedCollection: 
			[:a :b |
			(a isMetaclass printString , a selector)
				< (b isMetaclass printString , b selector)])
		do: [:each | each addToDigest: aMessageDigestStream]

]

{ #category : '*Cypress-MesssageDigest' }
CypressClassStructure >> isSkeleton [

	^instanceMethods isNil
		and: [classMethods isNil
		and: [comment isNil
		and: [isClassExtension isNil]]]
]
