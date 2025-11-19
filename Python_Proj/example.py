from hdbcli import dbapi

try:
    connection = dbapi.connect(
        address='your_hana_host',
        port=30015,
        user='your_username',
        password='your_password'
    )
    cursor = connection.cursor()
    cursor.execute("SELECT 'Hello Python World' FROM DUMMY")
    results = cursor.fetchone()
    print(results)

except Exception as e:
    print(f"Error connecting to database: {e}")

finally:
    if connection:
        connection.close()