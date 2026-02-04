"""
Advanced Feature Engineering Pipeline for Obesity & Exercise Datasets
======================================================================
Goal: Improve model performance through intelligent feature creation

Targets:
- Obesity: 80.14% → 88-92% accuracy
- Exercise: Poor → 60-70%+ accuracy or MAE < ±40 calories

Author: NovaHealth ML Team
"""

import pandas as pd
import numpy as np
import json
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import (accuracy_score, precision_score, recall_score, f1_score,
                            confusion_matrix, classification_report, r2_score,
                            mean_absolute_error, mean_squared_error)
from imblearn.over_sampling import SMOTE
import matplotlib.pyplot as plt
import seaborn as sns
from pytorch_tabnet.tab_model import TabNetClassifier, TabNetRegressor

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

OUTPUT_DIR = Path('/Users/gitanjanganai/Downloads/NovaHealth/enriched_models')
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
(OUTPUT_DIR / 'confusion_matrices').mkdir(exist_ok=True)

print("=" * 80)
print("ADVANCED FEATURE ENGINEERING PIPELINE")
print("=" * 80)


class ObesityFeatureEngineer:
    """Feature engineering for Obesity dataset"""
    
    def __init__(self):
        self.feature_map = []
    
    def engineer_features(self, df):
        """Apply all obesity-specific feature engineering"""
        print("\n" + "=" * 80)
        print("OBESITY FEATURE ENGINEERING")
        print("=" * 80)
        
        df = df.copy()
        original_features = len(df.columns)
        
        # 1. BMI calculation (if not present)
        if 'BMI' not in df.columns and 'Height' in df.columns and 'Weight' in df.columns:
            df['BMI'] = df['Weight'] / (df['Height'] ** 2)
            self.feature_map.append("BMI = Weight / Height²")
        
        # 2. BMR (Basal Metabolic Rate) - Mifflin-St Jeor Equation
        if 'Age' in df.columns and 'Weight' in df.columns and 'Height' in df.columns and 'Gender' in df.columns:
            # Convert height to cm if needed (assume meters if < 3)
            height_cm = df['Height'].apply(lambda x: x * 100 if x < 3 else x)
            weight_kg = df['Weight'] if df['Weight'].mean() < 200 else df['Weight'] / 2.205
            
            # BMR for males: 10 × weight(kg) + 6.25 × height(cm) − 5 × age(y) + 5
            # BMR for females: 10 × weight(kg) + 6.25 × height(cm) − 5 × age(y) − 161
            df['BMR'] = 10 * weight_kg + 6.25 * height_cm - 5 * df['Age']
            df.loc[df['Gender'].str.lower().str.contains('female', na=False), 'BMR'] -= 161
            df.loc[df['Gender'].str.lower().str.contains('male', na=False) & 
                   ~df['Gender'].str.lower().str.contains('female', na=False), 'BMR'] += 5
            self.feature_map.append("BMR = Mifflin-St Jeor equation (gender-specific)")
        
        # 3. Diet Quality Score
        diet_cols = [c for c in df.columns if any(x in c.lower() for x in ['food', 'veg', 'fruit', 'water', 'meal', 'eat'])]
        if diet_cols:
            df['Diet_Quality_Score'] = df[diet_cols].apply(lambda row: row.sum() if row.dtype != 'object' else 0, axis=1)
            self.feature_map.append(f"Diet_Quality_Score = sum of {len(diet_cols)} diet-related features")
        
        # 4. Activity Score
        activity_cols = [c for c in df.columns if any(x in c.lower() for x in ['physactive', 'exercise', 'activity', 'sport', 'walk'])]
        if activity_cols:
            activity_score = 0
            for col in activity_cols:
                if df[col].dtype == 'object':
                    # Binary: Yes=1, No=0
                    activity_score += df[col].str.lower().str.contains('yes', na=False).astype(int)
                else:
                    activity_score += df[col].fillna(0)
            df['Activity_Score'] = activity_score
            self.feature_map.append(f"Activity_Score = sum of {len(activity_cols)} activity indicators")
        
        # 5. Sleep Score (if available)
        sleep_cols = [c for c in df.columns if 'sleep' in c.lower()]
        if sleep_cols:
            df['Sleep_Score'] = df[sleep_cols].sum(axis=1)
            self.feature_map.append(f"Sleep_Score = sum of {len(sleep_cols)} sleep features")
        
        # 6. Age Buckets
        if 'Age' in df.columns:
            df['Age_Bucket'] = pd.cut(df['Age'], bins=[0, 25, 35, 45, 55, 100],
                                      labels=['18-25', '26-35', '36-45', '46-55', '55+'])
            df['Age_Bucket_Encoded'] = LabelEncoder().fit_transform(df['Age_Bucket'].astype(str))
            self.feature_map.append("Age_Bucket = categorical age groups")
        
        # 7. Health Risk Score (composite)
        risk_factors = []
        if 'Diabetes' in df.columns:
            risk_factors.append(df['Diabetes'].str.lower().str.contains('yes', na=False).astype(int))
        if 'Smoke100' in df.columns:
            risk_factors.append(df['Smoke100'].str.lower().str.contains('yes', na=False).astype(int))
        if 'BPSysAve' in df.columns:
            risk_factors.append((df['BPSysAve'] > 140).astype(int))  # Hypertension
        if 'TotChol' in df.columns:
            risk_factors.append((df['TotChol'] > 5.2).astype(int))  # High cholesterol
        
        if risk_factors:
            df['Health_Risk_Score'] = sum(risk_factors)
            self.feature_map.append(f"Health_Risk_Score = sum of {len(risk_factors)} risk factors")
        
        # 8. Lifestyle Score
        lifestyle_score = 0
        if 'PhysActive' in df.columns:
            lifestyle_score += df['PhysActive'].str.lower().str.contains('yes', na=False).astype(int) * 2
        if 'Alcohol12PlusYr' in df.columns:
            lifestyle_score -= df['Alcohol12PlusYr'].str.lower().str.contains('yes', na=False).astype(int)
        if 'Smoke100' in df.columns:
            lifestyle_score -= df['Smoke100'].str.lower().str.contains('yes', na=False).astype(int)
        
        if isinstance(lifestyle_score, pd.Series):
            df['Lifestyle_Score'] = lifestyle_score
            self.feature_map.append("Lifestyle_Score = activity - alcohol - smoking")
        
        # 9. Socioeconomic indicators
        if 'Education' in df.columns:
            education_map = {
                '8th grade': 1, '9 - 11th grade': 2, 'high school': 3,
                'some college': 4, 'college grad': 5
            }
            df['Education_Level'] = df['Education'].str.lower().map(
                {k: v for k, v in education_map.items()}
            ).fillna(3)
            self.feature_map.append("Education_Level = ordinal encoding of education")
        
        if 'HHIncome' in df.columns:
            # Extract numeric from income ranges
            income_numeric = df['HHIncome'].str.extract(r'(\d+)')[0].astype(float).fillna(50000)
            df['Income_Numeric'] = income_numeric
            self.feature_map.append("Income_Numeric = extracted from income ranges")
        
        new_features = len(df.columns) - original_features
        print(f"\n✓ Created {new_features} new features")
        print(f"  Original features: {original_features}")
        print(f"  Total features: {len(df.columns)}")
        
        return df


