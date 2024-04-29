-- Search for all MPPs and TPPs based with an intended active ingredient a word containing 'amox'
select
    v4_mpp_to_tpp.mppid,
    v4_mpp_to_tpp.mppterm,
    v4_mpp_to_tpp.tppid,
    v4_mpp_to_tpp.tppterm
from v4_mpp_to_tpp
    join v4_ingredient_strength
        on v4_mpp_to_tpp.mppid = v4_ingredient_strength.mppid
where v4_ingredient_strength.substanceterm regexp (

    @search_term:='(^|[^a-zA-Z]+)amox'

    )
or v4_mpp_to_tpp.mppterm regexp @search_term
or v4_mpp_to_tpp.tppterm like @search_term
;

-- Show dose forms of 4 sample MPPs
SELECT
    v4_ingredient_strength.mppid,
    v4_ingredient_strength.mppterm,
    v4_ingredient_strength.bossterm,
    get_PT(hasDoseForm.destinationid)

from v4_ingredient_strength

    LEFT join relationships_snapshot hasDoseForm
        on hasDoseForm.sourceid = v4_ingredient_strength.mpuuid
        and hasDoseForm.typeid in (411116001,999000061000168105) -- Has manufactured dose form (attribute), Has device type (attribute)
        and hasDoseForm.active = 1

where v4_ingredient_strength.mppid in (
    26624011000036107, -- 'Amoxicillin 100 mg/mL powder for oral liquid, 20 mL'
    51931000036106, -- 'Ribavirin 200 mg capsule, 196'
    720371000168109, -- 'Insulin glargine 300 units/mL injection, 1.5 mL pen device'
    1046681000168103  -- 'Buprenorphine 10 microgram/hour patch, 4'
)
;

-- List ingredient strengths for a given MPP
select *
from v4_ingredient_strength
where mppid = 63182011000036107
;

-- List unit of use size and quantity for a given MPP
select *
from v4_Packs_Size_Details
where mppid = 933206081000036105
;

-- List acceptable TPPs (for dispensing) for a given MPP
select 
mppid,mppterm,
tppid, tppterm
from v4_mpp_to_tpp
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

from v4_mpp_to_tpp tpp1
join v4_mpp_to_tpp substitutetpp
    on tpp1.mppid = substitutetpp.mppid
    and tpp1.tppid = 12809011000036105 -- Amoxil 250 mg capsule: hard, 20
join relationships_snapshot ctpps
    on substitutetpp.tppid = ctpps.destinationid
    and ctpps.sourceId in (select referencedComponentId from refset_snapshot where refsetId = 929360051000036108) -- CTPP refset
;


-- Find all MPUUs containing more than 20 milligrams of codeine, in tablet form
select distinct
    mpuu.mpuuid,
    mpuu.mpuuterm,
    mpuu.substanceterm,    
    mpuu.bossterm,    
    mpuu.TotalQuantity,
    mpuu.TotalQuantityUnitTerm,
    get_PT(hasDoseForm.destinationid)
from v4_ingredient_strength mpuu
join relationships_snapshot hasDoseForm
        on mpuu.mpuuid = hasDoseForm.sourceid
        and hasDoseForm.typeid in (411116001,999000061000168105) -- Has manufactured dose form (attribute), Has device type (attribute)
        and hasDoseForm.active = 1
        and hasDoseForm.destinationid in (select distinct conceptid from descriptions_snapshot where term like 'tablet%')                
        
        and mpuu.bossterm like '%codeine%'
        and mpuu.TotalQuantity > 20
        and mpuu.TotalQuantityUnitId = 258684004 -- milligram
;

-- Find all MPUUs containing Lamotrigine, in any Oral dose form
select
    v4_ingredient_strength.mpuuid,
    v4_ingredient_strength.mpuuterm,    
    v4_ingredient_strength.bossterm,
    v4_ingredient_strength.substanceterm,
    v4_ingredient_strength.TotalQuantity,    
    v4_ingredient_strength.TotalQuantityUnitTerm,
    get_PT(hasDoseForm.destinationid),
from v4_ingredient_strength

    join relationships_snapshot hasDoseForm
       on hasDoseForm.sourceid = v4_ingredient_strength.mpuuid
       and hasDoseForm.typeid in (411116001,999000061000168105) -- Has manufactured dose form (attribute), Has device type (attribute)
       and hasDoseForm.active = 1
WHERE v4_ingredient_strength.substanceid = 387562000 -- Lamotrigine   
and hasDoseForm.destinationid in (
            select sourceId from transitive_closure where destinationid = 385268001 -- Oral dose form
            )
;


-- Appending ARTGID to CTPPs in the S8 refset

SELECT
CTPP.referencedcomponentid,
CTPPdesc.term,
ARTG.schemeValue

FROM refset_snapshot CTPP -- refset that contains CTPP and TPUU for reportable drugs

JOIN irefset_snapshot ARTG -- refset that maps CTPP with ARTGID
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

