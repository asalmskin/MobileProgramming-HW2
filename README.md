# Mastermind (Swift Terminal Version)

This is a terminal-based implementation of the Mastermind game written in Swift, developed for the Mobile Programming course assignment.

## How to Play

- The program generates a 4-digit secret code using digits 1–6.
- After each guess, feedback is provided:
  - `B` (Black): Correct digit in the correct position.
  - `W` (White): Correct digit in the wrong position.
- The game ends when the player guesses the full code (4 black pegs) or types `exit`.

## Run Instructions

Ensure Swift is installed, then run:

```bash
swift main.swift
