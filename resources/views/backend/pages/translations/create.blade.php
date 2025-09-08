<div x-data="{ open: false }" 
     x-on:open-add-language-modal.window="open = true"
     id="add-language-modal">
    <x-modal x-show="open">
        <x-slot name="header">
            {{ __('Add New Language') }}
        </x-slot>

        <form
            action="{{ route('admin.translations.create') }}"
            method="POST"
            id="add-language-form"
        >
            @csrf
            <div class="mb-4">
                <label for="language-code" class="block mb-2 text-sm font-medium text-gray-700 dark:text-white">
                    {{ __('Select Language') }}
                </label>
                <select id="language-code" name="language_code" class="h-11 w-full rounded-md border border-gray-300 bg-transparent px-4 py-2 text-sm text-gray-700 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90" required>
                    <option value="">{{ __('Select a language') }}</option>
                    @foreach($allLanguages as $code => $languageName)
                        @if(!array_key_exists($code, $languages))
                            <option value="{{ $code }}">{{ $languageName }}</option>
                        @endif
                    @endforeach
                </select>
            </div>
            <div class="mb-4">
                <label for="translation-group" class="block mb-2 text-sm font-medium text-gray-700 dark:text-white">
                    {{ __('Translation Group') }}
                </label>
                <select id="translation-group" name="group" class="h-11 w-full rounded-md border border-gray-300 bg-transparent px-4 py-2 text-sm text-gray-700 focus:ring-brand-500/10 focus:outline-hidden dark:border-gray-700 dark:bg-gray-900 dark:text-white/90" required>
                    <option value="json" selected>{{ __('General') }}</option>
                    @foreach($groups as $key => $name)
                        @if($key !== 'json')
                            <option value="{{ $key }}">{{ $name }}</option>
                        @endif
                    @endforeach
                </select>
            </div>
        </form>

        <x-slot name="footer">
            <button type="button" class="btn-primary" @click="document.getElementById('add-language-form').submit()">
                <iconify-icon icon="lucide:plus-circle" class="mr-2"></iconify-icon>{{ __('Add Language') }}
            </button>
            <button type="button" class="btn-default" @click="open = false">
                {{ __('Cancel') }}
            </button>
        </x-slot>
    </x-modal>
</div>
