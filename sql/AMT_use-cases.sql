-- Search for all MPPs and TPPs based with an intended active ingredient a word containing 'amox'
select
    v3_mpp_to_tpp.mppid,
    v3_mpp_to_tpp.mppterm,
    v3_mpp_to_tpp.tppid,
    v3_mpp_to_tpp.tppterm
from v3_mpp_to_tpp
    join v3_ingredient_strength
        on v3_mpp_to_tpp.mppid = v3_ingredient_strength.mppid
where v3_ingredient_strength.substanceterm regexp (

    @search_term:='(^|[^a-zA-Z]+)amox'

    )
or v3_mpp_to_tpp.mppterm regexp @search_term
or v3_mpp_to_tpp.tppterm like @search_term
;

-- Show dose forms of 4 sample MPPs
select
    v3_ingredient_strength.mppid,
    v3_ingredient_strength.mppterm,
    v3_ingredient_strength.bossterm,
    get_PT(hasDoseForm.destinationid)
from v3_ingredient_strength

    join relationships_snapshot hasDoseForm
        on hasDoseForm.sourceid = v3_ingredient_strength.mpuuid
        and hasDoseForm.typeid = 30523011000036108 -- has manufactured dose form (relationship type)
        and hasDoseForm.active = 1

where v3_ingredient_strength.mppid in (
    26624011000036107, -- 'amoxycillin 100 mg/mL oral...'
    51572011000036101, -- 'goserelin 3.6 mg implant [...'
    26781011000036107, -- 'peginterferon alfa-2a 135 ...'
    28051011000036109  -- 'peginterferon alfa-2b 150 ...'
)
;

-- List ingredient strengths for a given MPP
select *
from v3_ingredient_strength
where mppid = 63182011000036107
;

-- List unit of use size and quantity for a given MPP
select *
from v3_unit_of_use
where mppid = 26624011000036107
;

-- List acceptable TPPs (for dispensing) for a given MPP
select 
mppid,mppterm,
tppid, tppterm
from v3_mpp_to_tpp
where mppid = 63919011000036102
order by tppterm
;

-- List acceptable substitutable TPPs, and associated CTPPs (for dispensing) for a given TPP (brand substitute)
select 
    tpp1.tppid as originaltppid,
    tpp1.tppterm as originaltppterm,
    substitutetpp.tppid as substitutetppid,
    substitutetpp.tppterm as substitutetppterm,
    ctpps.sourceid as substitutectpp,
    get_PT(ctpps.sourceid) as substitutectppterm

from v3_mpp_to_tpp tpp1
join v3_mpp_to_tpp substitutetpp
    on tpp1.mppid = substitutetpp.mppid
    and tpp1.tppid = 12809011000036105 -- Amoxil 250 mg capsule: hard, 20
join relationships_snapshot ctpps
    on substitutetpp.tppid = ctpps.destinationid
    and ctpps.sourceId in (select referencedComponentId from refset_snapshot where refsetId = 929360051000036108) -- CTPP refset
;

-- Find all MPUUs containing more than 10 milligrams of codeine, in tablet form
-- Note the strengths are stored using microgram/each unit (10 mg == 10000 microgram)
select distinct
    mpuu.mpuuid,
    mpuu.mpuuterm,
    mpuu.substanceterm,    
    mpuu.bossterm,    
    mpuu.strengthvalue,
    mpuu.unitterm,
    get_PT(hasDoseForm.destinationid)
from v3_ingredient_strength mpuu
join relationships_snapshot hasDoseForm
        on mpuu.mpuuid = hasDoseForm.sourceid
        and hasDoseForm.typeid = 30523011000036108 -- has manufactured dose form (relationship type)
        and hasDoseForm.active = 1
        and hasDoseForm.destinationid in (select distinct conceptid from descriptions_snapshot where term like 'tablet%')                
        
        and mpuu.bossterm like '%codeine%'
        and mpuu.strengthvalue > 10000
        and mpuu.unitid = 700000881000036108 -- microgram/each
;

