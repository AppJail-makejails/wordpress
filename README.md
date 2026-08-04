# WordPress

WordPress is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service. Features include a plugin architecture and a template system. WordPress is used by more than 22.0% of the top 10 million websites as of August 2013. WordPress is the most popular blogging system in use on the Web, at more than 60 million websites. The most popular languages used are English, Spanish and Bahasa Indonesia.

wikipedia.org/wiki/WordPress

<img src="https://raw.githubusercontent.com/docker-library/docs/01c12653951b2fe592c1f93a13b4e289ada0e3a1/wordpress/logo.png" width="30%" height="auto" alt="WordPress logo">

## How to use this Makejail

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    ghcr.io/appjail-makejails/wordpress wordpress
```

The following environment variables are also honored for configuring your WordPress instance (by [a custom `wp-config.php` implementation](wp-config-oci.php)):

* `-e WORDPRESS_DB_HOST=...`
* `-e WORDPRESS_DB_USER=...`
* `-e WORDPRESS_DB_PASSWORD=...`
* `-e WORDPRESS_DB_NAME=...`
* `-e WORDPRESS_TABLE_PREFIX=...`
* `-e WORDPRESS_AUTH_KEY=...`, `-e WORDPRESS_SECURE_AUTH_KEY=...`, `-e WORDPRESS_LOGGED_IN_KEY=...`, `-e WORDPRESS_NONCE_KEY=...`, `-e WORDPRESS_AUTH_SALT=...`, `-e WORDPRESS_SECURE_AUTH_SALT=...`, `-e WORDPRESS_LOGGED_IN_SALT=...`, `-e WORDPRESS_NONCE_SALT=...` (default to unique random SHA1s, but only if other environment variable configuration is provided)
* `-e WORDPRESS_DEBUG=1` (defaults to disabled, non-empty value will enable `WP_DEBUG` in `wp-config.php`)
* `-e WORDPRESS_CONFIG_EXTRA=...` (defaults to nothing, the value will be evaluated by the `eval()` function in `wp-config.php`. This variable is especially useful for applying extra configuration values this image does not provide by default such as `WP_ALLOW_MULTISITE`; see [docker-library/wordpress#142](https://github.com/docker-library/wordpress/pull/142) for more details)
The `WORDPRESS_DB_NAME` needs to already exist on the given MySQL server; it will not be created by the `wordpress` container.

If you'd like to be able to access the instance from an external host, standard port mappings can be used:

```console
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose="8080:80" \
    ghcr.io/appjail-makejails/wordpress wordpress
```

Then, access it via `http://wordpress` or `http://host-ip:8080` (from external hosts) in a browser.

