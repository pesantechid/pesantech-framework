<?php

declare(strict_types=1);

namespace App\Enums\Hooks;

enum RoleFilterHook: string
{
    case ROLE_CREATED_BEFORE = 'filter.role.created_before';
    case ROLE_CREATED_AFTER = 'filter.role.created_after';

    case ROLE_UPDATED_BEFORE = 'filter.role.updated_before';
    case ROLE_UPDATED_AFTER = 'filter.role.updated_after';

    case ROLE_DELETED_BEFORE = 'filter.role.deleted_before';
    case ROLE_DELETED_AFTER = 'filter.role.deleted_after';

    case ROLE_BULK_DELETED_BEFORE = 'filter.role.bulk_deleted_before';
    case ROLE_BULK_DELETED_AFTER = 'filter.role.bulk_deleted_after';

    // Validation hooks
    case ROLE_STORE_VALIDATION_RULES = 'filter.role.store.validation.rules';
    case ROLE_UPDATE_VALIDATION_RULES = 'filter.role.update.validation.rules';

    // UI Hooks.
    case ROLE_CREATE_BEFORE_FORM = 'filter.role.create_before_form';
    case ROLE_EDIT_BEFORE_FORM = 'filter.role.edit_before_form';
    case ROLE_CREATE_AFTER_FORM = 'filter.role.create_after_form';
    case ROLE_EDIT_AFTER_FORM = 'filter.role.edit_after_form';
}
