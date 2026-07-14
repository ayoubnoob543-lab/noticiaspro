-- ============================================================
-- CATEGORIES
-- ============================================================
INSERT INTO categories (slug, name, description, color, priority) VALUES
  ('general', 'General', 'Todas las noticias de actualidad', '#3b82f6', 100),
  ('espana', 'España', 'Noticias de España', '#dc2626', 95),
  ('internacional', 'Internacional', 'Noticias del mundo', '#0ea5e9', 90),
  ('futbol', 'Fútbol', 'Todo el fútbol nacional e internacional', '#16a34a', 99),
  ('nba', 'NBA', 'Noticias de la NBA', '#f59e0b', 70),
  ('tenis', 'Tenis', 'Noticias del mundo del tenis', '#22c55e', 65),
  ('motogp', 'MotoGP', 'Noticias del Campeonato MotoGP', '#ef4444', 65),
  ('formula-1', 'Fórmula 1', 'Noticias de la Fórmula 1', '#e11d48', 65),
  ('tecnologia', 'Tecnología', 'Noticias de tecnología e innovación', '#0ea5e9', 85),
  ('videojuegos', 'Videojuegos', 'Noticias de videojuegos y gaming', '#a855f7', 60),
  ('economia', 'Economía', 'Noticias de economía y finanzas', '#0d9488', 80),
  ('salud', 'Salud', 'Noticias de salud y bienestar', '#ec4899', 55),
  ('ciencia', 'Ciencia', 'Noticias científicas y descubrimientos', '#06b6d4', 55),
  ('viajes', 'Viajes', 'Noticias de viajes y turismo', '#14b8a6', 50),
  ('entretenimiento', 'Entretenimiento', 'Noticias de entretenimiento y cultura', '#d946ef', 75)
ON CONFLICT (slug) DO NOTHING;

-- Child categories (parent = futbol)
INSERT INTO categories (slug, name, description, color, parent_id, priority)
SELECT slug, name, description, color, parent.id, priority
FROM (VALUES
  ('laliga', 'LaLiga', 'Noticias de LaLiga EA Sports', '#f97316', 90),
  ('premier-league', 'Premier League', 'Noticias de la Premier League inglesa', '#7c3aed', 85),
  ('champions-league', 'Champions League', 'Noticias de la UEFA Champions League', '#1e40af', 88),
  ('europa-league', 'Europa League', 'Noticias de la UEFA Europa League', '#f59e0b', 80),
  ('real-madrid', 'Real Madrid', 'Noticias del Real Madrid CF', '#fbbf24', 95),
  ('barcelona', 'Barcelona', 'Noticias del FC Barcelona', '#1e3a8a', 95),
  ('atletico-madrid', 'Atlético de Madrid', 'Noticias del Atlético de Madrid', '#dc2626', 90),
  ('seleccion-espanola', 'Selección Española', 'Noticias de la Selección Española', '#c81d25', 87),
  ('mercado-fichajes', 'Mercado de Fichajes', 'Últimos fichajes y rumores del mercado', '#10b981', 92)
) AS v(slug, name, description, color, priority)
CROSS JOIN (SELECT id FROM categories WHERE slug = 'futbol') parent
ON CONFLICT (slug) DO NOTHING;

