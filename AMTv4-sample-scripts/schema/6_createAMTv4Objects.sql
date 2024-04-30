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


-- Create TPP has TPUU table
-- This table is reused in the other derived objects tables.
DROP TABLE IF EXISTS v4_TPPhasTPUU;
CREATE TABLE v4_TPPhasTPUU AS
SELECT 
    TPPhasTPUU.sourceId as tppid,
    get_PT(TPPhasTPUU.sourceId) as tppterm,
    TPPhasTPUU.destinationId as tpuuid,
    get_PT(TPPhasTPUU.destinationId) as tpuuterm

FROM relationships_snapshot TPPhasTPUU  
    WHERE TPPhasTPUU.active = 1
	 AND TPPhasTPUU.typeid IN (774160008,999000081000168101) -- Contains clinical drug / Contains device
    AND TPPhasTPUU.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105 AND active = 1) -- TPP refset
    AND TPPhasTPUU.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100 AND active = 1); -- TPUU refset

CREATE INDEX v4_TPPhasTPUU_tppid_idx ON v4_TPPhasTPUU(tppid);
CREATE INDEX v4_TPPhasTPUU_tppterm_idx ON v4_TPPhasTPUU(tppterm(100));
CREATE INDEX v4_TPPhasTPUU_tpuuid_idx ON v4_TPPhasTPUU(tpuuid);
CREATE INDEX v4_TPPhasTPUU_tpuuterm_idx ON v4_TPPhasTPUU(tpuuterm(100));


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

-- Clean up the numeric columns by removing the # character
UPDATE v4_ingredient_strength SET ConcentrationValue = REPLACE(ConcentrationValue, '#', '');
UPDATE v4_ingredient_strength SET TotalQuantity = REPLACE(TotalQuantity, '#', '');


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
    get_PT(MPUU_MP.destinationId) as mpterm   
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
										
CREATE INDEX v4_MPUU_ISA_MP_mpuuid_idx ON v4_MPUU_ISA_MP(mpuuid);
CREATE INDEX v4_MPUU_ISA_MP_mpuuterm_idx ON v4_MPUU_ISA_MP(mpuuterm(100));
CREATE INDEX v4_MPPhasMPUU_mpid_idx ON v4_MPUU_ISA_MP(mpid);
CREATE INDEX v4_MPPhasMPUU_mpterm_idx ON v4_MPUU_ISA_MP(mpterm(100));




-- CREATE table for v4_AMT_products
-- This table lists the seven AMT products with the IDs, preferred terms AND ARTGID
DROP TABLE IF EXISTS v4_AMT_products;
CREATE TABLE v4_AMT_products AS

SELECT
    CTPP_TPP.sourceId as ctppid,
    get_PT(CTPP_TPP.sourceId) as ctppterm,
    
    IF(artgid.schemeValue is null, '', artgid.schemeValue) ARTG_ID,
    
    CTPP_TPP.destinationId as tppid,
    get_PT(CTPP_TPP.destinationId) as tppterm,
    
    tpp_tpuu.destinationId as tpuuid,
    get_PT(tpp_tpuu.destinationId) as tpuuterm,
    
    CTPP_ProductName.destinationId as CTPP_ProductName_id,
    get_PT(CTPP_ProductName.destinationId) as CTPP_ProductName_term,
    
    TPUU_ProductName.destinationId as TPUU_ProductName_id,
    get_PT(TPUU_ProductName.destinationId) as TPUU_ProductName_term,
    
    mpp_tpp.mppid as mppid,
    mpp_tpp.mppterm as mppterm,
    
    tpuu_mpuu.destinationId as mpuuid,
    get_PT(tpuu_mpuu.destinationId) as mpuuterm,
      
    mpuu_mp.mpid as mp_id,
    mpuu_mp.mpterm AS mp_term
    
FROM relationships_snapshot CTPP_TPP
LEFT JOIN irefset_snapshot artgid
	ON CTPP_TPP.sourceid = artgid.referencedComponentId
	
LEFT JOIN v4_mpp_to_tpp mpp_tpp
   ON CTPP_TPP.destinationid = mpp_tpp.tppid
   
