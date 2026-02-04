
"""
Lightweight ML model loader optimized for low-memory environments
"""
import torch
import gc
from pytorch_tabnet.tab_model import TabNetClassifier, TabNetRegressor
from pathlib import Path

# Force CPU-only mode to reduce memory
torch.set_num_threads(1)

class LightweightMLModels:
    """Memory-optimized model loader with lazy loading"""
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(LightweightMLModels, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def _load_models(self):
        """Load models with memory optimization"""
        if self._initialized:
            return
        
        print("Loading optimized ML models...")
        MODEL_DIR = Path(__file__).parent / 'optimized_models'
        
        # Load models one at a time and clear memory between loads
        try:
            self.obesity_model = TabNetClassifier()
            model_path = MODEL_DIR / 'obesity' / 'obesity_tabnet_best_optimized.zip'
            if not model_path.exists():
                model_path = MODEL_DIR / 'obesity' / 'obesity_tabnet_best.zip'
            self.obesity_model.load_model(str(model_path))
            self.obesity_model.network.eval()
            self.obesity_classes = ['Insufficient_Weight', 'Normal_Weight', 'Obesity_Type_I', 
                                   'Obesity_Type_II', 'Obesity_Type_III', 'Overweight_Level_I', 
                                   'Overweight_Level_II']
            print("✓ Obesity model loaded")
            gc.collect()
        except Exception as e:
            print(f"✗ Obesity model failed: {e}")
            self.obesity_model = None
        
        try:
            self.exercise_model = TabNetRegressor()
            model_path = MODEL_DIR / 'exercise' / 'exercise_tabnet_best_optimized.zip'
            if not model_path.exists():
                model_path = MODEL_DIR / 'exercise' / 'exercise_tabnet_best.zip'
            self.exercise_model.load_model(str(model_path))
            self.exercise_model.network.eval()
            print("✓ Exercise model loaded")
            gc.collect()
        except Exception as e:
            print(f"✗ Exercise model failed: {e}")
            self.exercise_model = None
        
        try:
            self.menstrual_model = TabNetClassifier()
            model_path = MODEL_DIR / 'menstrual' / 'menstrual_tabnet_best_optimized.zip'
            if not model_path.exists():
                model_path = MODEL_DIR / 'menstrual' / 'menstrual_tabnet_best.zip'
            self.menstrual_model.load_model(str(model_path))
            self.menstrual_model.network.eval()
            self.menstrual_classes = ['Regular', 'Short', 'Long']
            print("✓ Menstrual model loaded")
            gc.collect()
        except Exception as e:
            print(f"✗ Menstrual model failed: {e}")
            self.menstrual_model = None
        
        self._initialized = True
        print("Model loading complete!")
    
    def get_obesity_model(self):
        if not self._initialized:
            self._load_models()
        return self.obesity_model
    
    def get_exercise_model(self):
        if not self._initialized:
            self._load_models()
        return self.exercise_model
    
    def get_menstrual_model(self):
        if not self._initialized:
            self._load_models()
        return self.menstrual_model
