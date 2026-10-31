# Contact Management App (Ostad Flutter Module-9 Assignment)

A clean, modern, and user-friendly Flutter Contact Management application built with a local SQLite database (`sqflite`).

---

## 📱 Features

- **Add New Contact**: Seamlessly add contacts with validation for name, phone, email, and address.
- **View All Saved Contacts**: Alphabetically sorted contact list with colorful dynamic initials avatars.
- **Update Contact Information**: Edit any contact detail anytime.
- **Delete Contact**: Secure deletion with confirmation dialog.
- **Live Search**: Instant real-time search filtering contacts by name.
- **🌟 Bonus - Favorite Contacts**:
  - Mark or unmark contacts as favorites with a single tap.
  - Quick filter chip to view only favorite contacts.

---

## 🗃️ Contact Information Fields

Each contact contains the following structured fields:
- **ID**: Auto-incremented primary key (`INTEGER PRIMARY KEY AUTOINCREMENT`)
- **Name**: Contact full name (`TEXT NOT NULL`)
- **Phone Number**: Contact phone number (`TEXT NOT NULL`)
- **Email**: Contact email address (`TEXT NOT NULL`)
- **Address**: Physical or postal address (`TEXT NOT NULL`)
- **Favorite**: Boolean flag (`INTEGER NOT NULL DEFAULT 0`)

---

## 🏗️ Project Architecture

```
lib/
├── database/
│   └── database_helper.dart      # SQLite singleton, tables, and CRUD operations
├── models/
│   └── contact.dart              # Contact model with toMap, fromMap, and copyWith
├── screens/
│   ├── home_screen.dart          # Main contact list, search bar, & favorites filter
│   ├── add_edit_contact_screen.dart # Form screen for adding & updating contacts
│   └── contact_details_screen.dart # Detailed profile view with quick actions
├── theme/
│   └── app_theme.dart            # Material 3 styling, color palette, & typography
├── widgets/
│   ├── contact_card.dart         # Reusable card tile with avatar, actions, & badge
│   ├── delete_confirmation_dialog.dart # Alert dialog for safe deletion
│   └── empty_state.dart          # Friendly empty states for list and search
└── main.dart                     # App entry point
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  address TEXT NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0
);
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.13.5)
- Dart SDK

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/i-am-mamun/Module-9-Local-Database-CRUD-App_Ostad.git
   cd Module-9-Local-Database-CRUD-App_Ostad
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

4. Run unit tests:
   ```bash
   flutter test
   ```