-- Find all MPUUs containing dihydrocodeine, in any tablet form
select
    v3_ingredient_strength.mpuuid,
    v3_ingredient_strength.mpuuterm,    
    v3_ingredient_strength.bossterm,
    v3_ingredient_strength.substanceterm,
    v3_ingredient_strength.strengthvalue,    
    v3_ingredient_strength.unitterm,
    get_PT(hasDoseForm.destinationid)
from v3_ingredient_strength

    join relationships_snapshot hasDoseForm
       on hasDoseForm.sourceid = v3_ingredient_strength.mpuuid
       and hasDoseForm.typeid = 30523011000036108 -- has manufactured dose form (relationship type)
       and hasDoseForm.active = 1

where v3_ingredient_strength.substanceid = (
    select distinct conceptid 
    from descriptions_snapshot where term = 'dihydrocodeine (AU substance)'
     )
    and hasDoseForm.destinationid in (
            select sourceId from transitive_closure where destinationid = 154011000036109 -- tablet dose form (AU qualifier)
            )
;


-- Query MPPs and corresponding concepts that have sub roles to subtype MPUUs of 'paracetamol 500 mg tablet' in them
select 
    hasMpuu.sourceid as mppid,
    get_PT(hasMpuu.sourceid) as mppterm,
    hasMpuu.typeid as hasmpuu_typeid,
    get_PT(hasMpuu.typeid) as hasmpuu_typeterm,
    hasMpuu.destinationid as mpuuid,
    get_PT(hasMpuu.destinationid) as mpuuterm,       
    subRole.sourceid as sub_sourceid,
    get_PT(subRole.sourceid) as sub_sourceterm,
    subRole.typeid as sub_typeid,
    get_PT(subRole.typeid) as sub_typeterm,
    subRole.destinationid as sub_destinationid,
    get_PT(subRole.destinationid) as sub_destinationterm
from relationships_snapshot hasMpuu
    join relationships_snapshot subRole
        on  hasMpuu.active = 1 and subRole.active = 1
        and hasMpuu.typeid = 30348011000036104                   
        and hasMpuu.destinationid = 23628011000036109
        and subRole.typeid in (select sourceId from transitive_closure where destinationId = 30348011000036104)
        and subRole.destinationid in (select sourceId from transitive_closure where destinationId = 23628011000036109)
	and subRole.sourceid in (select sourceId from transitive_closure where destinationId = hasMpuu.sourceid)
order by mppterm, sub_sourceterm;


-- Appending ARTGID to CTPPs in the S8 refset

SELECT
CTPP.referencedcomponentid,
CTPPdesc.term,
ARTG.schemeValue

FROM refset_snapshot CTPP -- refset that contains CTPP and TPUU for reportable drugs

JOIN artgid_refset_snapshot ARTG -- refset that maps CTPP with ARTGID
ON CTPP.referencedcomponentid = ARTG.referencedcomponentid
AND CTPP.referencedcomponentid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360051000036108 -- containered trade product pack reference set
    AND active = 1)
    
JOIN descriptions_snapshot CTPPdesc
ON CTPP.referencedcomponentid = CTPPdesc.conceptid
AND CTPPdesc.active = 1
AND CTPPdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot CTPPadrs
ON CTPPdesc.id = CTPPadrs.referencedcomponentid
AND CTPPadrs.acceptabilityid = 900000000000548007 -- preferred
AND CTPPadrs.active = 1

WHERE CTPP.refsetid = 1050951000168102 -- S8 drugs
AND CTPP.active = 1;


-- Deriving TPPs from CTPPs

SELECT

CTPP.referencedcomponentid AS ctpp_id,
CTPPdesc.term AS ctpp_pt,
CTPPisTPP.destinationid,
TPPdesc.term

FROM refset_snapshot CTPP -- refset that contains CTPP and TPUU for reportable drugs

JOIN relationships_snapshot CTPPisTPP
ON CTPP.referencedcomponentid = CTPPisTPP.sourceid
AND CTPPisTPP.typeid = 116680003 -- is a
AND CTPPisTPP.active = 1
AND CTPPisTPP.destinationid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360041000036105 -- restricting destination to TPPs
    AND active = 1)


