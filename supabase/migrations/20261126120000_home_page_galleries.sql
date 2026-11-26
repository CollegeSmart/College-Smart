alter table public.site_gallery drop constraint site_gallery_gallery_check;
alter table public.site_gallery add constraint site_gallery_gallery_check
  check (gallery in ('spoken-at','campus','past-sessions','admits','home-moments'));
