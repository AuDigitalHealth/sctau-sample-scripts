-- 1.Find active concept by term 
SELECT * 
FROM descriptions_snapshot 
WHERE term LIKE 'Myocardial infarction%'
AND active=1
ORDER BY conceptid;

-- 2.List the Fully Specified Name and Synonym(s) for a concept
SELECT conceptid, term, 
CASE typeid WHEN 900000000000013009 THEN 'Synonym' ELSE 'Fully specified name' END 	AS description_type
FROM descriptions_snapshot 
WHERE conceptId = 248713000
AND active=1;

-- 3.List all MEMBERS(descriptions) of a reference set
SELECT 
	c.id AS conceptid,
	d.id AS descriptionid,
	d.term AS preferred_term
FROM 
	concepts_snapshot AS c,
	refset_snapshot AS rs,
	descriptions_snapshot AS d,
	language_refset_snapshot AS adrs
	
WHERE c.id=rs.referencedComponentId
AND c.id=d.conceptid
AND d.id=adrs.referencedComponentId
AND rs.refsetid= 11000036103 -- ID of Adverse reaction type refset
AND d.typeid = 900000000000013009 -- Synonym
AND adrs.refsetid = 32570271000036106 -- ADRS
AND adrs.acceptabilityid=900000000000548007 -- ID of Preferred Term
AND c.active=1
AND d.active=1
AND rs.active=1
AND ADRS.active = 1
ORDER BY preferred_term;

-- 4. List of Australian reference sets & member count 

SELECT 
refset_active.refsetid AS "Reference Set ID",
desc_active.term AS "Name of Reference Set",
refset_active.member_count AS "No of Members"
FROM 
	(SELECT 
	term,id,conceptid 
	FROM descriptions_snapshot AS ds
	WHERE active=1 AND typeid = 900000000000013009 -- Synonym
	) AS desc_active,
	
    	(SELECT 
	referencedComponentId 
	FROM language_refset_snapshot AS lrs
	WHERE refsetId = 32570271000036106  -- Australian dialect refset
	AND acceptabilityid = 900000000000548007  -- Preferred Term
	AND active=1) AS lang_refset_active,

	(SELECT 
	refsetid, COUNT(referencedcomponentid) AS member_count
    	FROM refset_snapshot AS rss
	WHERE active=1
    	GROUP BY refsetid) AS refset_active

WHERE desc_active.conceptid = refset_active.refsetid
AND desc_active.id = lang_refset_active.referencedcomponentid
ORDER by desc_active.term;

-- 5. List of descendants of the Fetal finding hierarchy 

SELECT 
	c.id AS conceptid,
	d.id AS descriptionid,
	d.term AS preferred_term
FROM 
	concepts_snapshot AS c
JOIN (SELECT sourceId 
		FROM transitive_closure 
		WHERE destinationId=106112009 -- Fetal finding
		) AS ffd
		ON c.id=ffd.sourceid
JOIN descriptions_snapshot AS d
	   ON c.id=d.conceptid AND d.typeid = 900000000000013009 -- Synonym
JOIN language_refset_snapshot AS adrs
		ON d.id=adrs.referencedComponentId AND adrs.refsetId = 32570271000036106  -- Australian dialect refset
WHERE adrs.acceptabilityid = 900000000000548007 -- ID of Preferred Term
AND c.active=1
AND d.active=1
AND adrs.active=1;

-- 6. Applying the Clincal Finding Grouper Exclusion RefSet against the Fetal Finding hierarchy
SELECT 
	c.id AS conceptid,
	d.id AS descriptionid,
	d.term AS preferred_term
FROM 
concepts_snapshot AS c,

(SELECT sourceId 
FROM transitive_closure 
WHERE destinationId=106112009 -- Fetal finding
AND sourceid NOT IN 
	(SELECT referencedcomponentid
	FROM refset_snapshot
	WHERE refsetid = 171991000036103 -- clinical finding grouper exclusion refset
	AND active=1
 	)) AS ffd,

descriptions_snapshot AS d,
language_refset_snapshot AS adrs
WHERE c.id=ffd.sourceid
AND c.id=d.conceptid
AND d.id=adrs.referencedComponentId
AND d.typeid = 900000000000013009 -- Synonym
AND adrs.refsetId = 32570271000036106  -- Australian dialect refset
AND adrs.acceptabilityid=900000000000548007 -- ID of Preferred Term
AND c.active=1
AND d.active=1
AND adrs.active=1;

-- 7. Finding terms within a specific hierarchy
SELECT 
d.term AS preferred_term

FROM 
concepts_snapshot AS c,

(SELECT sourceId 
FROM transitive_closure 
WHERE destinationId=71388002 -- Procedure hierarchy
) AS pd,

descriptions_snapshot AS d,
language_refset_snapshot AS adrs

WHERE 
c.id=pd.sourceid
AND c.id=d.conceptid
AND d.id=adrs.referencedComponentId
AND d.typeid = 900000000000013009 -- Synonym
AND adrs.refsetId = 32570271000036106  -- Australian dialect refset
AND adrs.acceptabilityid=900000000000548007 -- ID of Preferred Term
AND c.active=1
AND d.active=1
AND adrs.active=1
AND d.term like '% obstetric%';

-- 8. Finding AMT product concepts that have been inactivated and has an association with another concept

SELECT effectiveTime,
refsetid,
get_PT(refsetid),
referencedcomponentid,
get_PT(referencedcomponentid),
targetComponentid,
get_PT(targetComponentid)
 
FROM crefset_snapshot
 
WHERE targetComponentid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid IN (929360061000036106,929360021000036102,929360081000036101,929360041000036105,929360051000036108,929360071000036103,929360031000036100)
    AND active = 1
    )
AND active = 1

-- 9. Finding AMT product concepts that have been inactivated and has NO association with another concept

SELECT
refset_snapshot.referencedcomponentid AS original_concept_ID,
get_PT(refset_snapshot.referencedcomponentid) AS original_concept_PT,
crefset_snapshot.targetComponentid AS replacement_concept_ID,
get_PT(crefset_snapshot.targetComponentid) AS replacement_concept_term

FROM refset_snapshot

LEFT OUTER JOIN crefset_snapshot
ON refset_snapshot.referencedcomponentid = crefset_snapshot.referencedcomponentid
AND crefset_snapshot.active = 1

WHERE refset_snapshot.refsetid IN (929360061000036106,929360021000036102,929360081000036101,929360041000036105,929360051000036108,929360071000036103,929360031000036100)
AND refset_snapshot.active = 0
AND crefset_snapshot.targetComponentid IS null


