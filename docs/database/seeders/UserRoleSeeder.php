<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

/**
 * Multi-role assignment.
 * Ahmad = librarian + staff (2 roles)
 * Admin = admin + librarian + staff (3 roles)
 */
class UserRoleSeeder extends Seeder
{
    public function run(): void
    {
        $now   = Carbon::now();
        $admin = 'c1b2c3d4-0003-4000-8000-000000000006';

        $rMhs  = 'b1b2c3d4-0002-4000-8000-000000000001';
        $rStf  = 'b1b2c3d4-0002-4000-8000-000000000002';
        $rLib  = 'b1b2c3d4-0002-4000-8000-000000000003';
        $rAdm  = 'b1b2c3d4-0002-4000-8000-000000000004';

        $assignments = [
            // User Budi → mahasiswa
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000001', 'role' => $rMhs, 'by' => null],
            // User Rina → mahasiswa
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000002', 'role' => $rMhs, 'by' => null],
            // User Dimas → mahasiswa
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000003', 'role' => $rMhs, 'by' => null],
            // User Putri → mahasiswa
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000007', 'role' => $rMhs, 'by' => null],
            // User Reza → mahasiswa
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000008', 'role' => $rMhs, 'by' => null],
            // Staff Sarah → staff
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000004', 'role' => $rStf, 'by' => $admin],
            // Librarian Ahmad → librarian + staff (multi-role)
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000005', 'role' => $rLib, 'by' => $admin],
            ['user' => 'c1b2c3d4-0003-4000-8000-000000000005', 'role' => $rStf, 'by' => $admin],
            // Admin → admin + librarian + staff (multi-role)
            ['user' => $admin, 'role' => $rAdm, 'by' => null],
            ['user' => $admin, 'role' => $rLib, 'by' => null],
            ['user' => $admin, 'role' => $rStf, 'by' => null],
        ];

        foreach ($assignments as $a) {
            DB::table('user_roles')->insert([
                'id'          => Str::uuid()->toString(),
                'user_id'     => $a['user'],
                'role_id'     => $a['role'],
                'assigned_at' => $now,
                'assigned_by' => $a['by'],
                'is_active'   => true,
                'created_at'  => $now,
                'updated_at'  => $now,
                'deleted_at'  => null,
            ]);
        }
    }
}
