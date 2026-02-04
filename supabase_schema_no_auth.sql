-- NovaHealth Supabase Database Schema (No Authentication Required)
-- This version completely removes all authentication requirements

-- Drop existing tables
DROP TABLE IF EXISTS food_log_data CASCADE;
DROP TABLE IF EXISTS mood_data CASCADE;
DROP TABLE IF EXISTS health_metrics CASCADE;
DROP TABLE IF EXISTS hydration_data CASCADE;
DROP TABLE IF EXISTS workout_data CASCADE;
DROP TABLE IF EXISTS analytics_events CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;

-- User Profiles Table
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL UNIQUE,
  name TEXT,
  email TEXT,
  age INTEGER,
  gender TEXT,
  height REAL,
  weight REAL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics Events Table
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workout Data Table
CREATE TABLE workout_data (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workout_type TEXT NOT NULL,
  duration INTEGER NOT NULL,
  calories_burned INTEGER,
  intensity TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hydration Data Table
CREATE TABLE hydration_data (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount_ml INTEGER NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Health Metrics Table (merged with period and symptom tracking)
CREATE TABLE health_metrics (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  weight REAL,
  height REAL,
  bmi REAL,
  heart_rate INTEGER,
  blood_pressure TEXT,
  sleep_hours REAL,
  steps INTEGER,
  mood TEXT,
  stress_level INTEGER,
  energy_level INTEGER,
  notes TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_period_day INTEGER DEFAULT 0,
  flow_intensity TEXT,
  period_symptoms TEXT,
  cycle_day INTEGER,
  symptoms TEXT,
  symptom_severity TEXT,
  symptom_body_parts TEXT,
  symptom_triggers TEXT,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mood Data Table
CREATE TABLE mood_data (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  mood_type TEXT NOT NULL,
  mood_score INTEGER NOT NULL,
  notes TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Food Log Data Table
CREATE TABLE food_log_data (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  meal_type TEXT NOT NULL,
  food_name TEXT NOT NULL,
  calories INTEGER,
  protein REAL,
  carbs REAL,
  fats REAL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
  synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX idx_workout_user_id ON workout_data(user_id);
CREATE INDEX idx_hydration_user_id ON hydration_data(user_id);
CREATE INDEX idx_health_metrics_user_id ON health_metrics(user_id);
CREATE INDEX idx_mood_user_id ON mood_data(user_id);
CREATE INDEX idx_food_log_user_id ON food_log_data(user_id);

-- DISABLE Row Level Security on ALL tables
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE workout_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE hydration_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE health_metrics DISABLE ROW LEVEL SECURITY;
ALTER TABLE mood_data DISABLE ROW LEVEL SECURITY;
ALTER TABLE food_log_data DISABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own analytics" ON analytics_events;
DROP POLICY IF EXISTS "Users can insert own analytics" ON analytics_events;
DROP POLICY IF EXISTS "Users can view own workouts" ON workout_data;
DROP POLICY IF EXISTS "Users can insert own workouts" ON workout_data;
DROP POLICY IF EXISTS "Users can update own workouts" ON workout_data;
DROP POLICY IF EXISTS "Users can view own hydration" ON hydration_data;
DROP POLICY IF EXISTS "Users can insert own hydration" ON hydration_data;
DROP POLICY IF EXISTS "Users can update own hydration" ON hydration_data;
DROP POLICY IF EXISTS "Users can view own health metrics" ON health_metrics;
DROP POLICY IF EXISTS "Users can insert own health metrics" ON health_metrics;
DROP POLICY IF EXISTS "Users can update own health metrics" ON health_metrics;
DROP POLICY IF EXISTS "Users can view own mood data" ON mood_data;
DROP POLICY IF EXISTS "Users can insert own mood data" ON mood_data;
DROP POLICY IF EXISTS "Users can update own mood data" ON mood_data;
DROP POLICY IF EXISTS "Users can view own food logs" ON food_log_data;
DROP POLICY IF EXISTS "Users can insert own food logs" ON food_log_data;
DROP POLICY IF EXISTS "Users can update own food logs" ON food_log_data;

-- Grant full access to anon role (your app's API key)
GRANT ALL ON user_profiles TO anon;
GRANT ALL ON analytics_events TO anon;
GRANT ALL ON workout_data TO anon;
GRANT ALL ON hydration_data TO anon;
GRANT ALL ON health_metrics TO anon;
GRANT ALL ON mood_data TO anon;
GRANT ALL ON food_log_data TO anon;

-- Grant usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;
