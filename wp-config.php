<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'root' );

/** Database password */
define( 'DB_PASSWORD', '' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         ' K]+n}peo-WBy(f{RMCpg)B0^,Y/}JU7iSi4/3f;_a31kD#DBN8z,2$p1xOK<)VQ');
define('SECURE_AUTH_KEY',  'o,z5<kCEkSaTlfA 4mHe`K@.;0uZiKX?,7~+je[c^B&H+mSS|aA?|-A+*5egyJ`,');
define('LOGGED_IN_KEY',    'K_H=sce4N!8s$,xtTg8;3zIRVao^~OamnE*@;o% o*ja{XLC|oY/OmO{2)>ON4%*');
define('NONCE_KEY',        'm+vqr4 v!d))C8=.~nLu0xsUaV0,Kis(4r!Zc|D`&=i)CV34+:-[BN9j=X^75A+Q');
define('AUTH_SALT',        '$dht~T`y|nFCj-n<s0D[An+P3|`>Y]7::D-E@+XuSSC@wV12[sjQXl.vl-<56~>H');
define('SECURE_AUTH_SALT', 'CF+Y4BwE*5 WCcPf,5^-:$IVS|`?s2{n-`;CbL>Y72(jXJ<KG<Yv}aG-h~3L@`AL');
define('LOGGED_IN_SALT',   'k/l+6-[j53guQ^->E4L1H8v)Y1*xF{A$>Qxj&xDb;@K{ej(lC:{r`]+?@9k]d<Bo');
define('NONCE_SALT',       'q,&p[!R-9@O,n--Nk^n3vU+~2_6kfPF/&b 2fr%J-<-kLRuV>iO:O,2T_;9<-0V+');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );
define( 'AUTOMATIC_UPDATER_DISABLED', true );
define( 'WP_AUTO_UPDATE_CORE', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
