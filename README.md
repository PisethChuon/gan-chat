# Software Architecture Document
**Project Name:** GanChat  
**Target Audience:** Gen Z users  
**Document Type:** Software Architecture Document (SAD)  
---
## 1. Introduction & Overview
### 1.1 Purpose
This document provides a comprehensive architectural overview of the **GanChat** application. It details the structural design, system components, data flow, domain models, and technical decisions governing the v1 Minimum Viable Product (MVP).

### 1.2 Product Vision & Problem Statement
- **App Name:** GanChat  
- **Description:** A simple, chat application designed for Gen Z users to register, find people, and initiate one-to-one messaging with minimal friction and zero setup overhead.
- **Problem Solved:** Existing messaging platforms are heavily bloated with complex features. GanChat addresses this by delivering a lightweight, clean, and responsive text communication platform.
- **Target Audience:** Young users desiring a minimal, fast, and feature-focused messaging application.

### 1.3 Scope (MVP vs. Out of Scope)
* **MVP Features (v1):**
  * User Registration, Login, and Logout
  * Basic User Profile (Email, Username, User ID)
  * Conversation List
  * One-to-one Direct Text Messaging
  * Persistent Message History & Near Real-time Synchronisation
  * Offline-first local messaging with automatic syncing
* **Explicitly Out of Scope for v1:**
  * Group Chat
  * Message Reactions
  * Voice Messages
  * Video Calls
  * Stories

### 2. System Architecture & High-Level Design
### 2.1 System Context & Data Flow
GanChat employs client architecture integrated with Firebase backend services. The remote cloud storage serves as the authoritative source of truth, while the local client storage acts as an active cache facilitating offline read/write capabilities and instant UI updates.

```
┌─────────────────────────────────────────────────────────┐
│                    iOS Device (Client)                  │
│                                                         │
│  ┌──────────────┐    ┌───────────────┐   ┌───────────┐  │
│  │  ChatView    │ ── │ ChatViewModel │ ──│Repository │  │
│  └──────────────┘    └───────────────┘   └─────┬─────┘  │
│                                                │        │
│                                      ┌─────────┴──────┐ │
│                                      │  Local Cache   │ │
│                                      │  (On-Device)   │ │
│                                      └────────────────┘ │
└──────────────────────────────┬──────────────────────────┘
                               │
                Persistent Listener / HTTPS
                               │
┌──────────────────────────────▼──────────────────────────┐
│                   Firebase Backend Service              │
│                                                         │
│  ┌────────────────────────┐    ┌─────────────────────┐  │
│  │ Firebase Auth          │    │ Cloud Firestore     │  │
│  │ (Identity & Creds)     │    │ (Source of Truth)   │  │
│  └────────────────────────┘    └─────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

> **[DIAGRAM REMARK 1: System Context Architecture Diagram]**  
> *Insert a formal UML Deployment Diagram or C4 Context Diagram here illustrating the boundary between the iOS Client (View, ViewModel, Repository, Local Storage) and Cloud Services (Firebase Auth, Cloud Firestore).*

### 2.2 Client-Side Architecture (iOS Layering)
The client application is built using **SwiftUI** with the **MVVM (Model-View-ViewModel)** architectural pattern, enforcing strict separation of concerns:

```
View (ChatView / LoginView)
   │
   ▼
ViewModel (ChatViewModel / LoginViewModel)
   │  (Holds Repository protocol reference; no direct Firebase dependency)
   ▼
Repository (MessageRepository / AuthRepository Protocol)
   │  (Decides business rules & caching policy)
   ▼
Data Source (FirestoreMessageRepository / FirebaseAuthService)
   │  (Direct API implementation using Firebase SDK)
   ▼
