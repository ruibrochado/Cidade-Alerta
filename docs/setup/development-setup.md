# Development Environment Setup

To develop the **Cidade Alerta** application, a suitable development environment was set up with the necessary tools, dependencies, and supporting services.

## Tools and Technologies

The main tools and technologies used in the project were:

- **Flutter SDK** – used to develop the cross-platform mobile application
- **Dart** – programming language used in the project
- **Visual Studio Code** – main code editor used during development
- **Android Studio** – used to manage the Android SDK and run an Android emulator
- **Flutter CLI** – used to run, build, and manage the application
- **Supabase** – used for authentication, database, and storage
- **Firebase** – used for push notifications
- **Google ML Kit** – used for image recognition and recycling-related identification features
- **Stadia** – used to support map visualization and location-related features
- **Resend** – used to send email notifications to municipalities when a new report is submitted
- **Git and GitHub** – used for version control and collaboration

## Setting Up the Development Environment

The development environment was set up through the following steps:

1. Install the **Flutter SDK** and make sure Flutter is available in the system path.

2. Install **Android Studio** and configure the Android SDK.

3. Clone the project repository from GitHub:

```bash
git clone <repository-link>
```

4. Open a terminal in the project folder.

5. Install the project dependencies:

```bash
flutter pub get
``` 

6. Create and configure the `.env` file with the required environment variables, such as:

- `SUPABASE_URL`
- `SUPABASE_KEY`
- `RESEND_KEY`
- `STADIA_MAPS_API_KEY`

7. Add the Firebase configuration files to the project:

- `google-services.json` for Android
- other Firebase configuration files if required by the target platform

8. Start an Android emulator using **Android Studio** through: **Tools** -> **Device Manager**

9. Run the application:

```bash
flutter run
``` 

10. If a physical mobile device is used, enable developer mode and USB debugging, connect the device, and run:

```bash
flutter run
``` 

## Supabase

Supabase was used to provide backend support, including:

- Authentication
- Database management
- Storage for uploaded content
- User profile management

This required creating and configuring a Supabase project and connecting it to the application through environment variables.

## Firebase

Firebase was used only to support push notifications in the application.

This required creating and configuring a Firebase project, enabling Firebase Cloud Messaging, and linking it to the Flutter application.

## Google ML Kit

Google ML Kit was used to support image labeling and object recognition features within the application.

This required installing the appropriate package dependencies and ensuring the mobile environment was correctly configured to run ML Kit services.

## Stadia

Map and location features were included to allow users to detect, adjust, and visualize report locations.

This required configuring the map-related dependencies and ensuring that location services and permissions were enabled on the emulator or physical device.

## Resend

Resend was used to support email notifications sent to municipalities whenever a new report was submitted through the application.

This required creating and configuring a Resend account, generating an API key, and connecting the service to the application through the RESEND_KEY environment variable.

## Testing and Running the Project

To verify that the development environment was correctly configured, the following command was used:

```bash
flutter run
``` 

Additional checks could also be performed with:

```bash
flutter doctor
``` 

This helped confirm that Flutter, Dart, Android Studio, and the connected device or emulator were correctly configured.

## Notes

- The `.env` file must be configured correctly before running the application
- Firebase must be configured correctly to support push notifications
- An emulator or physical Android device is required to test mobile-specific features such as camera, notifications, and location
- Some features, such as image capture, map interaction, and notifications, may require additional device permissions
- The RESEND_KEY must be configured correctly to allow email notifications to municipalities
