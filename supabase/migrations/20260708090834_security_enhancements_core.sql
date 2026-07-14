/*
# Security Enhancements and Rate Limiting - Core Tables Only

1. Security Functions
- `is_admin()`: Helper function to check if user is admin
- `check_rate_limit()`: Basic rate limiting for login attempts
- Safe increment functions for daily stats

2. RLS Policy Improvements
- Ensure proper RLS on existing tables
- Add admin check helper

3. Cleanup
- Remove duplicate daily_stats table
*/

-- Cleanup: Drop duplicate table
DROP TABLE IF EXISTS daily_stats;

-- Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Safe increment function for daily stats (anonymous)
CREATE OR REPLACE FUNCTION safe_increment_daily_stats(
  p_date date DEFAULT CURRENT_DATE
)
RETURNS void AS $$
BEGIN
  INSERT INTO daily_visit_stats (date, total_visits, unique_visitors, authenticated_visits, anonymous_visits)
  VALUES (p_date, 1, 1, 0, 1)
  ON CONFLICT (date) DO UPDATE SET
    total_visits = daily_visit_stats.total_visits + 1,
    anonymous_visits = daily_visit_stats.anonymous_visits + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Safe increment for authenticated visits
CREATE OR REPLACE FUNCTION safe_increment_authenticated_visit(
  p_date date DEFAULT CURRENT_DATE
)
RETURNS void AS $$
BEGIN
  INSERT INTO daily_visit_stats (date, total_visits, unique_visitors, authenticated_visits, anonymous_visits)
  VALUES (p_date, 1, 1, 1, 0)
  ON CONFLICT (date) DO UPDATE SET
    total_visits = daily_visit_stats.total_visits + 1,
    authenticated_visits = daily_visit_stats.authenticated_visits + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add rate limiting table for login attempts
CREATE TABLE IF NOT EXISTS login_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  ip_address text,
  success boolean DEFAULT false,
  attempted_at timestamptz DEFAULT now()
);

-- Create index for rate limiting lookups
CREATE INDEX IF NOT EXISTS idx_login_attempts_email_time ON login_attempts(email, attempted_at DESC);

-- RLS for login_attempts
ALTER TABLE login_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin_read_login_attempts" ON login_attempts;
CREATE POLICY "admin_read_login_attempts" ON login_attempts FOR SELECT
  TO authenticated
  USING (is_admin());

-- Function to check rate limit (max 5 attempts per 15 minutes per email)
CREATE OR REPLACE FUNCTION check_rate_limit(p_email text)
RETURNS boolean AS $$
DECLARE
  attempt_count integer;
BEGIN
  SELECT COUNT(*) INTO attempt_count
  FROM login_attempts
  WHERE email = p_email
  AND attempted_at > NOW() - INTERVAL '15 minutes'
  AND success = false;
  
  RETURN attempt_count < 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to log login attempt
CREATE OR REPLACE FUNCTION log_login_attempt(
  p_email text,
  p_ip_address text DEFAULT null,
  p_success boolean DEFAULT false
)
RETURNS void AS $$
BEGIN
  INSERT INTO login_attempts (email, ip_address, success)
  VALUES (p_email, p_ip_address, p_success);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure profiles has proper admin check policy
DROP POLICY IF EXISTS "admin_update_profiles" ON profiles;
CREATE POLICY "admin_update_profiles" ON profiles FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Grant execute on public functions
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION check_rate_limit(text) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION log_login_attempt(text, text, boolean) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION safe_increment_daily_stats(date) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION safe_increment_authenticated_visit(date) TO authenticated, anon;

-- Update existing admin profile
UPDATE profiles SET is_admin = true WHERE email = 'ayoubnoob543@gmail.com';
