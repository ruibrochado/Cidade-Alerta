## Features and Assumptions

**Features**

* Report Submission: Create and submit public issue reports.
* Issue Categorization: Classify reports by category.
* Report Details: Add a title and description to each report.
* Photo Upload: Attach photos to support a report.
* Automatic Location Detection: Detect the user's current location automatically.
* Map Location Confirmation: Confirm or adjust the report location on a map.
* Report Review: Check all report information before submission.
* Report Tracking: Monitor the status of submitted reports.
* Notifications: Receive updates on report progress.
* User Authentication: Create an account, sign in, access the app securely, and log out.
* Report Management for Authorities: Review and manage submitted reports.
* Municipality Worker Role-Based Access: Restrict municipality-specific features to authenticated users with the municipality worker role.
* Municipality Issue Feed: Display a dedicated feed for municipality workers to view reported issues assigned to their municipality.
* Municipality Report Filtering: Automatically filter municipality reports based on the municipality assigned to the authenticated worker.
* Issue Status Management: Allow municipality workers to update the status of reported issues, such as open, in progress, or resolved.
* Archive Resolved Issues: Allow municipality workers to archive resolved reports so they no longer appear in the active municipality feed.
* Municipality Statistics: Display statistics about reported issues in the municipality, including totals, status distribution, category distribution, and resolution rate.
* Main Feed: Display a public list of submitted reports for users to browse.
* Vote on Reported Issues: Allow users to upvote or downvote reports based on their importance.
* Prioritize Issues in the Feed: Order reports so that the most supported issues appear first.
* Comment on Reports: Let users add comments to existing reports to provide extra context or feedback.
* Municipality Email Notification: Send an email notification to the responsible municipality after a new report is created.
* Activity Feed for Reports: View a real-time public feed of recently submitted reports and community activity.
* AI Recyclable Object Identification: Use AI-powered image recognition to identify recyclable objects and assist users with correct waste disposal.
* Reported Issues Map: Display all submitted reports on an interactive map to help users explore issues geographically.
* Citizen Profile Page: Display user information, submitted reports, activity history, and account-related details.
* Edit Profile: Enable users to update their personal information, profile details, and account preferences.
* Ecocenter Details: Show detailed information about ecocenters, including location, services, opening hours, and contact information.
* Terms of Service and Privacy Policy: Provide legal information regarding platform usage, user rights, data protection, and privacy policies.
* Feedback Dialogs: Display informative dialogs for errors, confirmations, warnings, or important user actions throughout the application.
* Success Feedback Notifications: Notify users when actions such as report submissions or profile updates are completed successfully.
* Order Issues by Different Criteria: Allow users to sort reports based on criteria such as popularity, date, status, or urgency.
* Filter Issues by City: Enable users to filter reports according to a selected city or municipality.
* Filter Issues by Type: Allow users to filter reports based on issue categories or report types.

**Assumptions**

* Location Services: The app requires access to the user's device location services.
* Internet Access: The app requires an internet connection to send and retrieve report data.
* Camera Access: The app requires camera access to capture photos.
* Notification Permission: The app requires notification permission to send push notifications.

**Dependencies**

* Supabase: used for database, authentication, and storage.
* Stadia: used for map display and location confirmation.
* Resend: used to send emails to users and the corresponding municipality.
* Firebase: used for push notifications.
* Google ML Kit: used for image scanning and item recognition.