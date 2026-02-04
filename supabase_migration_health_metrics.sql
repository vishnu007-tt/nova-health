-- Migration: Add Period and Symptom Tracking to Health Metrics Table
-- Run this on your existing Supabase database to add the new columns

-- Add period tracking columns
ALTER TABLE health_metrics 
  ADD COLUMN IF NOT EXISTS mood TEXT,
  ADD COLUMN IF NOT EXISTS stress_level INTEGER,
  ADD COLUMN IF NOT EXISTS energy_level INTEGER,
  ADD COLUMN IF NOT EXISTS notes TEXT,
  ADD COLUMN IF NOT EXISTS is_period_day INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS flow_intensity TEXT,
  ADD COLUMN IF NOT EXISTS period_symptoms TEXT,
  ADD COLUMN IF NOT EXISTS cycle_day INTEGER;

-- Add symptom tracking columns
ALTER TABLE health_metrics 
  ADD COLUMN IF NOT EXISTS symptoms TEXT,
  ADD COLUMN IF NOT EXISTS symptom_severity TEXT,
  ADD COLUMN IF NOT EXISTS symptom_body_parts TEXT,
  ADD COLUMN IF NOT EXISTS symptom_triggers TEXT;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_health_metrics_period ON health_metrics(user_id, is_period_day) WHERE is_period_day = 1;
CREATE INDEX IF NOT EXISTS idx_health_metrics_symptoms ON health_metrics(user_id) WHERE symptoms IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_health_metrics_date ON health_metrics(user_id, date);

-- Add comments for documentation
COMMENT ON COLUMN health_metrics.mood IS 'User mood (happy, sad, anxious, calm, stressed, etc.)';
COMMENT ON COLUMN health_metrics.stress_level IS 'Stress level from 1-10';
COMMENT ON COLUMN health_metrics.energy_level IS 'Energy level from 1-10';
COMMENT ON COLUMN health_metrics.notes IS 'General notes for the day';
COMMENT ON COLUMN health_metrics.is_period_day IS 'Boolean flag (0 or 1) indicating if this is a period day';
COMMENT ON COLUMN health_metrics.flow_intensity IS 'Period flow intensity (light, medium, heavy)';
COMMENT ON COLUMN health_metrics.period_symptoms IS 'Comma-separated list of period symptoms';
COMMENT ON COLUMN health_metrics.cycle_day IS 'Day number in the menstrual cycle';
COMMENT ON COLUMN health_metrics.symptoms IS 'Comma-separated list of general symptoms';
COMMENT ON COLUMN health_metrics.symptom_severity IS 'JSON map of symptom to severity (1-10)';
COMMENT ON COLUMN health_metrics.symptom_body_parts IS 'JSON map of symptom to affected body part';
COMMENT ON COLUMN health_metrics.symptom_triggers IS 'Comma-separated list of possible symptom triggers';
