<?php

declare(strict_types=1);

namespace App\Enums\Hooks;

enum TermFilterHook: string
{
    case TERM_CREATED_BEFORE = 'filter.term.created_before';
    case TERM_CREATED_AFTER = 'filter.term.created_after';

    case TERM_UPDATED_BEFORE = 'filter.term.updated_before';
    case TERM_UPDATED_AFTER = 'filter.term.updated_after';

    case TERM_DELETED_BEFORE = 'filter.term.deleted_before';
    case TERM_DELETED_AFTER = 'filter.term.deleted_after';

    case TERM_BULK_DELETED_BEFORE = 'filter.term.bulk_deleted_before';
    case TERM_BULK_DELETED_AFTER = 'filter.term.bulk_deleted_after';

    // Validation hooks
    case TERM_STORE_VALIDATION_RULES = 'filter.term.store.validation.rules';
    case TERM_UPDATE_VALIDATION_RULES = 'filter.term.update.validation.rules';

    // UI Hooks
    case TERM_AFTER_BREADCRUMBS = 'filter.term.after_breadcrumbs';
}