class ExerciseFeatureEngineer:
    """Feature engineering for Exercise dataset"""
    
    def __init__(self):
        self.feature_map = []
    
    def engineer_features(self, df):
        """Apply all exercise-specific feature engineering"""
        print("\n" + "=" * 80)
        print("EXERCISE FEATURE ENGINEERING")
        print("=" * 80)
        
        df = df.copy()
        original_features = len(df.columns)
        
        # 1. MET Score (Metabolic Equivalent of Task)
        # MET = 3.5 × weight(kg) × duration(hours) × intensity_factor
        if 'Actual Weight' in df.columns and 'Duration' in df.columns:
            weight_kg = df['Actual Weight']
            duration_hours = df['Duration'] / 60
            
            # Intensity factor based on Exercise Intensity (1-10 scale)
            if 'Exercise Intensity' in df.columns:
                intensity_factor = df['Exercise Intensity'] / 10 * 8  # Scale to 0-8 METs
            else:
                intensity_factor = 5  # Default moderate intensity
            
            df['MET_Score'] = 3.5 * weight_kg * duration_hours * intensity_factor
            self.feature_map.append("MET_Score = 3.5 × weight × duration × intensity")
        
        # 2. Calories per minute
        if 'Calories Burn' in df.columns and 'Duration' in df.columns:
            df['Calories_Per_Minute'] = df['Calories Burn'] / df['Duration'].replace(0, 1)
            self.feature_map.append("Calories_Per_Minute = total calories / duration")
        
        # 3. Heart Rate Zones
        if 'Heart Rate' in df.columns and 'Age' in df.columns:
            max_hr = 220 - df['Age']
            df['HR_Percentage'] = (df['Heart Rate'] / max_hr) * 100
            
            # Zone classification
            df['HR_Zone'] = pd.cut(df['HR_Percentage'], 
                                   bins=[0, 60, 70, 80, 90, 100],
                                   labels=['Very Light', 'Light', 'Moderate', 'Hard', 'Maximum'])
            df['HR_Zone_Encoded'] = LabelEncoder().fit_transform(df['HR_Zone'].astype(str))
            self.feature_map.append("HR_Zone = heart rate as % of max (age-based)")
        
        # 4. BMI-adjusted intensity
        if 'BMI' in df.columns and 'Exercise Intensity' in df.columns:
            df['BMI_Adjusted_Intensity'] = df['Exercise Intensity'] * (df['BMI'] / 25)
            self.feature_map.append("BMI_Adjusted_Intensity = intensity × (BMI / 25)")
        
        # 5. Weight difference (motivation indicator)
        if 'Dream Weight' in df.columns and 'Actual Weight' in df.columns:
            df['Weight_Difference'] = df['Actual Weight'] - df['Dream Weight']
            df['Weight_Diff_Percentage'] = (df['Weight_Difference'] / df['Actual Weight']) * 100
            self.feature_map.append("Weight_Difference = actual - dream weight")
        
        # 6. Session-based aggregations (rolling features)
        if 'ID' in df.columns:
            # Sort by ID to ensure temporal order
            df = df.sort_values('ID')
            
            # Rolling heart rate features (window=5)
            if 'Heart Rate' in df.columns:
                df['HR_Rolling_Mean'] = df['Heart Rate'].rolling(window=5, min_periods=1).mean()
                df['HR_Rolling_Std'] = df['Heart Rate'].rolling(window=5, min_periods=1).std().fillna(0)
                df['HR_Rolling_Max'] = df['Heart Rate'].rolling(window=5, min_periods=1).max()
                self.feature_map.append("HR_Rolling_* = rolling statistics (window=5)")
            
            # Rolling calories
            if 'Calories Burn' in df.columns:
                df['Calories_Rolling_Mean'] = df['Calories Burn'].rolling(window=5, min_periods=1).mean()
                df['Calories_Trend'] = df['Calories Burn'] - df['Calories_Rolling_Mean']
                self.feature_map.append("Calories_Trend = current - rolling mean")
        
        # 7. Intensity category
        if 'Exercise Intensity' in df.columns:
            df['Intensity_Category'] = pd.cut(df['Exercise Intensity'],
                                              bins=[0, 3, 6, 10],
                                              labels=['Low', 'Medium', 'High'])
            df['Intensity_Category_Encoded'] = LabelEncoder().fit_transform(df['Intensity_Category'].astype(str))
            self.feature_map.append("Intensity_Category = Low/Medium/High")
        
        # 8. Efficiency score (calories per heart rate)
        if 'Calories Burn' in df.columns and 'Heart Rate' in df.columns:
            df['Calorie_Efficiency'] = df['Calories Burn'] / df['Heart Rate'].replace(0, 1)
            self.feature_map.append("Calorie_Efficiency = calories / heart rate")
        
        # 9. Age-adjusted performance
        if 'Age' in df.columns and 'Calories Burn' in df.columns:
            # Younger people typically burn more calories
            age_factor = 1 + (40 - df['Age']) / 100  # Peak at age 40
            df['Age_Adjusted_Calories'] = df['Calories Burn'] * age_factor
            self.feature_map.append("Age_Adjusted_Calories = calories × age_factor")
        
        # 10. Gender-based features
        if 'Gender' in df.columns:
            df['Gender_Encoded'] = LabelEncoder().fit_transform(df['Gender'])
            
            # Gender-specific calorie adjustment
            if 'Calories Burn' in df.columns:
                df['Gender_Adjusted_Calories'] = df['Calories Burn'].copy()
                # Males typically burn ~10% more calories
                df.loc[df['Gender'].str.lower().str.contains('male', na=False) & 
                       ~df['Gender'].str.lower().str.contains('female', na=False), 
                       'Gender_Adjusted_Calories'] *= 1.1
                self.feature_map.append("Gender_Adjusted_Calories = gender-specific adjustment")
        
        new_features = len(df.columns) - original_features
        print(f"\n✓ Created {new_features} new features")
        print(f"  Original features: {original_features}")
        print(f"  Total features: {len(df.columns)}")
        
        return df


