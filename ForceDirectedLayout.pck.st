'From Cuis 5.0 of 7 November 2016 [latest update: #3397] on 9 October 2018 at 6:31:59 pm'!
'Description Layout a graph by assigning vertices magnetic repulsion forces, and edges spring attraction forces. '!
!provides: 'ForceDirectedLayout' 1 0!
SystemOrganization addCategory: #ForceDirectedLayout!


!classDefinition: #ForceDirectedLayoutWindow category: #ForceDirectedLayout!
SystemWindow subclass: #ForceDirectedLayoutWindow
	instanceVariableNames: 'magnetSpace'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ForceDirectedLayout'!
!classDefinition: 'ForceDirectedLayoutWindow class' category: #ForceDirectedLayout!
ForceDirectedLayoutWindow class
	instanceVariableNames: ''!

!classDefinition: #ForceDirectedLayoutSystem category: #ForceDirectedLayout!
Object subclass: #ForceDirectedLayoutSystem
	instanceVariableNames: 'magnets springs errorTolerance initialTotalEnergy totalEnergy'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ForceDirectedLayout'!
!classDefinition: 'ForceDirectedLayoutSystem class' category: #ForceDirectedLayout!
ForceDirectedLayoutSystem class
	instanceVariableNames: ''!

!classDefinition: #Magnet category: #ForceDirectedLayout!
Object subclass: #Magnet
	instanceVariableNames: 'position force charge searchDirection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ForceDirectedLayout'!
!classDefinition: 'Magnet class' category: #ForceDirectedLayout!
Magnet class
	instanceVariableNames: ''!

!classDefinition: #Spring category: #ForceDirectedLayout!
Object subclass: #Spring
	instanceVariableNames: 'strength aParticle anAdjacentParticle'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ForceDirectedLayout'!
!classDefinition: 'Spring class' category: #ForceDirectedLayout!
Spring class
	instanceVariableNames: ''!


!ForceDirectedLayoutWindow methodsFor: 'stepping' stamp: 'DF 10/9/2018 18:27:10'!
stepAt: millisecondSinceLast
	magnetSpace submorphsDo: [:each | each stepAt: millisecondSinceLast ].
! !

!ForceDirectedLayoutWindow methodsFor: 'GUI building' stamp: 'DF 10/9/2018 18:26:22'!
buildMorphicWindow

	magnetSpace _ PasteUpMorph new.
	magnetSpace color:Color white.

	self layoutMorph addMorphs: (Array with:magnetSpace).
	^self.! !

!ForceDirectedLayoutWindow methodsFor: 'initialization' stamp: 'DF 10/9/2018 18:27:56'!
populateMagnets
	model magnets do:[:each | magnetSpace addMorph:each asMorph].
	^self! !

!ForceDirectedLayoutWindow class methodsFor: 'as yet unclassified' stamp: 'DF 10/9/2018 18:26:47'!
open: aForceLayoutSystem

	| aForceLayoutWindow |
	
	aForceLayoutWindow _ self new model: aForceLayoutSystem; buildMorphicWindow; populateMagnets ; openInWorld.
	
	[aForceLayoutWindow model solve] fork.
	
	aForceLayoutWindow startSteppingStepTime: 100.
	
	! !

!ForceDirectedLayoutSystem methodsFor: 'initialization' stamp: 'DF 10/9/2018 18:24:40'!
initialize
	magnets _ OrderedCollection new.
	springs _ OrderedCollection new.! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:24:47'!
accumulateForces

	magnets do:[ :each | each dischargeForce ].

	self accumulateSpringForces.
	self accumulateMagneticForces.! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:24:53'!
accumulateMagneticForces

	magnets do:[ :each |
		magnets do: [:other | each accumulateMagneticForce: other ] without: each ]! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 9/25/2018 22:03:12'!
accumulateSpringForces

	springs do: [:each | each accumulateForces ]! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:25:15'!
computeSearchDirection

	magnets do:[:each | each searchDirection: each force ].! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:25:19'!
firstStep
	
	self accumulateForces.
	
	initialTotalEnergy _ magnets inject:0 into:[ :acc :p | acc + (p force dotProduct: p force) ].

	^false.! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:25:25'!
moveToLowestPoint

	| current next h alpha |
	
	h _ 0.0001.
		
	current _ magnets inject:0 into:[ :acc :p | acc + (p force dotProduct: p searchDirection) ].
	
	5 timesRepeat: [

		magnets do:[ :each | each moveAlongSearchDirection: h ].
	
		self accumulateForces.
	
		next _ magnets inject:0 into:[ :acc :p | acc + (p force dotProduct: p searchDirection)].
	
		alpha _ h * ( ( current / ( current - next ) ) - 1 ).
	
		magnets do:[:each | each moveAlongSearchDirection: alpha ].
		
		current _ next.
		
	]
! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/8/2018 21:15:46'!
solve

	| isSolved |
	
	isSolved _ self firstStep.
	
	[isSolved] whileFalse:[
		isSolved _ self step.
	]! !

