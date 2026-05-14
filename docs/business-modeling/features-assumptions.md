## Features and Assumptions
<!-- 
Indicate an  initial/tentative list of high-level features - high-level capabilities or desired services of the system that are necessary to deliver benefits to the users.
 - Feature XPTO - a few words to briefly describe the feature
 - Feature ABCD - ...
...

Optionally, indicate an initial/tentative list of assumptions that you are doing about the app and dependencies of the app to other systems.
-->

**Features**

- Report Submission: Create and submit public issue reports.
- Issue Categorization: Classify reports by category.
- Report Details: Add a title and description to each report.
- Photo Upload: Attach photos to support a report.
- Automatic Location Detection: Detect the user's current location automatically.
- Map Location Confirmation: Confirm or adjust the report location on a map.
- Report Review: Check all report information before submission.
- Report Tracking: Monitor the status of submitted reports.
- Notifications: Receive updates on report progress.
- User Authentication: Create an account, sign in, access the app securely, and log out.
- Report Management for Authorities: Review and manage submitted reports.
- Main feed: Display a public list of submitted reports for users to browse.
- Vote on reported issues: Allow users to upvote or downvote reports based on their importance.
- Prioritize issues in the feed based on vote score: Order reports so that the most supported issues appear first.
- Comment other reports: Let users add comments to existing reports to provide extra context or feedback.
- Notify the responsible municipality by email when a report is submitted: Send an email notification to the appropriate municipality after a new report is created.

**Assumptions**

- Location Services: The app requires access to the user's device location services.
- Internet Access: The app requires an internet connection to send and retrieve report data.
- Camera Access: The app requires camera access to capture photos.
- Notification Permission: The app requires notification permission to send push notifications..

**Dependencies**

- Supabase: used for database, authentication and storage.
- Stadia: used for map display and location confirmation.
- Resend: used to send emails for the user and corresponding municipality.
- Firebase: used for push notifications.
- Google ML Kit: used for image scanning and item recognition.