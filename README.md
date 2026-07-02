# 黄金郷の家計簿 — うみねこのなく頃に2 収支帳

スマスロ「うみねこのなく頃に2」の収支を記録する、単一HTMLの家計簿アプリ。
差枚・回転数・ビタ押しを記録し、カレンダー・グラフ・台帳で振り返れます。

- **フロント**: HTML1枚（Cormorant Garamond / しっぽり明朝 / DM Mono、羊皮紙の帳簿デザイン）
- **保存**: Supabase（アカウント登録＋クラウド保存、どの端末からでも開帳）／ 未登録なら端末内(localStorage)のみでも利用可
- **グラフ**: Chart.js（累計差枚・日別・ビタ成功率・月別）

## 公開（GitHub Pages）

1. リポジトリの **Settings → Pages** で Source を `main` ブランチ / `/ (root)` に設定
2. 発行URL `https://shunsuke2121.github.io/Umineko2/` を開く

## 初回セットアップ

1. [supabase.com](https://supabase.com) で無料プロジェクトを作成
2. **SQL Editor** に [`supabase_setup.sql`](./supabase_setup.sql) を貼って実行（テーブル＋行レベルセキュリティを作成）
3. **Project Settings → API** の `Project URL` と `anon public` キーをコピー
4. アプリの「接続の設定」画面に貼り付け → アカウント登録 / ログイン

### 補足
- 確認メールを使う場合、Supabase の **Authentication → URL Configuration → Site URL** を Pages のURLに設定してください。すぐ使いたい場合は同画面でメール確認をオフにできます。
- URL/キーを毎回貼るのが面倒なら、`index.html` 冒頭の `HARD_URL` / `HARD_KEY` に直書きすると設定画面を省けます（Publicリポジトリでは anon key が公開される点に注意。RLSで保護される設計です）。
- データは「JSONで封じる」でいつでもバックアップできます。
