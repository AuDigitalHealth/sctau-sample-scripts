USE `sctau`;

DELIMITER //

DROP PROCEDURE IF EXISTS createTransitiveClosure //
CREATE PROCEDURE createTransitiveClosure ()

BEGIN
-- Create the Transitive Closure table schema
    DROP TABLE IF EXISTS Transitive_Closure;
    CREATE TABLE Transitive_Closure (
            sourceid BIGINT NOT NULL,
            destinationid BIGINT NOT NULL,
            PRIMARY KEY (sourceid, destinationid)
            ) ENGINE = MyISAM;

-- Insert the immediate set of IS A relationships from the distributed relationships table
    INSERT INTO Transitive_Closure (sourceid,destinationid)
        SELECT DISTINCT sourceid,destinationid
        FROM relationships_snapshot
        WHERE typeid = 116680003 -- "IS A" relationship type
        AND active = 1;

-- Recursively loop through the transitive closure adding additional relationships until there are no more left to insert
    REPEAT

    INSERT INTO Transitive_Closure (sourceid,destinationid)
        SELECT DISTINCT b.sourceid,a.destinationid
        FROM Transitive_Closure a
        JOIN Transitive_Closure b 
            ON a.sourceid = b.destinationid
        LEFT JOIN Transitive_Closure c 
            ON c.sourceid = b.sourceid
        AND c.destinationid = a.destinationid
        WHERE c.sourceid IS NULL;

    SET @x = row_count();
-- Non essential output logger.
    SELECT CONCAT ('Inserted ',@x);

    UNTIL @x = 0
END REPEAT;

CREATE INDEX idx_TransitiveClosure_sourceid ON Transitive_Closure (sourceid);
CREATE INDEX idx_TransitiveClosure_destinationid ON Transitive_Closure (destinationid);

END //

call createTransitiveClosure ();