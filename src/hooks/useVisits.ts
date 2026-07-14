import { useState, useEffect, useCallback } from 'react';
import { supabase, Visit, DailyStats } from '../lib/supabase';
import { useAuth } from './useAuth';

export function useVisits() {
  const { isAdmin, user } = useAuth();
  const [visits, setVisits] = useState<Visit[]>([]);
  const [dailyStats, setDailyStats] = useState<DailyStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalStats, setTotalStats] = useState({
    total: 0,
    today: 0,
    thisWeek: 0,
    thisMonth: 0,
  });

  const fetchVisits = useCallback(async () => {
    if (!isAdmin) {
      setLoading(false);
      return;
    }

    setLoading(true);

    const [visitsResult, statsResult] = await Promise.all([
      supabase
        .from('visits')
        .select('*')
        .order('visited_at', { ascending: false })
        .limit(100),
      supabase
        .from('daily_stats')
        .select('*')
        .order('date', { ascending: false })
        .limit(30),
    ]);

    if (visitsResult.data) {
      setVisits(visitsResult.data);
    }

    if (statsResult.data) {
      setDailyStats(statsResult.data);

      const now = new Date();
      const today = now.toISOString().split('T')[0];
      const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
      const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

      const total = statsResult.data.reduce((sum, s) => sum + s.total_visits, 0);
      const todayCount = statsResult.data.find(s => s.date === today)?.total_visits || 0;
      const thisWeek = statsResult.data
        .filter(s => s.date >= weekAgo)
        .reduce((sum, s) => sum + s.total_visits, 0);
      const thisMonth = statsResult.data
        .filter(s => s.date >= monthAgo)
        .reduce((sum, s) => sum + s.total_visits, 0);

      setTotalStats({ total, today: todayCount, thisWeek, thisMonth });
    }

    setLoading(false);
  }, [isAdmin]);

  const trackVisit = useCallback(async () => {
    const visitData: Omit<Visit, 'id' | 'visited_at'> = {
      user_id: user?.id || null,
      page_url: window.location.href,
      page_title: document.title,
      referrer: document.referrer || null,
      user_agent: navigator.userAgent,
      ip_address: null,
      country: null,
      city: null,
    };

    await supabase.from('visits').insert(visitData);

    const today = new Date().toISOString().split('T')[0];

    const { data: existingStats } = await supabase
      .from('daily_stats')
      .select('*')
      .eq('date', today)
      .maybeSingle();

    if (existingStats) {
      await supabase
        .from('daily_stats')
        .update({
          total_visits: existingStats.total_visits + 1,
          authenticated_visits: user ? existingStats.authenticated_visits + 1 : existingStats.authenticated_visits,
          anonymous_visits: !user ? existingStats.anonymous_visits + 1 : existingStats.anonymous_visits,
        })
        .eq('id', existingStats.id);
    } else {
      await supabase.from('daily_stats').insert({
        date: today,
        total_visits: 1,
        unique_visitors: 1,
        authenticated_visits: user ? 1 : 0,
        anonymous_visits: !user ? 1 : 0,
      });
    }
  }, [user]);

  useEffect(() => {
    if (isAdmin) {
      fetchVisits();
    }
  }, [isAdmin, fetchVisits]);

  return {
    visits,
    dailyStats,
    totalStats,
    loading,
    trackVisit,
    refetch: fetchVisits,
  };
}
