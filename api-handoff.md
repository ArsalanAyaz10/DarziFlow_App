# API Handoff: Chat Feature

## Business Context
This feature enables real-time messaging between users. It supports 1-on-1 (direct) chat rooms, sending text and media, mentioning users, replying to specific messages, and tracking the last message in a room. It is primarily used for communication regarding orders or general inquiries between users and the platform.

## Endpoints

### GET /api/chat/rooms
- **Purpose**: Fetches all chat rooms the current user belongs to, ordered by latest activity.
- **Auth**: Protected (Requires valid user authentication)
- **Request**: `N/A`
- **Response** (success):
  ```json
  {
    "success": true,
    "rooms": [
      {
        "_id": "room_id",
        "name": "Room Name",
        "type": "direct",
        "orderId": "order_id",
        "participants": [
          { "_id": "user_id", "name": "John Doe", "role": "client", "avatar": "url_here" }
        ],
        "lastMessage": {
          "_id": "message_id",
          "text": "Hello!",
          "sender": { "name": "Jane Doe", "role": "tailor" }
        },
        "createdAt": "2023-10-01T12:00:00.000Z",
        "updatedAt": "2023-10-01T12:05:00.000Z"
      }
    ]
  }
  ```
- **Response** (error): 500 Internal Server Error (`{ "success": false, "message": "error details" }`)
- **Notes**: `rooms` are returned in descending order of `updatedAt` (most recently active first). `lastMessage` provides context for list views.

### POST /api/chat/rooms/direct
- **Purpose**: Find or create a direct 1-on-1 chat room with another user.
- **Auth**: Protected
- **Request**:
  ```json
  {
    "targetUserId": "string (ObjectId of the target user)"
  }
  ```
- **Response** (success):
  ```json
  {
    "success": true,
    "room": {
      "_id": "room_id",
      "type": "direct",
      "participants": ["current_user_id", "target_user_id"],
      "createdAt": "2023-10-01T12:00:00.000Z",
      "updatedAt": "2023-10-01T12:00:00.000Z"
    }
  }
  ```
- **Response** (error): 400 Bad Request if `targetUserId` is missing. 500 Internal Server Error.
- **Notes**: Useful when clicking a "Message" button on a user's profile.

### GET /api/chat/rooms/:roomId/messages
- **Purpose**: Fetch message history for a specific chat room.
- **Auth**: Protected
- **Request**: URL param `:roomId`
- **Response** (success):
  ```json
  {
    "success": true,
    "messages": [
      {
        "_id": "message_id",
        "chatRoomId": "room_id",
        "sender": { "_id": "user_id", "name": "John Doe", "role": "client", "avatar": "url_here" },
        "text": "Message content",
        "media": [
          { "url": "media_url", "type": "image" }
        ],
        "replyTo": {
          "_id": "parent_message_id",
          "text": "Original text",
          "media": [],
          "sender": { "name": "Jane Doe" }
        },
        "mentions": [{ "_id": "user_id", "name": "Mentioned User" }],
        "createdAt": "2023-10-01T12:01:00.000Z",
        "updatedAt": "2023-10-01T12:01:00.000Z"
      }
    ]
  }
  ```
- **Response** (error): 500 Internal Server Error.
- **Notes**: Messages are sorted chronologically (`createdAt: 1`) for reading order. Pagination is currently not implemented but may be added later.

## Data Models / DTOs

```typescript
// Example shapes for frontend typing

interface UserPreview {
  _id: string;
  name: string;
  role: string;
  avatar?: string;
}

interface MediaItem {
  url: string;
  type: 'image' | 'video' | 'document';
}

interface MessageDto {
  _id: string;
  chatRoomId: string;
  sender: UserPreview;
  text: string;
  media: MediaItem[];
  replyTo?: {
    _id: string;
    text: string;
    media: MediaItem[];
    sender: { name: string };
  } | null;
  mentions: { _id: string; name: string }[];
  readBy?: string[]; // Array of user IDs
  createdAt: string;
  updatedAt: string;
}

interface ChatRoomDto {
  _id: string;
  name?: string;
  type: 'direct' | 'group';
  orderId?: string;
  participants: UserPreview[] | string[];
  lastMessage?: MessageDto | string;
  createdAt: string;
  updatedAt: string;
}
```

## Enums & Constants

| Context | Value | Meaning |
|---------|-------|---------|
| ChatRoom `type` | `direct` | 1-on-1 private chat |
| ChatRoom `type` | `group` | Group chat |
| Media `type` | `image` | Image attachment |
| Media `type` | `video` | Video attachment |
| Media `type` | `document` | Document/file attachment |

## Validation Rules
- **Direct Room Creation**: `targetUserId` is required.
- **Message Sending (via Socket)**: `media` objects must have both a `url` and a `type` (`image`, `video`, or `document`). Either `text` or `media` should logically be present (though DB defaults text to empty string).

## Business Logic & Edge Cases
- When sending a message, the backend automatically updates the `ChatRoom.lastMessage` field to surface the latest message in the recent chats view.
- Offline push notifications (FCM) are currently marked as a TODO on the backend.
- Creating a direct room is idempotent; if a room exactly matching the two participants already exists, it is returned instead of duplicated.

## Integration Notes
- **Recommended flow**: 
  1. Load `/api/chat/rooms` for recent chats inbox.
  2. Click on a chat, join socket room `join_room` with `roomId`, and load `/api/chat/rooms/:roomId/messages`.
  3. Emit `send_message` to post messages.
- **Real-time**:
  - The socket server runs on the same port as the API (`http://localhost:5000` / production domain).
  - Emits/Listeners:
    - **Emit `join_room` (payload: `roomId`)**: Call this when opening a chat window.
    - **Emit `send_message`**:
      ```json
      {
        "chatRoomId": "string",
        "senderId": "string",
        "text": "string",
        "media": [{ "url": "string", "type": "image" }],
        "replyTo": "messageId (optional)",
        "mentions": ["userIds (optional)"]
      }
      ```
    - **Emit `typing`**: `{ "chatRoomId": "string", "userName": "string" }`
    - **Listen `receive_message`**: Receives a fully populated `MessageDto` object. Append this to the local UI state.
    - **Listen `user_typing`**: `{ "userName": "string" }`
    - **Listen `message_error`**: `{ "error": "string" }`

## Test Scenarios
1. **Happy path**: Open app -> fetch recent rooms -> click user -> join socket room & fetch messages -> type message -> emit `send_message` -> listen to `receive_message` -> view populated new message.
2. **First-time chat**: From user profile -> call `POST /api/chat/rooms/direct` -> empty chat history -> emit first message -> room `lastMessage` updates.
3. **Typing Indicator**: Emit `typing` -> other client in the same room listens to `user_typing` and shows UI indicator.
