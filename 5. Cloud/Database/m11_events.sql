--Create m11_ptd
CREATE TABLE m11_events( 
id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
link_id INT NOT NULL COMMENT 'Unique identifier of the network link',
type VARCHAR(20) NOT NULL COMMENT 'Event type', 
start_date TIMESTAMP NOT NULL COMMENT 'Event start timestamp',
end_date TIMESTAMP NOT NULL COMMENT 'Event end timestamp',
FOREIGN KEY (link_id) REFERENCES links(link_id)
) ENGINE = InnoDB;
