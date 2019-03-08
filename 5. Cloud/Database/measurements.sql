--Create measurements table
CREATE TABLE measurements( 
site_id CHAR(32) NOT NULL COMMENT 'Unique identifier of the loop site',
m_index TINYINT UNSIGNED NOT NULL COMMENT 'Unique measurement index per site',
m_lane VARCHAR(32) COMMENT 'Lane measured',
m_type VARCHAR(20) COMMENT 'Type of measurement', 
lower_length FLOAT DEFAULT NULL COMMENT 'Lower bound on vehicle length', 
upper_length FLOAT DEFAULT NULL COMMENT 'Upper bound on vehicle length', 
CONSTRAINT pk_site_index PRIMARY KEY (site_id, m_index),
FOREIGN KEY (site_id) REFERENCES sites(site_id)
)Engine = InnoDB;

