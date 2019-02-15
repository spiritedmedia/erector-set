<?php

define('WP_DEBUG', true);
if (WP_DEBUG ) {
    // For analyzing database queries i.e. the Debug Bar plugin
    define('SAVEQUERIES', true);

    // Enable debug logging to the /wp-content/debug.log file
    define('WP_DEBUG_LOG', true);

    // Disable the 'trash', posts will be deleted immediately
    define('EMPTY_TRASH_DAYS', 0);

    // Uncomment the following line to display expanded CSS in email templates
    // for easier CSS debugging
    // define( 'PEDESTAL_DEBUG_EMAIL_CSS', true );
}

define('WP_ENV', 'development');

// MailChimp API Credentials
define('MAILCHIMP_API_KEY', '***');

// AWS API Keys for AWS SES wp_mail() drop-in
define('AWS_SES_WP_MAIL_REGION', '***');
define('AWS_SES_WP_MAIL_KEY', '***');
define('AWS_SES_WP_MAIL_SECRET', '***');

define('YOUTUBE_DATA_API_KEY', '***');

// AWS API Keys for S3 Uploads plugin
// define( 'S3_UPLOADS_BUCKET_URL', 'https://a.spirited.media' );

// define( 'TACHYON_URL', S3_UPLOADS_BUCKET_URL . '/wp-content/uploads' );
$redis_server = array(
    'host'     => '127.0.0.1',
    'port'     => 6379,
);

define('REDIS_CACHE_PURGE_LOGGING', true);
