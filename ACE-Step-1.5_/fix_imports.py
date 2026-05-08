#!/usr/bin/env python3
"""
Fix import paths for ACE-Step module loading.

This utility ensures that the ACE-Step package is properly discoverable
regardless of where the script is executed from.

Usage:
    import fix_imports
    fix_imports.setup_acestep_path()
"""
import os
import sys
import site
from pathlib import Path


def get_acestep_root() -> str:
    """
    Detect the ACE-Step-1.5_ directory.
    Works from any location in the repo.
    """
    # Method 1: Check if we're already in ACE-Step-1.5_
    if os.path.basename(os.getcwd()).startswith('ACE-Step'):
        acestep_dir = os.getcwd()
        parent_dir = os.path.dirname(acestep_dir)
        return parent_dir
    
    # Method 2: Check script location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    if os.path.basename(script_dir).startswith('ACE-Step'):
        return os.path.dirname(script_dir)
    
    # Method 3: Search upward from current location
    current = Path(os.getcwd()).resolve()
    for parent in [current] + list(current.parents):
        acestep_path = parent / 'ACE-Step-1.5_'
        if acestep_path.exists() and (acestep_path / 'acestep').exists():
            return str(parent)
        # Also check if current dir IS ACE-Step-1.5_
        if parent.name.startswith('ACE-Step') and (parent / 'acestep').exists():
            return str(parent.parent)
    
    # Method 4: Check environment variable
    if 'ACESTEP_PATH' in os.environ:
        acestep_path = os.environ['ACESTEP_PATH']
        if os.path.exists(acestep_path):
            # ACESTEP_PATH might point to parent or ACE-Step-1.5_ dir
            if os.path.basename(acestep_path).startswith('ACE-Step'):
                return os.path.dirname(acestep_path)
            return acestep_path
    
    raise EnvironmentError(
        "Could not find ACE-Step-1.5_ directory.\n"
        "Make sure you're running from the repo root or ACE-Step-1.5_ directory.\n"
        "Or set ACESTEP_PATH environment variable."
    )


def setup_acestep_path() -> dict:
    """
    Setup Python path for ACE-Step imports.
    
    Returns:
        dict: Configuration with paths and status
    """
    try:
        # Get project root (parent of ACE-Step-1.5_)
        project_root = get_acestep_root()
        acestep_dir = os.path.join(project_root, 'ACE-Step-1.5_')
        
        # Verify structure
        if not os.path.isdir(acestep_dir):
            raise EnvironmentError(f"ACE-Step-1.5_ not found at {acestep_dir}")
        
        acestep_pkg = os.path.join(acestep_dir, 'acestep')
        if not os.path.isdir(acestep_pkg):
            raise EnvironmentError(f"acestep package not found at {acestep_pkg}")
        
        # Add project root to path (so 'from acestep...' works)
        if project_root not in sys.path:
            sys.path.insert(0, project_root)
        
        # Add ACE-Step-1.5_ to path as fallback
        if acestep_dir not in sys.path:
            sys.path.insert(0, acestep_dir)
        
        # Set environment variables for HuggingFace and model loading
        os.environ['ACESTEP_PATH'] = acestep_dir
        os.environ['PYTHONPATH'] = f"{project_root}{os.pathsep}{os.environ.get('PYTHONPATH', '')}"
        
        config = {
            'project_root': project_root,
            'acestep_dir': acestep_dir,
            'acestep_pkg': acestep_pkg,
            'venv_active': hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix),
            'python_executable': sys.executable,
            'python_version': f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
            'sys_path': sys.path[:3],  # First 3 entries
            'status': 'OK'
        }
        
        return config
        
    except Exception as e:
        return {
            'status': 'ERROR',
            'error': str(e),
            'python_executable': sys.executable,
            'current_working_dir': os.getcwd(),
        }


def print_diagnostics() -> None:
    """
    Print import path diagnostics.
    Useful for debugging import issues.
    """
    config = setup_acestep_path()
    
    print("\n" + "="*60)
    print("ACE-Step Import Path Diagnostics")
    print("="*60)
    
    if config['status'] == 'OK':
        print(f"\u2713 Status: OK")
        print(f"  Project Root: {config['project_root']}")
        print(f"  ACE-Step Dir: {config['acestep_dir']}")
        print(f"  Python: {config['python_executable']}")
        print(f"  Version: {config['python_version']}")
        print(f"  Venv Active: {config['venv_active']}")
        print(f"\nPython Path (first 3):")
        for i, p in enumerate(config['sys_path'], 1):
            print(f"  [{i}] {p}")
    else:
        print(f"\u2717 Status: ERROR")
        print(f"  Error: {config['error']}")
        print(f"  Current Dir: {config['current_working_dir']}")
        print(f"  Python: {config['python_executable']}")
    
    print("\n" + "="*60 + "\n")
    
    return config


if __name__ == '__main__':
    config = print_diagnostics()
    if config['status'] != 'OK':
        sys.exit(1)
