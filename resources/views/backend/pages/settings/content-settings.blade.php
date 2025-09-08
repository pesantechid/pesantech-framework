{!! Hook::applyFilters(SettingFilterHook::SETTINGS_CONTENT_TAB_BEFORE_SECTION_START, '') !!}
<div
    class="rounded-md border border-gray-200 dark:border-gray-800 dark:bg-white/[0.03]"
>
    <div class="px-5 py-4 sm:px-6 sm:py-5">
        <h3 class="text-base font-medium text-gray-700 dark:text-white/90">
            {{ __("Content Settings") }}
        </h3>
    </div>
    <div
        class="space-y-6 border-t border-gray-100 p-5 sm:p-6 dark:border-gray-800"
    >
        <div class="flex flex-col sm:flex-row sm:space-x-4 space-y-4 sm:space-y-0">
            <div class="flex-1">
                <x-inputs.combobox
                    name="default_pagination_ui"
                    :label="__('Default Pagination UI')"
                    :options="[
                        ['value' => 'default', 'label' => __('Default Pagination'), 'description' => __('Shows page numbers and navigation arrows.')],
                        ['value' => 'cursor', 'label' => __('Cursor Pagination'), 'description' => __('Efficient for large datasets, only next/previous.')],
                        ['value' => 'simple', 'label' => __('Simple Pagination'), 'description' => __('Shows only next/previous buttons.')]
                    ]"
                    :selected="config('settings.default_pagination_ui', 'default')"
                    searchable="false"
                    class="w-full"
                />
            </div>
            <div class="flex-1">
                <label class="form-label">
                    {{ __("Default Pagination per page") }}
                </label>
                <input
                    type="number"
                    name="default_pagination"
                    min="1"
                    value="{{ config('settings.default_pagination') ?? 10 }}"
                    class="form-control"
                />
            </div>
        </div>
    </div>
    {!! Hook::applyFilters(SettingFilterHook::SETTINGS_CONTENT_TAB_BEFORE_SECTION_END, '') !!}
</div>
{!! Hook::applyFilters(SettingFilterHook::SETTINGS_CONTENT_TAB_AFTER_SECTION_END, '') !!}
