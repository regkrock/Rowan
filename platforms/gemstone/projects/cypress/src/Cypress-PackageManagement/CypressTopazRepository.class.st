"
All Cypress classes are private to GemStone and are likely to be removed in a future release.

This is a ""write-only"" repository.
It could be made readable, to be able to file-in Topaz scripts, but it's not the same thing.

"
Class {
	#name : 'CypressTopazRepository',
	#superclass : 'CypressAbstractFileoutRepository',
	#category : 'Cypress-PackageManagement'
}

{ #category : 'initializing - private' }
CypressTopazRepository >> initializeReaderAndWriterClasses [

	readerClass := CypressDoNothingPackageReader.
	writerClass := CypressTopazFileoutWriter.

]
