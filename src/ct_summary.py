import psycopg2
import csv
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



# get n CTs, area, total population, % of canada?

year = 2021

data = []

while year >= 1951:
    
    print(year)

    if year < 1971:

        polygon_name = "in_" + str(year) + "_ct"

    else:

        polygon_name = "in_" + str(year) + "_cbf_ct"

    query = f"""
        SELECT 
        SUM(ST_Area(geom::geography)) / (1000*1000),
        count(*)
        FROM {polygon_name}
    """

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone();
        a = result[0]
        n = result[1]

    row = [year, n, a]
    data.append(row)

    year -= 5

with open("ct_summary.csv", "w") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["year","n","area"])
    for row in data:
        writer.writerow(row)