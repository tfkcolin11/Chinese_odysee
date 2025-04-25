**Key:**

*   `PK`: Primary Key
*   `FK`: Foreign Key
*   `NN`: Not Null
*   `U`: Unique

---

**Core Tables:**

1.  **Users**
    *   `user_id` (VARCHAR or UUID, PK, NN) - Matches Firebase Auth UID.
    *   `email` (VARCHAR, U, NN) - For login/identification.
    *   `display_name` (VARCHAR, Nullable) - Optional user nickname.
    *   `created_at` (TIMESTAMP, NN) - When the user account was created.
    *   `last_login_at` (TIMESTAMP, Nullable) - Last recorded login time.
    *   `settings_json` (JSON or TEXT, Nullable) - Stores user preferences like TTS enabled, preferred input mode, etc.

2.  **HSKLevels** (Reference Table - Relatively Static)
    *   `hsk_level_id` (INT, PK, NN) - 1, 2, 3, 4, 5, 6.
    *   `name` (VARCHAR, NN) - e.g., "HSK Level 1".
    *   `description` (TEXT, Nullable) - Optional description.

3.  **GrammarPoints** (Reference Table - Populate initially)
    *   `grammar_point_id` (UUID or INT AUTO_INCREMENT, PK, NN)
    *   `hsk_level_id` (INT, FK referencing HSKLevels, NN) - The level this point primarily belongs to.
    *   `name` (VARCHAR, NN) - e.g., "Using 了 (le) for completed actions".
    *   `description_html` (TEXT, Nullable) - Explanation of the grammar point.
    *   `example_sentence_chinese` (TEXT, Nullable)
    *   `example_sentence_pinyin` (TEXT, Nullable)
    *   `example_sentence_translation` (TEXT, Nullable)

4.  **Vocabulary** (Reference Table - Populate initially)
    *   `vocabulary_id` (UUID or INT AUTO_INCREMENT, PK, NN)
    *   `hsk_level_id` (INT, FK referencing HSKLevels, NN) - The level this word primarily belongs to.
    *   `characters` (VARCHAR, NN) - The Chinese characters (e.g., 你好).
    *   `pinyin` (VARCHAR, NN) - e.g., "nǐ hǎo".
    *   `english_translation` (TEXT, NN) - Primary meaning(s).
    *   `part_of_speech` (VARCHAR, Nullable) - e.g., "pronoun", "verb".
    *   `audio_pronunciation_url` (VARCHAR, Nullable) - Link to a standard pronunciation audio file.

**Scenario & Conversation Tables:**

5.  **Scenarios**
    *   `scenario_id` (UUID, PK, NN) - Unique identifier for any scenario.
    *   `created_by_user_id` (VARCHAR or UUID, FK referencing Users, Nullable) - NULL if it's a predefined scenario.
    *   `name` (VARCHAR, NN) - e.g., "Ordering Coffee", "Returning an Item".
    *   `description` (TEXT, NN) - Detailed description of the scenario setup.
    *   `is_predefined` (BOOLEAN, NN, Default: FALSE) - TRUE for system scenarios, FALSE for user-created.
    *   `suggested_hsk_level` (INT, FK referencing HSKLevels, Nullable) - A baseline difficulty suggestion.
    *   `created_at` (TIMESTAMP, NN)
    *   `last_used_at` (TIMESTAMP, Nullable)

6.  **Conversations** (Represents one game session)
    *   `conversation_id` (UUID, PK, NN)
    *   `user_id` (VARCHAR or UUID, FK referencing Users, NN)
    *   `scenario_id` (UUID, FK referencing Scenarios, NN) - The scenario being played.
    *   `hsk_level_played` (INT, FK referencing HSKLevels, NN) - The HSK level selected *for this specific game*.
    *   `started_at` (TIMESTAMP, NN)
    *   `ended_at` (TIMESTAMP, Nullable) - When the game concluded or was abandoned.
    *   `current_score` (INT, NN, Default: 100 or other starting value) - Dynamic score during the game.
    *   `final_score` (INT, Nullable) - Score upon completion.
    *   `ai_hidden_goal_description` (TEXT, Nullable) - Internal text describing the objective the AI wants the user to reach.
    *   `outcome_status` (VARCHAR Enum('Pending', 'Achieved', 'Failed', 'Abandoned'), NN, Default: 'Pending')
    *   `saved_instance_details_json` (JSON or TEXT, Nullable) - If the user explicitly saves *this instance*, store key details (like outcome, key turns) here for the AI to reference later when "reusing" this saved instance. Might include a user-provided name for the save.

