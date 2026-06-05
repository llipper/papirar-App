create table if not exists public.lei_highlights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lei_id text not null,
  bloco_index integer not null check (bloco_index >= 0),
  part_index integer not null default 0 check (part_index >= 0),
  start_offset integer not null check (start_offset >= 0),
  end_offset integer not null check (end_offset > start_offset),
  color text not null check (color in ('yellow', 'red', 'blue', 'green')),
  selected_text text not null check (char_length(selected_text) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists lei_highlights_user_lei_idx
on public.lei_highlights (user_id, lei_id, bloco_index, part_index);

alter table public.lei_highlights enable row level security;

create policy "Users can read own highlights"
on public.lei_highlights
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert own highlights"
on public.lei_highlights
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can delete own highlights"
on public.lei_highlights
for delete
to authenticated
using (auth.uid() = user_id);
