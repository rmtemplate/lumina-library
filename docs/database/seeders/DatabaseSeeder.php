<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Lumina Library — Master Database Seeder
     *
     * Urutan seeder berdasarkan dependency antar tabel.
     * Jalankan: php artisan db:seed
     *
     * Data yang di-seed mencakup SELURUH flow aplikasi:
     * - Auth (register, login, role)
     * - Catalog & Book management
     * - Cart → Checkout → Borrowing → QR Scan → Return
     * - Fine & Payment
     * - Search & Discovery
     * - Rack Management & Book Move
     * - Notification & Activity Log
     * - Reservation, Review, Wishlist
     */
    public function run(): void
    {
        $this->command->info('🌱 Seeding Lumina Library Database...');
        $this->command->newLine();

        // ========================================
        // PHASE 1: Master / Reference Tables
        // ========================================
        $this->command->info('📋 Phase 1: Master Tables');
        $this->call([
            ProfileTypeSeeder::class,
            RoleSeeder::class,
            PermissionSeeder::class,
            RolePermissionSeeder::class,
            AppSettingSeeder::class,
        ]);

        // ========================================
        // PHASE 2: Library Infrastructure
        // ========================================
        $this->command->info('🏛️ Phase 2: Library Infrastructure');
        $this->call([
            LibraryBranchSeeder::class,
            BookCategorySeeder::class,
        ]);

        // ========================================
        // PHASE 3: Users & Auth
        // ========================================
        $this->command->info('👤 Phase 3: Users & Auth');
        $this->call([
            UserSeeder::class,
            UserRoleSeeder::class,
            UserSessionSeeder::class,
            NotificationPreferenceSeeder::class,
        ]);

        // ========================================
        // PHASE 4: Books & Inventory
        // ========================================
        $this->command->info('📚 Phase 4: Books & Inventory');
        $this->call([
            BookSeeder::class,
            BookStockSeeder::class,
            RackSeeder::class,
            BookRackAssignmentSeeder::class,
        ]);

        // ========================================
        // PHASE 5: Transactions
        // ========================================
        $this->command->info('💳 Phase 5: Transactions');
        $this->call([
            CartSeeder::class,
            CartItemSeeder::class,
            BorrowingSeeder::class,
            BorrowingItemSeeder::class,
            BorrowingStatusHistorySeeder::class,
            BorrowingRenewalSeeder::class,
        ]);

        // ========================================
        // PHASE 6: Fines & Payments
        // ========================================
        $this->command->info('💸 Phase 6: Fines & Payments');
        $this->call([
            FineSeeder::class,
            FinePaymentSeeder::class,
        ]);

        // ========================================
        // PHASE 7: Search & Discovery
        // ========================================
        $this->command->info('🔍 Phase 7: Search & Discovery');
        $this->call([
            SearchHistorySeeder::class,
            BookViewSeeder::class,
            TrendingKeywordSeeder::class,
        ]);

        // ========================================
        // PHASE 8: Engagement Features
        // ========================================
        $this->command->info('⭐ Phase 8: Engagement');
        $this->call([
            BookReviewSeeder::class,
            UserWishlistSeeder::class,
            BookReservationSeeder::class,
        ]);

        // ========================================
        // PHASE 9: Content & Communication
        // ========================================
        $this->command->info('📢 Phase 9: Content & Communication');
        $this->call([
            BannerSeeder::class,
            NotificationSeeder::class,
            ActivityLogSeeder::class,
        ]);

        // ========================================
        // PHASE 10: Staff Operations
        // ========================================
        $this->command->info('🔧 Phase 10: Staff Operations');
        $this->call([
            BookMoveHistorySeeder::class,
            AttachmentSeeder::class,
        ]);

        $this->command->newLine();
        $this->command->info('✅ Lumina Library seeding complete!');
        $this->command->info('📊 Summary:');
        $this->command->table(
            ['Table', 'Records'],
            [
                ['profile_types', '7'],
                ['roles', '4'],
                ['permissions', '20'],
                ['users', '8'],
                ['library_branches', '3'],
                ['book_categories', '8'],
                ['books', '15'],
                ['racks', '6'],
                ['borrowings', '5 (semua status)'],
                ['fines', '2'],
                ['notifications', '6'],
                ['activity_logs', '10'],
            ]
        );
    }
}
