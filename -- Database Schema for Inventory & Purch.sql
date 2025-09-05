-- Database Schema for Inventory & Purchase Management System


-- Master Tables

-- Company table
CREATE TABLE companies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    tax_id VARCHAR(50),
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- Brand table
CREATE TABLE brands (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Categories
CREATE TABLE product_categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    parent_id BIGINT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES product_categories(id)
);

-- Product table
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_id BIGINT NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    brand_id BIGINT NULL,
    description TEXT,
    min_stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    FOREIGN KEY (category_id) REFERENCES product_categories(id);
    FOREIGN KEY (brand_id) REFERENCES brands(id);
);

-- Product Variants table
CREATE TABLE product_variants (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    variant_name VARCHAR(255) NOT NULL,
    barcode VARCHAR(50) UNIQUE,
    variant_sku VARCHAR(50) UNIQUE NOT NULL,
    abbreviation VARCHAR(20) NULL,
    external_id VARCHAR(50) NULL;
    price DECIMAL(15,2) DEFAULT 0,
    cost DECIMAL(15,2) DEFAULT 0,
    min_stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Warehouse table
CREATE TABLE warehouses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    warehouse_type ENUM('main', 'partner', 'marketplace', 'transit') DEFAULT 'main';
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE suppliers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    tax_id VARCHAR(50),
    payment_terms INT DEFAULT 30, -- days
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role ENUM('admin', 'supervisor', 'manager', 'director', 'finance', 'warehouse') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Transaction Tables - Purchases

CREATE TABLE purchase_orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    po_number VARCHAR(50) UNIQUE NOT NULL,
    supplier_id BIGINT NOT NULL,
    created_by BIGINT NOT NULL,
    status ENUM('draft', 'submitted', 'under_approval', 'approved', 'ordered', 'received', 'partially_received', 'closed', 'cancelled') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP NULL,
    approved_at TIMESTAMP NULL,
    ordered_at TIMESTAMP NULL,
    received_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    global_discount DECIMAL(5,2) DEFAULT 0,
    global_tax_percent DECIMAL(5,2) DEFAULT 0,
    shipping_cost DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    revision_number INT DEFAULT 0,
    expected_delivery_date DATE NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE purchase_order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    received_quantity INT DEFAULT 0,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
);

CREATE TABLE approval_rules (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role ENUM('supervisor', 'manager', 'director') NOT NULL,
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2) NULL,
    approver_user_id BIGINT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (approver_user_id) REFERENCES users(id)
);

CREATE TABLE purchase_approval_actions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role ENUM('supervisor', 'manager', 'director') NOT NULL,
    action ENUM('approved', 'rejected', 'revision_requested') NOT NULL,
    note TEXT,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE purchase_order_revisions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT NOT NULL,
    revision_number INT NOT NULL,
    revision_by BIGINT NOT NULL,
    revision_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    previous_total DECIMAL(15,2) NOT NULL,
    new_total DECIMAL(15,2) NOT NULL,
    revision_notes TEXT,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (revision_by) REFERENCES users(id)
);

-- Inventory Management

