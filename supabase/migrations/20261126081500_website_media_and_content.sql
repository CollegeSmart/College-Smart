-- Who may change the website (add rows here to make someone an admin)
create table public.site_admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.site_admins enable row level security;
revoke all on public.site_admins from anon;
grant select on public.site_admins to authenticated;
create policy "Admins can see their own admin row"
  on public.site_admins for select to authenticated
  using ((select auth.uid()) = user_id);

-- Images / videos placed in named slots on the website
create table public.site_media (
  slot text primary key check (char_length(slot) between 1 and 120),
  kind text not null check (kind in ('image','video','youtube')),
  url text not null check (char_length(url) <= 2000),
  storage_path text,
  alt text check (char_length(alt) <= 300),
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid() references auth.users (id) on delete set null
);
alter table public.site_media enable row level security;
grant select on public.site_media to anon, authenticated;
grant insert, update, delete on public.site_media to authenticated;
create policy "Anyone can view site media" on public.site_media
  for select to anon, authenticated using (true);
create policy "Admins can add site media" on public.site_media
  for insert to authenticated
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can change site media" on public.site_media
  for update to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can remove site media" on public.site_media
  for delete to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));

-- Edited text blocks on the website
create table public.site_content (
  slot text primary key check (char_length(slot) between 1 and 120),
  html text not null check (char_length(html) <= 20000),
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid() references auth.users (id) on delete set null
);
alter table public.site_content enable row level security;
grant select on public.site_content to anon, authenticated;
grant insert, update, delete on public.site_content to authenticated;
create policy "Anyone can view site text" on public.site_content
  for select to anon, authenticated using (true);
create policy "Admins can add site text" on public.site_content
  for insert to authenticated
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can change site text" on public.site_content
  for update to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can remove site text" on public.site_content
  for delete to authenticated
  using (exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));

create index site_media_updated_by_idx on public.site_media (updated_by);
create index site_content_updated_by_idx on public.site_content (updated_by);

-- Public storage bucket for uploaded photos and videos (50 MB per file)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-media', 'site-media', true, 52428800,
        array['image/jpeg','image/png','image/webp','image/gif','image/avif','video/mp4','video/webm','video/quicktime']);

create policy "Admins can upload site files" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'site-media' and exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can read site files" on storage.objects
  for select to authenticated
  using (bucket_id = 'site-media' and exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can replace site files" on storage.objects
  for update to authenticated
  using (bucket_id = 'site-media' and exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())))
  with check (bucket_id = 'site-media' and exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
create policy "Admins can delete site files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'site-media' and exists (select 1 from public.site_admins a where a.user_id = (select auth.uid())));
