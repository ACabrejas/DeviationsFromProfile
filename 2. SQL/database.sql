--Create nodes table
CREATE TABLE nodes( 
node_id INT NOT NULL PRIMARY KEY,
node_lat FLOAT NOT NULL,
node_lon FLOAT NOT NULL
);

--Create links table
CREATE TABLE links( 
link_id INT NOT NULL PRIMARY KEY,
link_type VARCHAR(30) NOT NULL,
link_length FLOAT NOT NULL, 
link_direction VARCHAR(30) NOT NULL, 
link_location VARCHAR(10) NOT NULL,
from_node INT NOT NULL,
to_node INT NOT NULL,
FOREIGN KEY (from_node) REFERENCES nodes(node_id)
);

--Create sites table
CREATE TABLE sites( 
site_id CHAR(32) NOT NULL PRIMARY KEY,
site_reference VARCHAR(20) NOT NULL,
link_id INT NOT NULL,
distance_along FLOAT NOT NULL,
latitude FLOAT NOT NULL, 
longitude FLOAT NOT NULL, 
n_measurements SMALLINT,
FOREIGN KEY (link_id) REFERENCES links(link_id)
);

--Create measurements table
CREATE TABLE measurements( 
site_id CHAR(32) NOT NULL,
m_index TINYINT NOT NULL,
m_lane VARCHAR(32),
m_type VARCHAR(20), 
lower_length FLOAT DEFAULT NULL, 
upper_length FLOAT DEFAULT NULL, 
CONSTRAINT pk_site_index PRIMARY KEY (site_id, m_index),
FOREIGN KEY (site_id) REFERENCES sites(site_id)
);

------------------------------------------------------------------------

--Create m25_midas
CREATE TABLE m25_midas( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
site_id CHAR(32) NOT NULL,
m_index TINYINT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_error BIT NOT NULL, 
m_value FLOAT
);

--Create m25_ptd
CREATE TABLE m25_ptd( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_value FLOAT
);

--Create m25_events
CREATE TABLE m25_travel_time( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
travel_time FLOAT,
free_flow FLOAT,
profile_time FLOAT
);

--Create m25_events
CREATE TABLE m25_events( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
event_id INT NOT NULL,
link_id INT NOT NULL,
type VARCHAR(40) NOT NULL, 
start_date VARCHAR(40) NOT NULL,
end_date VARCHAR(40) NOT NULL
);

---------------------------------------------------

--Create m6_midas
CREATE TABLE m6_midas( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
site_id CHAR(32) NOT NULL,
m_index TINYINT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_error BIT NOT NULL, 
m_value FLOAT
);

--Create m6_ptd
CREATE TABLE m6_ptd( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_value FLOAT
);

--Create m6_ptd
CREATE TABLE m6_travel_time( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
travel_time FLOAT,
free_flow FLOAT,
profile_time FLOAT
);

--Create m6_events
CREATE TABLE m6_events( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
event_id INT NOT NULL,
link_id INT NOT NULL,
type VARCHAR(40) NOT NULL, 
start_date VARCHAR(40) NOT NULL,
end_date VARCHAR(40) NOT NULL
);

-------------------------------------------------------------------

--Create m11_midas
CREATE TABLE m11_midas( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
site_id CHAR(32) NOT NULL,
m_index TINYINT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_error BIT NOT NULL, 
m_value FLOAT
);

--Create m11_ptd
CREATE TABLE m11_ptd( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
type VARCHAR(20) NOT NULL, 
m_value FLOAT
);

--Create m11_ptd
CREATE TABLE m11_travel_time( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
link_id INT NOT NULL,
m_date DATE NOT NULL,
absolute_time SMALLINT NOT NULL,
travel_time FLOAT,
free_flow FLOAT,
profile_time FLOAT
);

--Create m11_events
CREATE TABLE m11_events( 
id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
event_id INT NOT NULL,
link_id INT NOT NULL,
type VARCHAR(40) NOT NULL, 
start_date VARCHAR(40) NOT NULL,
end_date VARCHAR(40) NOT NULL
);

