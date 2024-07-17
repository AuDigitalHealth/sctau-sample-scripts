
-- ------------------------------------------------------------------------------------------------------------------
-- IMPORT FILES
-- File names are exemplar only. Please update to match the files you have downloaded.
-- xsct2 and xder2 are the current Beta naming conventions for the RF2 files.
-- Remove "LOCAL" from the LOAD DATA LOCAL INFILE statements if you are running this script on the MySQL server.
-- ------------------------------------------------------------------------------------------------------------------

-- Set the database schema to owner of xSCTAU tables
USE `sctau`;

-- RF2_CONCEPTS_SNAPSHOT
TRUNCATE TABLE concepts_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Terminology/xsct2_Concept_Snapshot_AU1000036_20231130.txt' INTO TABLE concepts_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, definitionstatusid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_DESCRIPTIONS_SNAPSHOT
TRUNCATE TABLE descriptions_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Terminology/xsct2_Description_Snapshot-en-AU_AU1000036_20231130.txt' INTO TABLE descriptions_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, conceptid, languagecode, typeid, term, casesignificanceid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_RELATIONSHIPS_SNAPSHOT
TRUNCATE TABLE relationships_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Terminology/xsct2_Relationship_Snapshot_AU1000036_20231130.txt' INTO TABLE relationships_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, sourceid, destinationid, relationshipgroup, typeid, characteristictypeid, modifierid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

-- RF2_RELATIONSHIPS_CONCRETE_VALUES_SNAPSHOT
TRUNCATE TABLE relationships_concrete_values_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Terminology/xsct2_RelationshipConcreteValues_Snapshot_AU1000036_20231130.txt' INTO TABLE relationships_concrete_values_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, sourceid, value, relationshipgroup, typeid, characteristictypeid, modifierid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

-- Remove the # character from the value field (Description logic artefact)
UPDATE relationships_concrete_values_snapshot
SET value = REPLACE(value, '#', '');

-- RF2_LANGUAGE_REFSET_SNAPSHOT
TRUNCATE TABLE language_refset_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Language/xder2_cRefset_LanguageSnapshot-en-AU_AU1000036_20231130.txt' INTO TABLE language_refset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid, acceptabilityid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_REFSET_SNAPSHOT
-- AMTv4, only a single import is required. All simple refsets exist in the same file.
LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Content/xder2_Refset_SimpleSnapshot_AU1000036_20231130.txt' INTO TABLE refset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

-- RF2_CREFSET_SNAPSHOT
-- Import historical association reference sets
TRUNCATE TABLE crefset_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Content/xder2_cRefset_AssociationSnapshot_AU1000036_20231130.txt' INTO TABLE crefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid, targetComponentid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Content/xder2_cRefset_AttributeValueSnapshot_AU1000036_20231130.txt' INTO TABLE crefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid, targetComponentid) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_CCREFSET_SNAPSHOT
-- Import extended association schema refset. Currently only one exists - Route and form extended association
TRUNCATE TABLE ccrefset_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Content/xder2_ccRefset_ExtendedAssociationSnapshot_AU1000036_20231130.txt' INTO TABLE ccrefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid,value1,value2) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');


-- RF2_IREFSET_SNAPSHOT
-- Import the 11000168105 ARTG Id reference set
TRUNCATE TABLE irefset_snapshot;

LOAD DATA LOCAL INFILE '<release-files>/Snapshot/Refset/Map/xder2_iRefset_SimpleMapSnapshot_AU1000036_20231130.txt' INTO TABLE irefset_snapshot CHARACTER SET 'utf8' LINES TERMINATED BY '\r\n' IGNORE 1 LINES
(id, @effectivetime, active, moduleid, refsetid, referencedcomponentid, schemeValue) 
set effectivetime = str_to_date(@effectivetime, '%Y%m%d');
