-- DERIVED Objects

-- CREATE Table for v3_ingredient_strength
-- This table lists all the MPPs, their MPUUs and the corresponding ingredients (IAI and BoSS) and strengths
DROP TABLE IF EXISTS v3_ingredient_strength;
CREATE TABLE v3_ingredient_strength AS
select 
    MPPhasMPUU.sourceId as mppid,
    get_PT(MPPhasMPUU.sourceId) as mppterm,
    MPPhasMPUU.destinationid as mpuuid,
    get_PT(MPPhasMPUU.destinationid) as mpuuterm,
    hasIngredient.destinationid as substanceid,
    get_PT(hasIngredient.destinationid) as substanceterm,
    hasBoSS.destinationid as bossid,
    get_PT(hasBoSS.destinationid) as bossterm,
    strength.operatorid as operatorid,
    get_PT(strength.operatorid) as operatorterm,
    strength.value as strengthvalue,
    strength.unitid as unitid,
    get_PT(strength.unitid) as unitterm
from relationships_snapshot MPPhasMPUU

    join relationships_snapshot hasIngredient
        on MPPhasMPUU.destinationId = hasIngredient.sourceId
        and MPPhasMPUU.sourceId in (select referencedComponentId from refset_snapshot where refsetId = 929360081000036101) -- MPP refset
        and MPPhasMPUU.destinationId in (select referencedComponentId from refset_snapshot where refsetId = 929360071000036103) -- MPUU refset
        and MPPhasMPUU.typeId = 30348011000036104 -- has MPUU (relationship type)
        and MPPhasMPUU.active = 1
        and hasIngredient.typeId = 700000081000036101 -- has intended active ingredient (attribute)
        and hasIngredient.active = 1

    join relationships_snapshot hasBoSS
        on hasIngredient.sourceId = hasBoSS.sourceId and hasIngredient.relationshipgroup = hasBoSS.relationshipgroup
        and hasBoSS.typeId = 30364011000036101 -- has Australian BoSS (relationship type)
        and hasBoSS.active = 1

    left outer join ccsrefset_snapshot strength
        on hasBoSS.id = strength.referencedcomponentid
        and strength.refsetid=700000111000036105 and strength.active = 1;

-- Create Indexes for v3_ingredient_strength table
CREATE INDEX v3_ingredient_strength_mppid_idx ON v3_ingredient_strength(mppid);
CREATE INDEX v3_ingredient_strength_mppterm_idx ON v3_ingredient_strength(mppterm(100));
CREATE INDEX v3_ingredient_strength_mpuuid_idx ON v3_ingredient_strength(mpuuid);
CREATE INDEX v3_ingredient_strength_mpuuterm_idx ON v3_ingredient_strength(mpuuterm(100));
CREATE INDEX v3_ingredient_strength_substanceid_idx ON v3_ingredient_strength(substanceid);
CREATE INDEX v3_ingredient_strength_substanceterm_idx ON v3_ingredient_strength(substanceterm(100));
CREATE INDEX v3_ingredient_strength_bossid_idx ON v3_ingredient_strength(bossid);
CREATE INDEX v3_ingredient_strength_bossterm_idx ON v3_ingredient_strength(bossterm(100));
CREATE INDEX v3_ingredient_strength_operatorid_idx ON v3_ingredient_strength(operatorid);
CREATE INDEX v3_ingredient_strength_operatorterm_idx ON v3_ingredient_strength(operatorterm(100));
CREATE INDEX v3_ingredient_strength_strengthvalue_idx ON v3_ingredient_strength(strengthvalue);
CREATE INDEX v3_ingredient_strength_unitid_idx ON v3_ingredient_strength(unitid);
CREATE INDEX v3_ingredient_strength_unitterm_idx ON v3_ingredient_strength(unitterm(100));

