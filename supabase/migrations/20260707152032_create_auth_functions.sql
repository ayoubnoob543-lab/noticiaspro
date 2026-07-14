/*
# Create Auth Visit Stats Functions

1. Functions
- `get_connected_users_count()`: Returns count of users active in last 5 minutes
- Daily stats trigger to update stats automatically

2. Important Notes
- Admin can see real-time connected users
- Automatic stats aggregation
*/

-- Function to get connected users (users who visited in last 5 minutes)
CREATE OR REPLACE FUNCTION get_connected_users_count()
RETURNS integer AS $$
BEGIN
  RETURN (
    SELECT COUNT(DISTINCT user_id)::integer
    FROM visits
    WHERE visited_at > NOW() - INTERVAL '5 minutes'
    AND user_id IS NOT NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get today's connected users count
CREATE OR REPLACE FUNCTION get_today_stats()
RETURNS TABLE (
  total_visits integer,
  unique_visitors bigint,
  authenticated_visits integer,
  anonymous_visits integer,
  connected_users integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE((SELECT total_visits FROM daily_visit_stats WHERE date = CURRENT_DATE), 0)::integer,
    COALESCE((SELECT COUNT(DISTINCT user_id) FROM visits WHERE visited_at::date = CURRENT_DATE), 0),
    COALESCE((SELECT authenticated_visits FROM daily_visit_stats WHERE date = CURRENT_DATE), 0)::integer,
    COALESCE((SELECT anonymous_visits FROM daily_visit_stats WHERE date = CURRENT_DATE), 0)::integer,
    get_connected_users_count();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_connected_users_count() TO authenticated;
GRANT EXECUTE ON FUNCTION get_today_stats() TO authenticated;
