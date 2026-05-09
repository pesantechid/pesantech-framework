<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Here you may configure your settings for cross-origin resource sharing
    | or "CORS". This determines what cross-origin operations may execute
    | in web browsers. You are free to adjust these settings as needed.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    | SECURITY NOTE (Pesantech Playbook §11.1):
    | CORS_ALLOWED_ORIGINS must be set to specific domains in production.
    | Example: CORS_ALLOWED_ORIGINS=https://app.yourdomain.com,https://api.yourdomain.com
    | Wildcard '*' is only acceptable for fully public, read-only APIs.
    |
    */

    'paths' => ['api/*'],

    'allowed_methods' => ['*'],

    // Set CORS_ALLOWED_ORIGINS in .env — comma-separated. Defaults to '*' for local dev only.
    'allowed_origins' => array_filter(
        explode(',', env('CORS_ALLOWED_ORIGINS', '*')),
        fn ($origin) => $origin !== ''
    ),

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
