-- Every form submission from the website
create table public.leads (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  form text not null check (form in ('clarity_session','book_order','workshop','shop_order')),
  name text not null check (char_length(name) between 1 and 200),
  email text check (email is null or (char_length(email) <= 320 and email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$')),
  phone text check (phone is null or char_length(phone) <= 40),
  city text check (city is null or char_length(city) <= 120),
  details jsonb not null default '{}'::jsonb check (pg_column_size(details) <= 16000),
  status text not null default 'new' check (status in ('new','contacted','enrolled','closed')),
  notes text check (notes is null or char_length(notes) <= 5000),
  updated_at timestamptz not null default now()
);
create index leads_created_at_idx on public.leads (created_at desc);
create index leads_form_idx on public.leads (form);
alter table public.leads enable row level security;

-- Visitors may only add a lead (they cannot read, change or delete any)
grant insert (form, name, email, phone, city, details) on public.leads to anon, authenticated;
grant select, update, delete on public.leads to authenticated;
create policy "Visitors can submit a form" on public.leads
  for insert to anon, authenticated
  with check (status = 'new' and notes is null);
create policy "Admins can read leads" on public.leads
  for select to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can update leads" on public.leads
  for update to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can delete leads" on public.leads
  for delete to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));

create function public.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end; $$;
revoke execute on function public.touch_updated_at() from public, anon, authenticated;
create trigger leads_touch before update on public.leads
  for each row execute function public.touch_updated_at();

-- Photo galleries admins can add any number of images to
create table public.site_gallery (
  id uuid primary key default gen_random_uuid(),
  gallery text not null check (gallery in ('spoken-at','campus','past-sessions')),
  url text not null check (char_length(url) <= 2000),
  storage_path text,
  caption text check (caption is null or char_length(caption) <= 300),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id) on delete set null
);
create index site_gallery_gallery_idx on public.site_gallery (gallery, sort_order, created_at);
create index site_gallery_created_by_idx on public.site_gallery (created_by);
alter table public.site_gallery enable row level security;
grant select on public.site_gallery to anon, authenticated;
grant insert, update, delete on public.site_gallery to authenticated;
create policy "Anyone can view gallery photos" on public.site_gallery
  for select to anon, authenticated using (true);
create policy "Admins can add gallery photos" on public.site_gallery
  for insert to authenticated
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can change gallery photos" on public.site_gallery
  for update to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can remove gallery photos" on public.site_gallery
  for delete to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
