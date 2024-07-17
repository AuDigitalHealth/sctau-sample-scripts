-- DERIVED Objects

-- Create MPP has MPUU table
-- This table is reused in the other derived objects tables.
DROP TABLE IF EXISTS v4_MPPhasMPUU;
CREATE TABLE v4_MPPhasMPUU AS
SELECT 
    MPPhasMPUU.sourceId as mppid,
    get_PT(MPPhasMPUU.sourceId) as mppterm,
    MPPhasMPUU.destinationId as mpuuid,
    get_PT(MPPhasMPUU.destinationId) as mpuuterm

FROM relationships_snapshot MPPhasMPUU  
    WHERE MPPhasMPUU.active = 1
	 AND MPPhasMPUU.typeid IN (774160008,999000081000168101) -- Contains clinical drug / Contains device
    AND MPPhasMPUU.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360081000036101 AND active = 1) -- MPP refset
    AND MPPhasMPUU.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360071000036103 AND active = 1); -- MPUU refset

CREATE INDEX v4_MPPhasMPUU_mppid_idx ON v4_MPPhasMPUU(mppid);
CREATE INDEX v4_MPPhasMPUU_mppterm_idx ON v4_MPPhasMPUU(mppterm(100));
CREATE INDEX v4_MPPhasMPUU_mpuuid_idx ON v4_MPPhasMPUU(mpuuid);
CREATE INDEX v4_MPPhasMPUU_mpuuterm_idx ON v4_MPPhasMPUU(mpuuterm(100));


-- Create TPP contains TPUU table
-- This table is reused in the other derived objects tables.
-- Three types of queries are required for the different patterns of products
DROP TABLE IF EXISTS v4_TPPcontainsTPUU;
CREATE TABLE v4_TPPcontainsTPUU AS

-- First level of packs is simple "TPP contains TPUU" type relationships.
SELECT 
    TPPhasTPUU.sourceId as tppid,
    get_PT(TPPhasTPUU.sourceId) as tppterm,
    TPPhasTPUU.destinationId as tpuuid,
    get_PT(TPPhasTPUU.destinationId) as tpuuterm
FROM relationships_snapshot TPPhasTPUU  
    WHERE TPPhasTPUU.active = 1
	 AND TPPhasTPUU.typeid IN (774160008,999000081000168101) -- Contains clinical drug / Contains device
    AND TPPhasTPUU.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105 AND active = 1) -- TPP refset
    AND TPPhasTPUU.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100 AND active = 1) -- TPUU refset
    
UNION    
-- Second level of packs - Get the TPUU for a combinationPack
-- In AMTv4 the "containsTPUU" type relationship is not restated on combination packs.
SELECT 
    TPPcontainsPack.sourceId as tppid,
    get_PT(TPPcontainsPack.sourceId) as tppterm,
    PackhasTPUU.destinationId as tpuuid,
    get_PT(PackhasTPUU.destinationId) as tpuuterm
FROM relationships_snapshot TPPcontainsPack
JOIN relationships_snapshot PackhasTPUU
ON TPPcontainsPack.destinationid = PackhasTPUU.sourceid
    WHERE TPPcontainsPack.active = 1
    AND PackhasTPUU.active = 1
	 AND TPPcontainsPack.typeid = 999000011000168107 -- Contains packaged clinical drug
    AND TPPcontainsPack.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105 AND active = 1) -- TPP refset
    AND PackhasTPUU.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100 AND active = 1) -- TPUU refset   
	 AND PackhasTPUU.typeid IN (774160008,999000081000168101) -- Contains clinical drug / Contains device

UNION
-- Third level of packs
-- These are combination packs, where one of the components is it's self a multicomponent pack.
-- These are exceptional products with atypical modelling. 
-- Pegatron Combination Therapy with Redipen products & Viekira Pak-RBV products
SELECT 
    TPPcontainsCTPP.sourceId as tppid,
    get_PT(TPPcontainsCTPP.sourceId) as tppterm,
    CTPPcontainsTPUU.destinationId as tpuuid,
    get_PT(CTPPcontainsTPUU.destinationId) as tpuuterm
