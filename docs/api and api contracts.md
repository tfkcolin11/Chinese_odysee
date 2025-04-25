Okay, let's define the API endpoints and their contracts using the OpenAPI 3.0 specification format (represented here in YAML-like structure for clarity). This defines the agreement between your Flutter frontend and the backend.

We'll assume:

*   **Base URL:** `https://your-api-domain.com/v1`
*   **Authentication:** All protected endpoints require a `Authorization: Bearer <Firebase_JWT_Token>` header.
*   **Standard Success Response:** `200 OK` unless otherwise specified (e.g., `201 Created`).
*   **Standard Error Response Format:**
    ```json
    {
      "error": {
        "code": "ERROR_CODE_STRING", // e.g., "INVALID_INPUT", "NOT_FOUND", "UNAUTHENTICATED"
        "message": "User-friendly error description or details.",
        "details": {} // Optional structured details
      }
    }
    ```
    Common error codes: `400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `500 Internal Server Error`.

---

**API Specification (Conceptual OpenAPI YAML)**

```yaml
openapi: 3.0.0
info:
  title: HSK Conversational Learning App API
  version: 1.0.0
  description: API for the Flutter HSK learning app powered by Gemini.

servers:
  - url: https://your-api-domain.com/v1

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    # ----------- Common Objects -----------
    ErrorResponse:
      type: object
      properties:
        error:
          type: object
          properties:
            code:
              type: string
            message:
              type: string
            details:
              type: object
              additionalProperties: true # Allows for flexible error details

    UserProfile:
      type: object
      properties:
        userId:
          type: string
          format: uuid # Or string matching Firebase UID
        email:
          type: string
          format: email
        displayName:
          type: string
          nullable: true
        createdAt:
          type: string
          format: date-time
        lastLoginAt:
          type: string
          format: date-time
          nullable: true

    UserSettings:
      type: object
      properties:
        ttsEnabled:
          type: boolean
          default: true
        preferredInputMode:
          type: string
          enum: [text, voice]
          default: text
        # Add other settings as needed

    HskLevel:
      type: object
      properties:
        hskLevelId:
          type: integer
          example: 1
        name:
          type: string
          example: "HSK Level 1"
        description:
          type: string
          nullable: true

    GrammarPoint:
      type: object
      properties:
        grammarPointId:
          type: string # UUID or Int depending on DB model
        hskLevelId:
          type: integer
        name:
          type: string
        descriptionHtml:
          type: string
          nullable: true
        exampleSentenceChinese:
          type: string
          nullable: true
        exampleSentencePinyin:
          type: string
          nullable: true
        exampleSentenceTranslation:
          type: string
          nullable: true

    VocabularyItem:
      type: object
      properties:
        vocabularyId:
          type: string # UUID or Int
        hskLevelId:
          type: integer
        characters:
          type: string
        pinyin:
          type: string
        englishTranslation:
          type: string
        partOfSpeech:
          type: string
          nullable: true
        audioPronunciationUrl:
          type: string
          format: url
          nullable: true

    MasteryItem:
      type: object
      properties:
        itemId: # Corresponds to grammarPointId or vocabularyId
          type: string
        masteryScore:
          type: number
          format: float
          minimum: 0
          maximum: 1
        timesEncountered:
          type: integer
        timesCorrect:
          type: integer
        lastPracticedAt:
          type: string
          format: date-time
          nullable: true

    SavedWord:
      type: object
      properties:
        savedWordId:
          type: string # UUID
        wordCharacters:
          type: string
        wordPinyin:
          type: string
          nullable: true
        contextualMeaning:
          type: string
        exampleUsage:
          type: string
        sourceHskLevel:
          type: integer
          nullable: true
        addedAt:
          type: string
          format: date-time
        conversationId: # Reference to where it was learned
          type: string
          format: uuid

    Scenario:
      type: object
      properties:
        scenarioId:
          type: string
          format: uuid
        name:
          type: string
        description:
          type: string
        isPredefined:
          type: boolean
        suggestedHskLevel:
          type: integer
          nullable: true
        createdByUserId:
          type: string
          format: uuid
          nullable: true # Null if predefined
        createdAt:
          type: string
          format: date-time
        lastUsedAt:
          type: string
          format: date-time
          nullable: true

    Conversation:
      type: object
      properties:
        conversationId:
          type: string
          format: uuid
        userId:
          type: string
          format: uuid
        scenarioId:
          type: string
          format: uuid
        scenarioName: # Denormalized for convenience
          type: string
        hskLevelPlayed:
          type: integer
        startedAt:
          type: string
          format: date-time
        endedAt:
          type: string
          format: date-time
          nullable: true
        currentScore:
          type: integer
        finalScore:
          type: integer
          nullable: true
        outcomeStatus:
          type: string
          enum: [Pending, Achieved, Failed, Abandoned]
        # Maybe include first few turns or last turn for context

    ConversationTurn:
      type: object
      properties:
        turnId:
          type: string # UUID or BigInt
        turnNumber:
          type: integer
        timestamp:
          type: string
          format: date-time
        speaker:
          type: string
          enum: [user, ai]
        inputText: # User validated text or AI response text
          type: string
        inputMode: # Only for user turns
          type: string
          enum: [text, voice]
          nullable: true
        # Data about analysis could be added here if needed immediately
        # e.g., identifiedErrors: array, scoreChange: integer
        # Alternatively, this analysis affects the overall Conversation score/state

    TurnAnalysisFeedback: # Included in response to user submitting a turn
      type: object
      properties:
        scoreChange:
          type: integer
        errors:
          type: array
          items:
            type: object
            properties:
              type:
                type: string
                enum: [grammar, vocabulary, relevance, fluency]
              message:
                type: string # Description of the error
              suggestion:
                type: string
                nullable: true
        correctGrammarPoints:
          type: array
          items:
            type: string # grammarPointId
        correctVocabulary:
          type: array
          items:
            type: string # vocabularyId
        newlySavedWord: # Details if AI introduced and saved a new word in *its* response
          $ref: '#/components/schemas/SavedWord'
          nullable: true