JOIN descriptions_snapshot CTPPdesc
ON CTPPisTPP.sourceid = CTPPdesc.conceptid
AND CTPPdesc.active = 1
AND CTPPdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot CTPPadrs
ON CTPPdesc.id = CTPPadrs.referencedcomponentid
AND CTPPadrs.acceptabilityid = 900000000000548007 -- preferred
AND CTPPadrs.active = 1

JOIN descriptions_snapshot TPPdesc
ON CTPPisTPP.destinationid = TPPdesc.conceptid
AND TPPdesc.active = 1
AND TPPdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot TPPadrs
ON TPPdesc.id = TPPadrs.referencedcomponentid
AND TPPadrs.acceptabilityid = 900000000000548007 -- preferred
AND TPPadrs.active = 1

WHERE CTPP.refsetid = 1050951000168102 -- S8 drugs
AND CTPP.active = 1;



-- Deriving MPUUs from TPUUs in the reference set

SELECT
TPUU.referencedcomponentid AS tpuu_id,
TPUUdesc.term AS tpuu_pt,
MPUUdesc.conceptid AS mpuu_id,
MPUUdesc.term AS mpuu_pt

FROM refset_snapshot TPUU -- refset that contains CTPP and TPUU for reportable drugs

JOIN relationships_snapshot TPUUisMPUU
ON TPUUisMPUU.sourceid = TPUU.referencedcomponentid
AND TPUU.referencedcomponentid IN ( 
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360031000036100 -- restricting join to TPUUs
    AND active = 1)
AND TPUUisMPUU.typeid = 116680003 -- is a
AND TPUUisMPUU.destinationid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360071000036103 -- restricting destination to MPUUs
    AND active = 1)
AND TPUUisMPUU.active = 1

JOIN descriptions_snapshot TPUUdesc
ON TPUUisMPUU.sourceid = TPUUdesc.conceptid
AND TPUUdesc.active = 1
AND TPUUdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot TPUUadrs
ON TPUUdesc.id = TPUUadrs.referencedcomponentid
AND TPUUadrs.acceptabilityid = 900000000000548007 -- Preferred
AND TPUUadrs.active = 1

JOIN descriptions_snapshot MPUUdesc
ON TPUUisMPUU.destinationid = MPUUdesc.conceptid
AND MPUUdesc.active = 1
AND MPUUdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot MPUUadrs
ON MPUUdesc.id = MPUUadrs.referencedcomponentid
AND MPUUadrs.acceptabilityid = 900000000000548007 -- Preferred
AND MPUUadrs.active = 1

WHERE TPUU.refsetid = 1050951000168102 -- S8 reference set
AND TPUU.active = 1;


-- Deriving TPUUs and MPUUs from CTPPs in the reference set

SELECT

CTPP.referencedcomponentid AS ctpp_id,
CTPPdesc.term AS ctpp_pt,
TPUUdesc.conceptid AS tpuu_id,
TPUUdesc.term AS tpuu_pt,
MPUUdesc.conceptid AS mpuu_id,
MPUUdesc.term AS mpuu_pt

FROM refset_snapshot CTPP -- refset that contains CTPP and TPUU for reportable drugs

JOIN relationships_snapshot CTPPhasTPUU
ON CTPP.referencedcomponentid = CTPPhasTPUU.sourceid
AND CTPPhasTPUU.typeid = 30409011000036107 -- has TPUU
AND CTPPhasTPUU.active = 1
AND CTPPhasTPUU.destinationid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360031000036100 -- restricting destination to TPUUs
    AND active = 1)

JOIN relationships_snapshot TPUUisMPUU
ON CTPPhasTPUU.destinationid = TPUUisMPUU.sourceid
AND TPUUisMPUU.typeid = 116680003 -- is a
AND TPUUisMPUU.destinationid IN (
    SELECT referencedcomponentid
    FROM refset_snapshot
    WHERE refsetid = 929360071000036103 -- restricting destination to MPUUs
    AND active = 1)
AND TPUUisMPUU.active = 1

