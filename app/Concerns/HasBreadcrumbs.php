<?php

declare(strict_types=1);

namespace App\Concerns;

use Illuminate\View\View;

trait HasBreadcrumbs
{
    public array $breadcrumbs = [
        'title' => '',
        'show_home' => true,
        'show_current' => true,
        'items' => [],
    ];

    public function setBreadcrumbTitle(string $title): self
    {
        $this->breadcrumbs['title'] = $title;

        return $this;
    }

    public function setBreadcrumbShowHome(bool $show): self
    {
        $this->breadcrumbs['show_home'] = $show;

        return $this;
    }

    public function setBreadcrumbShowCurrent(bool $show): self
    {
        $this->breadcrumbs['show_current'] = $show;

        return $this;
    }

    public function setBreadcrumbItems(array $items): self
    {
        $this->breadcrumbs['items'] = $items;

        return $this;
    }

    public function addBreadcrumbItem(string $label, ?string $url = null): self
    {
        $this->breadcrumbs['items'][] = [
            'label' => $label,
            'url' => $url,
        ];

        return $this;
    }

    public function renderViewWithBreadcrumbs($view, $data = []): View
    {
        return view($view, array_merge($data, [
            'breadcrumbs' => $this->breadcrumbs,
        ]));
    }
}
