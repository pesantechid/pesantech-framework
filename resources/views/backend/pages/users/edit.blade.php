<x-layouts.backend-layout :breadcrumbs="$breadcrumbs">
    <x-card>
        <form
            action="{{ route('admin.users.update', $user->id) }}"
            method="POST"
            class="space-y-6"
            enctype="multipart/form-data"
            data-prevent-unsaved-changes
        >
            @csrf
            @method('PUT')

            @php
                // Load user metadata for additional information
                $userMeta = $user->userMeta()->pluck('meta_value', 'meta_key')->toArray();

                // Load localization data
                $locales = app(\App\Services\LanguageService::class)->getLanguages();
                $timezones = app(\App\Services\TimezoneService::class)->getTimezones();
            @endphp

            @include('backend.pages.users.partials.form', [
                'user' => $user,
                'roles' => $roles,
                'timezones' => $timezones,
                'locales' => $locales,
                'userMeta' => $userMeta,
                'mode' => 'edit',
                'showUsername' => true,
                'showRoles' => true,
                'showAdditional' => true
            ])
        </form>
    </x-card>
</x-layouts.backend-layout>