JOIN descriptions_snapshot CTPPdesc
ON CTPPhasTPUU.sourceid = CTPPdesc.conceptid
AND CTPPdesc.active = 1
AND CTPPdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot CTPPadrs
ON CTPPdesc.id = CTPPadrs.referencedcomponentid
AND CTPPadrs.acceptabilityid = 900000000000548007 -- preferred
AND CTPPadrs.active = 1

JOIN descriptions_snapshot TPUUdesc
ON TPUUisMPUU.sourceid = TPUUdesc.conceptid
AND TPUUdesc.active = 1
AND TPUUdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot TPUUadrs
ON TPUUdesc.id = TPUUadrs.referencedcomponentid
AND TPUUadrs.acceptabilityid = 900000000000548007 -- preferred
AND TPUUadrs.active = 1

JOIN descriptions_snapshot MPUUdesc
ON TPUUisMPUU.destinationid = MPUUdesc.conceptid
AND MPUUdesc.active = 1
AND MPUUdesc.typeid = 900000000000013009 -- synonym

JOIN language_refset_snapshot MPUUadrs
ON MPUUdesc.id = MPUUadrs.referencedcomponentid
AND MPUUadrs.acceptabilityid = 900000000000548007 -- preferred
AND MPUUadrs.active = 1

WHERE CTPP.refsetid = 1050951000168102 -- S8 reference set
AND CTPP.active = 1;

-- Finding the proximal MP for an MPUU

SELECT DISTINCT
MPUUisMP.sourceid AS MPUU_id,
get_PT(MPUUisMP.sourceid) AS MPUU_term,
MPUUisMP.destinationid AS MP_id,
get_PT(MPUUisMP.destinationid) AS MP_term

FROM transitive_closure MPUUisMP

INNER JOIN refset_snapshot MPUU
ON MPUUisMP.sourceid = MPUU.referencedcomponentid
AND MPUU.refsetid = 929360071000036103 -- MPUU refset
AND MPUU.active = 1

INNER JOIN refset_snapshot MP
ON MPUUisMP.destinationid = MP.referencedcomponentid
AND MP.refsetid = 929360061000036106 -- MP refset
AND MP.active = 1

AND NOT EXISTS( -- don't give me MPUUs that don't have the same IAIs as the parent MP
    SELECT 1 FROM relationships_snapshot MPUUhasIAI
    WHERE MPUUhasIAI.sourceid = MPUUisMP.sourceid
    AND MPUUhasIAI.typeid = 700000081000036101 -- has intended active ingredient
    AND MPUUhasIAI.active = 1
    AND NOT EXISTS (
        SELECT 1 FROM relationships_snapshot MPhasIAI
        WHERE MPhasIAI.sourceid = MPUUisMP.destinationid
        AND MPhasIAI.destinationid = MPUUhasIAI.destinationid
        AND MPhasIAI.typeid = 700000081000036101 -- has intended active ingredient
        AND MPhasIAI.active = 1)
	)

AND NOT EXISTS ( -- don't give me MPs that don't have the same IAIs as the child MPUU
    SELECT 1 FROM relationships_snapshot MPhasIAI
    WHERE MPhasIAI.sourceid = MPUUisMP.destinationid
    AND MPhasIAI.typeid = 700000081000036101 -- has intended active ingredient
    AND MPhasIAI.active = 1
    AND NOT EXISTS (
        SELECT 1 FROM relationships_snapshot MPUUhasIAI
        WHERE MPUUhasIAI.sourceid = MPUUisMP.sourceid
        AND MPUUhasIAI.destinationid = MPhasIAI.destinationid
        AND MPUUhasIAI.typeid = 700000081000036101 -- has intended active ingredient
        AND MPUUhasIAI.active = 1)
	)

WHERE MPUUisMP.sourceid IN
    (685621000168108, -- buprenorphine 8 mg sublingual tablet
     22109011000036100, -- buprenorphine 8 mg + naloxone 2 mg sublingual tablet
     33677011000036108, -- naloxone hydrochloride 2 mg/5 mL injection, syringe
     22077011000036108 -- buprenorphine 10 microgram/hour patch
     )

ORDER BY MP_term;
