--Create links table
CREATE TABLE links( 
link_id INT NOT NULL PRIMARY KEY COMMENT 'Unique identifier of the network link',
link_type VARCHAR(30) NOT NULL COMMENT 'Network link type',
link_length FLOAT NOT NULL COMMENT 'Length of network link', 
link_direction VARCHAR(30) NOT NULL COMMENT 'Direction of network link', 
link_location VARCHAR(10) NOT NULL COMMENT 'Location of network link',
from_node INT NOT NULL COMMENT 'Unique identifier of the start node of the network link',
to_node INT NOT NULL COMMENT 'Unique identifier of the end node of the network link',
FOREIGN KEY (from_node) REFERENCES nodes(node_id)
) ENGINE = InnoDB;
