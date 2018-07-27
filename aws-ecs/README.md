# First run AWS

In `matomo.Dockerfile` comment line 3 so that you don't skip the setup of the database
`COPY config.ini.php /var/www/html/config/config.ini.php`

Copy `config.ini.php` file from `local` folder and edit the environment variables in `config.ini.php`

```
[database]
host = "db"
username = "myuser"
password = "mypassword"
dbname = "matomo"
tables_prefix = "matomo_"
```

Test the website going to stats.example.com .
This will hit the ALB on port 80/443 which will call the nginx container on a dynamic port, convert it into on port 80 which will then invoke matomo on port 9000 of its own container which in turn will communicate with the database on port 3306.

Configure the database as per the values you set above using the screens.

__IMPORTANT__ Set the health check port on ALB to 8888

# AWS runs after the database has been created

In `matomo.Dockerfile` uncomment line 3 so that your config is injected into the image
`COPY config.ini.php /var/www/html/config/config.ini.php`

In `config.ini.php` in the `[General]` section change the `trusted_hosts` to your own DNS
`trusted_hosts[] = "stats.example.com"`

## [Optional] Cloudflare and HTTPS

If are using Cloudflare/AWS and have it terminate your SSL connection uncomment the following lines in `config.ini.php`:

```
;assume_secure_protocol = 1
;proxy_client_headers[] = HTTP_CF_CONNECTING_IP
```

## [Optional] Email

Setup the following section according to your mailer (e.g. AWS SES):

```
[mail]
defaultHostnameIfEmpty = stats.example.com;
transport = smtp;
port = 587;
host = email123.amazonaws.com;
type = LOGIN; SMTP Auth type. By default: NONE. For example: LOGIN
username = aws_ses_username;
password = aws_ses_password;
encryption = tls;
```

## [Optional] Redis cache

```
[ChainedCache]
backends[] = array
backends[] = redis
[RedisCache]
host = "yourredis.cache.amazonaws.com"
port = 6379
timeout = 0.0
password = "yourpassword"
database = 14
```