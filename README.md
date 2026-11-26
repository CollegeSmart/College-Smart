# College Smart website

The website for College Smart, a boutique career and college counselling organisation. It is a single static page (`index.html`) with no build step, so any static host can serve it: Netlify, Vercel, GitHub Pages or Cloudflare Pages.

## Pages

The site switches pages using the address bar hash, for example `index.html#about`:

| Page | Hash |
| --- | --- |
| Home | `#home` |
| About | `#about` |
| Career counselling | `#career` |
| College admissions | `#admissions` |
| Profile building | `#profile` |
| Workshops & university sessions | `#workshops` |
| Shop | `#shop` |
| Book a Clarity Session (3-step form) | `#book` |
| Leads (admins only) | `#leads` |

## Files

```
index.html                     the whole website: markup, styles and scripts
assets/logo.png                logo for light backgrounds
assets/logo-white.png          logo for dark backgrounds
supabase/migrations/           database setup, already applied to the live project
```

The logos are also embedded in `index.html`, so the page works on its own.

## Supabase

The site uses the Supabase project **college-smart-website** (region `ap-south-1`, Mumbai). `index.html` holds the project URL and the **publishable** key. That key is meant to be public, and the row-level security rules below control what it can do. Never put a `service_role` or secret key in this repository.

| Table / bucket | What it holds | Who can read | Who can change |
| --- | --- | --- | --- |
| `leads` | Every form submission (clarity session, book order, workshop, shop order) | Admins | Visitors can only add; admins update status or delete |
| `site_media` | Photo, video or YouTube link for each photo box | Everyone | Admins |
| `site_gallery` | Photos in the three galleries (`spoken-at`, `campus`, `past-sessions`) | Everyone | Admins |
| `site_content` | Text edited on the website | Everyone | Admins |
| `site_admins` | Which logins are admins | Each admin sees only their own row | Set from the Supabase dashboard |
| Storage bucket `site-media` | Uploaded photos and videos, 50 MB per file | Public | Admins |

### Making someone an admin

1. In the Supabase dashboard, go to **Authentication → Users → Add user**. Enter their email and a password, and tick **Auto Confirm User**.
2. In the **SQL Editor**, run:

   ```sql
   insert into public.site_admins (user_id)
   select id from auth.users where email = 'their-email@example.com';
   ```

### Using the admin tools

Click **Admin login** in the footer and sign in. You can then:

- **Add photos and videos:** each photo box gets Upload photo / video, YouTube link and Remove buttons, and each gallery gets **+ Add photos** (or **+ Add logos**).
- **Edit text:** click **✎ Edit text**, change any text, then **Save changes**.
- **See leads:** click **Leads** to filter, search and update status, or **Download CSV**.

### Adding images to the home page

Sign in with **Admin login** (in the footer), go to the Home page, and use the orange-outlined areas:

| Where on the home page | What to add | How |
| --- | --- | --- |
| Top section (next to the headline) | Main photo or video | **Upload photo / video**, or **YouTube link** |
| Our admits | University logos | Type the university name, then **+ Add logos**. You can select several files at once. The same logos also show on the Admissions page. |
| Our 5-step process | One photo per step | **Upload photo / video** on each step |
| Hear it from parents and students | Testimonial videos | **YouTube link**, or upload a short video (up to 50 MB) |
| Life at College Smart | Any number of photos | Type an optional caption, then **+ Add photos** |
| Schools and events we've spoken at | Any number of photos | Type the school or event name, then **+ Add photos** |

Each image goes live as soon as it uploads. To take one down, use **Remove**. In a gallery it asks you to click again to confirm. Use JPG, PNG or WebP photos, and PNG logos with transparent or white backgrounds. Large photos are fine, but files under about 1 MB load faster for visitors.

Admin tools only work on the live site, or when `index.html` is opened directly in a browser. They do not work inside the claude.ai preview, which blocks outside connections.

## Deploying

- **Netlify:** drag this folder onto https://app.netlify.com/drop, or connect this repository with no build command and the publish directory set to `/`.
- **GitHub Pages:** go to **Settings → Pages** and deploy from the `main` branch, root folder.

Then point `www.college-smart.com` at the host.