-- CREATE Table for v3_unit_of_use
-- This table lists all the MPPs, their MPUUs the size of each MPUU, and the number of MPUU in each pack
DROP TABLE IF EXISTS v3_unit_of_use;
CREATE TABLE v3_unit_of_use AS
select 
    MPPhasMPUU.sourceId as mppid,
    get_PT(MPPhasMPUU.sourceId) as mppterm,
    MPPhasMPUU.destinationId as mpuuid,
    get_PT(MPPhasMPUU.destinationId) as mpuuterm,
    
    hasUnitOfUse.destinationId as unitofuseid,
    get_PT(hasUnitOfUse.destinationId) as unitofuseterm,

    uouSize.operatorid as sizeoperatorid,
    get_PT(uouSize.operatorid) as sizeoperatorterm,
    uouSize.value as sizevalue,
    uouSize.unitid as sizeunitid,
    get_PT(uouSize.unitid) as sizeunitterm,

    uouQty.operatorid as quantityoperatorid,
    get_PT(uouQty.operatorid) as quantityoperatorterm,
    uouQty.value as quantityvalue,
    uouQty.unitid as quantityunitid,
    get_PT(uouQty.unitid) as quantityunitterm
from relationships_snapshot MPPhasMPUU

    left outer join relationships_snapshot hasUnitOfUse
        on MPPhasMPUU.destinationId = hasUnitOfUse.sourceId
        and MPPhasMPUU.sourceId in (select referencedComponentId from refset_snapshot where refsetId = 929360081000036101) -- MPP refset
        and MPPhasMPUU.destinationId in (select referencedComponentId from refset_snapshot where refsetId = 929360071000036103) -- MPUU refset
        and hasUnitOfUse.typeId = 30548011000036101 -- has unit of use (relationship type)
        and hasUnitOfUse.active = 1

    join ccsrefset_snapshot uouSize
        on hasUnitOfUse.id = uouSize.referencedcomponentid
        and uouSize.refsetid=700000141000036106 and uouSize.active = 1 -- Unit of use size reference set

    join ccsrefset_snapshot uouQty
        on MPPhasMPUU.id = uouQty.referencedcomponentid
        and uouQty.refsetid=700000131000036101 and uouQty.active = 1; -- Unit of use quantity reference set

-- Create Indexes for v3_unit_of_use table
CREATE INDEX v3_unit_of_use_mppid_idx ON v3_unit_of_use(mppid);
CREATE INDEX v3_unit_of_use_mppterm_idx ON v3_unit_of_use(mppterm(100));
CREATE INDEX v3_unit_of_use_mpuuid_idx ON v3_unit_of_use(mpuuid);
CREATE INDEX v3_unit_of_use_mpuuterm_idx ON v3_unit_of_use(mpuuterm(100));
CREATE INDEX v3_unit_of_use_unitofuseid_idx ON v3_unit_of_use(unitofuseid);
CREATE INDEX v3_unit_of_use_unitofuseterm_idx ON v3_unit_of_use(unitofuseterm(100));
CREATE INDEX v3_unit_of_use_sizeoperatorid_idx ON v3_unit_of_use(sizeoperatorid);
CREATE INDEX v3_unit_of_use_sizeoperatorterm_idx ON v3_unit_of_use(sizeoperatorterm(100));
CREATE INDEX v3_unit_of_use_sizevalue_idx ON v3_unit_of_use(sizevalue);
CREATE INDEX v3_unit_of_use_sizeunitid_idx ON v3_unit_of_use(sizeunitid);
CREATE INDEX v3_unit_of_use_sizeunitterm_idx ON v3_unit_of_use(sizeunitterm(100));
CREATE INDEX v3_unit_of_use_quantityoperatorid_idx ON v3_unit_of_use(quantityoperatorid);
CREATE INDEX v3_unit_of_use_quantityoperatorterm_idx ON v3_unit_of_use(quantityoperatorterm(100));
CREATE INDEX v3_unit_of_use_quantityvalue_idx ON v3_unit_of_use(quantityvalue);
CREATE INDEX v3_unit_of_use_quantityunitid_idx ON v3_unit_of_use(quantityunitid);
CREATE INDEX v3_unit_of_use_quantityunitterm_idx ON v3_unit_of_use(quantityunitterm(100));        


