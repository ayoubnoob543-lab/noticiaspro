import { useEffect, useState } from 'react';
import { AuthProvider, useAuth } from './hooks/useAuth';
import { AuthForm } from './components/Auth';
import { AdminPanel } from './components/AdminPanel';
import { NewsPortal } from './components/NewsPortal';
import { Loader2 } from 'lucide-react';

function AppContent() {
  const { user, loading, isAdmin } = useAuth();
  const [currentPage, setCurrentPage] = useState<'home' | 'login' | 'admin'>('home');

  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.slice(1);
      if (hash === 'login' && !user) {
        setCurrentPage('login');
      } else if (hash === 'admin' && user && isAdmin) {
        setCurrentPage('admin');
      } else {
        setCurrentPage('home');
        window.location.hash = '';
      }
    };

    handleHashChange();
    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, [user, isAdmin]);

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-900 flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-white animate-spin" />
      </div>
    );
  }

  if (currentPage === 'login' && !user) {
    return (
      <AuthForm
        onSuccess={() => {
          setCurrentPage('home');
          window.location.hash = '';
        }}
      />
    );
  }

  if (currentPage === 'admin' && user && isAdmin) {
    return <AdminPanel />;
  }

  return <NewsPortal />;
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
