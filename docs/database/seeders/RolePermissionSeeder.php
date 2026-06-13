<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();

        // Permission ID map (from PermissionSeeder)
        $perm = fn(int $n) => sprintf('p1b2c3d4-000c-4000-8000-%012d', $n);

        // Role IDs
        $mahasiswa = 'b1b2c3d4-0002-4000-8000-000000000001';
        $staff     = 'b1b2c3d4-0002-4000-8000-000000000002';
        $librarian = 'b1b2c3d4-0002-4000-8000-000000000003';
        $admin     = 'b1b2c3d4-0002-4000-8000-000000000004';

        // Mahasiswa: book.view(1), borrowing.create(5)
        $mahasiswaPerms = [1, 5];

        // Staff: book.view(1), book.create(2), book.update(3), borrowing.approve(6),
        //        borrowing.return(7), borrowing.view_all(8), fine.create(9),
        //        fine.view_all(11), report.view(12), user.view_all(14),
        //        rack.manage(18), rack.move_books(19)
        $staffPerms = [1, 2, 3, 6, 7, 8, 9, 11, 12, 14, 18, 19];

        // Librarian: all staff + book.delete(4), fine.waive(10), report.export(13),
        //            user.create(15), user.update(16)
        $librarianPerms = array_merge($staffPerms, [4, 10, 13, 15, 16]);

        // Admin: ALL (1-20)
        $adminPerms = range(1, 20);

        $assignments = [
            $mahasiswa => $mahasiswaPerms,
            $staff     => $staffPerms,
            $librarian => $librarianPerms,
            $admin     => $adminPerms,
        ];

        foreach ($assignments as $roleId => $permIds) {
            foreach ($permIds as $permId) {
                DB::table('role_permissions')->insert([
                    'id'            => Str::uuid()->toString(),
                    'role_id'       => $roleId,
                    'permission_id' => $perm($permId),
                    'created_at'    => $now,
                    'created_by'    => null,
                ]);
            }
        }
    }
}
