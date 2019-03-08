--Create sites table
CREATE TABLE sites( 
site_id CHAR(32) NOT NULL PRIMARY KEY COMMENT 'Unique identifier of the loop site',
site_reference VARCHAR(20) NOT NULL COMMENT 'Unique reference of the loop site',
link_id INT NOT NULL COMMENT 'Unique identifier of the network link',
distance_along FLOAT NOT NULL COMMENT 'Distance along network link for this loop site',
latitude FLOAT NOT NULL COMMENT 'Latitude of the loop side', 
longitude FLOAT NOT NULL COMMENT 'Longitude of the loop side', 
n_measurements SMALLINT UNSIGNED COMMENT 'Number of measurements this site makes',
FOREIGN KEY (link_id) REFERENCES links(link_id)
) ENGINE = InnoDB;
