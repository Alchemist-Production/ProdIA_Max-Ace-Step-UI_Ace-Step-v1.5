"""
ACE-Step v1.5 Model Configuration

This module provides configuration classes for ACE-Step models.
It's imported dynamically by HuggingFace's transformers library.
"""
from transformers import PretrainedConfig
from typing import Dict, Any


class AceStepConfig(PretrainedConfig):
    """
    Configuration class for ACE-Step models.
    
    This configuration class is instantiated when loading an ACE-Step model
    from the HuggingFace Model Hub.
    """
    model_type = "acestep"
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # ACE-Step specific configurations can be set here
        # These are typically loaded from the model's config.json file
