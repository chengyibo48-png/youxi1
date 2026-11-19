from pathlib import Path
path=Path(__file__).resolve().parents[1]/'scripts/preview.gd'
source=path.read_text(encoding='utf-8')
start=source.index('  # Both arenas use the same world-to-panel transform')
end=source.index('  draw_string(get_theme_default_font(),origin+Vector2(12,183)',start)
source=source[:start]+source[end:]
path.write_text(source,encoding='utf-8')
print('Preview arenas now have independent clipping and synchronized legal actions.')
