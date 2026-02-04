# Exercise Feature Engineering Map

1. MET_Score = 3.5 × weight × duration × intensity
2. Calories_Per_Minute = total calories / duration
3. HR_Zone = heart rate as % of max (age-based)
4. BMI_Adjusted_Intensity = intensity × (BMI / 25)
5. Weight_Difference = actual - dream weight
6. HR_Rolling_* = rolling statistics (window=5)
7. Calories_Trend = current - rolling mean
8. Intensity_Category = Low/Medium/High
9. Calorie_Efficiency = calories / heart rate
10. Age_Adjusted_Calories = calories × age_factor
11. Gender_Adjusted_Calories = gender-specific adjustment
