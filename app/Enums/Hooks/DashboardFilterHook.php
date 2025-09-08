<?php

declare(strict_types=1);

namespace App\Enums\Hooks;

enum DashboardFilterHook: string
{
    // Dashboard breadcrumbs
    case DASHBOARD_AFTER_BREADCRUMBS = 'filter.dashboard.after_breadcrumbs';

    // Dashboard cards
    case DASHBOARD_CARDS_BEFORE_USERS = 'filter.dashboard.cards.before_users';
    case DASHBOARD_CARDS_AFTER_USERS = 'filter.dashboard.cards.after_users';
    case DASHBOARD_CARDS_AFTER_ROLES = 'filter.dashboard.cards.after_roles';
    case DASHBOARD_CARDS_AFTER_PERMISSIONS = 'filter.dashboard.cards.after_permissions';
    case DASHBOARD_CARDS_AFTER_TRANSLATIONS = 'filter.dashboard.cards.after_translations';
    case DASHBOARD_CARDS_AFTER = 'filter.dashboard.cards.after';

    // Dashboard sections
    case DASHBOARD_AFTER = 'filter.dashboard.after';
}
