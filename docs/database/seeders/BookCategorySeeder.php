<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class BookCategorySeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();
        $admin = 'c1b2c3d4-0003-4000-8000-000000000006';

        $categories = [
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000001', 'code' => 'fiksi',     'name' => 'Fiksi & Sastra',           'icon' => 'auto_stories',   'desc' => 'Novel, cerpen, puisi, dan karya sastra lainnya.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000002', 'code' => 'sains',     'name' => 'Sains & Matematika',       'icon' => 'science',        'desc' => 'Fisika, kimia, biologi, matematika, dan ilmu alam.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000003', 'code' => 'teknologi', 'name' => 'Teknologi & Komputer',     'icon' => 'computer',       'desc' => 'Programming, software engineering, AI, dan teknologi informasi.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000004', 'code' => 'sejarah',   'name' => 'Sejarah & Budaya',         'icon' => 'history_edu',    'desc' => 'Sejarah dunia, Indonesia, antropologi, dan studi budaya.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000005', 'code' => 'bisnis',    'name' => 'Bisnis & Ekonomi',         'icon' => 'business_center','desc' => 'Manajemen, ekonomi, keuangan, marketing, dan entrepreneurship.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000006', 'code' => 'psikologi', 'name' => 'Psikologi & Self-Help',    'icon' => 'psychology',     'desc' => 'Psikologi, pengembangan diri, kebiasaan, dan motivasi.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000007', 'code' => 'agama',     'name' => 'Agama & Filsafat',         'icon' => 'menu_book',      'desc' => 'Studi agama, filsafat, etika, dan spiritualitas.'],
            ['id' => 'e1b2c3d4-0005-4000-8000-000000000008', 'code' => 'referensi', 'name' => 'Referensi & Ensiklopedia', 'icon' => 'library_books',  'desc' => 'Kamus, ensiklopedia, atlas, dan buku referensi umum.'],
        ];

        foreach ($categories as $i => $c) {
            DB::table('book_categories')->insert([
                'id'          => $c['id'],
                'code'        => $c['code'],
                'name'        => $c['name'],
                'description' => $c['desc'],
                'icon_name'   => $c['icon'],
                'sort_order'  => $i + 1,
                'is_active'   => true,
                'created_at'  => $now,
                'updated_at'  => $now,
                'deleted_at'  => null,
                'created_by'  => $admin,
                'updated_by'  => $admin,
            ]);
        }
    }
}
