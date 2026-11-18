-- MENTALITYX — schema Supabase. Esegui tutto in Supabase > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  role text not null default 'user' check (role in ('user','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.contents (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 100),
  type text not null check (type in ('TikTok','YouTube','Immagine')),
  url text not null,
  description text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.votes (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.contents(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(content_id,user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.contents(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, username) values (new.id, split_part(new.email,'@',1));
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.contents enable row level security;
alter table public.votes enable row level security;
alter table public.comments enable row level security;

-- Profilo: tutti possono leggere i nomi pubblici; ciascuno modifica solo il proprio username.
drop policy if exists "profiles readable" on public.profiles;
create policy "profiles readable" on public.profiles for select using (true);
-- I profili sono in sola lettura dal client: il ruolo admin si assegna dal pannello SQL.

-- Contenuti visibili a tutti; solo admin può crearli/modificarli/eliminarli.
drop policy if exists "contents public read" on public.contents;
create policy "contents public read" on public.contents for select using (true);
drop policy if exists "admin inserts contents" on public.contents;
create policy "admin inserts contents" on public.contents for insert to authenticated with check (exists(select 1 from public.profiles where id=auth.uid() and role='admin'));
drop policy if exists "admin updates contents" on public.contents;
create policy "admin updates contents" on public.contents for update to authenticated using (exists(select 1 from public.profiles where id=auth.uid() and role='admin')) with check (exists(select 1 from public.profiles where id=auth.uid() and role='admin'));
drop policy if exists "admin deletes contents" on public.contents;
create policy "admin deletes contents" on public.contents for delete to authenticated using (exists(select 1 from public.profiles where id=auth.uid() and role='admin'));

-- Voti: visibili per calcolare la classifica; inserimento solo per sé; un voto per contenuto/account.
drop policy if exists "votes public read" on public.votes;
create policy "votes public read" on public.votes for select using (true);
drop policy if exists "users insert own vote" on public.votes;
create policy "users insert own vote" on public.votes for insert to authenticated with check (auth.uid() = user_id);

-- Commenti: pubblici in lettura; utenti autenticati scrivono e cancellano i propri.
drop policy if exists "comments public read" on public.comments;
create policy "comments public read" on public.comments for select using (true);
drop policy if exists "users insert own comments" on public.comments;
create policy "users insert own comments" on public.comments for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "users delete own comments" on public.comments;
create policy "users delete own comments" on public.comments for delete to authenticated using (auth.uid() = user_id);

-- NOTA: non mettere mai la service_role key nel sito. Usa solo la anon/publishable key.