FROM relationships_snapshot TPPcontainsCTPP
JOIN relationships_snapshot CTPPcontainsCTPP
ON TPPcontainsCTPP.destinationid = CTPPcontainsCTPP.sourceid
	AND TPPcontainsCTPP.active = 1
	AND TPPcontainsCTPP.typeid = 999000011000168107 -- Contains packaged clinical drug
	AND CTPPcontainsCTPP.active = 1
	AND CTPPcontainsCTPP.typeid = 999000011000168107 -- Contains packaged clinical drug
JOIN relationships_snapshot CTPPcontainsTPUU
ON CTPPcontainsCTPP.destinationid = CTPPcontainsTPUU.sourceid
	AND CTPPcontainsTPUU.active = 1
	 AND CTPPcontainsTPUU.typeid IN (774160008,999000081000168101) -- Contains clinical drug / Contains device
	AND CTPPcontainsTPUU.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100 AND active = 1); -- TPUU refset 


CREATE INDEX v4_TPPcontainsTPUU_tppid_idx ON v4_TPPcontainsTPUU(tppid);
CREATE INDEX v4_TPPcontainsTPUU_tppterm_idx ON v4_TPPcontainsTPUU(tppterm(100));
CREATE INDEX v4_TPPcontainsTPUU_tpuuid_idx ON v4_TPPcontainsTPUU(tpuuid);
CREATE INDEX v4_TPPcontainsTPUU_tpuuterm_idx ON v4_TPPcontainsTPUU(tpuuterm(100));



-- CREATE Table for v4_ingredient_strength
-- This table lists all the MPPs, their MPUUs AND the corresponding ingredients (Active Ingredient AND BoSS) AND strengths - as either  "total quantity" in the MPUU, "Concentration" or both.
DROP TABLE IF EXISTS v4_ingredient_strength;
CREATE TABLE v4_ingredient_strength AS
SELECT 
	 mppid,
    mppterm,
    mpuuid,
    mpuuterm,
    hasIngredient.destinationid as substanceid,
    get_PT(hasIngredient.destinationid) as substanceterm,
    hasBoSS.destinationid as bossid,
    get_PT(hasBoSS.destinationid) as bossterm,
    IF(TotalQuantityValue.value is null, '', TotalQuantityValue.value) TotalQuantity,
    TotalQuantityUnit.destinationId as TotalQuantityUnitId,
    get_PT(TotalQuantityUnit.destinationid) as TotalQuantityUnitTerm,    
    IF(ConcentrationValue.value is null, '', ConcentrationValue.value) ConcentrationValue,
    ConcentrationUnit.destinationId as ConcentrationUnitId,
    get_PT(ConcentrationUnit.destinationid) as ConcentrationUnitTerm       
    
FROM v4_MPPhasMPUU MPPhasMPUU

    LEFT JOIN relationships_snapshot hasIngredient
        on MPPhasMPUU.mpuuid = hasIngredient.sourceId
        AND hasIngredient.typeId in (127489000,762949000) -- Has active ingredient (attribute) / Has precise active ingredient (attribute)
        AND hasIngredient.active = 1

    LEFT JOIN relationships_snapshot hasBoSS
        on hasIngredient.sourceId = hasBoSS.sourceId 
        AND hasIngredient.relationshipgroup = hasBoSS.relationshipgroup
        AND hasBoSS.typeId = 732943007 -- Has basis of strength substance (attribute)
        AND hasBoSS.active = 1

    LEFT JOIN relationships_concrete_values_snapshot TotalQuantityValue
        on hasBoSS.sourceId = TotalQuantityValue.sourceId
        AND hasBoSS.relationshipgroup = TotalQuantityValue.relationshipgroup
		  AND TotalQuantityValue.typeid = 999000041000168106 -- Has total quantity value (attribute)
        AND TotalQuantityValue.active = 1

    LEFT JOIN relationships_snapshot TotalQuantityUnit
        on hasBoSS.sourceId = TotalQuantityUnit.sourceId
        AND hasBoSS.relationshipgroup = TotalQuantityUnit.relationshipgroup
		  AND TotalQuantityUnit.typeid = 999000051000168108 -- Has total quantity unit (attribute)
        AND TotalQuantityUnit.active = 1


    LEFT JOIN relationships_concrete_values_snapshot ConcentrationValue
        on hasBoSS.sourceId = ConcentrationValue.sourceId
        AND hasBoSS.relationshipgroup = ConcentrationValue.relationshipgroup
		  AND ConcentrationValue.typeid = 999000021000168100 -- Has concentration strength value (attribute)
        AND ConcentrationValue.active = 1

    LEFT JOIN relationships_snapshot ConcentrationUnit
        on hasBoSS.sourceId = ConcentrationUnit.sourceId
        AND hasBoSS.relationshipgroup = ConcentrationUnit.relationshipgroup
		  AND ConcentrationUnit.typeid = 999000031000168102 -- Has concentration strength unit (attribute)        
        AND ConcentrationUnit.active = 1;