-- Child categories (parent = tecnologia)
INSERT INTO categories (slug, name, description, color, parent_id, priority)
SELECT slug, name, description, color, parent.id, priority
FROM (VALUES
  ('ia', 'IA', 'Inteligencia Artificial y machine learning', '#8b5cf6', 90),
  ('apple', 'Apple', 'Noticias de Apple, iPhone, Mac y más', '#64748b', 85),
  ('android', 'Android', 'Noticias del mundo Android', '#22c55e', 80)
) AS v(slug, name, description, color, priority)
CROSS JOIN (SELECT id FROM categories WHERE slug = 'tecnologia') parent
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- AUTHORS
-- ============================================================
INSERT INTO authors (name, avatar, bio, role) VALUES
  ('Carlos Martínez', 'https://images.pexels.com/photos/2206170/pexels-photo-2206170.jpeg?auto=compress&cs=tinysrgb&w=150', 'Editor jefe de Deportes. Especialista en fútbol internacional y LaLiga.', 'Editor Jefe Deportes'),
  ('Laura Sánchez', 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=150', 'Periodista de tecnología e IA. Cubre los avances en inteligencia artificial.', 'Editora Tecnología'),
  ('Javier Ruiz', 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=150', 'Corresponsal internacional. Cubre Europa y Oriente Medio.', 'Corresponsal Internacional'),
  ('María García', 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150', 'Especialista en economía y mercados financieros.', 'Editora Economía'),
  ('Diego Fernández', 'https://images.pexels.com/photos/1222298/pexels-photo-1222298.jpeg?auto=compress&cs=tinysrgb&w=150', 'Periodista de motor. Apasionado de la Fórmula 1 y MotoGP.', 'Editor Motor'),
  ('Sofía López', 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=150', 'Cubre el mundo del entretenimiento, cine y streaming.', 'Editora Entretenimiento'),
  ('Pablo Ortega', 'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=150', 'Especialista en NBA y baloncesto internacional.', 'Editor NBA'),
  ('Elena Torres', 'https://images.pexels.com/photos/38554/girls-fashion-fashion-photography-38554.jpeg?auto=compress&cs=tinysrgb&w=150', 'Periodista de ciencia y salud. Doctora en biomedicina.', 'Editora Ciencia y Salud')
ON CONFLICT DO NOTHING;

-- ============================================================
-- SOURCES
-- ============================================================
INSERT INTO sources (name, url, type, category, priority, is_active, language, fetch_interval_seconds, config) VALUES
  ('Marca', 'https://e00-marca.com/rss/portada.xml', 'rss', 'Deportes', 10, true, 'es', 1800, '{}'),
  ('AS', 'https://as.com/rss/portada.html', 'rss', 'Deportes', 9, true, 'es', 1800, '{}'),
  ('Mundo Deportivo', 'https://www.mundodeportivo.com/feed', 'rss', 'Deportes', 8, true, 'es', 1800, '{}'),
  ('BBC News', 'https://feeds.bbci.co.uk/news/rss.xml', 'rss', 'Internacional', 9, true, 'en', 1800, '{}'),
  ('The Guardian', 'https://content.guardianapis.com', 'guardian', 'Internacional', 8, true, 'en', 3600, '{}'),
  ('The Verge', 'https://www.theverge.com/rss/index.xml', 'rss', 'Tecnología', 8, true, 'en', 1800, '{}'),
  ('TechCrunch', 'https://techcrunch.com/feed', 'rss', 'Tecnología', 7, false, 'en', 1800, '{}')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TEAMS
-- ============================================================
INSERT INTO teams (name, short_name, slug, league, logo, colors, stadium, manager, position, played, won, drawn, lost, points) VALUES
  ('Real Madrid', 'RMA', 'real-madrid', 'LaLiga', 'https://images.pexels.com/photos/46798/pexels-photo-46798.jpeg?auto=compress&cs=tinysrgb&w=200', '#FEBE10', 'Santiago Bernabéu', 'Carlo Ancelotti', 1, 38, 28, 6, 4, 90),
  ('FC Barcelona', 'BAR', 'barcelona', 'LaLiga', 'https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg?auto=compress&cs=tinysrgb&w=200', '#A50044', 'Spotify Camp Nou', 'Xavi Hernández', 2, 38, 26, 7, 5, 85),
  ('Atlético de Madrid', 'ATM', 'atletico-madrid', 'LaLiga', 'https://images.pexels.com/photos/47730/pexels-photo-47730.jpeg?auto=compress&cs=tinysrgb&w=200', '#CB3524', 'Cívitas Metropolitano', 'Diego Simeone', 3, 38, 24, 8, 6, 80)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- MATCHES
-- ============================================================
INSERT INTO matches (home_team, away_team, home_score, away_score, date, status, competition, venue) VALUES
  ('Real Madrid', 'FC Barcelona', 3, 1, '2026-07-04T20:00:00Z', 'finished', 'LaLiga', 'Santiago Bernabéu'),
  ('Atlético de Madrid', 'Sevilla', 2, 0, '2026-07-04T18:00:00Z', 'finished', 'LaLiga', 'Cívitas Metropolitano'),
  ('Manchester City', 'Liverpool', NULL, NULL, '2026-07-05T17:30:00Z', 'scheduled', 'Premier League', 'Etihad Stadium')
ON CONFLICT DO NOTHING;

-- ============================================================
-- SAMPLE ARTICLES
-- ============================================================
INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'real-madrid-gana-champions',
  'El Real Madrid gana la Champions League',
  'El equipo blanco se proclama campeón de Europa por decimoquinta vez.',
  '<p>El Real Madrid ha vuelto a hacer historia en la Champions League.</p>',
  'https://images.pexels.com/photos/46798/pexels-photo-46798.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'real-madrid',
  (SELECT id FROM authors WHERE name = 'Carlos Martínez' LIMIT 1),
  NOW(),
  4,
  15000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'barcelona-presenta-fichaje',
  'El FC Barcelona presenta su nuevo fichaje estrella',
  'El club culé anuncia la incorporación de un jugador importante.',
  '<p>El FC Barcelona ha hecho oficial la presentación de su nueva estrella.</p>',
  'https://images.pexels.com/photos/274506/pexels-photo-274506.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'barcelona',
  (SELECT id FROM authors WHERE name = 'Carlos Martínez' LIMIT 1),
  NOW() - INTERVAL '2 hours',
  3,
  12000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'openai-lanza-nuevo-modelo',
  'OpenAI lanza nuevo modelo de IA revolucionario',
  'La nueva versión promete capacidades avanzadas de razonamiento.',
  '<p>OpenAI ha presentado oficialmente su nuevo modelo de inteligencia artificial.</p>',
  'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'ia',
  (SELECT id FROM authors WHERE name = 'Laura Sánchez' LIMIT 1),
  NOW() - INTERVAL '4 hours',
  4,
  18000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'economia-mercados-suben',
  'Los mercados financieros registran subidas',
  'El Ibex y las principales bolsas europeas cotizan en positivo.',
  '<p>Los mercados financieros han reaccionado positivamente a los últimos datos económicos.</p>',
  'https://images.pexels.com/photos/534216/pexels-photo-534216.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'economia',
  (SELECT id FROM authors WHERE name = 'María García' LIMIT 1),
  NOW() - INTERVAL '6 hours',
  3,
  8000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'noticias-espana-hoy',
  'Las noticias más importantes de España hoy',
  'Repaso a la actualidad nacional del día.',
  '<p>Repasamos los acontecimientos más relevantes de la jornada en España.</p>',
  'https://images.pexels.com/photos/138804/pexels-photo-138804.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'espana',
  (SELECT id FROM authors WHERE name = 'Javier Ruiz' LIMIT 1),
  NOW() - INTERVAL '1 hour',
  5,
  20000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status, is_breaking)
SELECT 
  'ultima-hora-noticia-importante',
  'ÚLTIMA HORA: Noticia de última hora importante',
  'Información de última hora que afecta a España.',
  '<p>Información de última hora que está generando gran impacto.</p>',
  'https://images.pexels.com/photos/51054/pexels-photo-51054.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'general',
  (SELECT id FROM authors WHERE name = 'Javier Ruiz' LIMIT 1),
  NOW() - INTERVAL '30 minutes',
  2,
  50000,
  'published',
  true
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'formula-1-gran-premio',
  'Fórmula 1: Gran Premio emocionante',
  'La carrera ha dejado un resultado sorprendente.',
  '<p>La Fórmula 1 ha vivido un Gran Premio emocionante.</p>',
  'https://images.pexels.com/photos/2526145/pexels-photo-2526145.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'formula-1',
  (SELECT id FROM authors WHERE name = 'Diego Fernández' LIMIT 1),
  NOW() - INTERVAL '8 hours',
  4,
  10000,
  'published'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO articles (slug, title, summary, content, image, category_slug, author_id, published_at, reading_time, views, status)
SELECT 
  'streaming-nueva-serie-exito',
  'Streaming: nueva serie arrasa en audiencia',
  'La producción se convierte en el éxito de la temporada.',
  '<p>Una nueva serie se ha convertido en el éxito de la temporada.</p>',
  'https://images.pexels.com/photos/2873493/pexels-photo-2873493.jpeg?auto=compress&cs=tinysrgb&w=1200',
  'streaming',
  (SELECT id FROM authors WHERE name = 'Sofía López' LIMIT 1),
  NOW() - INTERVAL '10 hours',
  3,
  9000,
  'published'
ON CONFLICT (slug) DO NOTHING;
