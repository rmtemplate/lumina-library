<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();

        DB::table('roles')->insert([
            [
                'id'            => 'b1b2c3d4-0002-4000-8000-000000000001',
                'code'          => 'mahasiswa',
                'name'          => 'Mahasiswa',
                'description'   => 'Pengguna umum perpustakaan (mahasiswa, siswa, umum). Dapat meminjam buku, mencari katalog, dan mengelola profil.',
                'is_staff_role' => false,
                'sort_order'    => 1,
                'is_active'     => true,
                'created_at'    => $now,
                'updated_at'    => $now,
                'deleted_at'    => null,
                'created_by'    => null,
                'updated_by'    => null,
            ],
            [
                'id'            => 'b1b2c3d4-0002-4000-8000-000000000002',
                'code'          => 'staff',
                'name'          => 'Staff / Petugas',
                'description'   => 'Petugas perpustakaan. Dapat scan QR, approve peminjaman, kelola rak, dan lihat laporan.',
                'is_staff_role' => true,
                'sort_order'    => 2,
                'is_active'     => true,
                'created_at'    => $now,
                'updated_at'    => $now,
                'deleted_at'    => null,
                'created_by'    => null,
                'updated_by'    => null,
            ],
            [
                'id'            => 'b1b2c3d4-0002-4000-8000-000000000003',
                'code'          => 'librarian',
                'name'          => 'Librarian / Pustakawan',
                'description'   => 'Pustakawan senior dengan akses lebih luas. Dapat mengelola koleksi buku, waive denda, dan export laporan.',
                'is_staff_role' => true,
                'sort_order'    => 3,
                'is_active'     => true,
                'created_at'    => $now,
                'updated_at'    => $now,
                'deleted_at'    => null,
                'created_by'    => null,
                'updated_by'    => null,
            ],
            [
                'id'            => 'b1b2c3d4-0002-4000-8000-000000000004',
                'code'          => 'admin',
                'name'          => 'Administrator',
                'description'   => 'Administrator sistem dengan akses penuh ke seluruh fitur dan pengaturan.',
                'is_staff_role' => true,
                'sort_order'    => 4,
                'is_active'     => true,
                'created_at'    => $now,
                'updated_at'    => $now,
                'deleted_at'    => null,
                'created_by'    => null,
                'updated_by'    => null,
            ],
        ]);
    }
}
