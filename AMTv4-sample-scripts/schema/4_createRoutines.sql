-- --------------------------------------------------------------------------------
-- CREATE ROUTINES
-- --------------------------------------------------------------------------------
USE `sctau`;

DELIMITER //

DROP FUNCTION IF EXISTS get_FSN
//
CREATE FUNCTION get_FSN(candidate bigint(20)) RETURNS varchar(2048)

BEGIN
RETURN (select term from descriptions_snapshot
        where active = 1 
        and typeId = 900000000000003001
        and conceptId = candidate);
END
//

-- In V4, there are preferred FSNs, as per alignment with the International Edition.
DROP FUNCTION IF EXISTS get_PT
//
CREATE FUNCTION get_PT(candidate bigint(20)) RETURNS varchar(2048)

BEGIN
RETURN (SELECT term
        FROM descriptions_snapshot AS D
        INNER JOIN language_refset_snapshot AS ADRS
        ON D.id = ADRS.referencedcomponentid
        WHERE D.conceptId = candidate
        AND D.typeid = 900000000000013009
        AND ADRS.refsetId = 32570271000036106
        AND ADRS.acceptabilityid = 900000000000548007        
        AND ADRS.active = 1);
END
//


DELIMITER ;