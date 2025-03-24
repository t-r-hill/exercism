use crate::Suit::{Clubs, Diamonds, Hearts, Spades};
use std::cmp::Ordering;
use std::str::FromStr;

pub fn winning_hands<'a>(hands: &[&'a str]) -> Vec<&'a str> {
    if let Some((_, win_hands)) = hands
        .iter()
        .map(|&hand_str| hand_str.parse::<RankedHand>().unwrap())
        .zip(hands)
        .fold(None, |acc, (hand, &str_repr)| match acc {
            None => Some((hand, vec![str_repr])),
            Some((win_hand, mut list)) => match hand.cmp(&win_hand) {
                Ordering::Greater => Some((hand, vec![str_repr])),
                Ordering::Equal => {
                    list.push(str_repr);
                    Some((hand, list))
                }
                Ordering::Less => Some((win_hand, list)),
            },
        })
    {
        return win_hands;
    }
    Vec::new()
}

impl RankedHand {
    fn rank(cards: Vec<Card>) -> Self {
        let mut iter_cards = cards.iter();

        let flush = match iter_cards.next() {
            Some(first_card) => iter_cards.all(|card| card.suit == first_card.suit),
            None => false,
        };

        let mut card_values = cards.iter().map(|card| card.value).collect();

        let adjacent_diffs = cards
            .iter()
            .zip(cards.iter().skip(1))
            .map(|(a, b)| a.value - b.value)
            .collect::<Vec<u8>>();

        match adjacent_diffs.as_slice() {
            [1, 1, 1, 1] if flush => RankedHand::StraightFlush(card_values),
            [1, 1, 1, 1] => RankedHand::Straight(card_values),
            [9, 1, 1, 1] if flush => {
                // specific case for Ace low straight flush
                card_values.rotate_left(1);
                RankedHand::StraightFlush(card_values)
            }
            [9, 1, 1, 1] => {
                // specific case for Ace low straight
                card_values.rotate_left(1);
                RankedHand::Straight(card_values)
            }
            [0, 0, 0, _] => RankedHand::FourOfAKind(card_values),
            [_, 0, 0, 0] => {
                card_values.rotate_left(1);
                RankedHand::FourOfAKind(card_values)
            }
            [0, _, 0, 0] => {
                card_values.rotate_left(2);
                RankedHand::FullHouse(card_values)
            }
            [0, 0, _, 0] => RankedHand::FullHouse(card_values),
            [0, 0, _, _] => RankedHand::ThreeOfAKind(card_values),
            [_, 0, 0, _] => {
                card_values[..4].rotate_left(1);
                RankedHand::ThreeOfAKind(card_values)
            }
            [_, _, 0, 0] => {
                card_values.rotate_left(2);
                RankedHand::ThreeOfAKind(card_values)
            }
            [0, _, 0, _] => RankedHand::TwoPair(card_values),
            [0, _, _, 0] => {
                card_values[2..5].rotate_left(1);
                RankedHand::TwoPair(card_values)
            }
            [_, 0, _, 0] => {
                card_values.rotate_left(1);
                RankedHand::TwoPair(card_values)
            }
            [0, _, _, _] => RankedHand::Pair(card_values),
            [_, 0, _, _] => {
                card_values[0..3].rotate_left(1);
                RankedHand::Pair(card_values)
            }
            [_, _, 0, _] => {
                card_values[0..4].rotate_left(2);
                RankedHand::Pair(card_values)
            }
            [_, _, _, 0] => {
                card_values.rotate_right(2);
                RankedHand::Pair(card_values)
            }
            _ if flush => RankedHand::Flush(card_values),
            _ => RankedHand::HighCard(card_values),
        }
    }

    fn new(mut cards: Vec<Card>) -> Self {
        cards.sort_by(|card_a, card_b| card_b.value.cmp(&card_a.value));
        RankedHand::rank(cards)
    }
}

