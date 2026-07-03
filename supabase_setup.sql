-- ════════════════════════════════════════════════════════════════
--  黄金郷の家計簿 — Supabase セットアップSQL
--  Supabase の SQL Editor に貼り付けて「Run」を1回実行してください。
-- ════════════════════════════════════════════════════════════════

-- 記録テーブル
create table if not exists public.records (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  date       date not null,
  diff       integer not null default 0,   -- 差枚
  games      integer not null default 0,   -- 回転数
  bita_try   integer not null default 0,   -- ビタ試行
  bita_hit   integer not null default 0,   -- ビタ成功
  setting    text default '',              -- 推測設定
  memo       text default '',              -- 覚書
  photos     jsonb not null default '[]'::jsonb, -- 写真（圧縮画像dataURLの配列）
  created_at timestamptz not null default now()
);

-- 既にテーブルがある場合でも photos 列を追加（この1行だけでも移行できます）
alter table public.records
  add column if not exists photos jsonb not null default '[]'::jsonb;

-- 自分の記録を日付順に引きやすくする索引
create index if not exists records_user_date_idx
  on public.records (user_id, date);

-- 行レベルセキュリティ（他人の記録は見えない／触れない）
alter table public.records enable row level security;

-- 既存ポリシーがあれば作り直す
drop policy if exists "records_select_own" on public.records;
drop policy if exists "records_insert_own" on public.records;
drop policy if exists "records_update_own" on public.records;
drop policy if exists "records_delete_own" on public.records;

create policy "records_select_own" on public.records
  for select using (auth.uid() = user_id);

create policy "records_insert_own" on public.records
  for insert with check (auth.uid() = user_id);

create policy "records_update_own" on public.records
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "records_delete_own" on public.records
  for delete using (auth.uid() = user_id);
