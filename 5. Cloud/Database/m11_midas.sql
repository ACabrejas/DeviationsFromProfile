--Create m11_midas
CREATE TABLE m11_midas( 
id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
site_id CHAR(32) NOT NULL COMMENT 'Unique identifier of the loop site',
m_index TINYINT UNSIGNED NOT NULL COMMENT 'Unique measurement index per site',
m_date DATE NOT NULL COMMENT 'Measurement date',
absolute_time SMALLINT NOT NULL COMMENT 'Measurement time (minutes from midnight)',
type VARCHAR(20) NOT NULL COMMENT 'Type of measurement', 
m_error BOOLEAN NOT NULL COMMENT 'Error flag', 
m_value FLOAT COMMENT 'Measurement value',
FOREIGN KEY (site_id) REFERENCES sites(site_id)
) ENGINE = InnoDB;
