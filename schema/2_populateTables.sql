
-- ------------------------------------------------------------------------------
-- IMPORT FILES
-- ------------------------------------------------------------------------------

-- Set the database schema to owner of SCTAU tables
USE `sctau`;

-- RF2_CONCEPTS_SNAPSHOT
TRUNCATE TABLE concepts_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Terminology/sct2_Concept_Snapshot_AU1000036_20170831.txt' INTO TABLE concepts_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, definitionstatusid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_DESCRIPTIONS_SNAPSHOT
TRUNCATE TABLE descriptions_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Terminology/sct2_Description_Snapshot-en-AU_AU1000036_20170831.txt' INTO TABLE descriptions_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, conceptid, languagecode, typeid, term, casesignificanceid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_RELATIONSHIPS_SNAPSHOT
TRUNCATE TABLE relationships_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Terminology/sct2_Relationship_Snapshot_AU1000036_20170831.txt' INTO TABLE relationships_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, sourceid, destinationid, relationshipgroup, typeid, characteristictypeid, modifierid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_LANGUAGE_REFSET_SNAPSHOT
TRUNCATE TABLE language_refset_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Language/der2_cRefset_LanguageSnapshot-en-AU_AU1000036_20170831.txt' INTO TABLE language_refset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid, acceptabilityid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_REFSET_SNAPSHOT
-- NOTE: This SQL Statement will have to be executed once for every Refset file to ensure that all the Refsets in the release are in the table.
TRUNCATE TABLE refset_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_Refset_<REFSETNAME>Snapshot_AU1000036_20170831.txt' INTO TABLE refset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_CCREFSET_SNAPSHOT
-- Import extended association schema refset. Currently only one exists - Route and form extended association
TRUNCATE TABLE ccrefset_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_ccRefset_DoseRouteAndFormExtendedAssociationSnapshot_AU1000036_20170831.txt' INTO TABLE ccrefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,value1,value2) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

-- RF2_CCSREFSET_SNAPSHOT
-- Import the three concrete domain reference sets
--    * 700000111000036105	Strength reference set
--    * 700000131000036101	Unit of use quantity reference set
--    * 700000141000036106	Unit of use size reference set
--
TRUNCATE TABLE ccsrefset_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_ccsRefset_StrengthSnapshot_AU1000036_20170831.txt' INTO TABLE ccsrefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,unitid,operatorid,value) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_ccsRefset_UnitOfUseQuantitySnapshot_AU1000036_20170831.txt' INTO TABLE ccsrefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,unitid,operatorid,value) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_ccsRefset_UnitOfUseSizeSnapshot_AU1000036_20170831.txt' INTO TABLE ccsrefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,unitid,operatorid,value) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

-- RF2_CCIREFSET_SNAPSHOT
-- Import the 700000121000036103 Subpack quantity reference set
TRUNCATE TABLE ccirefset_snapshot;

LOAD DATA LOCAL INFILE 'release-files/RF2Release/Snapshot/Refset/Content/der2_cciRefset_SubpackQuantitySnapshot_AU1000036_20170831.txt' INTO TABLE ccirefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,unitid,operatorid,value) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');