-- CREATE Table for v3_mpp_to_tpp
-- This table lists all the MPPs and corresponding TPPs
DROP TABLE IF EXISTS v3_mpp_to_tpp;
CREATE TABLE v3_mpp_to_tpp AS
select 
    destinationId as mppid,
    get_PT(destinationId) as mppterm,
    sourceId as tppid,
    get_PT(sourceId) as tppterm
from relationships_snapshot TPPisMPP
        where TPPisMPP.sourceId in (select referencedComponentId from refset_snapshot where refsetId = 929360041000036105) -- TPP refset
        and TPPisMPP.destinationId in (select referencedComponentId from refset_snapshot where refsetId = 929360081000036101) -- MPP refset
        and TPPisMPP.typeId = 116680003 -- Is a
        and TPPisMPP.active = 1;

-- Create Indexes for v3_mpp_to_tpp table        
CREATE INDEX v3_mpp_to_tpp_mppid_idx ON v3_mpp_to_tpp(mppid);
CREATE INDEX v3_mpp_to_tpp_mppterm_idx ON v3_mpp_to_tpp(mppterm(100));
CREATE INDEX v3_mpp_to_tpp_tppid_idx ON v3_mpp_to_tpp(tppid);
CREATE INDEX v3_mpp_to_tpp_tppterm_idx ON v3_mpp_to_tpp(tppterm(100));

-- CREATE Table for v3_mpp_to_tpp
-- This table lists all the MPUUs, the strength of each BoSS, and the size of each MPUU
DROP TABLE IF EXISTS v3_total_ingredient_quantity;
CREATE TABLE v3_total_ingredient_quantity AS
select 
    strength.mpuuid as mpuuid, 
    strength.mpuuterm as mpuuterm, 
    strength.bossid as bossid,
    strength.bossterm as bossterm,
    strength.strengthvalue as strengthvalue,
    strength.unitid as strengthunitid,
    unitterm as strengthunitterm,
    substanceid as activeingredientid,
    substanceterm as activeingredientterm,
    sizevalue as sizevalue,
    sizeunitid as sizeunitid,
    sizeunitterm as sizeunitterm,
    round(strength.strengthvalue * sizevalue, 6) as totalquantity,
    hasNumeratorUnits.destinationid as totalquantityunitid,
    get_PT(hasNumeratorUnits.destinationid) as totalquantityunitterm
from v3_ingredient_strength strength
    join v3_unit_of_use uousize
        on strength.mpuuid = uousize.mpuuid

    join relationships_snapshot hasNumeratorUnits
        on strength.unitid = sourceId
        and typeid = 700000091000036104
        and active = 1;

-- Create Indexes for v3_total_ingredient_quantity table  
CREATE INDEX v3_total_ingredient_quantity_mpuuid_idx ON v3_total_ingredient_quantity(mpuuid);
CREATE INDEX v3_total_ingredient_quantity_mpuuterm_idx ON v3_total_ingredient_quantity(mpuuterm(100));
CREATE INDEX v3_total_ingredient_quantity_bossid_idx ON v3_total_ingredient_quantity(bossid);
CREATE INDEX v3_total_ingredient_quantity_bossterm_idx ON v3_total_ingredient_quantity(bossterm(100));
CREATE INDEX v3_total_ingredient_quantity_strengthvalue_idx ON v3_total_ingredient_quantity(strengthvalue);
CREATE INDEX v3_total_ingredient_quantity_strengthunitid_idx ON v3_total_ingredient_quantity(strengthunitid);
CREATE INDEX v3_total_ingredient_quantity_strengthunitterm_idx ON v3_total_ingredient_quantity(strengthunitterm(100));
CREATE INDEX v3_total_ingredient_quantity_activeingredientid_idx ON v3_total_ingredient_quantity(activeingredientid);
CREATE INDEX v3_total_ingredient_quantity_activeingredientterm_idx ON v3_total_ingredient_quantity(activeingredientterm(100));
CREATE INDEX v3_total_ingredient_quantity_sizevalue_idx ON v3_total_ingredient_quantity(sizevalue);
CREATE INDEX v3_total_ingredient_quantity_sizeunitid_idx ON v3_total_ingredient_quantity(sizeunitid);
CREATE INDEX v3_total_ingredient_quantity_sizeunitterm_idx ON v3_total_ingredient_quantity(sizeunitterm(100));
CREATE INDEX v3_total_ingredient_quantity_totalquantity_idx ON v3_total_ingredient_quantity(totalquantity);
CREATE INDEX v3_total_ingredient_quantity_totalquantityunitid_idx ON v3_total_ingredient_quantity(totalquantityunitid);
CREATE INDEX v3_total_ingredient_quantity_totalquantityunitterm_idx ON v3_total_ingredient_quantity(totalquantityunitterm(100));

