import { useEffect, useState, useCallback } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useVisits } from '../hooks/useVisits';
import { supabase, Article } from '../lib/supabase';
import { Menu, Search, User, Shield, Radio, ChevronRight, Clock, Flame } from 'lucide-react';

const CATEGORY_LABELS: Record<string, string> = {
  futbol: 'Fútbol',
  laliga: 'LaLiga',
  'real-madrid': 'Real Madrid',
  barcelona: 'Barcelona',
  'atletico-madrid': 'Atlético',
  'champions-league': 'Champions',
  'premier-league': 'Premier',
  'mercado-fichajes': 'Fichajes',
  'seleccion-espanola': 'La Roja',
  tecnologia: 'Tecnología',
  ia: 'Inteligencia Artificial',
  apple: 'Apple',
  android: 'Android',
  economia: 'Economía',
  negocios: 'Negocios',
  espana: 'España',
  internacional: 'Internacional',
  salud: 'Salud',
  ciencia: 'Ciencia',
  'formula-1': 'F1',
  motogp: 'MotoGP',
  tenis: 'Tenis',
  nba: 'NBA',
  entretenimiento: 'Entretenimiento',
  streaming: 'Streaming',
  series: 'Series',
  peliculas: 'Cine',
  viajes: 'Viajes',
  videojuegos: 'Videojuegos',
  general: 'General',
};

const FALLBACK_IMAGES: Record<string, string> = {
  futbol: 'https://images.pexels.com/photos/46798/the-ball-stadium-the-ball-stadium-46798.jpeg?auto=compress&cs=tinysrgb&w=800',
  tecnologia: 'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=800',
  economia: 'https://images.pexels.com/photos/534216/pexels-photo-534216.jpeg?auto=compress&cs=tinysrgb&w=800',
  espana: 'https://images.pexels.com/photos/138804/pexels-photo-138804.jpeg?auto=compress&cs=tinysrgb&w=800',
  internacional: 'https://images.pexels.com/photos/51054/pexels-photo-51054.jpeg?auto=compress&cs=tinysrgb&w=800',
  default: 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=800',
};

function getImage(article: Article) {
  if (article.image) return article.image;
  return FALLBACK_IMAGES[article.category_slug] || FALLBACK_IMAGES.default;
}

function getCategoryLabel(slug: string) {
  return CATEGORY_LABELS[slug] || slug;
}

