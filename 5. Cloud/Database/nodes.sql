--Create nodes table
CREATE TABLE nodes( 
node_id INT NOT NULL PRIMARY KEY COMMENT 'Unique identifier of the network node',
node_lat FLOAT NOT NULL COMMENT 'Latitude of the network node',
node_lon FLOAT NOT NULL COMMENT 'Longitude of the network node'
) Engine = InnoDB;
