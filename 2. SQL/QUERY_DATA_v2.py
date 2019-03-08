import pymssql

con = pymssql.connect(server='thales-mathsys1.database.windows.net', user='ayman-admin@thales-mathsys1', password='fb1123581321&', database='thales')
cur = con.cursor()

"""
    Execute each query in order
"""

#Parameters (avoid overlapped values when setting 'dates')
table = "m11"
dates = "m_date BETWEEN '2016-03-01' AND '2016-05-20'"

#Creation of m#_data (only once)
create_table = " CREATE TABLE " + table + "_data(id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, link_id INT NOT NULL, m_date DATE NOT NULL, absolute_time SMALLINT NOT NULL, travel_time FLOAT, free_flow FLOAT, profile_time FLOAT, traffic_concentration FLOAT, traffic_speed FLOAT, traffic_flow FLOAT, traffic_headway FLOAT, congestion_event TINYINT, poor_event TINYINT, other_event TINYINT, real_date DATETIME);"

#Insertion of links and dates
qry_initial = "INSERT INTO " + table + "_data SELECT link_id, m_date, absolute_time, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, DATEADD(minute,absolute_time,CAST(m_date AS DATETIME)) FROM"
qry_initial = qry_initial + " (SELECT DISTINCT link_id FROM " + table + "_ptd) AS L"
qry_initial = qry_initial + " CROSS JOIN (SELECT DISTINCT m_date FROM " + table + "_ptd WHERE " + dates + ") AS D"
qry_initial = qry_initial + " CROSS JOIN (SELECT DISTINCT absolute_time FROM " + table + "_ptd) AS A"
qry_initial = qry_initial + " ORDER BY link_id, m_date, absolute_time;"

#Insertion of data
qry_data_tt = "UPDATE D SET D.travel_time = T.travel_time, D.free_flow = T.free_flow, D.profile_time = T.profile_time FROM " + table + "_data D LEFT JOIN"
qry_data_tt = qry_data_tt + " (SELECT link_id, m_date, absolute_time, MAX(travel_time) AS travel_time, MAX(free_flow) AS free_flow, MAX(profile_time) AS profile_time FROM " + table + "_travel_time WHERE " + dates + " GROUP BY link_id, m_date, absolute_time) T ON D.link_id = T.link_id AND D.m_date = T.m_date AND D.absolute_time = T.absolute_time"
qry_data_tt = qry_data_tt + " WHERE D." + dates + ";"

qry_data_ptd_1 = "UPDATE D SET D.traffic_concentration = T.m_value FROM " + table + "_data D LEFT JOIN"
qry_data_ptd_1 = qry_data_ptd_1 + " (SELECT link_id, m_date, absolute_time, MAX(m_value) AS m_value FROM " + table + "_ptd WHERE type = 'TrafficConcentration' AND " + dates + " GROUP BY link_id, m_date, absolute_time) T ON D.link_id = T.link_id AND D.m_date = T.m_date AND D.absolute_time = T.absolute_time"
qry_data_ptd_1 = qry_data_ptd_1 + " WHERE D." + dates + ";"

qry_data_ptd_2 = "UPDATE D SET traffic_speed = T.m_value FROM " + table + "_data D LEFT JOIN"
qry_data_ptd_2 = qry_data_ptd_2 + " (SELECT link_id, m_date, absolute_time, MAX(m_value) AS m_value FROM " + table + "_ptd WHERE type = 'TrafficSpeed' AND " + dates + " GROUP BY link_id, m_date, absolute_time) T ON D.link_id = T.link_id AND D.m_date = T.m_date AND D.absolute_time = T.absolute_time"
qry_data_ptd_2 = qry_data_ptd_2 + " WHERE D." + dates + ";"

