# T&P Textiles — Online Store

Static frontend (plain HTML/JS + Supabase) deployable on Vercel, with a
Supabase Postgres database for products, accounts, and orders.

## 1. Create the Supabase project

1. Go to https://supabase.com → New Project (pick a region close to India, e.g. Mumbai/Singapore).
2. Once it's created, open **SQL Editor** → paste the contents of `supabase/schema.sql` → Run.
   This creates the `products`, `admins`, `orders`, and `order_items` tables with
   Row Level Security policies already applied.
3. Go to **Project Settings → API** and copy:
   - **Project URL**
   - **anon public key**
4. Open `public/config.js` in this project and paste those two values in.
   (The anon key is *meant* to be public — access control is handled by the
   RLS policies in the SQL file, not by hiding this key.)
5. In **Authentication → Providers**, Email sign-up is on by default — that's
   all you need for customer accounts. (Optional: turn off "Confirm email" in
   Authentication → Settings if you want instant sign-up without email verification.)

## 2. Make yourself an admin

1. Open your deployed (or locally run) site and use the **Sign Up** form to create your own account.
2. In Supabase → **SQL Editor**, run:
   ```sql
   select id, email from auth.users;
   ```
3. Copy your user's `id`, then run:
   ```sql
   insert into admins (user_id) values ('paste-your-uuid-here');
   ```
4. Reload the site and open the **Admin** tab — you can now upload products by category.

## 3. Deploy to Vercel

**Option A — from the Vercel dashboard (easiest):**
1. Push this folder to a GitHub repo.
2. Go to https://vercel.com/new → Import that repo.
3. Framework preset: "Other" (it's a static site + serverless functions — Vercel auto-detects `public/` and `api/`).
4. Deploy.

**Option B — from the command line:**
```bash
npm install -g vercel
vercel login
vercel        # deploy a preview
vercel --prod # deploy to production
```

## 4. Connect a real payment gateway (optional, for going live)

`api/create-payment-order.js` is a stub. To accept real payments:
1. Sign up with a gateway that supports Indian merchants (Razorpay, Cashfree, PayU, etc.).
2. Get your **Key ID** and **Key Secret** from their dashboard.
3. In Vercel → Project Settings → Environment Variables, add `RAZORPAY_KEY_ID`
   and `RAZORPAY_KEY_SECRET` (never put secret keys in `public/` files).
4. Fill in the real gateway call inside `api/create-payment-order.js` (a
   commented example is included) and wire the frontend's `placeOrder()`
   function in `public/index.html` to call `/api/create-payment-order` and
   open the gateway's checkout widget.
5. Redeploy.

Until this is wired up, checkout creates an order in Supabase with
`status: 'pending'` so you can follow up and collect payment manually
(UPI/bank transfer, cash on delivery, etc.) if you prefer not to integrate
a gateway right away.

## Project structure

```
public/
  index.html      ← the whole storefront (browse, cart, auth, checkout, admin)
  config.js       ← your Supabase URL + anon key go here
api/
  create-payment-order.js  ← serverless function, payment gateway stub
supabase/
  schema.sql      ← run this once in Supabase SQL Editor
vercel.json
package.json
.env.example
```
