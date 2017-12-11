<?php
define( 'WP_DEBUG', true );
if ( WP_DEBUG ) {
    // For analyzing database queries i.e. the Debug Bar plugin
    define( 'SAVEQUERIES', true );

    // Enable debug logging to the /wp-content/debug.log file
    define( 'WP_DEBUG_LOG', true );

    // Disable the 'trash', posts will be deleted immediately
    define( 'EMPTY_TRASH_DAYS', 0 );

    // define( 'PEDESTAL_DEBUG_EMAIL_CSS', true );
}

define( 'WP_ENV', 'development' );

// ActiveCampaign API Credentials
define( 'ACTIVECAMPAIGN_URL', '***' );
define( 'ACTIVECAMPAIGN_API_KEY', '***' );

// AWS API Keys for AWS SES wp_mail() drop-in
define( 'AWS_SES_WP_MAIL_REGION', '***' );
define( 'AWS_SES_WP_MAIL_KEY', '***' );
define( 'AWS_SES_WP_MAIL_SECRET', '***' );

define( 'YOUTUBE_DATA_API_KEY', '***' );
