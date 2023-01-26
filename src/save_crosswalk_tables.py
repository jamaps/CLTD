import psycopg2
import pandas as pd
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

def save_crosswalk(table_name):

    sql = f"""
        SELECT *
        FROM {table_name}
    """

    df = pd.read_sql(sql, connection)

    df1 = df.loc[df['source_ctuid'] != '-1'].sort_values(by=["source_ctuid","target_ctuid"])

    df2 = df.loc[df['source_ctuid'] == '-1'].sort_values(by=["source_ctuid","target_ctuid"])

    df = pd.concat([df1,df2])

    df.to_csv("crosswalk_tables/" + table_name + ".csv", index=False, float_format='%.10f')
    

for table in [
    # "ct_1951_1956",
    # "ct_1951_2021",
    # "ct_1956_1961",
    # "ct_1956_2021",
    # "ct_1961_1966",
    # "ct_1961_2021",
    # "ct_1966_1971",
    # "ct_1966_2021",
    # "ct_1971_1976",
    # "ct_1971_2021",
    # "ct_1976_1981",
    "ct_1976_2021"
    # "ct_1981_1986",
    # "ct_1981_2021",
    # "ct_1986_1991",
    # "ct_1986_2021",
    # "ct_1991_1996",
    # "ct_1991_2021",
    # "ct_1996_2001",
    # "ct_1996_2021",
    # "ct_2001_2006",
    # "ct_2001_2021",
    # "ct_2006_2011",
    # "ct_2006_2021",
    # "ct_2011_2016",
    # "ct_2011_2021",
    # "ct_2016_2021"
    ]:
    
    save_crosswalk(table)

