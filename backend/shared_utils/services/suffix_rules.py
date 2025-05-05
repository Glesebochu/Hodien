# ✅ STEP 2: Replace longer suffixes with simpler forms (from official Porter algorithm)
suffix_map_step2 = {
    'ational': 'ate',
    'tional': 'tion',
    'enci': 'ence',
    'anci': 'ance',
    'izer': 'ize',
    'abli': 'able',
    'alli': 'al',
    'entli': 'ent',
    'eli': 'e',
    'ousli': 'ous',
    'ization': 'ize',
    'ation': 'ate',
    'ator': 'ate',
    'alism': 'al',
    'iveness': 'ive',
    'fulness': 'ful',
    'ousness': 'ous',
    'aliti': 'al',
    'iviti': 'ive',
    'biliti': 'ble',
    'logi': 'log'
}

# ✅ STEP 3: Further suffix reductions (official Porter)
suffix_map_step3 = {
    'icate': 'ic',
    'ative': '',
    'alize': 'al',
    'iciti': 'ic',
    'ical': 'ic',
    'ful': '',
    'ness': ''
}

# ✅ STEP 4: Common endings to remove (official Porter step 4)
suffix_list_step4 = [
    'al',
    'ance',
    'ence',
    'er',
    'ic',
    'able',
    'ible',
    'ant',
    'ement',
    'ment',
    'ent',
    'ion',  # only if preceded by s or t in real implementation
    'ou',
    'ism',
    'ate',
    'iti',
    'ous',
    'ive',
    'ize'
]

# ❗ You can expand these maps/lists with rare or technical suffixes if needed,
# e.g., scientific or legal vocabulary. This base set already covers most English roots.
