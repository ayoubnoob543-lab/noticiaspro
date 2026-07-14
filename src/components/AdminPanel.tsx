import { useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useVisits } from '../hooks/useVisits';
import {
  Users,
  Eye,
  TrendingUp,
  Calendar,
  Globe,
  Monitor,
  Clock,
  RefreshCw,
  LogOut,
  BarChart3,
} from 'lucide-react';

export function AdminPanel() {
  const { profile, signOut, isAdmin } = useAuth();
  const { visits, dailyStats, totalStats, loading, refetch } = useVisits();

  useEffect(() => {
    refetch();
  }, [refetch]);

  if (!isAdmin) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center p-4">
        <div className="text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-red-500/20 rounded-full mb-4">
            <Monitor className="w-8 h-8 text-red-400" />
          </div>
          <h2 className="text-2xl font-bold text-white mb-2">Acceso Denegado</h2>
          <p className="text-slate-400">
            No tienes permisos para acceder a este panel.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <header className="border-b border-slate-700/50 bg-slate-900/50 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/25">
                <BarChart3 className="w-5 h-5 text-white" />
              </div>
              <div>
                <h1 className="text-xl font-bold text-white">
                  NoticiasPro Admin
                </h1>
                <p className="text-xs text-slate-400">
                  Panel de Administración
                </p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-medium text-white">
                  {profile?.email}
                </p>
                <p className="text-xs text-slate-400">Administrador</p>
              </div>
              <button
                onClick={signOut}
                className="flex items-center gap-2 px-4 py-2 bg-slate-700/50 hover:bg-red-500/20 border border-slate-600 hover:border-red-500/50 rounded-xl text-slate-300 hover:text-red-400 transition-all"
              >
                <LogOut className="w-4 h-4" />
                <span className="hidden sm:inline">Cerrar Sesión</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <StatCard
            title="Visitas Totales"
            value={totalStats.total.toLocaleString()}
            icon={<Eye className="w-6 h-6" />}
            color="from-blue-500 to-cyan-500"
          />
          <StatCard
            title="Hoy"
            value={totalStats.today.toLocaleString()}
            icon={<Calendar className="w-6 h-6" />}
            color="from-emerald-500 to-teal-500"
          />
          <StatCard
            title="Esta Semana"
            value={totalStats.thisWeek.toLocaleString()}
            icon={<TrendingUp className="w-6 h-6" />}
            color="from-orange-500 to-amber-500"
          />
          <StatCard
            title="Este Mes"
            value={totalStats.thisMonth.toLocaleString()}
            icon={<Users className="w-6 h-6" />}
            color="from-rose-500 to-pink-500"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <div className="bg-slate-800/50 backdrop-blur-xl border border-slate-700/50 rounded-2xl overflow-hidden">
              <div className="px-6 py-4 border-b border-slate-700/50 flex items-center justify-between">
                <h2 className="text-lg font-semibold text-white">
                  Visitas Recientes
                </h2>
                <button
                  onClick={refetch}
                  disabled={loading}
                  className="p-2 hover:bg-slate-700 rounded-lg transition-colors"
                >
                  <RefreshCw
                    className={`w-5 h-5 text-slate-400 ${loading ? 'animate-spin' : ''}`}
                  />
                </button>
              </div>

              <div className="divide-y divide-slate-700/50 max-h-96 overflow-y-auto">
                {visits.length === 0 ? (
                  <div className="p-8 text-center">
                    <Monitor className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                    <p className="text-slate-400">No hay visitas registradas</p>
                  </div>
                ) : (
                  visits.map((visit) => (
                    <div
                      key={visit.id}
                      className="px-6 py-4 hover:bg-slate-700/30 transition-colors"
                    >
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex-1 min-w-0">
                          <p className="text-white font-medium truncate">
                            {visit.page_title || 'Página sin título'}
                          </p>
                          <p className="text-sm text-slate-400 truncate">
                            {visit.page_url}
                          </p>
                          <div className="flex flex-wrap items-center gap-3 mt-2 text-xs text-slate-500">
                            <span className="flex items-center gap-1">
                              <Clock className="w-3 h-3" />
                              {new Date(visit.visited_at).toLocaleString()}
                            </span>
                            {visit.country && (
                              <span className="flex items-center gap-1">
                                <Globe className="w-3 h-3" />
                                {visit.city ? `${visit.city}, ` : ''}
                                {visit.country}
                              </span>
                            )}
                            {visit.user_id ? (
                              <span className="px-2 py-0.5 bg-emerald-500/20 text-emerald-400 rounded-full">
                                Autenticado
                              </span>
                            ) : (
                              <span className="px-2 py-0.5 bg-slate-600/50 text-slate-400 rounded-full">
                                Anónimo
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>

          <div className="lg:col-span-1">
            <div className="bg-slate-800/50 backdrop-blur-xl border border-slate-700/50 rounded-2xl overflow-hidden">
              <div className="px-6 py-4 border-b border-slate-700/50">
                <h2 className="text-lg font-semibold text-white">
                  Estadísticas Diarias
                </h2>
              </div>

              <div className="p-6 max-h-96 overflow-y-auto">
                {dailyStats.length === 0 ? (
                  <div className="text-center py-8">
                    <Calendar className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                    <p className="text-slate-400">Sin datos disponibles</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {dailyStats.map((stat) => (
                      <div
                        key={stat.id}
                        className="p-4 bg-slate-700/30 rounded-xl"
                      >
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-sm font-medium text-white">
                            {new Date(stat.date).toLocaleDateString('es-ES', {
                              weekday: 'short',
                              day: 'numeric',
                              month: 'short',
                            })}
                          </span>
                          <span className="text-lg font-bold text-blue-400">
                            {stat.total_visits}
                          </span>
                        </div>
                        <div className="flex gap-2">
                          <div className="flex-1 h-2 bg-slate-600 rounded-full overflow-hidden">
                            <div
                              className="h-full bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full"
                              style={{
                                width: `${
                                  stat.total_visits > 0
                                    ? (stat.authenticated_visits / stat.total_visits) * 100
                                    : 0
                                }%`,
                              }}
                            />
                          </div>
                        </div>
                        <div className="flex justify-between mt-2 text-xs text-slate-500">
                          <span>
                            <span className="text-emerald-400">
                              {stat.authenticated_visits}
                            </span>{' '}
                            auth
                          </span>
                          <span>
                            <span className="text-slate-400">
                              {stat.anonymous_visits}
                            </span>{' '}
                            anónimo
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

function StatCard({
  title,
  value,
  icon,
  color,
}: {
  title: string;
  value: string;
  icon: React.ReactNode;
  color: string;
}) {
  return (
    <div className="bg-slate-800/50 backdrop-blur-xl border border-slate-700/50 rounded-2xl p-6">
      <div className="flex items-center justify-between mb-4">
        <div
          className={`w-12 h-12 bg-gradient-to-br ${color} rounded-xl flex items-center justify-center shadow-lg`}
        >
          {icon}
        </div>
      </div>
      <p className="text-sm text-slate-400 mb-1">{title}</p>
      <p className="text-2xl font-bold text-white">{value}</p>
    </div>
  );
}
