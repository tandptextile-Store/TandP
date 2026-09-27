-- T&P Textiles — Supabase schema
-- Run this in Supabase Dashboard → SQL Editor (or via `supabase db push`)

create extension if not exists "pgcrypto";

-- ========== PRODUCTS ==========
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in
    ('uniforms','kids','womens','sports','doctor','nurse','safety')),
  price numeric(10,2) not null check (price >= 0),
  stock int not null default 0,
  image_url text,
  description text,
  created_at timestamptz not null default now()
);

-- ========== ADMINS ==========
-- Add rows here (by auth.users.id) for anyone allowed to manage products.
create table if not exists admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

-- ========== ORDERS ==========
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  address text not null,
  phone text not null,
  total numeric(10,2) not null,
  status text not null default 'pending', -- pending | paid | shipped | cancelled
  created_at timestamptz not null default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  product_name text not null,
  price numeric(10,2) not null,
  qty int not null check (qty > 0)
);

-- ========== ROW LEVEL SECURITY ==========
alter table products enable row level security;
alter table admins enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

-- Anyone (including anonymous visitors) can view products
create policy "Public can read products"
  on products for select
  using (true);

-- Only admins can insert/update/delete products
create policy "Admins can insert products"
  on products for insert
  with check (exists (select 1 from admins where user_id = auth.uid()));

create policy "Admins can update products"
  on products for update
  using (exists (select 1 from admins where user_id = auth.uid()));

create policy "Admins can delete products"
  on products for delete
  using (exists (select 1 from admins where user_id = auth.uid()));

-- Admins table: only admins can see who else is admin
create policy "Admins can read admins"
  on admins for select
  using (exists (select 1 from admins a where a.user_id = auth.uid()));

-- Orders: a user can see and create only their own orders; admins can see all
create policy "Users can read own orders"
  on orders for select
  using (auth.uid() = user_id or exists (select 1 from admins where user_id = auth.uid()));

create policy "Users can create own orders"
  on orders for insert
  with check (auth.uid() = user_id);

create policy "Admins can update orders"
  on orders for update
  using (exists (select 1 from admins where user_id = auth.uid()));

-- Order items: visible if the parent order is visible
create policy "Users can read own order items"
  on order_items for select
  using (
    exists (
      select 1 from orders o
      where o.id = order_items.order_id
      and (o.user_id = auth.uid() or exists (select 1 from admins where user_id = auth.uid()))
    )
  );

create policy "Users can insert own order items"
  on order_items for insert
  with check (
    exists (select 1 from orders o where o.id = order_items.order_id and o.user_id = auth.uid())
  );

-- ========== AFTER RUNNING THIS FILE ==========
-- 1. Create your admin's login normally through the site's Sign Up form
--    (this creates a row in auth.users).
-- 2. In the SQL Editor, find that user's id:
--      select id, email from auth.users;
-- 3. Grant admin access:
--      insert into admins (user_id) values ('<that-uuid>');