Cloud / Database (Firestore & Local Disk Cache)
```

> **[DIAGRAM REMARK 2: Client Layered Architecture Diagram]**  
> *Insert a Detailed Layer Sequence / Class Diagram showing data flow between View, ViewModel, Repository Interface, Firestore Concrete Data Source, and On-Device Disk Cache.*

#### Directory Structure Overview:
```
GanChat
├── Models
│   ├── User.swift
│   ├── Conversation.swift
│   └── Message.swift
├── Views
│   ├── Authentication
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   └── Chat
│       ├── ChatListView.swift
│       └── ChatView.swift
├── ViewModels
│   ├── LoginViewModel.swift
│   ├── RegisterViewModel.swift
│   └── ChatViewModel.swift
├── Services
│   ├── FirebaseAuthService.swift
│   └── FirestoreMessageRepository.swift
└── App
    ├── GanChatApp.swift
    └── RootView.swift
```
*(Reference:)*

---

## 3. User Flows & Navigation Architecture

### 3.1 Global Screen Navigation Flow
The navigation pipeline spans from initial application cold launch to authenticating and active chatting:

`Launch App` ➔ `Auth Check (AuthState)` ➔ (If Unauthenticated) `Login` / `Register` ➔ (If Authenticated) `Conversation List` ➔ `Chat View` ➔ `Send / Receive Messages`

> **[DIAGRAM REMARK 3: Navigation Flowchart Diagram]**  
> *Insert a State Diagram or Navigation Flowchart displaying user transitions across Launch Screen, Auth State Evaluation, Login/Register Forms, Conversation List, Chat Room, and Handling of Offline State Banner.*

---

## 4. Domain & Data Models

### 4.1 Domain Entities
The core entities within GanChat and their relationships are structured as follows:

#### 1. User
Represents an authenticated participant within the system [cite: 1, 2].
- `id`: String (Unique User Identifier) [cite: 1, 3]
- `username`: String (Public handle shown to other users; min 3 chars) [cite: 1, 3]
- `email`: String (Account identity credential) [cite: 3]
- `createdAt`: Timestamp (Account creation date) [cite: 3]

#### 2. Conversation
Represents the structural relationship and container between two participants [cite: 1, 2].
- `id`: String (Unique Conversation Identifier) [cite: 1]
- `participantA`: String (User ID of participant A) [cite: 1]
- `participantB`: String (User ID of participant B) [cite: 1]
- `latestMessage`: String / Message Object (Summary of last activity) [cite: 1]

#### 3. Message
Represents an individual unit of communication sent by a participant [cite: 1, 2].
- `id`: String (Client-generated unique ID for idempotency) [cite: 1, 2]
- `conversationID`: String (Foreign key mapping to Conversation) [cite: 1]
- `senderID`: String (User ID of the author) [cite: 1]
- `text`: String (Payload body) [cite: 1]
- `createdAt`: ServerTimestamp (Timestamp established by server) [cite: 1, 2]

> **[DIAGRAM REMARK 4: Entity-Relationship Diagram (ERD)]**  
> *Insert an ER Diagram showing the relationships between User, Conversation, and Message entities, highlighting key attributes and cardinalities (e.g., 1 Conversation contains N Messages).*

---

## 5. Key Architecture Mechanisms & Protocols

### 5.1 Authentication Subsystem
- **Provider:** Firebase Authentication coupled with Cloud Firestore profile persistence [cite: 3].
- **Rationale:** Firebase encapsulates the complete registration, login, and session persistence workflow without requiring custom backend PostgreSQL/schema maintenance [cite: 3].
- **Fields & Validation Rules:**
  - *Registration:* Email (valid format), Username (≥ 3 characters), Password (≥ 8 characters), Confirm Password [cite: 3].
  - *Login:* Username/Email and Password [cite: 3].
- **Session Lifecycle:** Persistent session management; session remains active until user manually logs out or session is explicitly invalidated [cite: 3].
- **Logout Behavior:** Terminates local authentication session, resets `AuthState` to `unauthenticated`, and redirects user to `LoginView` [cite: 3].

### 5.2 Real-Time Delivery & Synchronization Architecture
- **Persistent Listener Pattern:** Real-time message delivery is achieved via long-lived push subscriptions rather than polling [cite: 2].
- **Listener Workflow:**
  1. Client attaches a listener to `conversations/{id}/messages` [cite: 2].
  2. Server retains subscription connection open [cite: 2].
  3. Server pushes message deltas immediately upon database mutation [cite: 2].
- **Incremental Synchronization (Watermark Sync):** Upon reconnection, the client resumes tracking via internal resume tokens (cursors) to download only updated/added document deltas rather than re-downloading entire conversation histories [cite: 2].

> **[DIAGRAM REMARK 5: Real-Time Sync & Catch-Up Sequence Diagram]**  
> *Insert a Sequence Diagram showcasing real-time push message delivery, client disconnect, pending storage, client reconnect, and resume token synchronization.*

### 5.3 Offline Persistence & Local Cache
- **Source of Truth:** Cloud Firestore (hosted in Singapore data centers) serves as the ultimate source of truth [cite: 2]. Local client-side storage acts as a synchronized cache for offline execution and immediate local UI updates [cite: 2].
- **Optimistic Local Writes:** Writes update the local cache immediately, resolving UI rendering prior to network round-trip completion [cite: 2].
- **Write Queue:** When offline, writes are enqueued in an internal client pending queue and flushed in chronological order upon network re-establishment [cite: 2].
- **Metadata State Tracking:** Messages contain a `snapshotMetadata.hasPendingWrites` flag to allow the UI to accurately differentiate between "Sending..." and "Sent" states without custom flags [cite: 2].

### 5.4 Ordering & Deduplication (Idempotency)
- **Deterministic Ordering Rule:** Distributed client clocks are untrusted due to potential skew [cite: 2]. Message chronological ordering is strictly governed using `FieldValue.serverTimestamp()` applied at database insertion time [cite: 2]. Tie-breaking for simultaneous timestamps relies on Document ID [cite: 2].
- **Deduplication / Idempotency:** To prevent duplicate messages resulting from client retry attempts during connection loss, clients generate a unique UUID prior to dispatch [cite: 1, 2].
  - *Implementation:* Uses `db.collection("messages").document(messageId).setData(...)` instead of `addDocument(...)` [cite: 2]. Retries safely overwrite the explicit document path rather than inserting duplicate records [cite: 2].

> **[DIAGRAM REMARK 6: Message Lifecycle & Delivery Flowchart]**  
> *Insert a flowchart illustrating complete Message Lifecycle: Local Creation (Temporary ID, Sending) ➔ Submission & Acceptance ➔ Storage/Persistence ➔ Push Routing ➔ Delivery Confirmation ➔ Read Receipt [cite: 1].*

---

## 6. Non-Functional Requirements & Technical Constraints

### 6.1 Performance & Latency
- Online message delivery must complete within hundreds of milliseconds (near real-time delivery) [cite: 1].
- UI must remain fully responsive during network state changes via background queue synchronization [cite: 2].

### 6.2 Data Integrity & Reliability
- Zero message loss once acknowledged by the backend server [cite: 1].
- Strict message sequence ordering maintained within individual conversation threads [cite: 1, 2].
- Conflict resolution rule: In any discrepancy between local disk cache and Cloud Firestore, Cloud Firestore prevailing authority wins [cite: 2].

---

## 7. Implementation Roadmap & Milestones

The project development path is divided into eight incremental milestones [cite: 4]:

1. **M1: Project Foundation:** Repository initialization, core folder architecture, and base styling setup [cite: 4].
2. **M2: Authentication:** Implementation of Firebase Auth, Register/Login Views, and session retention [cite: 3, 4].
3. **M3: Conversation List:** UI and repository setup for listing active direct conversations [cite: 4].
4. **M4: Chat UI:** Building the Chat View, message bubbles, and input controls [cite: 4].
5. **M5: Send/Receive Messages:** Integration of Firestore real-time listeners, idempotency logic, and offline write queue [cite: 2, 4].
6. **M6: Error & Loading States:** Implementation of validation overlays, network connectivity banners, and retry indicators [cite: 3, 4].
7. **M7: Polish:** Fine-tuning UI responsiveness, transition animations, and optimistic state updates [cite: 4].
8. **M8: Testing & Documentation:** Finalizing unit tests, SAD documentation, and portfolio repository presentation [cite: 4].


