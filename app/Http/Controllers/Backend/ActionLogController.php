<?php

declare(strict_types=1);

namespace App\Http\Controllers\Backend;

use App\Http\Controllers\Controller;
use App\Models\ActionLog;

class ActionLogController extends Controller
{
    public function index()
    {
        $this->authorize('viewAny', ActionLog::class);

        $this->setBreadcrumbTitle(__('Action Logs'));

        return $this->renderViewWithBreadcrumbs('backend.pages.action-logs.index');
    }
}