function timeAgo(dateStr: string) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'ahora';
  if (mins < 60) return `${mins} min`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h`;
  return `${Math.floor(hrs / 24)}d`;
}

function SideCard({ article }: { article: Article }) {
  return (
    <div className="flex gap-3 py-3 border-b border-gray-100 last:border-0 cursor-pointer group">
      <div className="w-[90px] h-[62px] flex-shrink-0 overflow-hidden rounded">
        <img src={getImage(article)} alt={article.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-[10px] font-bold uppercase tracking-wide text-[#E85D04] mb-0.5">
          {getCategoryLabel(article.category_slug)}
        </p>
        <h4 className="text-sm font-semibold text-gray-900 leading-snug line-clamp-3 group-hover:text-[#E85D04] transition-colors">
          {article.title}
        </h4>
      </div>
    </div>
  );
}

function HeroCard({ article }: { article: Article }) {
  return (
    <div className="relative h-full min-h-[340px] cursor-pointer group overflow-hidden">
      <img src={getImage(article)} alt={article.title} className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />
      {article.is_breaking && (
        <div className="absolute top-3 left-3 flex items-center gap-1 bg-[#E85D04] text-white text-[10px] font-bold uppercase px-2 py-0.5 rounded-sm">
          <Flame className="w-2.5 h-2.5" /> Última hora
        </div>
      )}
      <div className="absolute bottom-0 left-0 right-0 p-4">
        <p className="text-[10px] font-bold uppercase tracking-wide text-[#E85D04] mb-1">
          {getCategoryLabel(article.category_slug)}
        </p>
        <h2 className="text-white font-bold text-xl leading-tight mb-1 group-hover:text-orange-200 transition-colors">
          {article.title}
        </h2>
        {article.subtitle && (
          <p className="text-gray-300 text-xs line-clamp-2">{article.subtitle}</p>
        )}
        <p className="text-gray-400 text-xs mt-1">{timeAgo(article.published_at)}</p>
      </div>
    </div>
  );
}

function HalfCard({ article, reverse = false }: { article: Article; reverse?: boolean }) {
  return (
    <div className={`flex ${reverse ? 'flex-row-reverse' : 'flex-row'} gap-0 cursor-pointer group overflow-hidden`}>
      <div className="w-2/5 h-[200px] flex-shrink-0 overflow-hidden">
        <img src={getImage(article)} alt={article.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
      </div>
      <div className={`flex-1 p-4 flex flex-col justify-center ${reverse ? 'pr-4' : 'pl-4'}`}>
        <p className="text-[10px] font-bold uppercase tracking-wide text-[#E85D04] mb-1">
          {getCategoryLabel(article.category_slug)}
        </p>
        <h3 className="font-bold text-gray-900 text-base leading-tight mb-2 group-hover:text-[#E85D04] transition-colors line-clamp-4">
          {article.title}
        </h3>
        {article.subtitle && (
          <p className="text-gray-500 text-xs line-clamp-2">{article.subtitle}</p>
        )}
        <p className="text-gray-400 text-xs mt-2 flex items-center gap-1">
          <Clock className="w-3 h-3" />
          {timeAgo(article.published_at)}
        </p>
      </div>
    </div>
  );
}

function GridCard({ article }: { article: Article }) {
  return (
    <div className="cursor-pointer group">
      <div className="aspect-[4/3] overflow-hidden mb-2">
        <img src={getImage(article)} alt={article.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
      </div>
      <p className="text-[10px] font-bold uppercase tracking-wide text-[#E85D04] mb-0.5">
        {getCategoryLabel(article.category_slug)}
      </p>
      <h4 className="text-sm font-semibold text-gray-900 leading-snug line-clamp-3 group-hover:text-[#E85D04] transition-colors">
        {article.title}
      </h4>
      {article.author && (
        <p className="text-[10px] font-bold uppercase tracking-wide text-gray-500 mt-1">
          {article.author.name}
        </p>
      )}
    </div>
  );
}

function StoryCard({ article }: { article: Article }) {
  return (
    <div className="flex-shrink-0 w-36 cursor-pointer group relative overflow-hidden rounded-sm">
      <div className="absolute top-2 left-2 z-10 flex items-center gap-0.5 bg-black/50 backdrop-blur-sm px-1.5 py-0.5 rounded-sm">
        <div className="w-2.5 h-2.5 bg-[#E85D04] rounded-sm flex items-center justify-center">
          <span className="text-white text-[6px] font-black leading-none">N</span>
        </div>
        <span className="text-white text-[9px] font-bold">Noticias</span>
      </div>
      <div className="h-[190px] overflow-hidden">
        <img src={getImage(article)} alt={article.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
      </div>
      <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-2">
        <p className="text-white text-[10px] font-medium leading-tight line-clamp-3">
          {article.title}
        </p>
      </div>
    </div>
  );
}

export function NewsPortal() {
  const { user, isAdmin } = useAuth();
  const { trackVisit } = useVisits();
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(true);
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeCategory, setActiveCategory] = useState('');
  const [ticker, setTicker] = useState('');

  const fetchArticles = useCallback(async () => {
    const { data } = await supabase
      .from('articles')
      .select('id, slug, title, subtitle, summary, image, category_slug, published_at, reading_time, views, is_breaking, is_featured, is_trending, author:authors(name, avatar)')
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(50);

    if (data && data.length > 0) {
      setArticles(data as Article[]);
      const breaking = (data as Article[]).find(a => a.is_breaking);
      if (breaking) setTicker(breaking.title);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    trackVisit();
    fetchArticles();

    const interval = setInterval(fetchArticles, 60000);

    const channel = supabase
      .channel('articles-changes')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'articles' }, () => {
        fetchArticles();
      })
      .subscribe();

    return () => {
      clearInterval(interval);
      supabase.removeChannel(channel);
    };
  }, [trackVisit, fetchArticles]);

  const navCategories = ['futbol', 'tecnologia', 'economia', 'espana', 'internacional', 'ciencia', 'salud'];

  const filtered = activeCategory
    ? articles.filter(a => a.category_slug === activeCategory || a.category_slug.startsWith(activeCategory))
    : articles;

  const hero = filtered[0];
  const sideArticles = filtered.slice(1, 5);
  const leftFeatured = filtered[5];
  const rightFeatured = filtered[6];
  const gridArticles = filtered.slice(7, 11);
  const bigFeature = filtered[11];
  const storyArticles = filtered.slice(12, 18);
  const remainingArticles = filtered.slice(18, 28);

  return (
    <div className="min-h-screen bg-white font-sans">
      {ticker && (
        <div className="bg-[#E85D04] text-white text-xs font-medium overflow-hidden">
          <div className="flex items-center">
            <span className="flex-shrink-0 bg-black/30 px-3 py-1.5 font-bold uppercase tracking-wider text-[10px]">DIRECTO</span>
            <div className="overflow-hidden relative flex-1">
              <div className="whitespace-nowrap px-4 py-1.5 animate-marquee">
                {ticker}
              </div>
            </div>
          </div>
        </div>
      )}

      <header className="bg-[#111111] sticky top-0 z-50">
        <div className="max-w-[700px] mx-auto px-3">
          <div className="flex items-center justify-between h-12">
            <button
              onClick={() => setMenuOpen(!menuOpen)}
              className="text-white p-1"
              aria-label="Menú"
            >
              <Menu className="w-5 h-5" />
            </button>

            <a href="#" onClick={() => { setActiveCategory(''); setMenuOpen(false); }} className="flex items-center gap-0">
              <span className="text-[#E85D04] font-black text-xl tracking-tight leading-none">Noticias</span>
              <span className="text-white font-black text-xl tracking-tight leading-none">Pro</span>
            </a>

            <div className="flex items-center gap-2">
              {user ? (
                <>
                  {isAdmin && (
                    <a href="#admin" className="flex items-center gap-1 text-[#E85D04] text-xs font-bold">
                      <Shield className="w-4 h-4" />
                    </a>
                  )}
                  <div className="w-7 h-7 rounded-full bg-[#E85D04] flex items-center justify-center">
                    <User className="w-4 h-4 text-white" />
                  </div>
                </>
              ) : (
                <a href="#login" className="flex items-center gap-1">
                  <div className="w-7 h-7 rounded-full bg-gray-600 flex items-center justify-center">
                    <User className="w-4 h-4 text-white" />
                  </div>
                </a>
              )}
              <button className="text-white p-1" aria-label="Buscar">
                <Search className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>

        <div className="border-t border-white/10 overflow-x-auto scrollbar-hide">
          <div className="flex items-center gap-0 px-3 max-w-[700px] mx-auto">
            <button
              onClick={() => setActiveCategory('')}
              className={`flex-shrink-0 px-3 py-2 text-xs font-bold uppercase tracking-wide transition-colors ${activeCategory === '' ? 'text-[#E85D04] border-b-2 border-[#E85D04]' : 'text-gray-400 hover:text-white'}`}
            >
              Todo
            </button>
            {navCategories.map(cat => (
              <button
                key={cat}
                onClick={() => setActiveCategory(activeCategory === cat ? '' : cat)}
                className={`flex-shrink-0 px-3 py-2 text-xs font-bold uppercase tracking-wide transition-colors ${activeCategory === cat ? 'text-[#E85D04] border-b-2 border-[#E85D04]' : 'text-gray-400 hover:text-white'}`}
              >
                {getCategoryLabel(cat)}
              </button>
            ))}
          </div>
        </div>

        {menuOpen && (
          <div className="absolute top-full left-0 right-0 bg-[#111111] border-t border-white/10 z-50 pb-4">
            <div className="max-w-[700px] mx-auto px-3 py-2 grid grid-cols-2 gap-1">
              {Object.entries(CATEGORY_LABELS).map(([slug, label]) => (
                <button
                  key={slug}
                  onClick={() => { setActiveCategory(slug); setMenuOpen(false); }}
                  className="text-left px-3 py-2 text-sm text-gray-300 hover:text-[#E85D04] hover:bg-white/5 rounded transition-colors"
                >
                  {label}
                </button>
              ))}
            </div>
          </div>
        )}
      </header>

      <main className="max-w-[700px] mx-auto">
        {loading ? (
          <div className="flex flex-col gap-4 p-4">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="animate-pulse">
                <div className="h-40 bg-gray-200 rounded mb-2" />
                <div className="h-4 bg-gray-200 rounded w-3/4 mb-1" />
                <div className="h-3 bg-gray-100 rounded w-1/2" />
              </div>
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-24 text-center text-gray-400">
            <Radio className="w-12 h-12 mx-auto mb-3 opacity-30" />
            <p className="font-medium">No hay artículos disponibles</p>
            <p className="text-sm">Las noticias se actualizan automáticamente</p>
          </div>
        ) : (
          <>
            {hero && (
              <section className="border-b border-gray-100">
                <div className="flex flex-col sm:flex-row">
                  <div className="sm:w-[40%] px-3 py-2 border-b sm:border-b-0 sm:border-r border-gray-100">
                    {sideArticles.map(a => (
                      <SideCard key={a.id} article={a} />
                    ))}
                  </div>
                  <div className="sm:w-[60%]">
                    <HeroCard article={hero} />
                  </div>
                </div>
              </section>
            )}

            {(leftFeatured || rightFeatured) && (
              <section className="border-b border-gray-100">
                {leftFeatured && (
                  <div className="border-b border-gray-100">
                    <HalfCard article={leftFeatured} />
                  </div>
                )}
                {rightFeatured && (
                  <HalfCard article={rightFeatured} reverse />
                )}
              </section>
            )}

            {gridArticles.length > 0 && (
              <section className="px-3 py-4 border-b border-gray-100">
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                  {gridArticles.map(a => (
                    <GridCard key={a.id} article={a} />
                  ))}
                </div>
              </section>
            )}

            {bigFeature && (
              <section className="border-b border-gray-100 cursor-pointer group">
                <div className="flex flex-col sm:flex-row">
                  <div className="sm:w-[45%] h-[220px] sm:h-auto overflow-hidden">
                    <img src={getImage(bigFeature)} alt={bigFeature.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
                  </div>
                  <div className="sm:w-[55%] p-4 flex flex-col justify-center">
                    <p className="text-[10px] font-bold uppercase tracking-wide text-[#E85D04] mb-2">
                      {getCategoryLabel(bigFeature.category_slug)}
                    </p>
                    <h2 className="font-bold text-gray-900 text-lg leading-tight mb-2 group-hover:text-[#E85D04] transition-colors">
                      {bigFeature.title}
                    </h2>
                    {bigFeature.subtitle && (
                      <p className="text-gray-500 text-sm mb-2 line-clamp-3">
                        — {bigFeature.subtitle}
                      </p>
                    )}
                    {bigFeature.author && (
                      <p className="text-[10px] font-bold uppercase tracking-widest text-gray-400">
                        {bigFeature.author.name}
                      </p>
                    )}
                  </div>
                </div>
              </section>
            )}

            {storyArticles.length > 0 && (
              <section className="py-4 border-b border-gray-100">
                <div className="px-3 flex items-center justify-between mb-3">
                  <h3 className="text-xs font-bold uppercase tracking-widest text-gray-700">
                    Destacados
                  </h3>
                  <ChevronRight className="w-4 h-4 text-gray-400" />
                </div>
                <div className="flex gap-2 px-3 overflow-x-auto scrollbar-hide pb-1">
                  {storyArticles.map(a => (
                    <StoryCard key={a.id} article={a} />
                  ))}
                </div>
              </section>
            )}

            {remainingArticles.length > 0 && (
              <section className="px-3 py-2">
                <div className="flex items-center justify-between py-3 border-b border-gray-200 mb-2">
                  <h3 className="text-xs font-bold uppercase tracking-widest text-gray-700">
                    Más noticias
                  </h3>
                  <div className="flex items-center gap-1 text-[10px] text-gray-400">
                    <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
                    En directo
                  </div>
                </div>
                <div className="divide-y divide-gray-100">
                  {remainingArticles.map(a => (
                    <SideCard key={a.id} article={a} />
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </main>

      <footer className="bg-[#111111] text-white mt-8 py-6 px-4">
        <div className="max-w-[700px] mx-auto">
          <div className="flex items-center gap-1 mb-4">
            <span className="text-[#E85D04] font-black text-lg">Noticias</span>
            <span className="font-black text-lg">Pro</span>
          </div>
          <div className="flex flex-wrap gap-4 text-xs text-gray-500 mb-4">
            {navCategories.map(c => (
              <button key={c} onClick={() => setActiveCategory(c)} className="hover:text-[#E85D04] transition-colors uppercase tracking-wide font-medium">
                {getCategoryLabel(c)}
              </button>
            ))}
          </div>
          <p className="text-[11px] text-gray-600">© 2026 NoticiasPro. Noticias en tiempo real.</p>
        </div>
      </footer>
    </div>
  );
}