CREATE TABLE stock_mutations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_variant_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    qty_in INT DEFAULT 0,
    qty_out INT DEFAULT 0,
    source_type ENUM('purchase_order', 'sales_order', 'adjustment', 'transfer', 'return') NOT NULL,
    source_id BIGINT NOT NULL,
    reference_no VARCHAR(100),
    notes TEXT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE product_stock (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_variant_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY variant_warehouse (product_variant_id, warehouse_id),
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE stock_transfers (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    reference_no VARCHAR(50) UNIQUE NOT NULL,
    from_warehouse_id BIGINT NOT NULL,
    to_warehouse_id BIGINT NOT NULL,
    status ENUM('draft', 'in_transit', 'completed', 'cancelled') DEFAULT 'draft',
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    notes TEXT,
    FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE stock_transfer_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    stock_transfer_id BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    received_quantity INT DEFAULT 0,
    FOREIGN KEY (stock_transfer_id) REFERENCES stock_transfers(id) ON DELETE CASCADE,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
);

-- Financial Module

CREATE TABLE invoices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT NULL,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    supplier_id BIGINT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    remaining_amount DECIMAL(15,2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,
    status ENUM('draft', 'verified', 'approved', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'draft',
    tax_total DECIMAL(15,2) DEFAULT 0,
    discount_total DECIMAL(15,2) DEFAULT 0,
    verified_by BIGINT NULL,
    verified_at TIMESTAMP NULL,
    approved_by BIGINT NULL,
    approved_at TIMESTAMP NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (verified_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

CREATE TABLE invoice_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invoice_id BIGINT NOT NULL,
    product_variant_id BIGINT NULL, -- NULL possible for non-inventory expenses
    description VARCHAR(255),
    quantity DECIMAL(15,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_percent DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
);

CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invoice_id BIGINT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('bank_transfer', 'cash', 'check', 'credit', 'other') NOT NULL,
    paid_amount DECIMAL(15,2) NOT NULL,
    payment_reference VARCHAR(100),
    bank_account VARCHAR(100),
    notes TEXT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE purchase_returns (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_order_id BIGINT NOT NULL,
    return_number VARCHAR(50) UNIQUE NOT NULL,
    return_date DATE NOT NULL,
    supplier_id BIGINT NOT NULL,
    status ENUM('draft', 'submitted', 'approved', 'completed', 'cancelled') DEFAULT 'draft',
    total_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE purchase_return_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    purchase_return_id BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    purchase_order_item_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    reason VARCHAR(255),
    FOREIGN KEY (purchase_return_id) REFERENCES purchase_returns(id) ON DELETE CASCADE,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id),
    FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items(id)
);


-- Additional tables for E-commerce integration

-- E-commerce Platforms
CREATE TABLE ecommerce_platforms (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- E-commerce Stores/Shops
CREATE TABLE ecommerce_stores (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    platform_id BIGINT NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    store_id VARCHAR(100),
    api_key VARCHAR(255),
    api_secret VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (platform_id) REFERENCES ecommerce_platforms(id)
);

-- Product platform mapping
CREATE TABLE product_platform_mapping (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_variant_id BIGINT NOT NULL,
    platform_id BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    external_product_id VARCHAR(100),
    external_variant_id VARCHAR(100),
    platform_sku VARCHAR(100),
    platform_price DECIMAL(15,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id),
    FOREIGN KEY (platform_id) REFERENCES ecommerce_platforms(id),
    FOREIGN KEY (store_id) REFERENCES ecommerce_stores(id)
);

-- Sales Orders from E-commerce Platforms
CREATE TABLE sales_orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    platform_id BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    external_order_id VARCHAR(100) NOT NULL,
    customer_name VARCHAR(255),
    customer_phone VARCHAR(50),
    customer_username VARCHAR(100),
    shipping_address TEXT,
    shipping_city VARCHAR(100),
    shipping_province VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'returned', 'refunded') DEFAULT 'pending',
    order_date TIMESTAMP NOT NULL,
    payment_method VARCHAR(50),
    subtotal DECIMAL(15,2) NOT NULL,
    shipping_fee DECIMAL(15,2) DEFAULT 0,
    platform_fee DECIMAL(15,2) DEFAULT 0,
    platform_commission DECIMAL(15,2) DEFAULT 0,
    seller_voucher DECIMAL(15,2) DEFAULT 0,
    shipping_subsidy DECIMAL(15,2) DEFAULT 0, -- Gratis ongkir subsidy
    cashback_fee DECIMAL(15,2) DEFAULT 0,
    extra_voucher_fee DECIMAL(15,2) DEFAULT 0,
    affiliate_fee DECIMAL(15,2) DEFAULT 0, -- AMS
    live_extra_fee DECIMAL(15,2) DEFAULT 0,
    shipping_excess DECIMAL(15,2) DEFAULT 0, -- Selisih ongkir
    grand_total DECIMAL(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (platform_id) REFERENCES ecommerce_platforms(id),
    FOREIGN KEY (store_id) REFERENCES ecommerce_stores(id)
);

-- Sales Order Items
CREATE TABLE sales_order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sales_order_id BIGINT NOT NULL,
    product_variant_id BIGINT NOT NULL,
    platform_product_id VARCHAR(100),
    quantity INT NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    final_price DECIMAL(15,2) NOT NULL,
    cost_price DECIMAL(15,2) NOT NULL, -- HPP
    profit DECIMAL(15,2) GENERATED ALWAYS AS (final_price - cost_price) STORED,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sales_order_id) REFERENCES sales_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
);

-- Advertising Expenses
CREATE TABLE advertising_expenses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    platform_id BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    campaign_name VARCHAR(255),
    expense_date DATE NOT NULL,
    expense_amount DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (platform_id) REFERENCES ecommerce_platforms(id),
    FOREIGN KEY (store_id) REFERENCES ecommerce_stores(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Daily E-commerce Summary
CREATE TABLE daily_ecommerce_summary (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    store_id BIGINT NOT NULL,
    total_sales DECIMAL(15,2) DEFAULT 0,
    total_voucher_discount DECIMAL(15,2) DEFAULT 0,
    total_admin_fee DECIMAL(15,2) DEFAULT 0,
    total_service_fee DECIMAL(15,2) DEFAULT 0,
    total_hpp DECIMAL(15,2) DEFAULT 0,
    total_ad_expense DECIMAL(15,2) DEFAULT 0,
    total_ad_tax DECIMAL(15,2) DEFAULT 0,
    total_shipping_excess DECIMAL(15,2) DEFAULT 0,
    total_affiliate_fee DECIMAL(15,2) DEFAULT 0,
    total_live_extra_fee DECIMAL(15,2) DEFAULT 0,
    net_profit DECIMAL(15,2) DEFAULT 0,
    total_orders INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY date_store_unique (date, store_id),
    FOREIGN KEY (store_id) REFERENCES ecommerce_stores(id)
);


-- Indexes to optimize query performance
CREATE INDEX idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX idx_purchase_order_items_po ON purchase_order_items(purchase_order_id);
CREATE INDEX idx_stock_mutations_variant ON stock_mutations(product_variant_id);
CREATE INDEX idx_stock_mutations_warehouse ON stock_mutations(warehouse_id);
CREATE INDEX idx_product_stock_variant ON product_stock(product_variant_id);
CREATE INDEX idx_invoices_po ON invoices(purchase_order_id);
CREATE INDEX idx_invoices_supplier ON invoices(supplier_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_payments_invoice ON payments(invoice_id);



-- Create index for faster reporting
CREATE INDEX idx_sales_order_date ON sales_orders(order_date);
CREATE INDEX idx_sales_order_platform ON sales_orders(platform_id, store_id);
CREATE INDEX idx_daily_summary_date ON daily_ecommerce_summary(date);
CREATE INDEX idx_daily_summary_store ON daily_ecommerce_summary(store_id);



// Menu Master Data

Master Data
--├── Perusahaan
--├── Brand
--├── Kategori Produk
--├── Produk & Varian
--├── Gudang
--├── Supplier
--├── User
--├── Platform E-Commerce
--├── Toko E-Commerce

companies
brands
product_categories
products
product_variants
warehouses
suppliers
users
ecommerce_platforms
ecommerce_stores


// Menu Purchasing
Pembelian
--├── Purchase Order
--├── Approval PO
--├── Revisi PO
--├── Invoice Pembelian
--├── Pembayaran
--├── Retur Pembelian

purchase_orders
purchase_order_items
approval_rules
purchase_approval_actions
purchase_order_revisions
invoices
invoice_items
payments
purchase_returns
purchase_return_items

// Menu Inventory & Warehouse
Stok & Gudang
--├── Mutasi Stok
--├── Stok Produk
--├── Transfer Stok

stock_mutations
product_stock
stock_transfers
stock_transfer_items


// Menu Sales
Penjualan
--├── Sales Order
--├── Mapping Produk ke Platform

sales_orders
sales_order_items
product_platform_mapping

// Menu Finances
Keuangan
--├── Pembayaran
--├── Biaya Iklan

payments
advertising_expenses

// Menu Analytic & Report
Laporan
--├── Ringkasan Harian Ecommerce

daily_ecommerce_summary


//=====
Modules/MasterData
Modules/Purchase
Modules/Inventory
Modules/Sales
Modules/Finance
Modules/Reports

Route::group(['prefix' => 'admin/master-data', 'as' => 'admin.master_data.', 'middleware' => ['auth']], function () {
    Route::resource('companies', CompanyController::class);
    Route::resource('brands', BrandController::class);
    Route::resource('product_categories', ProductCategoryController::class);
    Route::resource('products', ProductController::class);
    Route::resource('warehouses', WarehouseController::class);
    Route::resource('suppliers', SupplierController::class);
    Route::resource('ecommerce-platforms', EcommercePlatformController::class);
    Route::resource('ecommerce-stores', EcommerceStoreController::class);
});

Route::group(['prefix' => 'admin/purchase', 'as' => 'admin.purchase.', 'middleware' => ['auth']], function () {
    Route::resource('purchase-orders', PurchaseOrderController::class);
    Route::get('purchase-orders/{id}/revisions', [PurchaseOrderRevisionController::class, 'index'])->name('purchase-orders.revisions');

    Route::resource('approvals', PurchaseApprovalController::class);
    Route::resource('invoices', InvoiceController::class);
    Route::resource('payments', PaymentController::class);
    Route::resource('returns', PurchaseReturnController::class);
});

Route::group(['prefix' => 'admin/inventory', 'as' => 'admin.inventory.', 'middleware' => ['auth']], function () {
    Route::resource('stock-mutations', StockMutationController::class);
    Route::resource('product-stock', ProductStockController::class);
    Route::resource('stock-transfers', StockTransferController::class);
});

Route::group(['prefix' => 'admin/sales', 'as' => 'admin.sales.', 'middleware' => ['auth']], function () {
    Route::resource('sales-orders', SalesOrderController::class);
    Route::resource('product-mapping', ProductPlatformMappingController::class);
});

Route::group(['prefix' => 'admin/finance', 'as' => 'admin.finance.', 'middleware' => ['auth']], function () {
    Route::resource('advertising-expenses', AdvertisingExpenseController::class);
    Route::resource('payments', PaymentController::class);
});

Route::group(['prefix' => 'admin/reports', 'as' => 'admin.reports.', 'middleware' => ['auth']], function () {
    Route::get('daily-ecommerce-summary', [ReportController::class, 'dailyEcommerce'])->name('daily_ecommerce_summary');
});




-- TASK After runing
     Migrate Fresh
     Seed database
     Seed module MasterData


