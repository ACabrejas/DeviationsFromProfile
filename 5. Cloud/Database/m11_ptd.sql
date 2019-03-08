--Create m11_ptd
CREATE TABLE m11_ptd( 
id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
link_id INT NOT NULL COMMENT 'Unique identifier of the network link',
m_date DATE NOT NULL COMMENT 'Measurement date',
absolute_time SMALLINT NOT NULL COMMENT 'Measurement time (minutes from midnight)',
type VARCHAR(20) NOT NULL COMMENT 'Measurement time', 
m_value FLOAT COMMENT 'Measurement value',
FOREIGN KEY (link_id) REFERENCES links(link_id)
) ENGINE = InnoDB;
