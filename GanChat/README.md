- **App name**: GanChat
- **One-sentence description**: A simple local-first chat app for Gen Z users to register, find people, and start one-to-one conversations with minimal setup.
- **Target user**: Young users who want a simple chat experience without too many settings or complicated features.
- **Problem it solves**: Many chat apps are overloaded with features. GanChat focuses on simple communication with a lightweight experience and a local identity.
- **MVP features**: Authentication, user registration, login, conversation list, one-to-one text messaging, message history, logout. For now, I would move reaction and voice message out of MVP. They are good portfolio features, but they add quite a lot of complexity. Get text messaging working well first.
- **Not in v1**: Voice messages, message reactions, group chat.

Screens also make sense now: **Login** → **Register** → **Conversation List** → **Chat**
ONE-TO-ONE CHAT ARCHITECTURE
1. Domain
   User
   Conversation
   Message

2. Message lifecycle
   Sending → Sent → Delivered → Read

3. Message flow
   Sender → Backend → Recipient

4. Persistence
   Where is the source of truth?
	   - Cloud Firestore is the source of truth. It holds the real data.
	     Physical servers: Singapore.
	   - Local client-side storage (on-device disk) is a synced copy,
	     not a second source of truth. It exists for offline reading
	     and instant UI updates. If local and cloud ever disagree,
	     Firestore wins.
	   - Analogy: like Git. The remote repo is the source of truth,
	     your local clone is just a cache that can be stale or have
	     unpushed commits.

5. Realtime
   How does a connected user receive changes?
	   - Architecture-level answer (implementation-independent):
		   1. Client subscribes to a query ("give me messages in
		      conversation X").
		   2. Server keeps that subscription open.
		   3. When new data matches the query, the server pushes it
		      down to the client — no polling.
	   - Implementation detail: Firebase happens to implement this
	     push mechanism using a persistent connection and exposes it
	     to us as a "realtime listener" API. If Firebase were swapped
	     for a custom backend, this same push mechanism would still
	     be needed — that's the actual architecture, not the specific
	     API.

6. Offline
   What happens when a user disconnects?
	   Two separate behaviors, not one "Firebase handles it" black box:

	   1. Optimistic local writes
	      - Writing to Firestore writes to the local cache immediately
	        and resolves right away, before the network round trip
	        finishes. UI updates instantly whether online or offline.

	   2. Write queue
	      - If offline, the write sits in a pending queue instead of
	        being sent. On reconnect, the queue flushes in order.

	   - On the local client device
	      - Local cache takes over: the SDK switches to local disk
	        persistence. If the user types a message while
	        disconnected, the app doesn't break — it writes
	        successfully to the device's internal cache. Listeners
	        read from that local cache instead of the cloud.
	      - Each locally-written message has a
	        `snapshotMetadata.hasPendingWrites` flag, so the UI can
	        show "sending..." vs "sent" without building a custom
	        offline flag.

	   - Upon reconnection
	      - The connection is automatically re-established. The
	        client flushes its local queue (uploads messages written
	        while offline, in order), then pulls down any new
	        messages from the server.

7. Synchronization
   How does the client catch up?

	   1. What happens if Bob is offline?
		   - The server keeps the message until Bob syncs (comes
		     online).
		     Alice (Hey Bob) → Server → Database → ⨯ Bob offline
		     So when Bob comes back online, the server delivers the
		     message to him.

	   2. What happens if Alice sends a message and her connection
	      drops?
		   - Alice doesn't know whether the server received the
		     message. Two possibilities:
			   - Server never received it.
			   - Server received and stored it, but Alice never got
			     the confirmation.
		   - Solution: give every message a unique client-generated
		     ID. If Alice reconnects and resends ID "ABC123", the
		     server recognizes it already has that ID and doesn't
		     create a duplicate. This is idempotency / deduplication
		     (see section 9 for the code).

	   3. How does Bob catch up after reconnecting?
		   - The mechanism: incremental sync using a cursor /
		     watermark, not "redownload everything and diff it."
		   - Firestore's concrete version: the listener resumes from
		     a resume token it tracks internally, and only the delta
		     (changed documents) is sent down.

	   ```swift
	   // Bob reconnects. Firestore doesn't redownload everything —
	   // it resumes the listener and sends only what changed.
	   db.collection("conversations/\(id)/messages")
	       .order(by: "createdAt")
	       .addSnapshotListener { snapshot, error in
	           for change in snapshot?.documentChanges ?? [] {
	               if change.type == .added {
	                   // new message since last sync
	               }
	           }
	       }
	   ```

8. Ordering
   How do both users agree on message order?
	   - Don't trust the client's clock — a phone's clock can be
	     wrong or skewed.
	   - Use `FieldValue.serverTimestamp()`: the server sets the time
	     when it writes the document, not the client.
	   - Order messages by that server timestamp, not by
	     client-created time.
	   - Edge case: two messages can land on the same server
	     timestamp (rare but possible) — tiebreak using the document
	     ID or a secondary sequence field.
	   - Core concept: never order distributed events by client-side
	     time.

9. Duplicate prevention
   What happens when sending is retried?
	   - The key is idempotency: applying the same operation twice
	     has the same effect as applying it once. MessageID is the
	     key that enables this, not the mechanism itself.

	   ```swift
	   // BAD: creates a new doc every retry
	   db.collection("messages").addDocument(data: messageData)

	   // GOOD: same client-generated ID every retry = overwrite,
	   // not duplicate
	   let messageId = UUID().uuidString
	   db.collection("messages").document(messageId).setData(messageData)
	   ```

	   - `addDocument` generates a random ID each call, so a retry
	     creates a duplicate.
	   - `document(id).setData(...)` with a client-generated ID means
	     a retry just rewrites the same document — no duplicate.

10. iOS responsibilities
    ```
    View (ChatView)
       ↓
    ViewModel (ChatViewModel)          -- UI state, no Firebase code
       ↓
    Repository (ChatRepository)         -- protocol: "what" the app needs
       ↓
    Data Source (FirestoreMessageDataSource)  -- "how": Firebase-specific
    ```

    - View
	    - ChatView.swift
    - ViewModel
	    - ChatViewModel.swift
	    - Holds a `MessageRepository`, not a `Firestore` reference
	      directly. Doesn't know Firestore exists — it calls
	      `repository.sendMessage(...)`.
    - Repository
	    - A protocol/interface. Decides policy (e.g. "write local
	      cache first, then remote").
	    - Only this layer's concrete implementation is allowed to
	      import FirebaseFirestore.
    - Messaging Service / Data Source
	    - FirestoreMessageRepository (or FirestoreMessageDataSource)
	    - The only place that actually calls
	      `Firestore.firestore()...`.

    ```swift
    protocol MessageRepository {
        func send(_ message: Message) async throws
        func observeMessages(in conversationId: String) -> AsyncStream<[Message]>
    }

    final class FirestoreMessageRepository: MessageRepository {
        private let db = Firestore.firestore()
        // implements the protocol using Firestore
    }
    ```

    - Why this layering matters: if Firebase is ever swapped for a
      custom backend, only the Data Source changes. ViewModel and the
      Repository protocol stay untouched.

Discover anther user
Who is chatting with me?

Example:
Anther user should search user "Alice"
Then, chatting with she

---

### The flow is
```
Alice logs in
      ↓
Firebase Auth
      ↓
Alice's UID = A123
      ↓
Alice searches for Bob
      ↓
Find Bob's profile
      ↓
Bob's UID = B456
      ↓
Open/create conversation
      ↓
A123 ↔ B456
      ↓
Send messages
```

Luck...we are has implemented the `fetchUserProfile`, this is the direction.



