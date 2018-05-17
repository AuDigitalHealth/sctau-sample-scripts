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