def train_obesity_enriched():
    """Train Obesity with enriched features"""
    print("\n" + "=" * 80)
    print("OBESITY DATASET - ENRICHED TRAINING")
    print("=" * 80)
    
    # Load the correct obesity dataset
    df = pd.read_csv('/Users/gitanjanganai/Downloads/ObesityDataSet_raw_and_data_sinthetic.csv').drop_duplicates()
    print(f"Loaded: ObesityDataSet_raw_and_data_sinthetic.csv")
    
    print(f"Original shape: {df.shape}")
    
    # Create BMI and BMI_Category to match baseline
    if 'BMI' not in df.columns and 'Height' in df.columns and 'Weight' in df.columns:
        # Assume Weight is in kg and Height is in meters if Height < 3
        df['Weight_kg'] = df['Weight'] if 'Weight' in df.columns else 70
        df['Height_m'] = df['Height'] if df['Height'].mean() < 3 else df['Height'] / 100
        df['BMI'] = df['Weight_kg'] / (df['Height_m'] ** 2)
    
    # Create BMI categories
    if 'BMI' in df.columns and 'BMI_Category' not in df.columns:
        df['BMI_Category'] = pd.cut(df['BMI'], bins=[0, 18.5, 25, 30, 100],
                                     labels=['Underweight', 'Normal', 'Overweight', 'Obese'])
    
    # Engineer features
    engineer = ObesityFeatureEngineer()
    df_enriched = engineer.engineer_features(df)
    
    # Save feature map
    with open(OUTPUT_DIR / 'obesity_feature_map.md', 'w') as f:
        f.write("# Obesity Feature Engineering Map\n\n")
        for i, feat in enumerate(engineer.feature_map, 1):
            f.write(f"{i}. {feat}\n")
    
    # Determine target - use NObeyesdad from this dataset
    if 'NObeyesdad' in df_enriched.columns:
        target = 'NObeyesdad'
    elif 'BMI_Category' in df_enriched.columns:
        target = 'BMI_Category'
    elif 'BMI_WHO' in df_enriched.columns:
        target = 'BMI_WHO'
    else:
        target = df_enriched.columns[-1]
    
    print(f"\nTarget: {target}")
    print(f"Target distribution:")
    print(df_enriched[target].value_counts())
    
    # Prepare data
    y = df_enriched[target]
    X = df_enriched.drop(columns=[target])
    
    # Encode categorical
    for col in X.select_dtypes(include=['object', 'category']).columns:
        le = LabelEncoder()
        X[col] = le.fit_transform(X[col].astype(str))
    
    X = X.fillna(X.median()).fillna(0)
    
    # Encode target
    le_target = LabelEncoder()
    y_encoded = le_target.fit_transform(y)
    
    print(f"\nClass distribution:")
    for cls, count in zip(*np.unique(y_encoded, return_counts=True)):
        print(f"  Class {cls} ({le_target.classes_[cls]}): {count}")
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y_encoded, test_size=0.2, random_state=RANDOM_SEED, stratify=y_encoded
    )
    
    # Apply SMOTE if imbalanced
    class_counts = np.bincount(y_train)
    if max(class_counts) / min(class_counts) > 2:
        print("\n✓ Applying SMOTE for class balancing...")
        smote = SMOTE(random_state=RANDOM_SEED)
        X_train, y_train = smote.fit_resample(X_train, y_train)
        print(f"  After SMOTE: {X_train.shape[0]} samples")
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train TabNet with optimized hyperparameters
    print("\n✓ Training TabNet with optimized settings...")
    model = TabNetClassifier(
        n_steps=7, gamma=1.2, n_independent=4, n_shared=4,
        lambda_sparse=5e-5, optimizer_params=dict(lr=1.5e-2),
        scheduler_params={"step_size":15, "gamma":0.85},
        mask_type='sparsemax', verbose=0, seed=RANDOM_SEED
    )
    
    model.fit(
        X_train_scaled, y_train,
        eval_set=[(X_test_scaled, y_test)],
        max_epochs=200, patience=20,
        batch_size=256, virtual_batch_size=128
    )
    
    # Evaluate
    y_pred = model.predict(X_test_scaled)
    acc = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred, average='macro')
    precision = precision_score(y_test, y_pred, average='macro')
    recall = recall_score(y_test, y_pred, average='macro')
    
    print(f"\n{'=' * 80}")
    print("OBESITY RESULTS")
    print(f"{'=' * 80}")
    print(f"Baseline Accuracy: 80.14%")
    print(f"Enriched Accuracy: {acc*100:.2f}%")
    print(f"Improvement: {(acc - 0.8014)*100:+.2f}%")
    print(f"F1-Score: {f1:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"Target: 88-92% | Status: {'✓ MET' if 0.88 <= acc <= 0.92 else ('✓ EXCEEDED' if acc > 0.92 else '✗ NOT MET')}")
    
    # Save model
    model.save_model(str(OUTPUT_DIR / 'obesity_enriched_tabnet'))
    
    # Save enriched dataset
    df_enriched.to_csv(OUTPUT_DIR / 'obesity_enriched_dataset.csv', index=False)
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    plt.figure(figsize=(12, 10))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=le_target.classes_, yticklabels=le_target.classes_)
    plt.title(f'Obesity (Enriched) - TabNet\nAccuracy: {acc*100:.2f}%')
    plt.ylabel('True')
    plt.xlabel('Predicted')
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'confusion_matrices' / 'obesity_enriched.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Feature importance
    if hasattr(model, 'feature_importances_'):
        feat_imp = pd.DataFrame({
            'feature': X.columns,
            'importance': model.feature_importances_
        }).sort_values('importance', ascending=False).head(20)
        
        plt.figure(figsize=(10, 8))
        plt.barh(feat_imp['feature'], feat_imp['importance'])
        plt.xlabel('Importance')
        plt.title('Top 20 Feature Importances - Obesity')
        plt.tight_layout()
        plt.savefig(OUTPUT_DIR / 'obesity_feature_importance.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    return {
        'baseline_accuracy': 0.8014,
        'enriched_accuracy': float(acc),
        'improvement': float(acc - 0.8014),
        'f1': float(f1),
        'precision': float(precision),
        'recall': float(recall),
        'target_met': 0.88 <= acc <= 0.92,
        'features_created': len(engineer.feature_map)
    }


