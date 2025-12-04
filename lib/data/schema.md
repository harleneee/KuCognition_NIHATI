```mermaid
erDiagram
  AuthUser {
    string uid PK
    string email
    string displayName
    timestamp createdAt
  }

  FirestoreUser {
    string uid PK  "mirrors Auth uid"
    string fullName
    string email
    string phone
    string sex
    string profileImageUrl
    timestamp createdAt
    string lastScan
    int totalScans
    string mostCommonResult
  }

  HistoryEntry {
    string historyId PK   "Firestore auto-ID"
    string predictionLabel
    string conditionKey
    double confidence     "0.0–1.0 (1.0 = 100%)"
    string risk           "High|Moderate|Low|Unknown"
    string imageUrl       "Supabase public URL"
    string source         "upload|scan"
    timestamp timestamp   "server time"
  }

  SupabaseObject {
    string storagePath PK "history/{uid}/<epoch>_<name>.jpg"
    string ownerUid       "Auth/Firestore uid"
    string publicUrl
    timestamp createdAt
    string contentType
  }

  AuthUser ||--|| FirestoreUser : "same uid (logical)"
  FirestoreUser ||--o{ HistoryEntry : "users/{uid}/history"
  FirestoreUser ||--o{ SupabaseObject : "owns (history/{uid}/...)"
  HistoryEntry }o..|| SupabaseObject : "imageUrl → object (URL ref)"
