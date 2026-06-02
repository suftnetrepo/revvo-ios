# revvo-ios

Minimal Swift implementation for an AI flashcard app on iOS.

## Included

- `FlashcardService`: validates topic input, requests AI JSON, and parses flashcards.
- `LocalAIFlashcardGenerator`: local mock AI generator for development/testing.
- `FlashcardListView` (SwiftUI, when available): topic input + generated flashcards with show/hide answer.

## Run tests

```bash
swift test
```
