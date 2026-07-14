-- ============================================================
-- CATEGORIES
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  color text,
  icon text,
  parent_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  priority int NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_categories" ON categories;
CREATE POLICY "anon_read_categories" ON categories FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_categories" ON categories;
CREATE POLICY "anon_insert_categories" ON categories FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_categories" ON categories;
CREATE POLICY "anon_update_categories" ON categories FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_categories" ON categories;
CREATE POLICY "anon_delete_categories" ON categories FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- AUTHORS
-- ============================================================
CREATE TABLE IF NOT EXISTS authors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  avatar text,
  bio text,
  role text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_authors" ON authors;
CREATE POLICY "anon_read_authors" ON authors FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_authors" ON authors;
CREATE POLICY "anon_insert_authors" ON authors FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_authors" ON authors;
CREATE POLICY "anon_update_authors" ON authors FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_authors" ON authors;
CREATE POLICY "anon_delete_authors" ON authors FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- SOURCES
-- ============================================================
CREATE TABLE IF NOT EXISTS sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  url text NOT NULL,
  type text NOT NULL,
  category text,
  priority int NOT NULL DEFAULT 5,
  is_active boolean NOT NULL DEFAULT true,
  language text NOT NULL DEFAULT 'es',
  last_fetched_at timestamptz,
  fetch_interval_seconds int NOT NULL DEFAULT 1800,
  articles_fetched int NOT NULL DEFAULT 0,
  errors_count int NOT NULL DEFAULT 0,
  config jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE sources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_sources" ON sources;
CREATE POLICY "anon_read_sources" ON sources FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_sources" ON sources;
CREATE POLICY "anon_insert_sources" ON sources FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_sources" ON sources;
CREATE POLICY "anon_update_sources" ON sources FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_sources" ON sources;
CREATE POLICY "anon_delete_sources" ON sources FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- ARTICLES
-- ============================================================
CREATE TABLE IF NOT EXISTS articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  title text NOT NULL,
  subtitle text,
  summary text,
  content text,
  excerpt text,
  meta_description text,
  image text,
  image_alt text,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  category_slug text NOT NULL,
  subcategory_slug text,
  tags text[] DEFAULT '{}',
  author_id uuid REFERENCES authors(id) ON DELETE SET NULL,
  published_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  reading_time int DEFAULT 3,
  views int NOT NULL DEFAULT 0,
  comments_count int NOT NULL DEFAULT 0,
  shares int NOT NULL DEFAULT 0,
  is_breaking boolean NOT NULL DEFAULT false,
  is_featured boolean NOT NULL DEFAULT false,
  is_trending boolean NOT NULL DEFAULT false,
  status text NOT NULL DEFAULT 'published',
  source_id uuid REFERENCES sources(id) ON DELETE SET NULL,
  source_url text,
  source_title_hash text,
  ai_rewritten boolean NOT NULL DEFAULT false,
  original_language text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles(slug);
CREATE INDEX IF NOT EXISTS idx_articles_category_slug ON articles(category_slug);
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(status);
CREATE INDEX IF NOT EXISTS idx_articles_breaking ON articles(is_breaking) WHERE is_breaking = true;
CREATE INDEX IF NOT EXISTS idx_articles_featured ON articles(is_featured) WHERE is_featured = true;
CREATE INDEX IF NOT EXISTS idx_articles_trending ON articles(is_trending) WHERE is_trending = true;
CREATE INDEX IF NOT EXISTS idx_articles_source_hash ON articles(source_title_hash);

DROP POLICY IF EXISTS "anon_read_articles" ON articles;
CREATE POLICY "anon_read_articles" ON articles FOR SELECT
  TO anon, authenticated USING (status = 'published');

DROP POLICY IF EXISTS "anon_insert_articles" ON articles;
CREATE POLICY "anon_insert_articles" ON articles FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_articles" ON articles;
CREATE POLICY "anon_update_articles" ON articles FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_articles" ON articles;
CREATE POLICY "anon_delete_articles" ON articles FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- RAW_ARTICLES (queue for processing)
-- ============================================================
CREATE TABLE IF NOT EXISTS raw_articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid REFERENCES sources(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text,
  url text,
  image text,
  published_at timestamptz,
  fetched_at timestamptz DEFAULT now(),
  status text NOT NULL DEFAULT 'pending',
  title_hash text,
  processed_at timestamptz,
  error_message text
);
ALTER TABLE raw_articles ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_raw_status ON raw_articles(status);
CREATE INDEX IF NOT EXISTS idx_raw_source ON raw_articles(source_id);
CREATE INDEX IF NOT EXISTS idx_raw_title_hash ON raw_articles(title_hash);

