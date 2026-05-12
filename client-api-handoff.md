# API Handoff: Client Dashboard & Order Tracking

## Business Context
This feature set allows CLIENT users to track their orders, view overall progress, and check recent activity history. It solves the transparency problem for clients, giving them real-time visibility into their manufacturing workflow.

## Endpoints

### GET /api/client/all-orders
- **Purpose**: Retrieves all orders associated with the logged-in client along with summary counts.
- **Auth**: Bearer Token (Role: CLIENT)
- **Request**: N/A
- **Response** (success):
  ```json
  {
    "totalOrders": 10,
    "activeOrders": 4,
    "completedOrders": 6,
    "orders": [
      {
        "_id": "60d...1",
        "name": "Order 1",
        "type": "PANT",
        "overallStatus": "IN_PROGRESS",
        "amount": 5000,
        "currency": "Rs.",
        "dueDate": "2026-06-01T00:00:00.000Z"
      }
    ]
  }
  ```
- **Response** (error): 401 Unauthorized, 403 Forbidden.

### GET /api/client/order-progress/:orderId
- **Purpose**: Calculates and returns the percentage-based progress for a specific order.
- **Auth**: Bearer Token (Role: CLIENT)
- **Request**: `orderId` in URL path.
- **Response** (success):
  ```json
  {
    "success": true,
    "totalCheckpoints": 20,
    "completedCheckpoints": 10,
    "progress": 50
  }
  ```
- **Response** (error): 400 Bad Request (Missing ID), 404 Not Found (Invalid ID).

### GET /api/client/getRecentHistory
- **Purpose**: Fetches the last 10 QC activities related to the client's orders.
- **Auth**: Bearer Token (Role: CLIENT)
- **Request**: N/A
- **Response** (success):
  ```json
  {
    "activities": [
      {
        "_id": "60d...2",
        "orderName": "Order 1",
        "departmentName": "Stitching",
        "checkpointName": "Final Stitch",
        "action": "APPROVE",
        "comment": "Good quality",
        "createdAt": "2026-05-11T10:00:00.000Z"
      }
    ]
  }
  ```

### GET /api/client/getCompletedOrders
- **Purpose**: Retrieves a list of orders that have been marked as 'COMPLETED'.
- **Auth**: Bearer Token (Role: CLIENT)
- **Request**: N/A
- **Response** (success):
  ```json
  {
    "orders": [
      {
        "_id": "60d...3",
        "name": "Order 2",
        "type": "JACKET",
        "overallStatus": "COMPLETED"
      }
    ]
  }
  ```

---

## Data Models / DTOs (Dart Suggestions)

### Order Model
```dart
class Order {
  final String id;
  final String name;
  final String type; // PANT, SHORTS, JACKET, OTHER
  final String overallStatus; // DRAFT, DOCS_PENDING, READY_TO_START, IN_PROGRESS, QC_PENDING, CLIENT_PENDING, COMPLETED
  final DateTime? dueDate;
  final double amount;
  final String currency;

  Order({
    required this.id,
    required this.name,
    required this.type,
    required this.overallStatus,
    this.dueDate,
    required this.amount,
    required this.currency,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      name: json['name'] ?? '',
      type: json['type'],
      overallStatus: json['overallStatus'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'Rs.',
    );
  }
}
```

### QC History Model
```dart
class QcHistory {
  final String id;
  final String orderName;
  final String departmentName;
  final String checkpointName;
  final String action; // SUBMIT, APPROVE, REJECT, FINAL_APPROVE
  final String comment;
  final DateTime createdAt;

  QcHistory({
    required this.id,
    required this.orderName,
    required this.departmentName,
    required this.checkpointName,
    required this.action,
    required this.comment,
    required this.createdAt,
  });

  factory QcHistory.fromJson(Map<String, dynamic> json) {
    return QcHistory(
      id: json['_id'],
      orderName: json['orderName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      checkpointName: json['checkpointName'] ?? '',
      action: json['action'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

## Validation Rules
- `orderId` must be a valid MongoDB ObjectId.
- All requests require a `CLIENT` role token.

## Integration Notes
- **Recommended flow**: Fetch summary (`/all-orders`) -> Display counts -> Fetch progress for specific order if detailed view is opened.
- **Polling**: Progress can be polled every 30-60 seconds if the client is actively watching an order.

## Test Scenarios
1. **Happy path**: Fetch all orders and see total count matching active + completed.
2. **Progress Check**: Pass a valid `orderId` and receive a percentage.
3. **Empty History**: Handle cases where `getRecentHistory` returns an empty array.
4. **Unauthorized**: Verify 401 when token is missing.
