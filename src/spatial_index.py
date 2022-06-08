# creating spatial indices for all input tables
import psycopg2
from config import config as conf

# connect to database
connection = psycopg2.connect(
	"""host='{host}' port='{port}' dbname='{dbname}'
		user='{user}' password='{password}'
	""".format(
		host = conf['pg']['host'],
		port = conf['pg']['port'],
		dbname = conf['pg']['database'],
		user = conf['pg']['user'],
		password = conf['pg']['password']
	)
)
connection.autocommit = True

# getting input table names
query = """
SELECT table_name
FROM information_schema.tables
WHERE table_name LIKE 'in_%'
      AND table_type = 'BASE TABLE'
ORDER BY table_name;
"""

table_names = []
with connection.cursor() as cursor:
	cursor.execute(query)
	for row in cursor.fetchall():
		table_names.append(row[0])

for table in table_names:
	print(table)
	query = """DROP INDEX IF EXISTS %s_geom_idx;
	CREATE INDEX %s_geom_idx
  	ON %s
  	USING GIST (geom);
	""" % (table, table, table)
	with connection.cursor() as cursor:
		cursor.execute(query)