#[derive(Eq, Debug)]
enum RankedHand {
    HighCard(Vec<u8>),
    Pair(Vec<u8>),
    TwoPair(Vec<u8>),
    ThreeOfAKind(Vec<u8>),
    Straight(Vec<u8>),
    Flush(Vec<u8>),
    FullHouse(Vec<u8>),
    FourOfAKind(Vec<u8>),
    StraightFlush(Vec<u8>),
}

impl RankedHand {
    fn rank_ord(&self) -> u8 {
        match self {
            RankedHand::HighCard(_) => 0,
            RankedHand::Pair(_) => 1,
            RankedHand::TwoPair(_) => 2,
            RankedHand::ThreeOfAKind(_) => 3,
            RankedHand::Straight(_) => 4,
            RankedHand::Flush(_) => 5,
            RankedHand::FullHouse(_) => 6,
            RankedHand::FourOfAKind(_) => 7,
            RankedHand::StraightFlush(_) => 8,
        }
    }

    fn tiebreaker(&self) -> &Vec<u8> {
        match self {
            RankedHand::HighCard(tiebreakers)
            | RankedHand::Pair(tiebreakers)
            | RankedHand::TwoPair(tiebreakers)
            | RankedHand::ThreeOfAKind(tiebreakers)
            | RankedHand::Straight(tiebreakers)
            | RankedHand::Flush(tiebreakers)
            | RankedHand::FullHouse(tiebreakers)
            | RankedHand::FourOfAKind(tiebreakers)
            | RankedHand::StraightFlush(tiebreakers) => tiebreakers,
        }
    }
}

impl PartialEq for RankedHand {
    fn eq(&self, other: &Self) -> bool {
        if self.rank_ord() != other.rank_ord() {
            return false;
        }

        self.tiebreaker().eq(other.tiebreaker())
    }
}

impl PartialOrd for RankedHand {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for RankedHand {
    fn cmp(&self, other: &Self) -> Ordering {
        if self.rank_ord() != other.rank_ord() {
            return self.rank_ord().cmp(&other.rank_ord());
        }

        self.tiebreaker().cmp(other.tiebreaker())
    }
}

#[derive(Debug)]
struct ParseHandError;

impl FromStr for RankedHand {
    type Err = ParseHandError;

    fn from_str(str_repr: &str) -> Result<Self, Self::Err> {
        let cards = str_repr
            .split_whitespace()
            .map(|card| card.parse().unwrap())
            .collect::<Vec<Card>>();

        Ok(RankedHand::new(cards))
    }
}

#[derive(Eq, PartialEq, Debug)]
struct Card {
    value: u8,
    suit: Suit,
}

impl Card {
    fn new(value: u8, suit: Suit) -> Self {
        Card { value, suit }
    }
}

#[derive(Debug)]
struct ParseCardError;

impl FromStr for Card {
    type Err = ParseCardError;

    fn from_str(str_repr: &str) -> Result<Self, Self::Err> {
        let suit = Suit::try_from(str_repr.chars().last().unwrap())?;

        if str_repr.len() == 3 {
            return Ok(Card::new(10u8, suit));
        }

        let value_char = str_repr.chars().next().unwrap();

        if let Some(num) = value_char.to_digit(10) {
            return Ok(Card::new(num as u8, suit));
        }

        let value = match value_char {
            'A' => 14,
            'K' => 13,
            'Q' => 12,
            'J' => 11,
            _ => return Err(ParseCardError),
        };

        Ok(Card::new(value, suit))
    }
}

#[derive(Eq, PartialEq, Debug)]
enum Suit {
    Diamonds,
    Clubs,
    Hearts,
    Spades,
}

impl TryFrom<char> for Suit {
    type Error = ParseCardError;

    fn try_from(str_repr: char) -> Result<Self, Self::Error> {
        match str_repr {
            'D' => Ok(Diamonds),
            'H' => Ok(Hearts),
            'C' => Ok(Clubs),
            'S' => Ok(Spades),
            _ => Err(ParseCardError),
        }
    }
}
