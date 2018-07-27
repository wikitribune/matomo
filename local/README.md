# First run locally

Edit the environment variables in `docker-compose.yml`:

```
- MYSQL_ROOT_PASSWORD=myrootpassword
- MYSQL_USER=myuser
- MYSQL_PASSWORD=mypassword
- MYSQL_DATABASE=matomo
```

And match them with the ones in `config.ini.php` (`host` is the service name in `docker-compose.yml`)

```
[database]
host = "db"
username = "myuser"
password = "mypassword"
dbname = "matomo"
tables_prefix = "matomo_"
```

Start by running `docker-compose up`

Test the website going to http://localhost:8080 . This will hit nginx on port 80 which will then invoke matomo on port 9000 of its own container which in turn will communicate with the database on port 3306.

Run the setup through the screens.

# Local runs after the database has been created

After the DB is created, you can destroy the containers (not the database volume) using:
`docker-compose down`

In `matomo.Dockerfile` uncomment line 3 so that your config is injected into the image
`COPY config.ini.php /var/www/html/config/config.ini.php`

Then force the build and up the environment:
```
docker-compose build
docker-compose up
```