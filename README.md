##### *NOTE: It is not recommended that the terminology services be accessed through SQL. The following methods are suggested as an alternative:*
##### *FHIR*: https://www.healthterminologies.gov.au/specs/v2/conformant-server-apps/fhir-api
##### *Syndication API*: https://www.healthterminologies.gov.au/specs/v2/conformant-server-apps/syndication-api 

# SNOMED CT-AU Australian Terminology Sample Scripts
The purpose of these scripts, which are designed to align to the RF2 release structure of SNOMED CT-AU, is to explain and illustrate the release format of SNOMED CT-AU for those wishing to learn and understand its details. Section 9 of the [SNOMED CT-AU Australian Technical Implementation Guide](https://www.healthterminologies.gov.au/docs/DH_2697_2018_SNOMEDCT-AU_AustralianTechnicalImplementationGuide_v2.3.pdf) describes these scripts and the release format in detail.

These scripts *are NOT* recommended as a method of implementing SNOMED CT-AU, a terminology server and/or a bespoke data structure for the particular requirements should be used instead. Detail knowledge of the release format described by these scripts and the implementation guide are required to build, but *not* when using an appropriate terminology server, which will abstract these details away and typically provide much more relevant search functionality and algorithms.

The National Clinical Terminology Service provides an HL7 FHIR terminology service endpoint containing up to date terminologies for Australia, the [National Terminology Server](https://www.healthterminologies.gov.au/tools?content=nts). The NCTS also makes available the terminology server software available at this endpoint free for use in Australian health care which can synchronise in content from the NCTS and be augmented with additional FHIR terminology resources as required, [more details on this refer to the NCTS website](https://www.healthterminologies.gov.au/tools?content=onto).

Vendors and implementers in Australia are encouraged to use these services where possible to avoid the duplicated effort of implementing the details described by these scripts and insulate themselves from possible future change to them.

# Prerequisites
These scripts are based around MySQL, so access to a MySQL or MariaDB server is required. The scripts also assume a schema/database exists in the server called "sctau", this must be created and available to the user executing the scripts contained in this repository.

The scripts also require an unpacked release of SNOMED CT-AU available. SNOMED CT-AU may be downloaded from <https://www.healthterminologies.gov.au/access> or using the [National Syndication Server](https://www.healthterminologies.gov.au/tools?content=nts) for automated downloading.

# How to use these scripts
The scripts can be executed using any client to the MySQL/MariaDB server being used. The instructions below assume using the MySQL command line client.

1. The creation scripts contained in the NCTIS_Australian_Terminology_Sample_Scripts.zip file need to be executed in the following order:

```
mysql> source /schema/1_createSchema.sql

mysql> source /schema/2_populateTables.sql

mysql> source /schema/3_createIndexes.sql

mysql> source /schema/4_createRoutines.sql

mysql> source /schema/5_createTransitiveClosure.sql

mysql> source /schema/6_createAMTObjects.sql
```

2. The 2_populateTables.sql script contains relative paths to the RF2 files. 
Depending on the operating system and version of mysql, you may need to amend these and replace with the full path. 
For example:
	```
	release-files/RF2Release/Snapshot/Terminology/sct2_Concept_Snapshot_AU1000036_20170831.txt
	```
	changes to 
	```
	C:/Users/SomeUser/Downloads/release-files/RF2Release/Snapshot/Terminology/sct2_Concept_Snapshot_AU1000036_20170831.txt
	```

3. The 5_createTransitiveClosure.sql file creates a procedure, which upon execution creates the transitive_closure table 
	The creation of the transitive closure will take some time, up to 20 minutes, depending on the local system specifications.


4. Use case examples contained within each file:
	* AMT_use-cases.sql
		* Search for all MPPs and TPPs based with an intended active ingredient a word containing 'amoxy'
		* Show dose forms of 4 sample MPPs
		* List ingredient strengths for a given MPP
		* List unit of use size and quantity for a given MPP
		* List acceptable TPPs (for dispensing) for a given MPP
		* List acceptable substitutable TPPs, and associated CTPPs (for dispensing) for a given TPP (brand substitute)
		* Find all MPUUs containing more than 10 milligrams of codeine, in tablet form
		* Find all MPUUs containing dihydrocodeine, in any tablet form
		* Query MPPs and corresponding concepts that have sub roles to subtype MPUUs of 'paracetamol 500 mg tablet' in them
		* Appending ARTGID to CTPPs in the S8 refset
		* Deriving TPPs from CTPPs
		* Deriving MPUUs from TPUUs in the reference set
		* Deriving TPUUs and MPUUs from CTPPs in the reference set
	* query-extract.sql
		* Search the Musculoskeletal finding reference set for all concepts that are related to the Foot structure based on Finding site
		* List all available descriptions for conceptId 387517004 Paracetamol
		* List all descriptions that are referenced in the ADRS for concept 387517004 Paracetamol
		* The current Preferred Term for concept 387517004 Paracetamol
		* List all available descriptions for conceptId 837621000168102 Bordetella pertussis filamentous haemagglutinin antigen + Bordetella pertussis pertactin antigen + Bordetella pertussis toxoid + diphtheria toxoid + tetanus toxoid (medicinal product)
		* The current Preferred Term for concept 837621000168102 Bordetella pertussis filamentous haemagglutinin antigen + Bordetella pertussis pertactin antigen + Bordetella pertussis toxoid + diphtheria toxoid + tetanus toxoid (medicinal product)
		* Restrict the search for term ulcer to Clinical findings reference set
		* List Animal bite wound concepts, excluding the Arthropod bite wounds
		* Intersection of Congenital diseases and Anaemias
		* Alternative query to list intersection of Congenital diseases and Anaemias
	* sample_queries.sql
		* Find active concept by term 
		* List the Fully Specified Name and Synonym(s) for a concept
		* List all MEMBERS(descriptions) of a reference set
		* List of Australian reference sets & member count 
		* List of descendants of the Fetal finding hierarchy
		* Applying the Clincal Finding Grouper Exclusion RefSet against the Fetal Finding hierarchy
		* Finding terms within a specific hierarchy
		
