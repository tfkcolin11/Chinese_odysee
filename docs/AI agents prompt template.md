Okay, let's design distinct AI "Agents" using the LLM (like Gemini) for different tasks within your backend. This approach compartmentalizes the AI's responsibilities, making the system potentially easier to manage and refine. Each agent will have a specific prompt tailored to its function.

And you are absolutely correct: **As long as the backend adheres to the established API contract, changes in the *internal implementation* (like introducing these AI agents or modifying their logic) will *not* affect the frontend.** The frontend only cares about sending requests and receiving responses in the agreed-upon format defined by the API specification.

---

**Conceptual Backend Flow with Agents:**

1.  User submits input via Flutter App -> API Call (`POST /conversations/{id}/turns`).
2.  Backend receives the request.
3.  Backend calls **Analysis Agent** with user input, context, HSK level.
4.  Analysis Agent returns structured feedback (errors, correct usage, goal progress assessment).
5.  Backend processes feedback: updates score, logs errors/successes to DB (potentially affecting mastery scores later or immediately).
6.  Backend calls **Conversation Agent** with history, context, HSK level, (optionally) analysis results, and user input.
7.  Conversation Agent returns the AI's next response text (potentially flagging new words).
8.  Backend processes AI response: checks for flagged words, saves them to `UserSavedWords` if needed.
9.  Backend constructs the API response (containing AI's turn text, user feedback, score updates) adhering to the contract.
10. Backend sends response -> Flutter App displays it.
11. (Periodically or after conversation end) Backend calls **Mastery & Recommendation Agent** with user performance summary.
12. Mastery Agent returns suggested mastery updates and recommendations.
13. Backend updates `UserMastery...` tables and potentially stores recommendations for `/recommendations` API.

---

**AI Agents and Prompts:**

**Agent 1: Conversation Agent**

*   **Goal:** Generate the AI's next conversational turn, staying in character, adhering to the scenario and HSK level, and potentially introducing necessary out-of-level words correctly.
*   **Trigger:** After receiving validated user input and potentially after analysis.
*   **Input Data (Provided by Backend):**
    *   `target_hsk_level`: (e.g., 3)
    *   `user_proficiency_hint`: (e.g., "beginner", "intermediate", "advanced" - based on overall mastery within the level)
    *   `scenario_description`: (e.g., "User wants to order a coffee at a cafe. AI is the barista.")
    *   `ai_hidden_goal`: (e.g., "Try to upsell a pastry to the user.")
    *   `conversation_history`: (Last N turns, formatted clearly, e.g., `User: ... \n AI: ...`)
    *   `user_last_input`: (The validated text from the user)
*   **Prompt:**

```text
# ROLE: AI Language Partner (Chinese Tutor)

# CONTEXT:
You are role-playing as described in the scenario. Engage the user in a natural conversation in Mandarin Chinese.
- Scenario: {{scenario_description}}
- Your Secret Objective: {{ai_hidden_goal}} (Guide the conversation subtly towards this if possible, but prioritize natural flow).
- Target HSK Level for Vocabulary & Grammar: {{target_hsk_level}}
- User's Level within HSK {{target_hsk_level}}: {{user_proficiency_hint}} (Adjust complexity slightly based on this hint if appropriate, but stay mostly within HSK {{target_hsk_level}})

# HISTORY (Last few turns):
{{conversation_history}}
User: {{user_last_input}}

# TASK:
Generate your *next* response as the AI character in Mandarin Chinese.
1.  **Adhere Strictly to HSK {{target_hsk_level}}**: Use vocabulary and grammar primarily from HSK Level {{target_hsk_level}} or below.
2.  **Out-of-Level Words**: If using a word *significantly above* HSK {{target_hsk_level}} is absolutely necessary for natural conversation or the scenario, you MUST flag it. Use the EXACT format: `[FLAGGED_WORD: {word_characters}|{pinyin}|{contextual_meaning_in_english}|{example_sentence_in_chinese_using_word}]`. Use this format ONLY ONCE per response if needed. Do NOT flag words from HSK {{target_hsk_level}} or below.
3.  **Natural Flow**: Your response should follow logically from the user's last input and the conversation history.
4.  **Engage**: Keep the conversation going. Ask questions or make statements that encourage the user to respond using HSK {{target_hsk_level}} concepts.
5.  **Be Concise**: Keep your response relatively brief and conversational.

# RESPONSE:
(Your Mandarin Chinese response here, potentially containing one flagged word)
```

**Agent 2: Analysis Agent**

*   **Goal:** Evaluate the user's *most recent* input for correctness (grammar, vocab) and relevance against the target HSK level and scenario context. Provide structured feedback.
*   **Trigger:** Immediately after receiving validated user input, before calling the Conversation Agent.
*   **Input Data (Provided by Backend):**
    *   `user_input_text`: (The validated text from the user)
    *   `target_hsk_level`: (e.g., 3)
    *   `scenario_context`: (Brief description)
    *   `ai_hidden_goal`: (Description)
    *   `conversation_history`: (Last N turns for context)
    *   (Optional) `relevant_hsk_grammar_points`: [List of key grammar point names/IDs for this level]
    *   (Optional) `relevant_hsk_vocabulary`: [List of key vocabulary words for this level]
*   **Prompt:**

```text
# ROLE: Language Proficiency Evaluator

# CONTEXT:
Analyze the following user input provided in a Mandarin Chinese conversation simulation.
- Target HSK Level for Evaluation: {{target_hsk_level}}
- Scenario Context: {{scenario_context}}
- Conversation Goal (for relevance check): {{ai_hidden_goal}}
- Conversation History (for context):
{{conversation_history}}

# USER INPUT TO ANALYZE:
"{{user_input_text}}"

# TASK:
Evaluate the user's input based *only* on HSK Level {{target_hsk_level}} standards and the conversation context. Provide your analysis in JSON format.
1.  **Grammar Analysis**: Identify specific grammatical errors relevant to HSK {{target_hsk_level}} or fundamental Chinese grammar. Note correct usage of key HSK {{target_hsk_level}} grammar points if observed.
2.  **Vocabulary Analysis**: Identify misused vocabulary or use of words significantly *below* HSK {{target_hsk_level}} where a level-appropriate word exists and would be more natural. Note correct usage of key HSK {{target_hsk_level}} vocabulary. Do NOT penalize for using words *above* the target level if used correctly.
3.  **Relevance Analysis**: Assess if the input is relevant to the ongoing conversation and the scenario goal.
4.  **Score Suggestion**: Based on the analysis, suggest a small score adjustment (-2 for major error, -1 minor error, 0 neutral, +1 good usage, +2 excellent/complex usage for level).
5.  **Goal Progress**: Briefly assess if the user's input moves towards, away from, or is neutral regarding the `ai_hidden_goal`.

# OUTPUT FORMAT (Return ONLY valid JSON):
{
  "analysis_target_hsk": {{target_hsk_level}},
  "errors": [
    {
      "type": "grammar" | "vocabulary" | "relevance",
      "item": "specific point/word/concept", // e.g., "了 particle misuse", "word: 猫", "off-topic"
      "description": "Brief explanation of the error.",
      "suggestion": "Optional brief suggestion for correction." // e.g., "Should use 在", "Perhaps meant 狗?", "Try to focus on ordering."
    }
    // Add more error objects if multiple distinct errors found
  ],
  "correct_usage": [
    {
      "type": "grammar" | "vocabulary",
      "item": "specific point/word" // e.g., "Measure word: 杯", "word: 咖啡"
    }
    // Add more correct usage objects if relevant key items used well
  ],
  "goal_progress_assessment": "positive" | "negative" | "neutral" | "achieved",
  "suggested_score_adjustment": -2 | -1 | 0 | +1 | +2
}

```

**Agent 3: Mastery & Recommendation Agent**

*   **Goal:** Analyze summarized user performance data (from the database) to deduce patterns of weakness/strength, suggest updates to mastery scores, and recommend targeted practice.
*   **Trigger:** Periodically (e.g., after a conversation ends, or daily). Not necessarily real-time during a turn.
*   **Input Data (Provided by Backend):**
    *   `user_id`: (User identifier)
    *   `target_hsk_level`: (The level being analyzed)
    *   `performance_summary`: { // Data aggregated by the backend from DB
        `recent_grammar_errors`: [{"grammar_point_id": "...", "name": "...", "count": N}, ...],
        `recent_vocab_errors`: [{"vocabulary_id": "...", "word": "...", "count": N}, ...],
        `recent_grammar_successes`: [{"grammar_point_id": "...", "name": "...", "count": N}, ...],
        `recent_vocab_successes`: [{"vocabulary_id": "...", "word": "...", "count": N}, ...],
        `low_mastery_grammar`: [{"grammar_point_id": "...", "name": "...", "score": 0.X}, ...], // Items with score < threshold
        `low_mastery_vocab`: [{"vocabulary_id": "...", "word": "...", "score": 0.X}, ...] // Items with score < threshold
    }
*   **Prompt:**

```text
# ROLE: AI Learning Advisor

# CONTEXT:
Analyze the provided performance summary for User {{user_id}} regarding their proficiency in HSK Level {{target_hsk_level}}.

# PERFORMANCE SUMMARY:
{{performance_summary_json}}

# TASK:
Based *strictly* on the provided summary data:
1.  **Identify Weaknesses**: Pinpoint 1-3 specific grammar points or vocabulary topics/clusters where the user shows consistent errors or low mastery scores.
2.  **Suggest Mastery Adjustments (Optional & Conservative)**: If the data shows a very strong, recent pattern (e.g., multiple errors on a previously high-mastery item, or consistent success on a low-mastery item), suggest a minor adjustment (+/- 0.05 or +/- 0.1) to the mastery score for that specific item. Be conservative.
3.  **Recommend Practice**: Suggest 1-2 predefined scenario *types* (e.g., "Shopping", "Making Appointments", "Describing Objects") or specific grammar/vocabulary focus areas that would directly help the user practice the identified weaknesses.

# OUTPUT FORMAT (Return ONLY valid JSON):
{
  "analysis_target_hsk": {{target_hsk_level}},
  "identified_weaknesses": [
    {
      "type": "grammar" | "vocabulary",
      "item_id": "associated_id_if_available", // e.g., grammar_point_id or representative vocab_id
      "description": "Name or description of the weak area (e.g., 'Using 把 structure', 'Food vocabulary')"
    }
    // Max 3 items
  ],
  "suggested_mastery_adjustments": [
    {
      "item_type": "grammar" | "vocabulary",
      "item_id": "id_of_item_to_adjust",
      "suggested_adjustment": 0.05 | 0.1 | -0.05 | -0.1 // The proposed change
    }
    // Only if strong evidence exists in summary
  ],
  "practice_recommendations": [
    {
      "type": "scenario_type" | "grammar_focus" | "vocab_focus",
      "recommendation": "Name or description (e.g., 'Practice scenarios involving asking for directions', 'Focus on time expressions', 'Review clothing vocabulary')"
    }
    // Max 2-3 recommendations
  ]
}
```

By structuring the AI's tasks into these agents with specific prompts and defined JSON outputs (where applicable), the backend can reliably interact with the LLM, process its judgments, update the database, and maintain the stable API contract with the Flutter frontend.