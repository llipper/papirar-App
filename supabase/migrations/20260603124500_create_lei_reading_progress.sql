create table if not exists public.lei_reading_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lei_id text not null,
  lei_title text not null,
  lei_sigla text not null default '',
  last_offset double precision not null default 0,
  total_seconds integer not null default 0,
  updated_at timestamptz not null default now(),
  unique (user_id, lei_id)
);

create index if not exists lei_reading_progress_user_updated_idx
on public.lei_reading_progress (user_id, updated_at desc);

alter table public.lei_reading_progress enable row level security;

create policy "Users can read own reading progress"
on public.lei_reading_progress
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert own reading progress"
on public.lei_reading_progress
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update own reading progress"
on public.lei_reading_progress
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