DROP POLICY IF EXISTS "anon_read_raw_articles" ON raw_articles;
CREATE POLICY "anon_read_raw_articles" ON raw_articles FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_raw_articles" ON raw_articles;
CREATE POLICY "anon_insert_raw_articles" ON raw_articles FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_raw_articles" ON raw_articles;
CREATE POLICY "anon_update_raw_articles" ON raw_articles FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_raw_articles" ON raw_articles;
CREATE POLICY "anon_delete_raw_articles" ON raw_articles FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- COMMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  author_name text NOT NULL,
  author_avatar text,
  content text NOT NULL,
  likes int NOT NULL DEFAULT 0,
  parent_id uuid REFERENCES comments(id) ON DELETE CASCADE,
  is_approved boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_comments_article ON comments(article_id);

DROP POLICY IF EXISTS "anon_read_comments" ON comments;
CREATE POLICY "anon_read_comments" ON comments FOR SELECT
  TO anon, authenticated USING (is_approved = true);

DROP POLICY IF EXISTS "anon_insert_comments" ON comments;
CREATE POLICY "anon_insert_comments" ON comments FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_comments" ON comments;
CREATE POLICY "anon_update_comments" ON comments FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_comments" ON comments;
CREATE POLICY "anon_delete_comments" ON comments FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- NEWSLETTER_SUBSCRIBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  preferences text[] DEFAULT '{}',
  is_active boolean NOT NULL DEFAULT true,
  subscribed_at timestamptz DEFAULT now()
);
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_insert_subscribers" ON newsletter_subscribers;
CREATE POLICY "anon_insert_subscribers" ON newsletter_subscribers FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_read_subscribers" ON newsletter_subscribers;
CREATE POLICY "anon_read_subscribers" ON newsletter_subscribers FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_delete_subscribers" ON newsletter_subscribers;
CREATE POLICY "anon_delete_subscribers" ON newsletter_subscribers FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- FETCH_ERRORS
-- ============================================================
CREATE TABLE IF NOT EXISTS fetch_errors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid REFERENCES sources(id) ON DELETE SET NULL,
  type text NOT NULL,
  message text NOT NULL,
  severity text NOT NULL DEFAULT 'warning',
  is_resolved boolean NOT NULL DEFAULT false,
  timestamp timestamptz DEFAULT now(),
  resolved_at timestamptz
);
ALTER TABLE fetch_errors ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_errors_resolved ON fetch_errors(is_resolved);
CREATE INDEX IF NOT EXISTS idx_errors_source ON fetch_errors(source_id);

DROP POLICY IF EXISTS "anon_read_errors" ON fetch_errors;
CREATE POLICY "anon_read_errors" ON fetch_errors FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_errors" ON fetch_errors;
CREATE POLICY "anon_insert_errors" ON fetch_errors FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_errors" ON fetch_errors;
CREATE POLICY "anon_update_errors" ON fetch_errors FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_errors" ON fetch_errors;
CREATE POLICY "anon_delete_errors" ON fetch_errors FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- TEAMS
-- ============================================================
CREATE TABLE IF NOT EXISTS teams (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  short_name text,
  slug text UNIQUE NOT NULL,
  league text,
  logo text,
  colors text,
  stadium text,
  manager text,
  position int,
  played int,
  won int,
  drawn int,
  lost int,
  points int,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_teams" ON teams;
CREATE POLICY "anon_read_teams" ON teams FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_teams" ON teams;
CREATE POLICY "anon_insert_teams" ON teams FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_teams" ON teams;
CREATE POLICY "anon_update_teams" ON teams FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_teams" ON teams;
CREATE POLICY "anon_delete_teams" ON teams FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- MATCHES
-- ============================================================
CREATE TABLE IF NOT EXISTS matches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  home_team text NOT NULL,
  away_team text NOT NULL,
  home_score int,
  away_score int,
  date timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'scheduled',
  competition text,
  venue text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_matches" ON matches;
CREATE POLICY "anon_read_matches" ON matches FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_matches" ON matches;
CREATE POLICY "anon_insert_matches" ON matches FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_matches" ON matches;
CREATE POLICY "anon_update_matches" ON matches FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_matches" ON matches;
CREATE POLICY "anon_delete_matches" ON matches FOR DELETE
  TO anon, authenticated USING (true);

-- ============================================================
-- SETTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_read_settings" ON settings;
CREATE POLICY "anon_read_settings" ON settings FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_settings" ON settings;
CREATE POLICY "anon_insert_settings" ON settings FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_settings" ON settings;
CREATE POLICY "anon_update_settings" ON settings FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

-- ============================================================
-- HELPER: increment article views
-- ============================================================
CREATE OR REPLACE FUNCTION increment_article_views(article_slug text)
RETURNS void AS $$
BEGIN
  UPDATE articles SET views = views + 1 WHERE slug = article_slug;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