qry_data_ptd_3 = "UPDATE D SET traffic_flow = T.m_value FROM " + table + "_data D LEFT JOIN"
qry_data_ptd_3 = qry_data_ptd_3 + " (SELECT link_id, m_date, absolute_time, MAX(m_value) AS m_value FROM " + table + "_ptd WHERE type = 'TrafficFlow' AND " + dates + " GROUP BY link_id, m_date, absolute_time) T ON D.link_id = T.link_id AND D.m_date = T.m_date AND D.absolute_time = T.absolute_time"
qry_data_ptd_3 = qry_data_ptd_3 + " WHERE D." + dates + ";"

qry_data_ptd_4 = "UPDATE D SET traffic_headway = T.m_value FROM " + table + "_data D LEFT JOIN"
qry_data_ptd_4 = qry_data_ptd_4 + " (SELECT link_id, m_date, absolute_time, MAX(m_value) AS m_value FROM " + table + "_ptd WHERE type = 'TrafficHeadway' AND " + dates + " GROUP BY link_id, m_date, absolute_time) T ON D.link_id = T.link_id AND D.m_date = T.m_date AND D.absolute_time = T.absolute_time"
qry_data_ptd_4 = qry_data_ptd_4 + " WHERE D." + dates + ";"

#Creation of m#_events_temp (temporal)
qry_alter0 = "SELECT * INTO " + table + "_events_temp FROM " + table + "_events GO"
qry_alter0 = qry_alter0 + " ALTER TABLE " + table + "_events_temp ADD start_datetime DATETIME, end_datetime DATETIME;"
qry_alter = " UPDATE " + table + "_events_temp SET start_datetime = CAST(SUBSTRING(start_date,1,23) AS DATETIME);"
qry_alter = qry_alter + " UPDATE " + table + "_events_temp SET end_datetime = CAST(SUBSTRING(IIF(end_date = 'None', NULL, end_date),1,23) AS DATETIME);"

#Creation of m#_data_events (temporal)...
qry_events = "SELECT D.id, E.type INTO " + table + "_data_events FROM"
qry_events = qry_events + " (SELECT id, link_id, real_date FROM " + table + "_data WHERE " + dates + ") AS D LEFT JOIN (SELECT link_id, CASE type WHEN 'AbnormalTraffic' THEN 'AbnormalTraffic' WHEN 'PoorEnvironmentConditions' THEN 'PoorEnvironmentConditions' ELSE 'Other' END AS type, start_datetime, end_datetime FROM " + table + "_events_temp) AS E"
qry_events = qry_events + " ON D.link_id = E.link_id AND D.real_date BETWEEN E.start_datetime AND E.end_datetime"
qry_events = qry_events + " GROUP BY D.id, E.type"

#Updating data with events information
upd = "UPDATE D SET D.congestion_event = 1 FROM " + table + "_data D INNER JOIN (SELECT * FROM " + table + "_data_events WHERE type = 'AbnormalTraffic') E ON D.id = E.id WHERE D." + dates + ";"
upd = upd + " UPDATE D SET D.poor_event = 1 FROM " + table + "_data D INNER JOIN (SELECT * FROM " + table + "_data_events WHERE type = 'PoorEnvironmentConditions') E ON D.id = E.id WHERE D." + dates + ";"
upd = upd + " UPDATE D SET D.other_event = 1 FROM " + table + "_data D INNER JOIN (SELECT * FROM " + table + "_data_events WHERE type = 'Other') E ON D.id = E.id WHERE D." + dates + ";"

#Drop temporal tables
#drop_temp = "DROP TABLE " + table + "_events_temp"
#drop_temp = "DROP TABLE " + table + "_data_events"

#Execution
#query = create_table
#query = qry_initial
#query = qry_data_tt
#query = qry_data_ptd_1
#query = qry_data_ptd_2
#query = qry_data_ptd_3
#query = qry_data_ptd_4
#query = qry_alter0
#query = qry_alter
#query = qry_events
#query = upd

print query
cur.execute(query)

for row in cur:
    print('row = %r' % (row,))

con.commit()
con.close()