-- Create Indexes for v4_ingredient_strength table
CREATE INDEX v4_ingredient_strength ON v4_ingredient_strength(mppid);
CREATE INDEX v4_ingredient_strength_mppterm_idx ON v4_ingredient_strength(mppterm(100));
CREATE INDEX v4_ingredient_strength_mpuuid_idx ON v4_ingredient_strength(mpuuid);
CREATE INDEX v4_ingredient_strength_mpuuterm_idx ON v4_ingredient_strength(mpuuterm(100));
CREATE INDEX v4_ingredient_strength_substanceid_idx ON v4_ingredient_strength(substanceid);
CREATE INDEX v4_ingredient_strength_substanceterm_idx ON v4_ingredient_strength(substanceterm(100));
CREATE INDEX v4_ingredient_strength_bossid_idx ON v4_ingredient_strength(bossid);
CREATE INDEX v4_ingredient_strength_bossterm_idx ON v4_ingredient_strength(bossterm(100));
CREATE INDEX v4_ingredient_strength_TotalQuantity_idx ON v4_ingredient_strength(TotalQuantity);
CREATE INDEX v4_ingredient_strength_TotalQuantityUnitId_idx ON v4_ingredient_strength(TotalQuantityUnitId);
CREATE INDEX v4_ingredient_strength_TotalQuantityUnitTerm_idx ON v4_ingredient_strength(TotalQuantityUnitTerm(100));
CREATE INDEX v4_ingredient_strength_ConcentrationValue_idx ON v4_ingredient_strength(ConcentrationValue);
CREATE INDEX v4_ingredient_strength_ConcentrationUnitId_idx ON v4_ingredient_strength(ConcentrationUnitId);
CREATE INDEX v4_ingredient_strength_ConcentrationUnitTerm_idx ON v4_ingredient_strength(ConcentrationUnitTerm(100));


-- remove # from ConcentrationValue





-- CREATE Table for v4_Packs_Size_Details
-- This table lists all the MPPs, their MPUUs the size of each MPUU, AND the number of MPUU in each pack
DROP TABLE IF EXISTS v4_Packs_Size_Details;
CREATE TABLE v4_Packs_Size_Details AS
SELECT 
    mppid,
    mppterm,
    mpuuid,
    mpuuterm,
   
    MPUUHasContainerType.destinationId as MPUUContainerTypeId,
    get_PT(MPUUHasContainerType.destinationId) as MPUUContainerTypeTerm,
    
    MPUUPackSizeValue.value as MPUUPackSizeValue,
    MPUUPackSizeUnit.destinationId as MPUUPackSizeUnitId,
    get_PT(MPUUPackSizeUnit.destinationId) as MPUUPackSizeUnitTerm,

    MPPPackSizeValue.value as MPUUinMPPQuantityValue,
    MPPPackSizeUnit.destinationId as MPUUinMPPQuantityunitid,
    get_PT(MPPPackSizeUnit.destinationId) as MPUUinMPPQuantityUnitterm
    
