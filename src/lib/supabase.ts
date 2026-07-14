import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Profile = {
  id: string;
  email: string;
  is_admin: boolean;
  created_at: string;
};

export type Visit = {
  id: string;
  user_id: string | null;
  page_url: string;
  page_title: string | null;
  referrer: string | null;
  user_agent: string | null;
  ip_address: string | null;
  country: string | null;
  city: string | null;
  visited_at: string;
};

export type DailyStats = {
  id: string;
  date: string;
  total_visits: number;
  unique_visitors: number;
  authenticated_visits: number;
  anonymous_visits: number;
};

export type Article = {
  id: string;
  slug: string;
  title: string;
  subtitle: string | null;
  summary: string | null;
  image: string | null;
  category_slug: string;
  published_at: string;
  reading_time: number;
  views: number;
  is_breaking: boolean;
  is_featured: boolean;
  is_trending: boolean;
  author?: { name: string; avatar: string | null } | null;
};
