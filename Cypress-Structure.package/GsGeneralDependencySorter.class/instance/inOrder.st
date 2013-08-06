"
notice: This work is protected by copyright. All rights reserved.
category: sorting
"
inOrder

	| sorted |
	sorted := OrderedCollection new.
	self mapCandidatesIntoGraphs.
	self determineGraphRoots
		do: [:each | self transcribeGraph: each into: sorted].
	^sorted.