FROM v4_MPPhasMPUU MPPhasMPUU  
LEFT JOIN relationships_snapshot MPUUHasContainerType
        on MPPhasMPUU.mpuuid = MPUUHasContainerType.sourceId
		  AND MPUUHasContainerType.active = 1
        AND MPUUHasContainerType.typeId = 30465011000036106 -- Has container type (attribute)

	 LEFT JOIN relationships_concrete_values_snapshot MPUUPackSizeValue
        on MPPhasMPUU.mpuuid = MPUUPackSizeValue.sourceId
		  AND MPUUPackSizeValue.typeid = 1142142004 -- Has pack size (attribute)
        AND MPUUPackSizeValue.active = 1 

    LEFT JOIN relationships_snapshot MPUUPackSizeUnit
        on MPUUPackSizeValue.sourceId = MPUUPackSizeUnit.sourceId
        AND MPUUPackSizeValue.relationshipgroup = MPUUPackSizeUnit.relationshipgroup
		  AND MPUUPackSizeUnit.typeid = 774163005 -- Has pack size unit (attribute)
        AND MPUUPackSizeUnit.active = 1
        
    LEFT JOIN relationships_concrete_values_snapshot MPPPackSizeValue
        on MPPhasMPUU.mppid = MPPPackSizeValue.sourceId
		  AND MPPPackSizeValue.typeid = 1142142004 -- Has pack size (attribute)
        AND MPPPackSizeValue.active = 1 

    LEFT JOIN relationships_snapshot MPPPackSizeUnit
        on MPPPackSizeValue.sourceId = MPPPackSizeUnit.sourceId
        AND MPPPackSizeValue.relationshipgroup = MPPPackSizeUnit.relationshipgroup
		  AND MPPPackSizeUnit.typeid = 774163005 -- Has pack size unit (attribute)
        AND MPPPackSizeUnit.active = 1;

-- Create Indexes for v4_Packs_Size_Details table
CREATE INDEX v4_Packs_Size_Details_mppid_idx ON v4_Packs_Size_Details(mppid);
CREATE INDEX v4_Packs_Size_Details_mppterm_idx ON v4_Packs_Size_Details(mppterm(100));
CREATE INDEX v4_Packs_Size_Details_mpuuid_idx ON v4_Packs_Size_Details(mpuuid);
CREATE INDEX v4_Packs_Size_Details_mpuuterm_idx ON v4_Packs_Size_Details(mpuuterm(100));
CREATE INDEX v4_Packs_Size_Details_unitofuseid_idx ON v4_packs_size_details(MPUUContainerTypeId);
CREATE INDEX v4_Packs_Size_Details_unitofuseterm_idx ON v4_Packs_Size_Details(MPUUContainerTypeTerm(100));
CREATE INDEX v4_Packs_Size_Details_sizevalue_idx ON v4_Packs_Size_Details(MPUUPackSizeValue);
CREATE INDEX v4_Packs_Size_Details_sizeunitid_idx ON v4_Packs_Size_Details(MPUUPackSizeUnitId);
CREATE INDEX v4_Packs_Size_Details_sizeunitterm_idx ON v4_Packs_Size_Details(MPUUPackSizeUnitTerm(100));
CREATE INDEX v4_Packs_Size_Details_quantityvalue_idx ON v4_Packs_Size_Details(MPUUinMPPQuantityValue);
CREATE INDEX v4_Packs_Size_Details_quantityunitid_idx ON v4_Packs_Size_Details(MPUUinMPPQuantityunitid);
CREATE INDEX v4_Packs_Size_Details_quantityunitterm_idx ON v4_Packs_Size_Details(MPUUinMPPQuantityUnitterm(100));


-- CREATE Table for v4_mpp_to_tpp
-- This table lists all the MPPs AND corresponding TPPs
DROP TABLE IF EXISTS v4_mpp_to_tpp;
CREATE TABLE v4_mpp_to_tpp AS
SELECT 
    destinationId as mppid,
    get_PT(destinationId) as mppterm,
    sourceId as tppid,
    get_PT(sourceId) as tppterm
FROM relationships_snapshot TPPisMPP
        WHERE TPPisMPP.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105) -- TPP refset
        AND TPPisMPP.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360081000036101) -- MPP refset
        AND TPPisMPP.typeId = 116680003 -- Is a
        AND TPPisMPP.active = 1;

-- Create Indexes for v4_mpp_to_tpp table        
CREATE INDEX v4_mpp_to_tpp_mppid_idx ON v4_mpp_to_tpp(mppid);
CREATE INDEX v4_mpp_to_tpp_mppterm_idx ON v4_mpp_to_tpp(mppterm(100));
CREATE INDEX v4_mpp_to_tpp_tppid_idx ON v4_mpp_to_tpp(tppid);
CREATE INDEX v4_mpp_to_tpp_tppterm_idx ON v4_mpp_to_tpp(tppterm(100));

