"""Generate SDK-matched Android files without overwriting application source."""
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
flutter = shutil.which('flutter')
if not flutter:
    raise SystemExit('Flutter was not found. Install Flutter and add its bin folder to PATH first.')
android = root / 'android'
if not android.exists():
    with tempfile.TemporaryDirectory(prefix='signup_bootstrap_') as temp:
        scaffold = Path(temp) / 'signup_app'
        subprocess.run([flutter, 'create', '--platforms=android', '--project-name',
                        'signup_app', '--no-pub', str(scaffold)], check=True)
        shutil.copytree(scaffold / 'android', android)
        if (scaffold / '.metadata').exists():
            shutil.copy2(scaffold / '.metadata', root / '.metadata')
manifest = android / 'app/src/main/AndroidManifest.xml'
text = manifest.read_text(encoding='utf-8')
permission = '<uses-permission android:name="android.permission.INTERNET" />'
if 'android.permission.INTERNET' not in text:
    start = text.index('<manifest')
    end = text.index('>', start) + 1
    text = text[:end] + '\n    ' + permission + text[end:]
    manifest.write_text(text, encoding='utf-8')
subprocess.run([flutter, 'pub', 'get'], cwd=root, check=True)
print('Android scaffold and dependencies are ready. See README.md for run/test/build commands.')
