# Department Approval & Rejection Flow

## Previous Workflow

Previously, the workflow required the client to approve each individual operation within a department before the department itself could be approved.

### Flow
1. Client reviews an operation.
2. Client approves the operation.
3. Repeat until all operations are approved.
4. Once all operations are approved:
   - The **Approve Department** button becomes enabled.
5. Client approves the entire department.

---

# Updated Workflow

Due to UI and backend constraints, the separate operation approval phase has been removed.

Instead of approving operations individually, the client now reviews all operations and checkpoints, then directly approves or rejects the department.

---

# Client Review Experience

## Operation View

The client can:

- View a list of operations inside the department.
- Tap on an operation to expand it.
- Expanded view displays all related checkpoints.

---

## Checkpoint Review

Each checkpoint is clickable.

When a checkpoint is selected:
- The client is navigated to the respective checkpoint detail screen.
- The client can review:
  - Images
  - Videos
  - Files
  - Notes
  - Progress details
  - Any other submitted evidence

---

# Department Approval

After reviewing all operations and checkpoints:

## Approve Department Button

At the bottom of the screen:
- An **Approve Department** button is displayed.

### Approval Flow
1. Client taps **Approve Department**.
2. A confirmation dialog/popup appears.
3. Client confirms approval.
4. Department status is marked as approved.

---

# Department Rejection

Alongside approval, a **Reject Department** option is also available.

## Rejection Flow

When the client taps **Reject Department**:

### Bottom Sheet Opens

A bottom sheet/modal is displayed containing:

#### 1. Operation Selection
- User selects the operation where the issue exists.

#### 2. Checkpoint Selection
- User selects the specific checkpoint related to the issue.

This allows highly targeted feedback instead of rejecting the entire department without context.

#### 3. Issue Description
- A text input field is provided.
- Client writes the rejection reason/problem details.

---

# Final Rejection Submission

After entering all details:

1. Client submits the rejection.
2. The department is marked as rejected.
3. Selected operation and checkpoint references are stored.
4. Rejection notes are saved for review by the responsible department/supervisor.

---

# Benefits of Updated Workflow

- Reduced UI complexity
- Simpler backend approval handling
- Faster review process for clients
- More precise rejection feedback
- Cleaner user experience
- Eliminates dependency on operation-level approvals