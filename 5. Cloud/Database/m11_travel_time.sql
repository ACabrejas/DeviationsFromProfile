--Create m11_ptd
CREATE TABLE m11_travel_time( 
id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
link_id INT NOT NULL COMMENT 'Unique identifier of the network link',
m_date DATE NOT NULL COMMENT 'Measurement date',
absolute_time SMALLINT NOT NULL COMMENT 'Measurement time (minutes from midnight)',
travel_time FLOAT COMMENT 'Current travel time across link',
free_flow FLOAT COMMENT 'Travel time across link in free flow conditions',
profile_time FLOAT COMMENT 'Travel time across link in normal conditions',
FOREIGN KEY (link_id) REFERENCES links(link_id)
) ENGINE = InnoDB;
