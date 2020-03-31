<?php

use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        \App\User::query()->create([
            "name" => "Administrator",
            "username" => "admin",
            "password" => \Illuminate\Support\Facades\Hash::make("admin"),
        ]);
    }
}