def train_exercise_enriched():
    """Train Exercise with enriched features"""
    print("\n" + "=" * 80)
    print("EXERCISE DATASET - ENRICHED TRAINING")
    print("=" * 80)
    
    # Load data
    df = pd.read_csv('/Users/gitanjanganai/Downloads/exercise_dataset.csv')
    print(f"Original shape: {df.shape}")
    
    # Engineer features
    engineer = ExerciseFeatureEngineer()
    df_enriched = engineer.engineer_features(df)
    
    # Save feature map
    with open(OUTPUT_DIR / 'exercise_feature_map.md', 'w') as f:
        f.write("# Exercise Feature Engineering Map\n\n")
        for i, feat in enumerate(engineer.feature_map, 1):
            f.write(f"{i}. {feat}\n")
    
    # Target: Calories Burn (regression)
    target = 'Calories Burn'
    print(f"\nTarget: {target} (Regression)")
    
    # Prepare data
    y = df_enriched[target].values
    X = df_enriched.drop(columns=[target, 'ID'] if 'ID' in df_enriched.columns else [target])
    
    # Encode categorical
    for col in X.select_dtypes(include=['object', 'category']).columns:
        le = LabelEncoder()
        X[col] = le.fit_transform(X[col].astype(str))
    
    X = X.fillna(X.median()).fillna(0)
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=RANDOM_SEED
    )
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train TabNet
    print("\n✓ Training TabNet Regressor...")
    model = TabNetRegressor(
        n_steps=5, gamma=1.5, n_independent=3, n_shared=3,
        lambda_sparse=1e-4, optimizer_params=dict(lr=2e-2),
        scheduler_params={"step_size":10, "gamma":0.9},
        mask_type='sparsemax', verbose=0, seed=RANDOM_SEED
    )
    
    model.fit(
        X_train_scaled, y_train.reshape(-1, 1),
        eval_set=[(X_test_scaled, y_test.reshape(-1, 1))],
        max_epochs=150, patience=15,
        batch_size=512, virtual_batch_size=256
    )
    
    # Evaluate
    y_pred = model.predict(X_test_scaled).flatten()
    r2 = r2_score(y_test, y_pred)
    mae = mean_absolute_error(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    
    print(f"\n{'=' * 80}")
    print("EXERCISE RESULTS (Regression)")
    print(f"{'=' * 80}")
    print(f"R² Score: {r2:.4f}")
    print(f"MAE: {mae:.2f} calories")
    print(f"RMSE: {rmse:.2f} calories")
    print(f"Target: MAE < ±40 calories | Status: {'✓ MET' if mae < 40 else '✗ NOT MET'}")
    
    # Also try classification on intensity
    print(f"\n{'=' * 80}")
    print("EXERCISE RESULTS (Classification - Intensity)")
    print(f"{'=' * 80}")
    
    if 'Intensity_Category_Encoded' in df_enriched.columns:
        y_class = df_enriched['Intensity_Category_Encoded'].values
        X_class = df_enriched.drop(columns=[target, 'Intensity_Category', 'Intensity_Category_Encoded', 
                                            'ID'] if 'ID' in df_enriched.columns else [target])
        
        # Encode categorical
        for col in X_class.select_dtypes(include=['object', 'category']).columns:
            le = LabelEncoder()
            X_class[col] = le.fit_transform(X_class[col].astype(str))
        
        X_class = X_class.fillna(X_class.median()).fillna(0)
        
        X_train_c, X_test_c, y_train_c, y_test_c = train_test_split(
            X_class, y_class, test_size=0.2, random_state=RANDOM_SEED, stratify=y_class
        )
        
        scaler_c = StandardScaler()
        X_train_c_scaled = scaler_c.fit_transform(X_train_c)
        X_test_c_scaled = scaler_c.transform(X_test_c)
        
        model_class = TabNetClassifier(
            n_steps=5, gamma=1.5, n_independent=3, n_shared=3,
            lambda_sparse=1e-4, optimizer_params=dict(lr=2e-2),
            scheduler_params={"step_size":10, "gamma":0.9},
            mask_type='sparsemax', verbose=0, seed=RANDOM_SEED
        )
        
        model_class.fit(
            X_train_c_scaled, y_train_c,
            eval_set=[(X_test_c_scaled, y_test_c)],
            max_epochs=150, patience=15,
            batch_size=512, virtual_batch_size=256
        )
        
        y_pred_c = model_class.predict(X_test_c_scaled)
        acc_class = accuracy_score(y_test_c, y_pred_c)
        f1_class = f1_score(y_test_c, y_pred_c, average='macro')
        
        print(f"Intensity Classification Accuracy: {acc_class*100:.2f}%")
        print(f"F1-Score: {f1_class:.4f}")
        print(f"Target: 60-70%+ | Status: {'✓ MET' if acc_class >= 0.60 else '✗ NOT MET'}")
        
        # Save classification model
        model_class.save_model(str(OUTPUT_DIR / 'exercise_intensity_classifier'))
        
        # Confusion matrix for classification
        cm = confusion_matrix(y_test_c, y_pred_c)
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                    xticklabels=['Low', 'Medium', 'High'],
                    yticklabels=['Low', 'Medium', 'High'])
        plt.title(f'Exercise Intensity Classification\nAccuracy: {acc_class*100:.2f}%')
        plt.ylabel('True')
        plt.xlabel('Predicted')
        plt.tight_layout()
        plt.savefig(OUTPUT_DIR / 'confusion_matrices' / 'exercise_intensity.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # Save regression model
    model.save_model(str(OUTPUT_DIR / 'exercise_enriched_tabnet'))
    
    # Save enriched dataset
    df_enriched.to_csv(OUTPUT_DIR / 'exercise_enriched_dataset.csv', index=False)
    
    # Prediction scatter plot
    plt.figure(figsize=(10, 6))
    plt.scatter(y_test, y_pred, alpha=0.5)
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
    plt.xlabel('Actual Calories')
    plt.ylabel('Predicted Calories')
    plt.title(f'Exercise Calorie Prediction\nR²={r2:.4f}, MAE={mae:.2f}')
    plt.tight_layout()
    plt.savefig(OUTPUT_DIR / 'exercise_prediction_scatter.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Feature importance
    if hasattr(model, 'feature_importances_'):
        feat_imp = pd.DataFrame({
            'feature': X.columns,
            'importance': model.feature_importances_
        }).sort_values('importance', ascending=False).head(20)
        
        plt.figure(figsize=(10, 8))
        plt.barh(feat_imp['feature'], feat_imp['importance'])
        plt.xlabel('Importance')
        plt.title('Top 20 Feature Importances - Exercise')
        plt.tight_layout()
        plt.savefig(OUTPUT_DIR / 'exercise_feature_importance.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    results = {
        'regression': {
            'r2': float(r2),
            'mae': float(mae),
            'rmse': float(rmse),
            'target_met': mae < 40
        },
        'features_created': len(engineer.feature_map)
    }
    
    if 'Intensity_Category_Encoded' in df_enriched.columns:
        results['classification'] = {
            'accuracy': float(acc_class),
            'f1': float(f1_class),
            'target_met': acc_class >= 0.60
        }
    
    return results


if __name__ == "__main__":
    print("\nStarting advanced feature engineering pipeline...\n")
    
    results = {}
    
    # Train Obesity
    try:
        results['obesity'] = train_obesity_enriched()
    except Exception as e:
        print(f"\n✗ Obesity error: {e}")
        import traceback
        traceback.print_exc()
    
    # Train Exercise
    try:
        results['exercise'] = train_exercise_enriched()
    except Exception as e:
        print(f"\n✗ Exercise error: {e}")
        import traceback
        traceback.print_exc()
    
    # Save results
    with open(OUTPUT_DIR / 'experiment_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    # Generate improvement summary
    with open(OUTPUT_DIR / 'improvement_summary.txt', 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("FEATURE ENGINEERING IMPROVEMENT SUMMARY\n")
        f.write("=" * 80 + "\n\n")
        
        if 'obesity' in results:
            f.write("OBESITY DATASET:\n")
            f.write(f"  Baseline Accuracy: 80.14%\n")
            f.write(f"  Enriched Accuracy: {results['obesity']['enriched_accuracy']*100:.2f}%\n")
            f.write(f"  Improvement: {results['obesity']['improvement']*100:+.2f}%\n")
            f.write(f"  Features Created: {results['obesity']['features_created']}\n")
            f.write(f"  Target (88-92%): {'✓ MET' if results['obesity']['target_met'] else '✗ NOT MET'}\n\n")
        
        if 'exercise' in results:
            f.write("EXERCISE DATASET:\n")
            f.write(f"  Regression MAE: {results['exercise']['regression']['mae']:.2f} calories\n")
            f.write(f"  Regression R²: {results['exercise']['regression']['r2']:.4f}\n")
            f.write(f"  Target (MAE < 40): {'✓ MET' if results['exercise']['regression']['target_met'] else '✗ NOT MET'}\n")
            
            if 'classification' in results['exercise']:
                f.write(f"  Classification Accuracy: {results['exercise']['classification']['accuracy']*100:.2f}%\n")
                f.write(f"  Target (60-70%+): {'✓ MET' if results['exercise']['classification']['target_met'] else '✗ NOT MET'}\n")
            
            f.write(f"  Features Created: {results['exercise']['features_created']}\n\n")
        
        f.write("=" * 80 + "\n")
        f.write("ARTIFACTS SAVED:\n")
        f.write("  - enriched_datasets: obesity_enriched_dataset.csv, exercise_enriched_dataset.csv\n")
        f.write("  - feature_maps: obesity_feature_map.md, exercise_feature_map.md\n")
        f.write("  - models: obesity_enriched_tabnet, exercise_enriched_tabnet\n")
        f.write("  - visualizations: confusion matrices, feature importance plots\n")
        f.write("  - results: experiment_results.json\n")
        f.write("=" * 80 + "\n")
    
    print(f"\n{'=' * 80}")
    print("PIPELINE COMPLETE")
    print(f"{'=' * 80}")
    print(f"\nAll outputs saved to: {OUTPUT_DIR}")
    print("\nFiles created:")
    print("  - obesity_enriched_dataset.csv")
    print("  - exercise_enriched_dataset.csv")
    print("  - obesity_feature_map.md")
    print("  - exercise_feature_map.md")
    print("  - experiment_results.json")
    print("  - improvement_summary.txt")
    print("  - Model files and visualizations")
    print(f"{'=' * 80}")
