Class {
	#name : 'GsMultiLineTextInteraction',
	#superclass : 'GsTextInteraction',
	#category : 'GemStone-Interactions-Core'
}

{ #category : 'interacting' }
GsMultiLineTextInteraction >> interactWith: anObject [
  "opportunity for double dispatch:

     interactWithChoice:
     interactWithConfirm:
     interactWithInform:
     interactWithMultiLineText:
     interactWithText:
  "

  ^ anObject interactWithMultiLineText: self
]
