{!! Hook::applyFilters(SettingFilterHook::SETTINGS_INTEGRATIONS_TAB_BEFORE_SECTION_START, '') !!}
<div class="rounded-md border border-gray-200 dark:border-gray-800 dark:bg-white/[0.03]">
    <div class="px-5 py-4 sm:px-6 sm:py-5">
        <h3 class="text-base font-medium text-gray-700 dark:text-white/90">
            {{ __('Integration Setting') }}
        </h3>
    </div>
    <div class="space-y-6 border-t border-gray-100 p-5 sm:p-6 dark:border-gray-800">
        <div class="relative">
            <label class="mb-1.5 block text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ __('Google Analytics') }}
            </label>
            <textarea name="google_analytics_script" rows="6" placeholder="{{ __('Paste your Google Analytics script here') }}"
                @if (config('app.demo_mode', false)) disabled @endif
                class="form-control h-20"
                data-tooltip-target="tooltip-google-analytics">{{ config('settings.google_analytics_script') ?? '' }}</textarea>

            @if (config('app.demo_mode', false))
            <div id="tooltip-google-analytics" role="tooltip" class="absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium text-white transition-opacity duration-300 bg-gray-900 rounded-md shadow-xs opacity-0 tooltip dark:bg-gray-700">
                {{ __('Editing this script is disabled in demo mode.') }}
                <div class="tooltip-arrow" data-popper-arrow></div>
            </div>
            @endif

            <p class="mt-2 text-sm text-gray-500 dark:text-gray-300">
                {{ __('Learn more about Google Analytics and how to set it up:') }}
                <a href="https://analytics.google.com/" target="_blank" class="text-primary hover:underline">
                    {{ __('Google Analytics') }}
                </a>
            </p>
        </div>
    </div>

    {!! Hook::applyFilters(SettingFilterHook::SETTINGS_INTEGRATIONS_TAB_BEFORE_SECTION_END, '') !!}
</div>
{!! Hook::applyFilters(SettingFilterHook::SETTINGS_INTEGRATIONS_TAB_AFTER_SECTION_END, '') !!}

<div class="mt-6">
    @include('backend.pages.settings.ai-settings')
</div>