-- CREATE table for v3_AMT_products
-- This table lists the seven AMT products with the IDs, preferred terms and ARTGID
DROP TABLE IF EXISTS v3_AMT_products;
CREATE TABLE v3_AMT_products ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AS

SELECT 
ctpp_tpp.sourceid CTPP_ID, 
get_PT(ctpp_tpp.sourceid) COLLATE utf8_unicode_ci CTPP_PT, 
    IF(artgid.schemeValue is null, '', artgid.schemeValue) ARTG_ID,
    ctpp_tpp.destinationid TPP_ID, 
    get_PT(ctpp_tpp.destinationid) COLLATE utf8_unicode_ci TPP_PT,
    has_tpuu.destinationid TPUU_ID,
    get_PT(has_tpuu.destinationid) COLLATE utf8_unicode_ci TPUU_PT,
    has_tp.destinationid TPP_TP_ID,
    get_PT(has_tp.destinationid) COLLATE utf8_unicode_ci TPP_TP_PT,
    tpuu_tp.destinationid TPUU_TP_ID,
    get_PT(tpuu_tp.destinationid) COLLATE utf8_unicode_ci TPUU_TP_PT,
    tpp_mpp.destinationid MPP_ID, 
    get_PT(tpp_mpp.destinationid) COLLATE utf8_unicode_ci MPP_PT,
    tpuu_mpuu.destinationid MPUU_ID,
    get_PT(tpuu_mpuu.destinationid) COLLATE utf8_unicode_ci MPUU_PT,
    mpuu_mp.destinationid MP_ID,
    get_PT(mpuu_mp.destinationid)COLLATE utf8_unicode_ci MP_PT
    
FROM transitive_closure ctpp_tpp

JOIN transitive_closure ctpp_type
ON ctpp_tpp.sourceid = ctpp_type.sourceid
AND ctpp_type.destinationid = 30537011000036101 -- CTPP concept

JOIN transitive_closure tpp_mpp 
ON tpp_mpp.sourceid = ctpp_tpp.destinationid

JOIN relationships_snapshot has_tpuu 
ON ctpp_tpp.sourceid = has_tpuu.sourceid
AND has_tpuu.typeid = 30409011000036107 -- has TPUU
AND has_tpuu.active = 1

JOIN relationships_snapshot has_tp
ON ctpp_tpp.sourceid = has_tp.sourceid 
AND has_tp.typeid = 700000101000036108 -- has TP
AND has_tp.active = 1

JOIN transitive_closure tpuu_mpuu
ON tpuu_mpuu.sourceid = has_tpuu.destinationid

JOIN transitive_closure tpuu_tp
ON tpuu_tp.sourceid = has_tpuu.destinationid

JOIN transitive_closure mpuu_mp
ON mpuu_mp.sourceid = tpuu_mpuu.destinationid

LEFT OUTER JOIN irefset_snapshot artgid
ON artgid.refsetid = 11000168105 -- ARTG Id reference set
AND artgid.referencedComponentId = ctpp_tpp.sourceid
AND artgid.active = 1