!ForceDirectedLayoutSystem methodsFor: 'solving' stamp: 'DF 10/9/2018 18:25:31'!
step

	self accumulateForces.
	
	totalEnergy _ magnets inject:0 into:[ :acc :p | acc + (p force dotProduct: p force) ].
	
	(totalEnergy >  (initialTotalEnergy  * errorTolerance squared))
	ifTrue:
	[
		self computeSearchDirection.
		self moveToLowestPoint.
		^ false.
	]
	ifFalse:[^true]! !

!ForceDirectedLayoutSystem methodsFor: 'accessing' stamp: 'DF 10/9/2018 18:27:37'!
addMagnet: aMagnet
	magnets add:aMagnet.! !

!ForceDirectedLayoutSystem methodsFor: 'accessing' stamp: 'DF 9/25/2018 21:58:41'!
addSpring: aSpring
	springs add:aSpring! !

!ForceDirectedLayoutSystem methodsFor: 'accessing' stamp: 'DF 9/27/2018 10:32:50'!
errorTolerance: aNumber
	errorTolerance _ aNumber.! !

!ForceDirectedLayoutSystem methodsFor: 'accessing' stamp: 'DF 10/9/2018 18:27:48'!
magnets
	^magnets! !

!ForceDirectedLayoutSystem class methodsFor: 'as yet unclassified' stamp: 'DF 10/9/2018 18:23:28'!
example

| a b c d s |

a _ Magnet charge:1.0 position: -0.1@-0.1.
b _ Magnet charge:1.0 position: -0.1@0.1.
c _ Magnet charge:1.0 position: 0.1@0.1.
d _ Magnet charge:1.0 position: 0.1@-0.1.

s _ ForceDirectedLayoutSystem new.

s errorTolerance:0.1.

s addMagnet: a.
s addMagnet: b.
s addMagnet: c.
s addMagnet: d.

s addSpring: (Spring ofStrength:1.0 between:a and:b).
s addSpring: (Spring ofStrength:1.0 between:b and:c).
s addSpring: (Spring ofStrength:1.0 between:c and:d).
s addSpring: (Spring ofStrength:1.0 between:d and:a).

s firstStep.

ForceDirectedLayoutWindow open:s.
! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 21:38:12'!
charge
	^ charge! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 21:44:58'!
charge: aNumber
	charge _ aNumber.! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 22:15:19'!
force
	^force! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 21:17:52'!
position
	^position! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/26/2018 23:31:53'!
position: aPoint
	position _ aPoint.! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 22:26:22'!
searchDirection
	^searchDirection ! !

!Magnet methodsFor: 'accessing' stamp: 'DF 9/25/2018 22:15:30'!
searchDirection: aPoint
	searchDirection _ aPoint.! !

!Magnet methodsFor: 'solving' stamp: 'DF 9/25/2018 21:55:14'!
accumulateForce: aPoint

	
	force _ force + aPoint.! !

!Magnet methodsFor: 'solving' stamp: 'DF 9/25/2018 22:36:56'!
accumulateMagneticForce: aParticle

	| forceDirection  distance |
	
	forceDirection _ (position - aParticle position)  normalized.
	
	distance _ (position - aParticle position) r.
	
	force _ force + (forceDirection * charge * aParticle charge / (distance squared + 0.0) )! !

!Magnet methodsFor: 'solving' stamp: 'DF 9/25/2018 21:34:12'!
dischargeForce
	force _ 0@0.! !

!Magnet methodsFor: 'solving' stamp: 'DF 9/25/2018 22:42:47'!
moveAlongSearchDirection: aNumber
	position _ position + (aNumber * searchDirection).! !

!Magnet methodsFor: 'morphic' stamp: 'DF 9/26/2018 23:24:25'!
asMorph

	| aMorph  |
	
	aMorph _ EllipseMorph new.

	aMorph morphExtent: 20@20.

	aMorph when:#morphicStep evaluate:[ :deltaTime | aMorph morphPosition: (aMorph owner morphExtent/2) + (self position * 100) ].

	^aMorph.! !

!Magnet class methodsFor: 'as yet unclassified' stamp: 'DF 10/9/2018 18:23:02'!
charge: aNumber position: aPoint
	| aParticle |
	
	aParticle _ Magnet new.
	
	aParticle charge: aNumber.
	aParticle position: aPoint.
	
	^aParticle! !

!Spring methodsFor: 'initialization' stamp: 'DF 9/25/2018 21:14:36'!
strength: aNumber between: firstParticle and:secondParticle

strength _ aNumber.
aParticle _ firstParticle.
anAdjacentParticle _ secondParticle.
! !

!Spring methodsFor: 'solving' stamp: 'DF 9/25/2018 22:03:52'!
accumulateForces
	| direction length |
	
	direction _ (aParticle position - anAdjacentParticle position) normalized.
	
	length _ (aParticle position - anAdjacentParticle position) r.
	
	aParticle accumulateForce: direction * strength * length negated.
	
	anAdjacentParticle accumulateForce: direction * strength * length.! !

!Spring class methodsFor: 'as yet unclassified' stamp: 'DF 9/25/2018 21:15:57'!
ofStrength: aNumber between: aParticle and: anotherParticle

	| aSpring |
	
	aSpring _ Spring new.
	
	aSpring strength: aNumber between: aParticle and: anotherParticle.
	
	^ aSpring! !
