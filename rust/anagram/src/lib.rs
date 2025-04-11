use std::collections::HashSet;

pub fn anagrams_for<'a>(word: &str, possible_anagrams: &[&'a str]) -> HashSet<&'a str> {
    let mut word_chars: Vec<char> = word.to_lowercase().chars().collect();
    word_chars.sort();
    let sorted_word: String = word_chars.iter().collect();
    possible_anagrams
        .iter()
        .filter(|&&s| s.to_lowercase() != word.to_lowercase())
        .copied()
        .filter(|&s| {
            let mut p_anagram_chars: Vec<char> = s.to_lowercase().chars().collect();
            p_anagram_chars.sort();
            p_anagram_chars.iter().collect::<String>() == sorted_word
        })
        .collect()
}
