@props(['breadcrumbs' => []])

@extends('backend.layouts.app')

@section('title')
    @if ($pageTitle ?? false)
        {{ $pageTitle }}
    @else
        {{ $breadcrumbs['title'] ?? '' }} | {{ config('app.name') }}
    @endif
@endsection

@section('admin-content')
    <div class="p-4 mx-auto max-w-(--breakpoint-2xl) md:p-6">
        @if ($breadcrumbsData ?? false)
            {!! $breadcrumbsData !!}
        @else
            <x-breadcrumbs :breadcrumbs="$breadcrumbs" />
        @endif

        {{ $slot }}
    </div>
@endsection
