/* --------------------------------------------------------------------------
-- Demonstration SNOMED CT-AU Schema creation script
-- The script creates the schema and associated SNAPSHOT tables 
-- to provide platform for installing & querying SNOMED CT-AU 
-- content:
------------------------------------------------------------------------*/

-- Set the database schema to owner of SCTAU tables
USE `sctau`;

--
-- Table structure for table `concepts_snapshot`
--

DROP TABLE IF EXISTS `concepts_snapshot`;
CREATE TABLE IF NOT EXISTS `concepts_snapshot` (
  `id` bigint(18) NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `definitionstatusid` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `descriptions_snapshot`
--

DROP TABLE IF EXISTS `descriptions_snapshot`;
CREATE TABLE IF NOT EXISTS `descriptions_snapshot` (
  `id` bigint(18) NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `conceptid` bigint(18) NOT NULL,
  `languagecode` varchar(10) collate utf8_unicode_ci NOT NULL,
  `typeid` bigint(18) NOT NULL,
  `term` varchar(2048) collate utf8_unicode_ci NOT NULL,
  `casesignificanceid` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`),
  CONSTRAINT FOREIGN KEY (conceptid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (moduleid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (typeid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `relationships_snapshot`
--

DROP TABLE IF EXISTS `relationships_snapshot`;
CREATE TABLE IF NOT EXISTS `relationships_snapshot` (
  `id` bigint(18) NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `sourceid` bigint(18) NOT NULL,
  `destinationid` bigint(18) NOT NULL,
  `relationshipgroup` bigint(18) NOT NULL,
  `typeid` bigint(18) NOT NULL,
  `characteristictypeid` bigint(18) NOT NULL,
  `modifierid` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`),
  CONSTRAINT FOREIGN KEY (moduleid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (typeid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (characteristictypeid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (sourceid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (destinationid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `language_refset_snapshot`
--

DROP TABLE IF EXISTS `language_refset_snapshot`;
CREATE TABLE IF NOT EXISTS `language_refset_snapshot` (
  `id` varchar(36) collate utf8_unicode_ci NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `refsetid` bigint(18) NOT NULL,
  `referencedcomponentid` bigint(18) NOT NULL,
  `acceptabilityid` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`),
  CONSTRAINT FOREIGN KEY (moduleid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (refsetid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (referencedcomponentid) REFERENCES descriptions_snapshot(id) ON DELETE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `refset_snapshot`
-- Stores all simple type reference sets
--

DROP TABLE IF EXISTS `refset_snapshot`;
CREATE TABLE IF NOT EXISTS `refset_snapshot` (
  `id` varchar(36) collate utf8_unicode_ci NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `refsetid` bigint(18) NOT NULL,
  `referencedcomponentid` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`),
  CONSTRAINT FOREIGN KEY (moduleid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (refsetid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (referencedcomponentid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `ccrefset_snapshot`
-- Required for use of Dose route and form extended association reference set
--

DROP TABLE IF EXISTS `ccrefset_snapshot`;
CREATE TABLE IF NOT EXISTS `ccrefset_snapshot` (
  `id` varchar(36) collate utf8_unicode_ci NOT NULL,
  `effectivetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `active` int(1) NOT NULL,
  `moduleid` bigint(18) NOT NULL,
  `refsetid` bigint(18) NOT NULL,
  `referencedcomponentid` bigint(18) NOT NULL,
  `value1` bigint(18) NOT NULL,
  `value2` bigint(18) NOT NULL,
  PRIMARY KEY  (`id`,`effectivetime`),
  CONSTRAINT FOREIGN KEY (moduleid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (refsetid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (referencedcomponentid) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (value1) REFERENCES concepts_snapshot(id) ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (value2) REFERENCES concepts_snapshot(id) ON DELETE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `ccsrefset_snapshot`
-- Stores the following three concrete domain reference sets:
--    * 700000111000036105	Strength reference set
--    * 700000131000036101	Unit of use quantity reference set
--    * 700000141000036106	Unit of use size reference set
--

DROP TABLE IF EXISTS ccsrefset_snapshot;
CREATE TABLE IF NOT EXISTS ccsrefset_snapshot (
  id varchar(36) collate utf8_unicode_ci NOT NULL,
  effectivetime timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  active int(11) NOT NULL,
  moduleid bigint(20) NOT NULL,
  refsetid bigint(20) NOT NULL,
  referencedcomponentid bigint(20) NOT NULL,
  unitid bigint(20) NOT NULL,
  operatorid bigint(20) NOT NULL,
  value varchar(255) collate utf8_unicode_ci NOT NULL
--  PRIMARY KEY  (id,effective_time)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `ccirefset_snapshot`
-- Stores the 700000121000036103 Subpack quantity reference set
--

DROP TABLE IF EXISTS ccirefset_snapshot;
CREATE TABLE IF NOT EXISTS ccirefset_snapshot (
  id varchar(36) collate utf8_unicode_ci NOT NULL,
  effectivetime timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  active int(11) NOT NULL,
  moduleid bigint(20) NOT NULL,
  refsetid bigint(20) NOT NULL,
  referencedcomponentid bigint(20) NOT NULL,
  unitid bigint(20) NOT NULL,
  operatorid bigint(20) NOT NULL,
  value INT UNSIGNED NOT NULL
--  PRIMARY KEY  (id,effective_time)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

