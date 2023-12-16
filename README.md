# WordPress

WordPress is a state-of-the-art semantic personal publishing platform with a focus on aesthetics, web standards, and usability.

More simply, Wordpress is what you use when you want to work with your blogging software, not fight it.

wikipedia.org/wiki/WordPress

![](https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/WordPress_logo.svg/240px-WordPress_logo.svg.png)

## How to use this Makejail

### Requirements

```
# appjail makejail \
    -j mariadb \
    -f gh+AppJail-makejails/mariadb \
    -o virtualnet=":wordpress default" \
    -o nat -- \
        --mariadb_user "wpuser" \
        --mariadb_password "123" \
        --mariadb_database "wordpress" \
        --mariadb_root_password "321"
...
# appjail jail list -j mariadb
STATUS  NAME     TYPE  VERSION       PORTS  NETWORK_IP4
UP      mariadb  thin  13.2-RELEASE  -      10.0.0.15
```

### Apache

```
appjail makejail \
    -j wordpress \
    -f gh+AppJail-makejails/wordpress \
    -o virtualnet=":wordpress default" \
    -o nat \
    -o expose=80 -- \
        --wp_db_name "wordpress" \
        --wp_db_user "wpuser" \
        --wp_db_password "123" \
        --wp_db_host "10.0.0.15"
```

### FPM

```
# appjail makejail \
    -j wordpress \
    -f gh+AppJail-makejails/wordpress \
    -o virtualnet=":wordpress default" \
    -o nat -- \
        --wp_db_name "wordpress" \
        --wp_db_user "wpuser" \
        --wp_db_password "123" \
        --wp_db_host "10.0.0.15"
...
# appjail jail list -j wordpress
STATUS  NAME       TYPE  VERSION       PORTS  NETWORK_IP4
UP      wordpress  thin  13.2-RELEASE  -      10.0.0.22
```

To use this variant, you can use NGINX:

```sh
appjail makejail \
    -j nginx \
    -f gh+AppJail-makejails/nginx \
    -o virtualnet=":nginx default" \
    -o nat \
    -o expose=80
appjail cmd jexec nginx mkdir -p /usr/local/www/wordpress
appjail fstab jail nginx set \
    -d /usr/local/appjail/jails/wordpress/jail/usr/local/www/wordpress \
    -m /usr/local/www/wordpress
appjail fstab jail nginx compile
appjail fstab jail nginx mount -a
appjail cmd local nginx cp nginx.conf usr/local/etc/nginx/nginx.conf
appjail service jail nginx nginx restart
```

**nginx.conf**:

```
events {
        worker_connections 1024;
}

http {
    include       mime.types;
	default_type  application/octet-stream;

	upstream php {
		server 10.0.0.22:9000;
	}

    server {
        listen 80;
        server_name $hostname;
        root /usr/local/www/wordpress;
        index index.php;

		client_max_body_size 8M;

		location = /favicon.ico {
			log_not_found off;
			access_log off;
		}

		location = /robots.txt {
			allow all;
			log_not_found off;
			access_log off;
		}

		location / {
			try_files $uri $uri/ /index.php?$args;
		}

		location ~ \.php$ {
			include fastcgi_params;
			fastcgi_intercept_errors on;
			fastcgi_pass php;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		}

		location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
			expires max;
			log_not_found off;
		}
    }
}
```

### Arguments

* `wp_tag` (default: `13.2-php82-apache-6.4.2`): see [#tags](#tags).
* `wp_db_name` (default: `database_name_here`).
* `wp_db_user` (default: `username_here`).
* `wp_db_password` (default: `password_here`): Password to identify the database user. If the word `random` is used, a random hexadecimal string is used.
* `wp_db_host` (default: `localhost`).
* `wp_db_charset` (default: `utf8`).
* `wp_db_collate` (optional).
* `wp_auto_secret` (default: `1`): If `0`, `https://api.wordpress.org/secret-key/1.1/salt` is used to generate `AUTH_KEY`, `SECURE_AUTH_KEY`, `LOGGED_IN_KEY`, `NONCE_KEY`, `AUTH_SALT`, `SECURE_AUTH_SALT`, `LOGGED_IN_SALT` and `NONCE_SALT`.
* `wp_auth_key` (default: `put your unique phrase here`).
* `wp_secure_auth_key` (default: `put your unique phrase here`).
* `wp_logged_in_key` (default: `put your unique phrase here`).
* `wp_nonce_key` (default: `put your unique phrase here`).
* `wp_auth_salt` (default: `put your unique phrase here`).
* `wp_secure_auth_salt` (default: `put your unique phrase here`).
* `wp_logged_in_salt` (default: `put your unique phrase here`).
* `wp_nonce_salt` (default: `put your unique phrase here`).
* `wp_table_prefix` (default: `wp_`).
* `wp_debug` (default: `0`): If `0`, `WP_DEBUG` will be `false`. Any other value is `true`.
* `wp_php_type` (default: `production`) The PHP configuration file to link to `/usr/local/etc/php.ini`. Valid values: `development`, `production`. Only valid for apache, use the `php_type` argument when using php-fpm.

### Volumes

#### Apache

| Name        | Owner | Group | Perm | Type | Mountpoint                              |
| ----------- | ----- | ----- | ---- | ---- | --------------------------------------- |
| wp-content  |  -    |  -    |  -   |  -   | /usr/local/www/apache24/data/wp-content |

#### FPM

| Name        | Owner | Group | Perm | Type | Mountpoint                           |
| ----------- | ----- | ----- | ---- | ---- | ------------------------------------ |
| wp-content  |  -    |  -    |  -   |  -   | /usr/local/www/wordpress/wp-content  |

## Tags

| Tag                       | Arch    | Version        | Type   | `wp_version`  |
| ------------------------- | ------- | -------------- | ------ | ------------- |
| `13.2-php80-apache-6.4.2` | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `13.2-php81-apache-6.4.2` | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `13.2-php82-apache-6.4.2` | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `13.2-php80-fpm-6.4.2`    | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `13.2-php81-fpm-6.4.2`    | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `13.2-php82-fpm-6.4.2`    | `amd64` | `13.2-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php80-apache-6.4.2` | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php81-apache-6.4.2` | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php82-apache-6.4.2` | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php80-fpm-6.4.2`    | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php81-fpm-6.4.2`    | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
| `14.0-php82-fpm-6.4.2`    | `amd64` | `14.0-RELEASE` | `thin` |    `6.4.2`    |
