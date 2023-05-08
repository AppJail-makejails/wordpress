# wordpress

WordPress is a state-of-the-art semantic personal publishing platform with a focus on aesthetics, web standards, and usability.

More simply, Wordpress is what you use when you want to work with your blogging software, not fight it.

wikipedia.org/wiki/WordPress

![](https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/WordPress_logo.svg/240px-WordPress_logo.svg.png)

## How to use this Makejail

```
INCLUDE options/network.makejail
INCLUDE gh+AppJail-makejails/wordpress

OPTION expose=80
```

Where `options/network.makejail` are the options that suit your environment, for example:

```
ARG network
ARG interface=wordpress

OPTION virtualnet=${network}:${interface} default
OPTION nat
```

Open a shell and run `appjail makejail`:

```
appjail makejail -j wordpress -- --network web
```

### Arguments

* `wp_version` (default: `6.2`).
* `wp_db_name` (default: `wordpress`).
* `wp_db_user` (default: `wpuser`).
* `wp_db_password` (default: `random`): Password to identify the database user. If the word `random` is used, a random hexadecimal string is used.
* `wp_db_host` (default: `127.0.0.1`).
* `wp_db_charset` (default: `utf8`).
* `wp_db_collate` (default: `0`): If `0`, `DB_COLLATE` will have an empty value.
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