When running WordPress with TLS behind a reverse proxy such as NGINX which is responsible for doing TLS termination, be sure to set `X-Forwarded-Proto` appropriately (see ["Using a Reverse Proxy" in "Administration Over SSL" in upstream's documentation](https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy)). No additional environment variables or configuration should be necessary (this image automatically adds the noted `HTTP_X_FORWARDED_PROTO` code to `wp-config.php` if any of the above-noted environment variables are specified).

If your database requires SSL, [WordPress ticket #28625](https://core.trac.wordpress.org/ticket/28625) has the relevant details regarding support for that with WordPress upstream. As a workaround, [the "Secure DB Connection" plugin](https://wordpress.org/plugins/secure-db-connection/) can be extracted into the WordPress directory and the appropriate values described in the configuration of that plugin added in wp-config.php.

### Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container. In particular, this can be used to load passwords from secrets stored in `/volumes/wordpress-secrets/<secret_name>` files. For example:

```console
$ mkdir -p /path/to/your/wordpress/secrets
$ echo "mysecretpassword" > /path/to/your/wordpress/secrets/mysql-root
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o volume="wordpress-secrets" \
    -o fstab="/path/to/your/wordpress/secrets wordpress-secrets <volumefs> ro" \
    -e WORDPRESS_DB_PASSWORD_FILE=/volumes/wordpress-secrets/mysql-root \
    ghcr.io/appjail-makejails/wordpress wordpress
```

Currently, this is supported for `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`, `WORDPRESS_AUTH_KEY`, `WORDPRESS_SECURE_AUTH_KEY`, `WORDPRESS_LOGGED_IN_KEY`, `WORDPRESS_NONCE_KEY`, `WORDPRESS_AUTH_SALT`, `WORDPRESS_SECURE_AUTH_SALT`, `WORDPRESS_LOGGED_IN_SALT`, `WORDPRESS_NONCE_SALT`, `WORDPRESS_TABLE_PREFIX`, and `WORDPRESS_DEBUG`.

### ... via [`appjail-director`](https://github.com/DtxdF/director)

Example `appjail-director.yml` for `wordpress`:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:
  - container: 'args:--pull'

services:
  wordpress:
    name: wordpress
    makejail: gh+AppJail-makejails/wordpress
    oci:
      environment:
        - WORDPRESS_DB_HOST: 10.0.0.60
        - WORDPRESS_DB_USER: exampleuser
        - WORDPRESS_DB_PASSWORD: examplepass
        - WORDPRESS_DB_NAME: exampledb
    volumes:
      - wordpress: /usr/local/www/html
    options:
      - expose: '8080:80'
  db:
    name: wordpress-db
    makejail: gh+AppJail-makejails/mariadb
    oci:
      environment:
        - MARIADB_DATABASE: exampledb
        - MARIADB_USER: exampleuser
        - MARIADB_PASSWORD: examplepass
        - MARIADB_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db: /var/db/mysql
    options:
      - virtualnet: 'ajnet:<random> address:10.0.0.60 default'

volumes:
  wordpress:
    device: /var/appjail-volumes/wordpress/data
  db:
    device: /var/appjail-volumes/wordpress/db
```

Run `appjail-director up`, wait for it to initialize completely, and visit `http://wordpress` or `http://host-ip:8080` (from external hosts).

### Adding additional libraries / extensions

Mount the volume containing your themes or plugins to the proper directory; and then apply them through the "wp-admin" UI. Ensure read/write/execute permissions are in place for the user:

* Themes go in a subdirectory in `/usr/local/www/html/wp-content/themes/`
* Plugins go in a subdirectory in `/usr/local/www/html/wp-content/plugins/`

If you wish to provide additional content in an image for deploying in multiple installations, place it in the same directories under `/usr/local/www/wordpress/` instead (which gets copied to `/usr/local/www/html/` on the container's initial startup).

### Running as an arbitrary user

See [the "Running as an arbitrary user" section of the `php` image documentation](https://github.com/appJail-makejails/php#running-as-an-arbitrary-user).

### WP-CLI

This image variant does not contain WordPress itself, but instead contains [WP-CLI](https://wp-cli.org/).

The simplest way to use it with an existing WordPress container would be something similar to the following:

```console
$ appjail oci run \
    -o ephemeral \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o fstab="/var/appjail-volumes/wordpress/data /usr/local/www/html" \
    -e WORDPRESS_DB_HOST=wordpress-db \
    -e WORDPRESS_DB_USER=exampleuser \
    -e WORDPRESS_DB_PASSWORD=examplepass \
    -e WORDPRESS_DB_NAME=exampledb \
    ghcr.io/appjail-makejails/wordpress:15.1-cli wp-cli user list
```

Generally speaking, for WP-CLI to interact with a WordPress install, it needs access to the on-disk files of the WordPress install, and access to the database (and the easiest way to accomplish that such that wp-config.php does not require changes is to simply join the networking context of the existing and presumably working WordPress container, but there are many other ways to accomplish that which will be left as an exercise for the reader).

### Arguments (stage: build)

* `wordpress_from` (default: `ghcr.io/appjail-makejails/wordpress`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `wordpress_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-44aff70a60-usr_local_www_html | `${PUID}` | `${PGID}` | - | - | /usr/local/www/html |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1-apache
      containerfile: Containerfile.apache
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        APACHEVER: "24"
        PHPVER: "84"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-fpm
      containerfile: Containerfile.fpm
      args:
        FREEBSD_RELEASE: "15.1"
        PHPVER: "84"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
    - tag: 15.1-cli
      containerfile: Containerfile.cli
      args:
        FREEBSD_RELEASE: "15.1"
        PHPVER: "84"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```

## Notes

1. The ideas present in the Docker image of WordPress are taken into account for users who are familiar with it.