-- A an equivalent to the v3_total_ingredient_quantity table is not required
-- as total_ingredient_quantity is included in the v4_ingredient_strength table
-- For all discrete form MPUUs the total quantity is the strength
-- For continuant forms the total quantity is provided when both the concentration AND MPUU size are known.


-- Create a table of the MPUU-MP pairs.
-- Requires extra SQL criteria because a multi-ingredient MPUU have multiple ancestor MPs
-- It's proximal MP - has the same set of ingredients - but it may also be a subtype of subsets of these ingredients if such other products also exist
-- Additionally v4 introduces other intermediate concepts that are not MPs. Such as MP-Form.
DROP TABLE IF EXISTS v4_MPUU_ISA_MP;
CREATE TABLE v4_MPUU_ISA_MP AS

SELECT distinct MPUU_MP.sourceId as mpuuid,
    get_PT(MPUU_MP.sourceId) as mpuuterm,
    MPUU_MP.destinationId as mpid,
    get_PT(MPUU_MP.destinationId) as mpterm,
    
    --  Subquery TO sort the identified MPs by MP_PT length
	--  as other MPs with less ingredients/or modifications may be present too.
    ROW_NUMBER() OVER (
            PARTITION BY mpuuid
            ORDER BY LENGTH(mpterm) DESC
        ) AS rn   
FROM transitive_closure MPUU_MP
WHERE MPUU_MP.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360071000036103 AND active = 1) -- MPUU refset
AND MPUU_MP.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360061000036106 AND active = 1) -- MP refset

-- Nested condition to exclude MPs that are also anecestors of other MPs sharing the same MPUU.
AND MPUU_MP.destinationId NOT IN (SELECT MP_MP.destinationId as ancestorMPid	     
												FROM transitive_closure NESTED
												LEFT JOIN transitive_closure MP_MP
												ON NESTED.destinationid = MP_MP.sourceId
												WHERE NESTED.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360071000036103 AND active = 1) -- MPUU refset
												AND NESTED.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360061000036106 AND active = 1) -- MP refset
												AND MP_MP.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360061000036106 AND active = 1) -- MP refset												
												AND NESTED.sourceid = MPUU_MP.sourceid
												);

-- Remove the less specific ancestor MPs based on the MP_PT length sort
-- And drop the sort column.
DELETE FROM v4_MPUU_ISA_MP
WHERE rn != 1;
ALTER TABLE v4_MPUU_ISA_MP
DROP COLUMN rn;
										
CREATE INDEX v4_MPUU_ISA_MP_mpuuid_idx ON v4_MPUU_ISA_MP(mpuuid);
CREATE INDEX v4_MPUU_ISA_MP_mpuuterm_idx ON v4_MPUU_ISA_MP(mpuuterm(100));
CREATE INDEX v4_MPPhasMPUU_mpid_idx ON v4_MPUU_ISA_MP(mpid);
CREATE INDEX v4_MPPhasMPUU_mpterm_idx ON v4_MPUU_ISA_MP(mpterm(100));



-- CREATE table for v4_AMT_products
-- This table lists the seven AMT products with the IDs, preferred terms AND ARTGID
DROP TABLE IF EXISTS v4_AMT_products;
CREATE TABLE v4_AMT_products AS

SELECT 
	 ctpp_tpp.sourceid CTPP_ID, 
	 get_PT(ctpp_tpp.sourceid) COLLATE utf8_unicode_ci CTPP_PT, 
    IF(artgid.schemeValue is null, '', artgid.schemeValue) ARTG_ID,
 
    ctpp_tpp.destinationid TPP_ID, 
    get_PT(ctpp_tpp.destinationid) COLLATE utf8_unicode_ci TPP_PT,
    
	 tpp_tpuu.tpuuid TPUU_ID,
    get_PT(tpp_tpuu.tpuuid) COLLATE utf8_unicode_ci TPUU_PT,
    
	 tpp_tp.destinationid TPP_TP_ID,
    get_PT(tpp_tp.destinationid) COLLATE utf8_unicode_ci TPP_TP_PT,
    
	 tpuu_tp.destinationid TPUU_TP_ID,
    get_PT(tpuu_tp.destinationid) COLLATE utf8_unicode_ci TPUU_TP_PT,
    
	 tpp_mpp.destinationid MPP_ID, 
    get_PT(tpp_mpp.destinationid) COLLATE utf8_unicode_ci MPP_PT,
    
	 tpuu_mpuu.destinationid MPUU_ID,
    get_PT(tpuu_mpuu.destinationid) COLLATE utf8_unicode_ci MPUU_PT,
    
	 mpuu_mp.mpid MP_ID,
    get_PT(mpuu_mp.mpid)COLLATE utf8_unicode_ci MP_PT