LEFT JOIN relationships_snapshot tpp_tpuu
   ON mpp_tpp.tppid = tpp_tpuu.sourceid
   
LEFT JOIN relationships_snapshot CTPP_ProductName
   ON CTPP_TPP.sourceid = CTPP_ProductName.sourceid

LEFT JOIN relationships_snapshot tpuu_mpuu
   ON tpuu_mpuu.sourceid = tpp_tpuu.destinationid

LEFT JOIN relationships_snapshot TPUU_ProductName
   ON tpp_tpuu.destinationid = TPUU_ProductName.sourceid   

LEFT JOIN v4_MPUU_ISA_MP mpuu_mp
	ON tpuu_mpuu.destinationid = mpuu_mp.mpuuid
   
WHERE 
-- CTPP IS A TPP filters
CTPP_TPP.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360051000036108) -- CTPP refset
AND CTPP_TPP.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105) -- TPP refset
AND CTPP_TPP.typeId = 116680003 -- Is a
AND CTPP_TPP.active = 1

-- TPP contains TPUU filters
AND tpp_tpuu.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360041000036105) -- TPP refset
AND tpp_tpuu.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100) -- TPUU refset
AND tpp_tpuu.typeid IN (774160008,999000081000168101) -- Contains clinical drug, Contains device
AND tpp_tpuu.active = 1

-- CTPP_ProductName filters
AND CTPP_ProductName.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360051000036108) -- CTPP refset
AND CTPP_ProductName.typeid = 774158006 -- Has product name
AND CTPP_ProductName.active = 1

-- TPUU IS A MPP filters
AND tpuu_mpuu.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100) -- TPUU refset
AND tpuu_mpuu.destinationId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360071000036103) -- MPUU refset
AND tpuu_mpuu.typeid = 116680003 -- Is a
AND tpuu_mpuu.active = 1

-- TPUU_ProductName filters
AND TPUU_ProductName.sourceId in (SELECT referencedComponentId FROM refset_snapshot WHERE refsetId = 929360031000036100) -- TPUU refset
AND TPUU_ProductName.typeid = 774158006 -- Has product name
AND TPUU_ProductName.active = 1;

CREATE INDEX v4_AMT_products_ctppid_idx ON v4_AMT_products(ctppid);
CREATE INDEX v4_AMT_products_ctppterm_idx ON v4_AMT_products(ctppterm(100));
CREATE INDEX v4_AMT_products_ARTG_ID_idx ON v4_AMT_products(ARTG_ID);
CREATE INDEX v4_AMT_products_tppid_idx ON v4_AMT_products(tppid);
CREATE INDEX v4_AMT_products_tppterm_idx ON v4_AMT_products(tppterm(100));
CREATE INDEX v4_AMT_products_tpuuid_idx ON v4_AMT_products(tpuuid);
CREATE INDEX v4_AMT_products_tpuuterm_idx ON v4_AMT_products(tpuuterm(100));
CREATE INDEX v4_AMT_products_CTPP_ProductName_id_idx ON v4_AMT_products(CTPP_ProductName_id);
CREATE INDEX v4_AMT_products_CTPP_ProductName_term_idx ON v4_AMT_products(CTPP_ProductName_term(100));
CREATE INDEX v4_AMT_products_TPUU_ProductName_id_idx ON v4_AMT_products(TPUU_ProductName_id);
CREATE INDEX v4_AMT_products_TPUU_ProductName_term_idx ON v4_AMT_products(TPUU_ProductName_term(100));
CREATE INDEX v4_AMT_products_mppid_idx ON v4_AMT_products(mppid);
CREATE INDEX v4_AMT_products_mppterm_idx ON v4_AMT_products(mppterm(100));
CREATE INDEX v4_AMT_products_mpuuid_idx ON v4_AMT_products(mpuuid);
CREATE INDEX v4_AMT_products_mpuuterm_idx ON v4_AMT_products(mpuuterm(100));
CREATE INDEX v4_AMT_products_mp_id_idx ON v4_AMT_products(mp_id);
CREATE INDEX v4_AMT_products_mp_term_idx ON v4_AMT_products(mp_term(100));