WHERE EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360041000036105 AND ctpp_tpp.destinationid = referencedComponentId) -- TPP refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a 
                JOIN refset_snapshot ON refsetid = 929360041000036105 AND sourceid = referencedComponentId
                JOIN transitive_closure b on a.sourceid = b.destinationid 
                WHERE ctpp_tpp.destinationid = a.destinationid AND ctpp_tpp.sourceid = b.sourceid)
                
AND EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360081000036101 AND tpp_mpp.destinationid = referencedComponentId) -- MPP refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a
                JOIN refset_snapshot ON refsetid = 929360081000036101 AND sourceid = referencedComponentId 
                JOIN transitive_closure b ON a.sourceid = b.destinationid 
                WHERE tpp_mpp.destinationid = a.destinationid and tpp_mpp.sourceid = b.sourceid)
                
AND EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360071000036103 AND tpuu_mpuu.destinationid = referencedComponentId) -- MPUU refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a
                JOIN refset_snapshot ON refsetid = 929360071000036103 AND sourceid = referencedComponentId 
                JOIN transitive_closure b on a.sourceid = b.destinationid 
                WHERE tpuu_mpuu.destinationid = a.destinationid AND tpuu_mpuu.sourceid = b.sourceid)
                
AND EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360021000036102 AND tpuu_tp.destinationid = referencedComponentId) -- TP refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a
                JOIN refset_snapshot ON refsetid = 929360021000036102 and sourceid = referencedComponentId 
                JOIN transitive_closure b on a.sourceid = b.destinationid 
                WHERE tpuu_tp.destinationid = a.destinationid AND tpuu_tp.sourceid = b.sourceid)
                
AND EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360061000036106 and mpuu_mp.destinationid = referencedComponentId) -- MP refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a
                JOIN refset_snapshot ON refsetid = 929360061000036106 and sourceid = referencedComponentId 
                JOIN transitive_closure b ON a.sourceid = b.destinationid 
                WHERE mpuu_mp.destinationid = a.destinationid AND mpuu_mp.sourceid = b.sourceid);

-- Create Indexes for v3_AMT_products table
CREATE INDEX v3_AMT_products_CTPP_ID_idx ON v3_AMT_products(CTPP_ID);
CREATE INDEX v3_AMT_products_CTPP_PT_idx ON v3_AMT_products(CTPP_PT(100));
CREATE INDEX v3_AMT_products_ARTG_ID_idx ON v3_AMT_products(ARTG_ID);
CREATE INDEX v3_AMT_products_TPP_ID_idx ON v3_AMT_products(TPP_ID);
CREATE INDEX v3_AMT_products_TPP_PT_idx ON v3_AMT_products(TPP_PT(100));
CREATE INDEX v3_AMT_products_TPUU_ID_idx ON v3_AMT_products(TPUU_ID);
CREATE INDEX v3_AMT_products_TPUU_PT_idx ON v3_AMT_products(TPUU_PT(100));
CREATE INDEX v3_AMT_products_TPP_TP_ID_idx ON v3_AMT_products(TPP_TP_ID);
CREATE INDEX v3_AMT_products_TPP_TP_PT_idx ON v3_AMT_products(TPP_TP_PT(100));
CREATE INDEX v3_AMT_products_TPUU_TP_ID_idx ON v3_AMT_products(TPUU_TP_ID);
CREATE INDEX v3_AMT_products_TPUU_TP_PT_idx ON v3_AMT_products(TPUU_TP_PT(100));
CREATE INDEX v3_AMT_products_MPP_ID_idx ON v3_AMT_products(MPP_ID);
CREATE INDEX v3_AMT_products_MPP_PT_idx ON v3_AMT_products(MPP_PT(100));
CREATE INDEX v3_AMT_products_MPUU_ID_idx ON v3_AMT_products(MPUU_ID);
CREATE INDEX v3_AMT_products_MPUU_PT_idx ON v3_AMT_products(MPUU_PT(100));
CREATE INDEX v3_AMT_products_MP_ID_idx ON v3_AMT_products(MP_ID);
CREATE INDEX v3_AMT_products_MP_PT_idx ON v3_AMT_products(MP_PT(100));

