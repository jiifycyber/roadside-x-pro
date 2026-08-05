<?php
/**
 * Plugin Name: Roadside X Lead Connector
 * Description: Sends roadside request forms and advertising click identifiers to a Roadside X backend.
 * Version: 1.0.0
 */

if (!defined('ABSPATH')) { exit; }

add_action('rest_api_init', function () {
    register_rest_route('roadside-x/v1', '/lead', [
        'methods' => 'POST',
        'callback' => 'roadside_x_receive_lead',
        'permission_callback' => '__return_true',
        'args' => [
            'name' => ['required' => true, 'sanitize_callback' => 'sanitize_text_field'],
            'phone' => ['required' => true, 'sanitize_callback' => 'sanitize_text_field'],
            'address' => ['required' => true, 'sanitize_callback' => 'sanitize_text_field'],
            'service' => ['required' => true, 'sanitize_callback' => 'sanitize_text_field'],
        ],
    ]);
});

function roadside_x_receive_lead(WP_REST_Request $request) {
    $payload = [
        'source' => 'wordpress',
        'name' => sanitize_text_field($request->get_param('name')),
        'phone' => sanitize_text_field($request->get_param('phone')),
        'address' => sanitize_text_field($request->get_param('address')),
        'vehicle' => sanitize_text_field($request->get_param('vehicle')),
        'service' => sanitize_text_field($request->get_param('service')),
        'notes' => sanitize_textarea_field($request->get_param('notes')),
        'gclid' => sanitize_text_field($request->get_param('gclid')),
        'gbraid' => sanitize_text_field($request->get_param('gbraid')),
        'wbraid' => sanitize_text_field($request->get_param('wbraid')),
        'landing_page' => esc_url_raw($request->get_param('landing_page')),
        'submitted_at' => current_time('c'),
    ];

    // In production, forward this payload server-to-server to your protected
    // Roadside X backend using wp_remote_post(). Never store backend secrets in
    // public JavaScript or expose them in the Flutter application.
    do_action('roadside_x_lead_received', $payload);

    return new WP_REST_Response([
        'success' => true,
        'message' => 'Roadside request received.',
        'lead' => $payload,
    ], 201);
}
