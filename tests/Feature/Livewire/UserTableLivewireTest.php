<?php

declare(strict_types=1);

use App\Http\Middleware\VerifyCsrfToken;
use App\Livewire\Datatable\UserDatatable;
use App\Models\Permission;
use App\Models\Role;
use Livewire\Livewire;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

pest()->use(RefreshDatabase::class);

beforeEach(function () {
    // Disable CSRF protection for tests.
    $this->withoutMiddleware(VerifyCsrfToken::class);

    // Create admin user with permissions
    $this->admin = User::factory()->create();
    $adminRole = Role::create(['name' => 'Superadmin', 'guard_name' => 'web']);

    // Create necessary permissions
    Permission::create(['name' => 'user.view']);
    Permission::create(['name' => 'user.create']);
    Permission::create(['name' => 'user.edit']);
    Permission::create(['name' => 'user.delete']);

    $adminRole->syncPermissions([
        'user.view',
        'user.create',
        'user.edit',
        'user.delete',
    ]);

    $this->admin->assignRole($adminRole);
});

it('renders user table successfully', function () {
    $this->actingAs($this->admin);
    Livewire::test(UserDatatable::class)
        ->assertStatus(200);
});

it('searches users by name and email', function () {
    $this->actingAs($this->admin);
    $user = User::factory()->create(['first_name' => 'John Doe', 'email' => 'john@example.com']);
    Livewire::test(UserDatatable::class)
        ->set('search', 'John')
        ->assertSee('John Doe')
        ->set('search', 'john@example.com')
        ->assertSee('john@example.com');
});

it('filters users by role', function () {
    $this->actingAs($this->admin);
    $user = User::factory()->create(['first_name' => 'RoleUser']);
    $role = \Spatie\Permission\Models\Role::create(['name' => 'admin']);
    $user->assignRole('admin');
    Livewire::test(UserDatatable::class)
        ->set('role', 'admin')
        ->assertSee('RoleUser');
});

it('paginates users', function () {
    $this->actingAs($this->admin);
    User::factory()->count(15)->create();
    Livewire::test(UserDatatable::class)
        ->assertSee('Search by name or email...')
        ->set('page', 2)
        ->assertStatus(200);
});