# ----------- API Paths -----------
paths:
  # --- User & Settings ---
  /users/me:
    get:
      summary: Get current user profile
      security:
        - bearerAuth: []
      responses:
        '200':
          description: User profile data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserProfile'
        '401':
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'

  /settings:
    get:
      summary: Get user settings
      security:
        - bearerAuth: []
      responses:
        '200':
          description: User settings data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserSettings'
        '401':
          description: Unauthorized
    put:
      summary: Update user settings
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserSettings'
      responses:
        '200':
          description: Settings updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserSettings'
        '400':
          description: Invalid input
        '401':
          description: Unauthorized

  # --- Static Data ---
  /hsk-levels:
    get:
      summary: Get all available HSK levels
      # No auth needed for static data potentially
      responses:
        '200':
          description: List of HSK levels
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/HskLevel'

  /grammar-points:
    get:
      summary: Get grammar points, optionally filtered by HSK level
      parameters:
        - name: hskLevelId
          in: query
          required: false
          schema:
            type: integer
      responses:
        '200':
          description: List of grammar points
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/GrammarPoint'

  /vocabulary:
    get:
      summary: Get vocabulary, optionally filtered by HSK level
      parameters:
        - name: hskLevelId
          in: query
          required: false
          schema:
            type: integer
        # Add pagination parameters (page, limit) for large lists
        - name: page
          in: query
          required: false
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          required: false
          schema:
            type: integer
            default: 50
      responses:
        '200':
          description: Paginated list of vocabulary items
          content:
            application/json:
              schema:
                type: object
                properties:
                  items:
                    type: array
                    items:
                      $ref: '#/components/schemas/VocabularyItem'
                  total:
                    type: integer
                  page:
                    type: integer
                  limit:
                    type: integer

  # --- User Progress ---
  /mastery/grammar:
    get:
      summary: Get user mastery for grammar points, filtered by HSK level
      security:
        - bearerAuth: []
      parameters:
        - name: hskLevelId
          in: query
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: List of grammar mastery items for the user
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/MasteryItem'
        '401':
          description: Unauthorized

  /mastery/vocabulary:
    get:
      summary: Get user mastery for vocabulary, filtered by HSK level
      security:
        - bearerAuth: []
      parameters:
        - name: hskLevelId
          in: query
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: List of vocabulary mastery items for the user
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/MasteryItem'
        '401':
          description: Unauthorized

  /saved-words:
    get:
      summary: Get words saved by the user (learned out-of-level)
      security:
        - bearerAuth: []
      parameters: # Add pagination if list can grow large
        - name: page
          in: query
          required: false
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          required: false
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: Paginated list of saved words
          content:
            application/json:
              schema:
                type: object
                properties:
                  items:
                    type: array
                    items:
                      $ref: '#/components/schemas/SavedWord'
                  total:
                    type: integer
                  page:
                    type: integer
                  limit:
                    type: integer
        '401':
          description: Unauthorized

  # --- Scenarios ---
  /scenarios:
    get:
      summary: List scenarios (predefined and user-created)
      security:
        - bearerAuth: []
      parameters:
        - name: type
          in: query
          required: false
          schema:
            type: string
            enum: [predefined, user, all]
            default: all
      responses:
        '200':
          description: List of scenarios
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Scenario'
        '401':
          description: Unauthorized
    post:
      summary: Create a new custom scenario
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name, description]
              properties:
                name:
                  type: string
                description:
                  type: string
                suggestedHskLevel: # Optional suggestion by user
                  type: integer
                  nullable: true
      responses:
        '201':
          description: Scenario created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Scenario'
        '400':
          description: Invalid input
        '401':
          description: Unauthorized

  /scenarios/{scenarioId}:
    get:
      summary: Get details of a specific scenario
      parameters:
        - name: scenarioId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Scenario details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Scenario'
        '404':
          description: Scenario not found
    # PUT/PATCH/DELETE for user-created scenarios could be added if needed

  # --- Conversations (Game Sessions) ---
  /conversations:
    post:
      summary: Start a new conversation/game session
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [scenarioId, hskLevelPlayed]
              properties:
                scenarioId:
                  type: string
                  format: uuid
                hskLevelPlayed:
                  type: integer
                # Option to reference a previously saved instance for inspiration
                inspirationSavedInstanceId:
                  type: string
                  format: uuid
                  nullable: true
      responses:
        '201':
          description: Conversation started, returns initial state and first AI message
          content:
            application/json:
              schema:
                type: object
                properties:
                  conversation:
                    $ref: '#/components/schemas/Conversation'
                  initialTurn: # The AI's first turn
                    $ref: '#/components/schemas/ConversationTurn'
        '400':
          description: Invalid input (e.g., bad scenarioId)
        '401':
          description: Unauthorized
        '404':
          description: Scenario not found

  /conversations/{conversationId}:
    get:
      summary: Get the current state of a conversation
      security:
        - bearerAuth: []
      parameters:
        - name: conversationId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Current conversation state
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Conversation'
        '401':
          description: Unauthorized
        '403':
          description: Forbidden (user does not own this conversation)
        '404':
          description: Conversation not found

  /conversations/{conversationId}/turns:
    get:
      summary: Get history of turns for a conversation (optional pagination)
      security:
        - bearerAuth: []
      parameters:
        - name: conversationId
          in: path
          required: true
          schema:
            type: string
            format: uuid
        # Add pagination (e.g., ?limit=20&beforeTurnId=...)
      responses:
        '200':
          description: List of conversation turns
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/ConversationTurn'
        '401':
          description: Unauthorized
        '403':
          description: Forbidden
        '404':
          description: Conversation not found
    post:
      summary: Submit user's turn and get AI's response
      security:
        - bearerAuth: []
      parameters:
        - name: conversationId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [inputText, inputMode]
              properties:
                inputText: # The validated text from user (typed or voice transcript)
                  type: string
                inputMode:
                  type: string
                  enum: [text, voice]
      responses:
        '200': # Or 201 Created for the new AI turn resource? 200 is fine for request/response.
          description: AI response turn and analysis of user's submitted turn
          content:
            application/json:
              schema:
                type: object
                properties:
                  aiTurn: # The AI's response turn
                    $ref: '#/components/schemas/ConversationTurn'
                  userTurnFeedback: # Analysis of the turn the user just submitted
                    $ref: '#/components/schemas/TurnAnalysisFeedback'
                  updatedConversationScore: # Optional: Current overall score after this exchange
                     type: integer
        '400':
          description: Invalid input (e.g., empty text)
        '401':
          description: Unauthorized
        '403':
          description: Forbidden
        '404':
          description: Conversation not found
        '409': # Conflict State - e.g., Conversation already ended
          description: Conversation is not in a state to accept turns


  /conversations/{conversationId}/end:
    post: # Or PUT/PATCH? POST is okay for triggering an action.
      summary: Explicitly end a conversation (e.g., user quits)
      security:
        - bearerAuth: []
      parameters:
        - name: conversationId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Conversation ended successfully, returns final state
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Conversation' # With updated status and final score
        '401':
          description: Unauthorized
        '403':
          description: Forbidden
        '404':
          description: Conversation not found

  /conversations/{conversationId}/save:
    post:
      summary: Save the current state/outcome of this conversation instance for future reference
      security:
        - bearerAuth: []
      parameters:
        - name: conversationId
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody: # Optional: Allow user to name this saved instance
        content:
          application/json:
            schema:
              type: object
              properties:
                savedInstanceName:
                  type: string
      responses:
        '200':
          description: Conversation instance saved successfully
          content:
            application/json:
              schema: # May return the updated Conversation object showing it's saved
                 $ref: '#/components/schemas/Conversation'
        '401':
          description: Unauthorized
        '403':
          description: Forbidden
        '404':
          description: Conversation not found

  # --- Utility Services (STT/TTS - Simplified direct handling) ---
  # Note: For production, consider signed URLs + GCS for efficiency/cost.

  /stt:
    post:
      summary: Process audio data for Speech-to-Text (local STT bypasses this)
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          # Option 1: Base64 encoded audio
          application/json:
             schema:
               type: object
               required: [audioContent, languageCode]
               properties:
                 audioContent: # Base64 encoded string of audio data
                   type: string
                   format: byte
                 languageCode: # e.g., "cmn-CN"
                   type: string
          # Option 2: Multipart form data (better for large files)
          # multipart/form-data:
          #   schema:
          #     type: object
          #     properties:
          #       audioFile:
          #         type: string
          #         format: binary
          #       languageCode:
          #         type: string
      responses:
        '200':
          description: Transcription result
          content:
            application/json:
              schema:
                type: object
                properties:
                  transcript:
                    type: string
                  confidence: # Optional
                    type: number
                    format: float
        '400':
          description: Invalid input (e.g., bad audio format)
        '401':
          description: Unauthorized

  /tts:
    post:
      summary: Generate audio from text (local TTS bypasses this)
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [text, languageCode]
              properties:
                text:
                  type: string
                languageCode: # e.g., "cmn-CN"
                  type: string
                voiceName: # Optional: Specify preferred voice
                  type: string
                  nullable: true
      responses:
        '200':
          description: Returns URL to the generated audio file
          content:
            application/json:
              schema:
                type: object
                properties:
                  audioUrl: # Signed URL to audio file in GCS
                    type: string
                    format: url
        '400':
          description: Invalid input
        '401':
          description: Unauthorized

  # --- Learning Recommendations ---
  /recommendations:
    get:
      summary: Get personalized learning recommendations (scenarios, grammar, vocab)
      security:
        - bearerAuth: []
      parameters:
        - name: type
          in: query
          required: false
          schema:
            type: string
            enum: [scenario, grammar, vocabulary] # Request specific type or get mixed
      responses:
        '200':
          description: List of recommended items/scenarios for practice
          content:
            application/json:
              schema:
                type: object
                properties:
                  scenarios:
                    type: array
                    items:
                      $ref: '#/components/schemas/Scenario' # Suggested scenarios
                  grammarPoints:
                    type: array
                    items:
                      $ref: '#/components/schemas/GrammarPoint' # Suggested points
                  vocabulary:
                    type: array
                    items:
                      $ref: '#/components/schemas/VocabularyItem' # Suggested words
        '401':
          description: Unauthorized

