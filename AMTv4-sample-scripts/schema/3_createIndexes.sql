
-- Create indexes to support queries executed on sample SCT-AU -- SNAPSHOT tables

-- Set the database schema to owner of SCTAU tables
USE `sctau`;

CREATE INDEX concepts_active_snap_idx ON concepts_snapshot(active);
CREATE INDEX concepts_id_snap_idx ON concepts_snapshot(id);

CREATE INDEX descriptions_active_snap_idx ON descriptions_snapshot(active);
CREATE INDEX descriptions_id_snap_idx ON descriptions_snapshot(id);
CREATE INDEX descriptions_concept_id_snap_idx ON descriptions_snapshot(conceptid);
CREATE INDEX descriptions_term_snap_idx ON descriptions_snapshot(term);
CREATE INDEX descriptions_type_id_snap_idx ON descriptions_snapshot(typeid);

CREATE INDEX relationships_active_snap_idx ON relationships_snapshot(active);
CREATE INDEX relationships_sourceid_snap_idx ON relationships_snapshot(sourceid);
CREATE INDEX relationships_typeid_snap_idx ON relationships_snapshot(typeid);
CREATE INDEX relationships_destinationid_snap_idx ON relationships_snapshot(destinationid);

CREATE INDEX relationships_concrete_values_active_snap_idx ON relationships_concrete_values_snapshot(active);
CREATE INDEX relationships_concrete_values_sourceid_snap_idx ON relationships_concrete_values_snapshot(sourceid);
CREATE INDEX relationships_concrete_values_typeid_snap_idx ON relationships_concrete_values_snapshot(typeid);

CREATE INDEX lang_refset_active_snap_idx ON language_refset_snapshot(active);
CREATE INDEX lang_refset_refset_id_snap_idx ON language_refset_snapshot(refsetId);
CREATE INDEX lang_refset_referenced_description_id_snap_idx ON language_refset_snapshot(referencedcomponentid);

CREATE INDEX refset_active_snap_idx ON refset_snapshot(active);
CREATE INDEX refset_refset_id_snap_idx ON refset_snapshot(refsetid);
CREATE INDEX refset_referenced_concept_id_snap_idx ON refset_snapshot(referencedcomponentid);

CREATE INDEX crefset_active_snap_idx ON crefset_snapshot(active);
CREATE INDEX crefset_refset_id_snap_idx ON crefset_snapshot(refsetid);
CREATE INDEX crefset_referenced_component_id_snap_idx ON crefset_snapshot(referencedcomponentid);
CREATE INDEX crefset_target_component_id_snap_idx ON crefset_snapshot(targetComponentid);

CREATE INDEX ccrefset_active_snap_idx ON ccrefset_snapshot(active);
CREATE INDEX ccrefset_referenced_concept_id_snap_idx ON ccrefset_snapshot(referencedcomponentid);
CREATE INDEX ccrefset_value1_snap_idx ON ccrefset_snapshot(value1);
CREATE INDEX ccrefset_value2_snap_idx ON ccrefset_snapshot(value2);

CREATE INDEX irefset_active_snap_idx ON irefset_snapshot(active);
CREATE INDEX irefset_referenced_component_id_snsp_idx ON irefset_snapshot(referencedcomponentid);
CREATE INDEX irefset_scheme_value_snap_idx ON irefset_snapshot(schemeValue);