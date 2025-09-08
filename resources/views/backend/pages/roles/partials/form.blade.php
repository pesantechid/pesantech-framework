<x-card>
    <x-slot name="header">
        {{ __('Role Details') }}
        <x-buttons.submit-buttons :classNames="['wrapper' => 'flex gap-4']" cancelUrl="{{ route('admin.roles.index') }}" />
    </x-slot>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
            <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ __('Role Name') }}
            </label>
            <input required autofocus name="name" value="{{ old('name') ?? $role->name ?? '' }}" type="text"
                placeholder="{{ __('Enter a Role Name') }}" class="mt-2 form-control" autofocus>
        </div>
    </div>
</x-card>

<x-card class="mt-6">
    <x-slot name="header">{{ __('Permissions') }}</x-slot>
    <div>
        <div class="mb-4">
            <input type="checkbox" id="checkPermissionAll" class="form-checkbox mr-2" @isset($role) {{ $roleService->roleHasPermissions($role, $all_permissions) ? 'checked' : '' }} @endisset>
            <label for="checkPermissionAll" class="text-sm text-gray-700 dark:text-gray-300 font-medium">
                {{ __('Select All') }}
            </label>
        </div>
        <hr class="mb-6">
        @php $i = 1; @endphp
        @foreach ($permission_groups as $group)
            <div class="mb-6">
                <div class="flex items-center mb-2">
                    <input type="checkbox" id="group{{ $i }}Management" class="form-checkbox mr-2" @isset($role) {{ $roleService->roleHasPermissions($role, $roleService->getPermissionsByGroupName($group->name)) ? 'checked' : '' }} @endisset>
                    <label for="group{{ $i }}Management" class="capitalize text-sm font-medium text-gray-700 dark:text-gray-300">
                        {{ ucfirst($group->name) }}
                    </label>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 xl:grid-cols-6 gap-4" data-group="group{{ $i }}Management">
                    @php
                        $permissions = $roleService->getPermissionsByGroupName($group->name);
                    @endphp
                    @foreach ($permissions as $permission)
                    <div>
                        <input type="checkbox" id="checkPermission{{ $permission->id }}" name="permissions[]" value="{{ $permission->name }}" class="form-checkbox mr-2"
                                @isset($role) {{ $role->hasPermissionTo($permission->name) ? 'checked' : '' }} @endisset>
                        <label for="checkPermission{{ $permission->id }}" class="capitalize text-sm text-gray-700 dark:text-gray-300">
                            {{ $permission->name }}
                        </label>
                    </div>
                    @php $i++; @endphp
                    @endforeach
                </div>
            </div>
        @endforeach
    </div>
    <x-slot name="footer">
        <div class="flex justify-end">
            <x-buttons.submit-buttons cancelUrl="{{ route('admin.roles.index') }}" />
        </div>
    </x-slot>
</x-card>

@push('scripts')
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // Get the main "Select All" checkbox
            const checkPermissionAll = document.getElementById("checkPermissionAll");

            // Direct click handler for "Select All" checkbox
            checkPermissionAll.addEventListener("click", function () {
                const isChecked = this.checked;
                document
                    .querySelectorAll('input[type="checkbox"]')
                    .forEach((checkbox) => {
                        checkbox.checked = isChecked;
                    });
            });

            // Direct click handler for each group checkbox
            document
                .querySelectorAll('[id$="Management"]')
                .forEach((groupCheckbox) => {
                    groupCheckbox.addEventListener("click", function () {
                        const isChecked = this.checked;
                        const groupId = this.id;
                        const groupClass = `group-${groupId}`;

                        // Find all checkboxes within this group container
                        const checkboxContainer = document.querySelector(
                            `[data-group="${groupId}"]`
                        );
                        if (checkboxContainer) {
                            const childCheckboxes = checkboxContainer.querySelectorAll(
                                'input[type="checkbox"]'
                            );
                            childCheckboxes.forEach((checkbox) => {
                                checkbox.checked = isChecked;
                            });
                        }

                        updateSelectAllState();
                    });
                });

            // Direct click handler for individual permission checkboxes
            document
                .querySelectorAll('input[name="permissions[]"]')
                .forEach((checkbox) => {
                    checkbox.addEventListener("click", function () {
                        // Find the group this checkbox belongs to
                        const groupContainer = this.closest('[data-group]');
                        if (!groupContainer) return;

                        const groupId = groupContainer.getAttribute('data-group');
                        if (!groupId) return;

                        // Get all checkboxes in this group
                        const allCheckboxes = groupContainer.querySelectorAll('input[name="permissions[]"]');
                        const allChecked = Array.from(allCheckboxes).every(cb => cb.checked);

                        // Update the group checkbox state
                        const groupCheckbox = document.getElementById(groupId);
                        if (groupCheckbox) {
                            groupCheckbox.checked = allChecked;
                        }

                        updateSelectAllState();
                    });
                });

            // Function to update the "Select All" checkbox state
            function updateSelectAllState() {
                const totalPermissionCheckboxes = document.querySelectorAll('input[name="permissions[]"]').length;
                const checkedPermissionCheckboxes = document.querySelectorAll('input[name="permissions[]"]:checked').length;

                checkPermissionAll.checked = (totalPermissionCheckboxes > 0 &&
                    checkedPermissionCheckboxes === totalPermissionCheckboxes);
            }

            // Initialize the correct state for all checkboxes
            updateSelectAllState();
        });
    </script>
@endpush