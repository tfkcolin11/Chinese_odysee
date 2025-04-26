# Chinese Odyssey - Freemium Model & Pre-Learning Implementation Plan

## Table of Contents
1. [Overview](#overview)
2. [Feature Requirements](#feature-requirements)
   - [Pre-Conversation Learning](#pre-conversation-learning)
   - [Subscription Plans & Feature Gating](#subscription-plans--feature-gating)
3. [Database Schema Updates](#database-schema-updates)
4. [API Specification Updates](#api-specification-updates)
5. [Frontend Implementation](#frontend-implementation)
6. [Backend Implementation](#backend-implementation)
7. [Testing Strategy](#testing-strategy)
8. [Rollout Plan](#rollout-plan)

## Overview

This document outlines the implementation plan for adding a freemium business model to the Chinese Odyssey app, along with a new Pre-Conversation Learning feature. The plan maintains separation of concerns through a well-defined API contract and ensures a smooth user experience across both free and premium tiers.

## Feature Requirements

### Pre-Conversation Learning

#### Goal
Allow users to optionally review and familiarize themselves with key vocabulary and grammar points relevant to a chosen scenario *before* starting the main conversational practice.

#### User Flow
1. After selecting a scenario (predefined or custom) and target HSK level, the user is presented with two options:
   - "Start Conversation" (Proceeds directly to the existing game flow)
   - "Learn & Practice First" (Navigates to the new Pre-Learning screen)
2. The Pre-Learning screen displays relevant vocabulary and grammar points
3. (Future Enhancement) Include simple interactive practice exercises (e.g., flashcards, basic quizzes) on this screen
4. User can navigate back or proceed to the "Start Conversation" from the Pre-Learning screen

#### Content Generation
- The backend (triggered via API) uses an AI agent (e.g., Gemini) to generate a list of relevant vocabulary (characters, pinyin, translation) and grammar points (name, brief explanation, simple example) based on the selected scenario's description/context and the target HSK level
- Generated content should be cached per scenario/HSK level combination to reduce redundant AI calls and costs

#### Subscription Tier Implications
- **Free Tier:**
  - Access to Pre-Learning for *predefined* scenarios only
  - Limit on the *number* of Pre-Learning generations allowed per day (e.g., 3-5 per day)
- **Premium Tier:**
  - Access to Pre-Learning for *all* scenarios (predefined and custom)
  - *Unlimited* Pre-Learning generations

### Subscription Plans & Feature Gating

#### Goal
Introduce subscription tiers to provide enhanced features for paying users while offering a valuable core experience for free users, ensuring financial sustainability by limiting costly resource usage in the free tier.

#### Tiers
- **Free:** Basic access with limitations on resource-intensive features
- **Premium:** (e.g., Monthly/Annual options) Unlocks limitations and potentially adds exclusive features

#### Feature Gating Strategy
- **Conversation Turns (Core LLM Cost):**
  - *Free:* Limited number of conversational turns per day (e.g., 20-30 turns). Limits reset daily
  - *Premium:* Unlimited conversational turns
- **AI Analysis & Feedback (Analysis Agent Cost):**
  - *Free:* Basic feedback (e.g., simple error flags without detailed AI explanation) or limited detailed analysis requests per day
  - *Premium:* Full, detailed AI-driven analysis and feedback on every relevant turn
- **Pre-Conversation Learning (Generation Agent Cost):**
  - *Free:* Limited generations per day, potentially restricted to predefined scenarios
  - *Premium:* Unlimited generations for all scenarios
- **Custom Scenarios:**
  - *Free:* Limited number of custom scenarios users can create and save (e.g., 3)
  - *Premium:* Unlimited custom scenarios
- **Saved Conversation Instances:**
  - *Free:* Limited number of conversation instances users can save for AI inspiration (e.g., 5)
  - *Premium:* Unlimited saved instances
- **Mastery Tracking & Recommendations:**
  - *Free:* Access to basic mastery scores. Recommendations may be more generic
  - *Premium:* Access to detailed mastery breakdowns and more personalized, AI-driven recommendations
- **Local STT/TTS:** Remains available for all tiers as it doesn't incur direct cloud costs
- **(Future Premium Features):** Advanced practice modes, multi-modal content (if implemented), priority support, etc.

#### Implementation Requirements
- Integration with native platform billing SDKs (App Store Connect In-App Purchases, Google Play Billing Library)
- Secure backend receipt validation to confirm purchases and manage subscription status
- User interface must clearly indicate premium features and provide an easy path to upgrade
- Free tier usage limits must be clearly communicated to the user (e.g., "Turns remaining today: X/30")

## Database Schema Updates

### New Tables

#### UserSubscriptions
- `subscription_id` (UUID, PK, NN)
- `user_id` (VARCHAR or UUID, FK referencing Users, NN)
- `plan_id` (VARCHAR, NN) - Identifier for the plan (e.g., 'free', 'premium_monthly', 'premium_yearly')
- `status` (VARCHAR Enum('active', 'pending', 'expired', 'cancelled', 'in_grace_period'), NN)
- `current_period_start` (TIMESTAMP, Nullable) - Start of the current billing cycle
- `current_period_end` (TIMESTAMP, Nullable) - End of the current billing cycle (or trial end)
- `store` (VARCHAR Enum('apple', 'google', 'none'), NN) - Source of the subscription
- `store_original_transaction_id` (VARCHAR, Nullable, U based on store) - Original purchase identifier
- `store_latest_transaction_id` (VARCHAR, Nullable) - Latest renewal identifier
- `created_at` (TIMESTAMP, NN)
- `updated_at` (TIMESTAMP, NN)

#### ScenarioPreLearningCache
- `cache_id` (UUID, PK, NN)
- `scenario_id` (UUID, FK referencing Scenarios, NN)
- `hsk_level_id` (INT, FK referencing HSKLevels, NN)
- `generated_content_json` (JSON or TEXT, NN) - Stores the generated list of vocab & grammar
- `generated_at` (TIMESTAMP, NN)
- `expires_at` (TIMESTAMP, NN) - Cache expiry timestamp
- **(Index on `scenario_id`, `hsk_level_id`)**

### Modifications to Existing Tables

#### Option 1: Add to Users table (Simpler approach)
- `current_plan_id` (VARCHAR, Default: 'free', NN) - Quick lookup of the current plan
- `daily_turns_used` (INT, Default: 0, NN)
- `daily_prelearn_used` (INT, Default: 0, NN)
- `usage_period_start` (TIMESTAMP, Nullable) - Timestamp when the current daily limit period started (e.g., midnight UTC)
- `custom_scenario_count` (INT, Default: 0, NN) - Track count against free limit
- `saved_instance_count` (INT, Default: 0, NN) - Track count against free limit

#### Option 2: Add UserUsageTracking Table (More scalable approach)
- `tracking_id` (UUID, PK, NN)
- `user_id` (VARCHAR or UUID, FK referencing Users, NN, U per period type)
- `period_type` (VARCHAR Enum('daily', 'total'), NN) - e.g., track daily turns, total scenarios
- `period_start_timestamp` (TIMESTAMP, NN) - e.g., Midnight UTC for daily
- `turns_used` (INT, Default: 0, NN)
- `prelearn_used` (INT, Default: 0, NN)
- `custom_scenarios_created` (INT, Default: 0, NN)
- `instances_saved` (INT, Default: 0, NN)
- `updated_at` (TIMESTAMP, NN)

*Note: We will implement Option 2 for better scalability and separation of concerns.*

## API Specification Updates

### New Schemas

```yaml
components:
  schemas:
    # ... (existing schemas) ...

    PreLearningContent:
      type: object
      properties:
        scenarioId:
          type: string
          format: uuid
        hskLevelId:
          type: integer
        vocabulary:
          type: array
          items:
            type: object
            properties:
              characters:
                type: string
              pinyin:
                type: string
              translation:
                type: string
        grammarPoints:
          type: array
          items:
            type: object
            properties:
              name:
                type: string
              explanation:
                type: string
              example:
                type: string
        generatedAt:
          type: string
          format: date-time

    SubscriptionStatus:
      type: object
      properties:
        userId:
          type: string
          format: uuid
        planId:
          type: string # e.g., 'free', 'premium_monthly'
        status:
          type: string
          enum: [active, pending, expired, cancelled, in_grace_period]
        currentPeriodEnd:
          type: string
          format: date-time
          nullable: true
        # Add other relevant fields like trial status if needed

    ReceiptValidationRequest:
      type: object
      required: [store, receiptData]
      properties:
        store:
          type: string
          enum: [apple, google]
        receiptData: # Store-specific receipt payload (e.g., base64 string for Apple, JSON for Google)
          type: object # Or string depending on format needed
          additionalProperties: true

    UsageLimits: # Optional: Could be part of SubscriptionStatus or UserProfile
      type: object
      properties:
         dailyTurnsLimit:
            type: integer # Or null for unlimited
         dailyTurnsUsed:
            type: integer
         dailyPrelearnLimit:
            type: integer # Or null
         dailyPrelearnUsed:
            type: integer
         customScenarioLimit:
             type: integer # Or null
         customScenarioUsed:
             type: integer
         # etc.
```

### New Endpoints

```yaml
paths:
  # ... (existing paths) ...

  /scenarios/{scenarioId}/pre-learning:
    get:
      summary: Get vocabulary & grammar for pre-conversation learning
      security:
        - bearerAuth: []
      parameters:
        - name: scenarioId
          in: path
          required: true
          schema:
            type: string
            format: uuid
        - name: hskLevelId
          in: query
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Successfully retrieved or generated pre-learning content
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PreLearningContent'
        '401':
          description: Unauthorized
        '402': # Payment Required - Use this if premium needed but user is free
          description: Premium subscription required for this feature/scenario
          content:
             application/json:
               schema:
                 $ref: '#/components/schemas/ErrorResponse' # Code: PREMIUM_REQUIRED
        '403':
          description: Forbidden (e.g., trying to access content not allowed)
        '404':
          description: Scenario not found
        '429': # Too Many Requests - Use this if free user exceeds daily limit
          description: Daily limit for pre-learning generation exceeded for free users
          content:
             application/json:
               schema:
                 $ref: '#/components/schemas/ErrorResponse' # Code: USAGE_LIMIT_EXCEEDED
        '500':
           description: Internal server error (e.g., AI generation failed)

  /users/me/subscription:
    get:
      summary: Get the current user's subscription status
      security:
        - bearerAuth: []
      responses:
        '200':
          description: User's current subscription details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SubscriptionStatus'
        '401':
          description: Unauthorized

  /subscriptions/validate-receipt:
    post:
      summary: Validate a purchase receipt from Apple/Google Play Store
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ReceiptValidationRequest'
      responses:
        '200':
          description: Receipt validated successfully, subscription updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SubscriptionStatus' # Return updated status
        '400':
          description: Invalid receipt data or request format
        '401':
          description: Unauthorized
        '409': # Conflict - e.g., receipt already processed
           description: Receipt validation conflict or error
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/ErrorResponse'
        '500':
           description: Internal server error (e.g., failed to communicate with store API)
```

### Modifications to Existing Endpoints

- **`POST /conversations/{conversationId}/turns`**:
  - **Add Check:** Before processing the turn and calling AI agents, check the user's subscription status and daily turn usage
  - **New Responses:**
    - `402 Payment Required`: If the feature requires premium and user is free
    - `429 Too Many Requests`: If the free user has exceeded their daily turn limit
- **`POST /conversations` (Start Conversation)**:
  - **Add Check:** Check if starting certain types of conversations requires premium
- **`POST /scenarios` (Create Custom Scenario)**:
  - **Add Check:** Check user's plan and custom scenario count
  - **New Responses:**
    - `402 Payment Required`: If requires premium
    - `429 Too Many Requests`: If free user exceeds limit
- **`POST /conversations/{conversationId}/save` (Save Instance)**:
  - **Add Check:** Check user's plan and saved instance count
  - **New Responses:**
    - `402 Payment Required`: If requires premium
    - `429 Too Many Requests`: If free user exceeds limit
- **`/recommendations`**:
  - **Add Check:** Check subscription status for advanced recommendations

## Frontend Implementation

### New Screens

#### Pre-Learning Screen
- **Path:** `lib/ui/screens/pre_learning_screen.dart`
- **Components:**
  - Header with scenario name and HSK level
  - Vocabulary section with list of words (characters, pinyin, translation)
  - Grammar points section with explanations and examples
  - Navigation buttons (Back, Start Conversation)
  - Loading state for content generation
  - Error handling for API failures or limits

#### Subscription Screen
- **Path:** `lib/ui/screens/subscription_screen.dart`
- **Components:**
  - Plan comparison table/cards
  - Pricing information
  - Subscribe buttons for different plans
  - Current subscription status display
  - Restore purchases option
  - Terms and privacy policy links

### UI Updates

#### Scenario Selection Screen
- Add "Learn & Practice First" button alongside "Start Conversation"
- Add premium indicators for features requiring subscription
- Add usage limit indicators for free users

#### Home Screen
- Add subscription status indicator
- Add remaining daily limits display for free users
- Add upgrade prompt for free users

#### Settings Screen
- Add subscription management section
- Add usage statistics display

### New Models

#### PreLearningContent
- **Path:** `lib/core/models/pre_learning_content.dart`
- **Properties:**
  - Scenario ID
  - HSK Level ID
  - List of vocabulary items (characters, pinyin, translation)
  - List of grammar points (name, explanation, example)
  - Generation timestamp

#### SubscriptionStatus
- **Path:** `lib/core/models/subscription_status.dart`
- **Properties:**
  - Plan ID
  - Status
  - Current period end date
  - Features included
  - Usage limits

#### UsageLimits
- **Path:** `lib/core/models/usage_limits.dart`
- **Properties:**
  - Daily turns limit and usage
  - Pre-learning generations limit and usage
  - Custom scenarios limit and usage
  - Saved instances limit and usage

### New Services

#### SubscriptionService
- **Path:** `lib/core/services/subscription/subscription_service.dart`
- **Methods:**
  - `getCurrentSubscription()`
  - `validateReceipt(store, receiptData)`
  - `restorePurchases()`
  - `getUsageLimits()`

#### PreLearningService
- **Path:** `lib/core/services/api/pre_learning_service.dart`
- **Methods:**
  - `getPreLearningContent(scenarioId, hskLevelId)`

### New Repositories

#### SubscriptionRepository
- **Path:** `lib/core/repositories/subscription_repository.dart`
- **Methods:**
  - `getCurrentSubscription()`
  - `validateReceipt(store, receiptData)`
  - `restorePurchases()`
  - `getUsageLimits()`
  - `checkFeatureAccess(featureType)`

#### PreLearningRepository
- **Path:** `lib/core/repositories/pre_learning_repository.dart`
- **Methods:**
  - `getPreLearningContent(scenarioId, hskLevelId)`
  - `cachePreLearningContent(content)`
  - `getCachedContent(scenarioId, hskLevelId)`

### New Providers

#### SubscriptionProvider
- **Path:** `lib/core/providers/subscription_provider.dart`
- **Providers:**
  - `subscriptionStatusProvider`
  - `usageLimitsProvider`
  - `subscriptionServiceProvider`

#### PreLearningProvider
- **Path:** `lib/core/providers/pre_learning_provider.dart`
- **Providers:**
  - `preLearningContentProvider`
  - `preLearningServiceProvider`

## Backend Implementation

### New Services

#### SubscriptionService
- Handle subscription validation with Apple/Google stores
- Track subscription status and periods
- Manage usage limits and resets
- Implement feature access control logic

#### PreLearningService
- Generate vocabulary and grammar content using AI
- Cache generated content
- Implement content retrieval logic
- Handle usage tracking and limits

### Database Migrations

- Create new tables (UserSubscriptions, ScenarioPreLearningCache)
- Create UserUsageTracking table
- Add indexes for performance

### API Endpoint Implementations

- Implement new endpoints for pre-learning and subscriptions
- Update existing endpoints to check subscription status and limits
- Add proper error handling for subscription-related errors

### Background Jobs

- Daily reset of usage limits
- Subscription status checks and updates
- Cache cleanup for expired pre-learning content

## Testing Strategy

### Unit Tests

- Test subscription status logic
- Test feature access control
- Test usage limit tracking
- Test pre-learning content generation and caching

### Integration Tests

- Test API endpoints with different subscription statuses
- Test limit enforcement
- Test subscription validation flow
- Test pre-learning content generation and retrieval

### UI Tests

- Test subscription screen flows
- Test pre-learning screen
- Test limit indicators and premium feature prompts
- Test graceful degradation for free users

### Manual Testing

- Complete end-to-end testing of subscription purchase flow
- Verify receipt validation
- Test cross-platform subscription recognition
- Test offline behavior with different subscription statuses

## Rollout Plan

### Phase 1: Infrastructure (Week 1-2)
- Implement database schema changes
- Create subscription and usage tracking services
- Implement basic API endpoints without frontend integration

### Phase 2: Core Features (Week 3-4)
- Implement pre-learning content generation
- Implement subscription validation
- Add feature access control to existing endpoints
- Create frontend models and repositories

### Phase 3: UI Implementation (Week 5-6)
- Create subscription management screens
- Create pre-learning screen
- Update existing screens with subscription indicators
- Implement usage limit displays

### Phase 4: Testing & Refinement (Week 7-8)
- Comprehensive testing of all features
- Fix issues and refine user experience
- Optimize performance
- Prepare for production deployment

### Phase 5: Soft Launch (Week 9)
- Release to limited audience
- Monitor usage and subscription conversions
- Gather feedback

### Phase 6: Full Launch (Week 10)
- Release to all users
- Marketing campaign for premium features
- Continue monitoring and optimization
