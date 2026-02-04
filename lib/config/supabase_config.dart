/// Supabase configuration
/// Replace these values with your actual Supabase project credentials
/// Get them from: https://app.supabase.com/project/_/settings/api

class SupabaseConfig {
  // Supabase project URL
  static const String supabaseUrl = 'https://eokygkeydtegeqzcktiv.supabase.co';
  
  // Supabase anon/public key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVva3lna2V5ZHRlZ2VxemNrdGl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NTQxNzAsImV4cCI6MjA3OTAzMDE3MH0.uLJqWosRvnqDycd0_YnoTj6jJRtOi8zxzAj-CyMeO8A';

  /// Check if Supabase is configured
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
}

/// SQL Schema for Supabase Tables
/// Run these SQL commands in your Supabase SQL Editor to create the required tables

const String supabaseSchema = '''
-- User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT,
  email TEXT,
  age INTEGER,
  gender TEXT,
  height REAL,
  weight REAL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Analytics Events Table
CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Data Table
CREATE TABLE IF NOT EXISTS workout_data (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  workout_type TEXT NOT NULL,
  duration INTEGER NOT NULL,
  calories_burned INTEGER,
  intensity TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hydration Data Table
CREATE TABLE IF NOT EXISTS hydration_data (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  amount_ml INTEGER NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Health Metrics Table
CREATE TABLE IF NOT EXISTS health_metrics (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  weight REAL,
  height REAL,
  bmi REAL,
  heart_rate INTEGER,
  blood_pressure TEXT,
  sleep_hours REAL,
  steps INTEGER,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mood Data Table
CREATE TABLE IF NOT EXISTS mood_data (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  mood_type TEXT NOT NULL,
  mood_score INTEGER NOT NULL,
  notes TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Food Log Data Table
CREATE TABLE IF NOT EXISTS food_log_data (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  meal_type TEXT NOT NULL,
  food_name TEXT NOT NULL,
  calories INTEGER,
  protein REAL,
  carbs REAL,
  fats REAL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_timestamp ON analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_workout_user_id ON workout_data(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_date ON workout_data(date);
CREATE INDEX IF NOT EXISTS idx_hydration_user_id ON hydration_data(user_id);
CREATE INDEX IF NOT EXISTS idx_health_metrics_user_id ON health_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_user_id ON mood_data(user_id);
CREATE INDEX IF NOT EXISTS idx_food_log_user_id ON food_log_data(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE hydration_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE mood_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_log_data ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies (Users can only access their own data)
CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own analytics" ON analytics_events FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own analytics" ON analytics_events FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own workouts" ON workout_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own workouts" ON workout_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own workouts" ON workout_data FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own hydration" ON hydration_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own hydration" ON hydration_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own hydration" ON hydration_data FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own health metrics" ON health_metrics FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own health metrics" ON health_metrics FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own health metrics" ON health_metrics FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own mood data" ON mood_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own mood data" ON mood_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own mood data" ON mood_data FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own food logs" ON food_log_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own food logs" ON food_log_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own food logs" ON food_log_data FOR UPDATE USING (auth.uid() = user_id);
''';