FROM transitive_closure ctpp_tpp


JOIN transitive_closure tpp_mpp 
ON tpp_mpp.sourceid = ctpp_tpp.destinationid

JOIN v4_TPPcontainsTPUU tpp_tpuu
ON ctpp_tpp.destinationid = tpp_tpuu.tppid

JOIN relationships_snapshot tpp_tp
ON ctpp_tpp.destinationId = tpp_tp.sourceid 
AND tpp_tp.typeid = 774158006 -- Has product name
AND tpp_tp.active = 1

JOIN transitive_closure tpuu_mpuu
ON tpuu_mpuu.sourceid = tpp_tpuu.tpuuid

JOIN relationships_snapshot tpuu_tp
ON tpuu_tp.sourceid = tpp_tpuu.tpuuid
AND tpuu_tp.typeid = 774158006 -- Has product name
AND tpuu_tp.active = 1

JOIN v4_mpuu_isa_mp mpuu_mp
ON mpuu_mp.mpuuid = tpuu_mpuu.destinationid

LEFT OUTER JOIN irefset_snapshot artgid
ON ctpp_tpp.sourceid = artgid.referencedComponentId
AND artgid.refsetid = 11000168105 -- ARTG Id reference set
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
               
AND EXISTS (SELECT 'a' FROM refset_snapshot WHERE refsetid = 929360061000036106 and mpuu_mp.mpid = referencedComponentId) -- MP refset
AND NOT EXISTS (SELECT 'a' FROM transitive_closure a
                JOIN refset_snapshot ON refsetid = 929360061000036106 and sourceid = referencedComponentId 
                JOIN transitive_closure b ON a.sourceid = b.destinationid 
                WHERE mpuu_mp.mpid = a.destinationid AND mpuu_mp.mpuuid = b.sourceid)
ORDER BY CTPP_PT,TPUU_PT;

-- Create Indexes for v4_AMT_products table
CREATE INDEX v4_AMT_products_CTPP_ID_idx ON v4_AMT_products(CTPP_ID);
CREATE INDEX v4_AMT_products_CTPP_PT_idx ON v4_AMT_products(CTPP_PT(100));
CREATE INDEX v4_AMT_products_ARTG_ID_idx ON v4_AMT_products(ARTG_ID);
CREATE INDEX v4_AMT_products_TPP_ID_idx ON v4_AMT_products(TPP_ID);
CREATE INDEX v4_AMT_products_TPP_PT_idx ON v4_AMT_products(TPP_PT(100));
CREATE INDEX v4_AMT_products_TPUU_ID_idx ON v4_AMT_products(TPUU_ID);
CREATE INDEX v4_AMT_products_TPUU_PT_idx ON v4_AMT_products(TPUU_PT(100));
CREATE INDEX v4_AMT_products_TPP_TP_ID_idx ON v4_AMT_products(TPP_TP_ID);
CREATE INDEX v4_AMT_products_TPP_TP_PT_idx ON v4_AMT_products(TPP_TP_PT(100));
CREATE INDEX v4_AMT_products_TPUU_TP_ID_idx ON v4_AMT_products(TPUU_TP_ID);
CREATE INDEX v4_AMT_products_TPUU_TP_PT_idx ON v4_AMT_products(TPUU_TP_PT(100));
CREATE INDEX v4_AMT_products_MPP_ID_idx ON v4_AMT_products(MPP_ID);
CREATE INDEX v4_AMT_products_MPP_PT_idx ON v4_AMT_products(MPP_PT(100));
CREATE INDEX v4_AMT_products_MPUU_ID_idx ON v4_AMT_products(MPUU_ID);
CREATE INDEX v4_AMT_products_MPUU_PT_idx ON v4_AMT_products(MPUU_PT(100));
CREATE INDEX v4_AMT_products_MP_ID_idx ON v4_AMT_products(MP_ID);
CREATE INDEX v4_AMT_products_MP_PT_idx ON v4_AMT_products(MP_PT(100));