7.  **ConversationTurns** (Individual messages within a conversation)
    *   `turn_id` (UUID or BIGINT AUTO_INCREMENT, PK, NN)
    *   `conversation_id` (UUID, FK referencing Conversations, NN)
    *   `turn_number` (INT, NN) - Sequential order within the conversation (e.g., 1, 2, 3...).
    *   `timestamp` (TIMESTAMP, NN)
    *   `speaker` (VARCHAR Enum('user', 'ai'), NN)
    *   `input_mode` (VARCHAR Enum('text', 'voice'), Nullable) - Only relevant if speaker is 'user'.
    *   `user_raw_input` (TEXT, Nullable) - What the user typed or originally said (before validation).
    *   `user_validated_transcript` (TEXT, Nullable) - The text submitted after voice validation.
    *   `ai_response_text` (TEXT, Nullable) - The AI's textual response.
    *   `grammar_points_used_correctly_ids` (JSON or TEXT, Nullable) - List/Array of `grammar_point_id`s identified as used correctly.
    *   `vocabulary_used_correctly_ids` (JSON or TEXT, Nullable) - List/Array of `vocabulary_id`s identified as used correctly.
    *   `identified_errors_json` (JSON or TEXT, Nullable) - Structured data about errors (e.g., `[{type: 'grammar', point_id: 123, description: 'Incorrect particle'}, {type: 'vocab', word: '苹果', suggestion: '香蕉'}]`).
    *   `score_change` (INT, Nullable) - The change in score resulting from this turn (+/-).
    *   `flagged_new_word_id` (UUID, FK referencing UserSavedWords, Nullable) - If this AI turn introduced a new word that was saved.

**User Progress & Learning Tables:**

8.  **UserMasteryGrammar**
    *   `user_id` (VARCHAR or UUID, FK referencing Users, PK, NN)
    *   `grammar_point_id` (UUID or INT, FK referencing GrammarPoints, PK, NN)
    *   `mastery_score` (FLOAT or DECIMAL, NN, Default: 0.0) - e.g., 0.0 to 1.0 representing mastery.
    *   `correct_streak` (INT, NN, Default: 0)
    *   `times_encountered` (INT, NN, Default: 0)
    *   `times_correct` (INT, NN, Default: 0)
    *   `last_practiced_at` (TIMESTAMP, Nullable)
    *   `last_updated_at` (TIMESTAMP, NN)

9.  **UserMasteryVocabulary**
    *   `user_id` (VARCHAR or UUID, FK referencing Users, PK, NN)
    *   `vocabulary_id` (UUID or INT, FK referencing Vocabulary, PK, NN)
    *   `mastery_score` (FLOAT or DECIMAL, NN, Default: 0.0)
    *   `correct_streak` (INT, NN, Default: 0)
    *   `times_encountered` (INT, NN, Default: 0)
    *   `times_correct` (INT, NN, Default: 0)
    *   `last_practiced_at` (TIMESTAMP, Nullable)
    *   `last_updated_at` (TIMESTAMP, NN)

10. **UserSavedWords** (Words learned outside the selected HSK level)
    *   `saved_word_id` (UUID, PK, NN)
    *   `user_id` (VARCHAR or UUID, FK referencing Users, NN)
    *   `conversation_turn_id` (UUID or BIGINT, FK referencing ConversationTurns, NN) - Where the word was first introduced/saved.
    *   `word_characters` (VARCHAR, NN)
    *   `word_pinyin` (VARCHAR, Nullable)
    *   `contextual_meaning` (TEXT, NN) - Meaning *in the context* it was used.
    *   `example_usage` (TEXT, NN) - Example generated by AI based on the situation.
    *   `source_hsk_level` (INT, FK referencing HSKLevels, Nullable) - The level the word *actually* belongs to, if known.
    *   `added_at` (TIMESTAMP, NN)

---

**Notes & Considerations:**

*   **Indexes:** Add indexes on all Foreign Key columns (`user_id`, `scenario_id`, `conversation_id`, `hsk_level_id`, `grammar_point_id`, `vocabulary_id`) and frequently queried columns like timestamps.
*   **JSON/TEXT Fields:** Fields like `identified_errors_json`, `grammar_points_used_correctly_ids`, `vocabulary_used_correctly_ids`, `saved_instance_details_json`, and `settings_json` offer flexibility but make complex SQL queries on their contents difficult. This is where NoSQL shines. In Firestore, these would likely be Maps or Arrays.
*   **Mastery Tables:** Using composite primary keys (`user_id`, `grammar_point_id`) is standard in SQL for this type of mapping table. In Firestore, you might structure this as a subcollection under `Users` or as a top-level collection queried by `user_id` and `grammar_point_id`.
*   **Error Tracking:** The `identified_errors_json` is simplified. You might want a more structured related table for errors if you need very detailed error analysis across all users.
*   **Scalability:** This model is reasonably normalized. For extreme scale (millions of users/conversations), you might need denormalization or specific NoSQL patterns (like sharding implicitly handled by Firestore).
*   **Adaptation to Firestore:**
    *   Each table becomes a top-level Collection (e.g., `users`, `scenarios`, `conversations`).
    *   PKs become Document IDs.
    *   FKs become fields within documents storing the ID of the related document.
    *   `ConversationTurns` could be a subcollection under its parent `Conversation` document.
    *   `UserMastery...` tables could be subcollections under `Users` or top-level collections.
    *   Joins are replaced by multiple reads or slight denormalization (e.g., storing `scenario_name` directly in the `Conversation` document if frequently needed together).

This model provides a comprehensive structure to build upon for your app's data requirements. Remember to adapt it based on the specific query patterns you anticipate and the strengths/weaknesses of your chosen database system (Firestore).