-- 1.Search the Musculoskeletal finding reference set for all concepts that are related to the Foot structure based on Finding site
SELECT referencedcomponentid 
FROM refset_snapshot AS MSrefset
WHERE MSrefset.refsetId = 32570351000036105 -- Musculoskeletal finding reference set
AND MSrefset.active = 1
AND MSrefset.referencedcomponentid in 
	(SELECT sourceId 
	FROM relationships_snapshot
	WHERE active = 1 
	AND typeId = 363698007 -- Finding site
	AND destinationId = 56459004 -- Foot structure

);


-- 2. List all available descriptions for conceptId 387517004 Paracetamol
SELECT conceptId,id,term 
FROM descriptions_snapshot
WHERE conceptId = 387517004;


-- 3. List all descriptions that are referenced in the ADRS for concept 387517004 Paracetamol
SELECT conceptId,D.id,term, acceptabilityid 
FROM descriptions_snapshot AS D
INNER JOIN language_refset_snapshot AS ADRS 
ON D.id = ADRS.referencedcomponentid
WHERE D.conceptId = 387517004;


-- 4. The current Preferred Term for concept 387517004 Paracetamol
SELECT conceptId,D.id,term, acceptabilityid 
FROM descriptions_snapshot AS D
INNER JOIN language_refset_snapshot AS ADRS 
ON D.id = ADRS.referencedcomponentid
WHERE D.conceptId = 387517004
AND ADRS.acceptabilityid = 900000000000548007 -- ConceptId for 'Preferred'
AND ADRS.active = 1;


-- 5. List all available descriptions for conceptId 837621000168102 Bordetella pertussis filamentous haemagglutinin antigen + Bordetella pertussis pertactin antigen + Bordetella pertussis toxoid + diphtheria toxoid + tetanus toxoid (medicinal product)
SELECT conceptId,id,term 
FROM descriptions_snapshot
WHERE conceptId = 837621000168102;


-- 6. The current Preferred Term for concept 837621000168102 Bordetella pertussis filamentous haemagglutinin antigen + Bordetella pertussis pertactin antigen + Bordetella pertussis toxoid + diphtheria toxoid + tetanus toxoid (medicinal product)
SELECT conceptId,D.id,term, acceptabilityid 
FROM descriptions_snapshot AS D
INNER JOIN language_refset_snapshot AS ADRS 
ON D.id = ADRS.referencedcomponentid
WHERE D.conceptId = 837621000168102
AND ADRS.acceptabilityid = 900000000000548007 -- ConceptId for 'Preferred'
AND ADRS.active = 1;

-- 7. Restrict the search for term ulcer to Clinical findings reference set
SELECT conceptId, term 
FROM descriptions_snapshot 
WHERE term LIKE '%ulcer%'
AND conceptId IN 
		(SELECT referencedcomponentId 
		FROM refset_snapshot 
		WHERE refsetId = 32570071000036102 -- Clinical finding foundation reference set
);


-- 8. List Animal bite wound concepts, excluding the Arthropod bite wounds.
SELECT sourceId 
FROM transitive_closure
WHERE destinationId = 399907009 -- Animal bite wound
-- exclude the concepts that are 409985002|Arthropod bite wound| descendants
AND sourceId NOT IN (SELECT sourceId FROM transitive_closure
		    WHERE destinationId = 409985002 -- Arthropod bite wound
		    );


-- 9. Intersection of Congenital diseases and Anaemias 
SELECT anaemia.sourceId 
FROM transitive_closure AS anaemia
INNER JOIN transitive_closure AS congenital
ON anaemia.sourceId = congenital.sourceId
WHERE anaemia.destinationId = 271737000 -- | anaemia | 
AND congenital.destinationId = 66091009; -- | congenital disease |


-- 10. Alternative query to list intersection of Congenital diseases and Anaemias 
SELECT sourceId FROM transitive_closure AS anaemia
WHERE anaemia.destinationId = 271737000 -- | anaemia | 
AND sourceId IN (
		SELECT sourceId FROM transitive_closure AS congenital
		WHERE congenital.destinationId = 66091009 -- | congenital disease |
			);
