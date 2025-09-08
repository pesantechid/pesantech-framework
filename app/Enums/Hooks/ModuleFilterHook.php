<?php

declare(strict_types=1);

namespace App\Enums\Hooks;

enum ModuleFilterHook: string
{
    case MODULE_CREATED_BEFORE = 'filter.module.created_before';
    case MODULE_CREATED_AFTER = 'filter.module.created_after';

    case MODULE_UPDATED_BEFORE = 'filter.module.updated_before';
    case MODULE_UPDATED_AFTER = 'filter.module.updated_after';

    case MODULE_DELETED_BEFORE = 'filter.module.deleted_before';
    case MODULE_DELETED_AFTER = 'filter.module.deleted_after';

    case MODULE_BULK_DELETED_BEFORE = 'filter.module.bulk_deleted_before';
    case MODULE_BULK_DELETED_AFTER = 'filter.module.bulk_deleted_after';

    // Validation hooks
    case MODULE_STORE_VALIDATION_RULES = 'filter.module.store.validation.rules';
    case MODULE_STORE_VALIDATION_MESSAGES = 'filter.module.store.validation.messages';

    // UI Hooks
    case MODULES_AFTER_BREADCRUMBS = 'filter.module.after_breadcrumbs';
}