```

**Key Considerations:**

1.  **STT/TTS Implementation:** The `/stt` and `/tts` endpoints assume direct data transfer. For better performance and cost (especially with large audio files), the backend should ideally provide signed URLs for the frontend to upload (STT) or download (TTS) directly from Cloud Storage. The API calls would then be for *orchestrating* this process (e.g., `POST /stt/initiateUpload` -> returns signed URL; `POST /tts` -> returns signed URL).
2.  **Real-time:** This model is RESTful (request/response). For a more dynamic feel (e.g., seeing the AI "typing"), you might consider WebSockets later for the conversation part, but REST is a solid starting point.
3.  **Mastery Updates:** Mastery scores (`/mastery/*`) are updated *asynchronously* by the backend after processing a `POST /conversations/{conversationId}/turns` request. The frontend fetches the latest mastery scores when needed.
4.  **Error Granularity:** The `TurnAnalysisFeedback` provides immediate feedback on the user's last turn. More detailed historical error logging could be added if required for deeper analytics.
5.  **Pagination:** Added basic pagination examples to `/vocabulary` and `/saved-words`. Apply this pattern to other list endpoints (`/scenarios`, `/conversations/{id}/turns`, `/mastery/*`) as needed.
6.  **Idempotency:** Consider using idempotency keys for `POST` requests that shouldn't be accidentally duplicated (like starting a conversation or submitting a turn).
7.  **Versioning:** The `/v1` in the base URL allows for future API versions without breaking existing clients.

This detailed contract provides a clear separation of concerns, allowing frontend and backend teams to develop independently while ensuring compatibility.