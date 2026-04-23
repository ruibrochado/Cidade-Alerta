# 2LEIC11T5
<!-- Template file for README.md for LEIC-ES-2025-26 -->
<!-- [!NOTE] In this file, you will find the structure you should follow to document your mobile app in the README.md file for LEIC-ES-2025-26. It is a single file with guidelines, as comments, only seen in Edit mode, not in Preview mode. You can add more sections, but for assessment reasons and automation, please make sure to include all sections of this template. Your professors will clarify about specificities of your app.-->

<img width="6912" height="1815" alt="cidadealerta_banner1" src="https://github.com/user-attachments/assets/9c28bb5b-b0e9-4f2e-bb0b-384e5470fcd4" />

# _Cidade Alerta_ Development Report

Welcome to the documentation of _Cidade Alerta_!

This Software Development Report, tailored for LEIC-ES-2025-26, provides comprehensive details about _Cidade Alerta_, starting from an high-level vision and going into low-level implementation decisions. 

It is organised by the following activities: 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
* [Requirements](#Requirements)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
  * [User interfaces](#User-interfaces)
  * [Validate Requirements](#mpirical-Validation)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Functional prototype](#Functional-Prototype)
* [Project management](#Project-Management)
  * [Sprint 0](#Sprint-0)
  * [Sprint 1](#Sprint-1)
  * [Sprint 2](#Sprint-2)
  * [Sprint 3](#Sprint-3)
  * [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

* André Sousa (<u>up202404210@up.pt</u>)
* Pedro Domingos (<u>up202404098@up.pt</u>)
* Ricardo Alves (<u>up202404099@up.pt</u>)
* Rui Brochado (<u>up202405335@up.pt</u>)

---
## Business Modelling

Business modeling in software development involves defining the product's vision, understanding market needs, aligning features with user expectations, and setting the groundwork for strategic planning and execution.

### Product Vision

For residents tired of waiting, Cidade Alerta is the direct bridge between a city’s flaws and its fixes. Zero bureaucracy, total transparency, real-time results.

#### The Problem

In modern urban environments, residents often encounter infrastructure issues—such as broken streetlights, potholes, and illegal dumping—that compromise public safety. Many of these issues persist for months because existing reporting methods are convoluted and provide zero feedback to the reporter. Citizens often feel ignored by their own local government.

Our application empowers citizens to act as active urban inspectors, streamlining the communication between the public and the city hall. By accelerating municipal responses, our platform aligns with two key Sustainable Development Goals (SDGs):

* SDG 11: Sustainable Cities and Communities – Ensuring safe and functional infrastructure helps build more resilient and inclusive urban environments for all residents.

<p align="center">
   <img width="220" height="220" alt="image" src="https://github.com/user-attachments/assets/4ed1aa22-31ba-426c-82f3-75213b4196da" />
</p>

* SDG 16: Peace, Justice, and Strong Institutions – By providing a transparent tracking system, we promote institutional accountability and build trust between citizens and local government.

<p align="center">
  <img width="220" height="220" alt="image" src="https://github.com/user-attachments/assets/9ad62064-be61-4f31-b500-fead6e389602" />
</p>

##### Target Audience

Our application is designed for civic-minded individuals who encounter maintenance failures in their daily lives and want to see immediate action. This includes:

* Individuals tired of bureaucratic delays and seeking more responsive municipal services.
* Daily commuters and pedestrians who want to ensure safe public spaces by reporting hazards while reducing community degradation.
<!-- 
Start by defining a clear and concise product vision for your app, to help members of the team, contributors, and users into focusing their often disparate views into a concise, visual, and short textual form. 

The vision should provide a "high concept" of the product for marketers, developers, and managers.

A product vision describes the essential of the product and sets the direction to where a product is headed, and what the product will deliver in the future. 

**We favor a catchy and concise statement, ideally one sentence.**

We suggest you use the product vision template described in the following link:
* [How To Create A Convincing Product Vision To Guide Your Team, by uxstudioteam.com](https://uxstudioteam.com/ux-blog/product-vision/)

To learn more about how to write a good product vision, please read:
* [Vision, by scrumbook.org](http://scrumbook.org/value-stream/vision.html)
* [Product Management: Product Vision, by ProductPlan](https://www.productplan.com/glossary/product-vision/)
* [20 Inspiring Vision Statement Examples (2019 Updated), by lifehack.org](https://www.lifehack.org/articles/work/20-sample-vision-statement-for-the-new-startup.html)
-->


### Features and Assumptions
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

## Requirements

### User Stories
<!-- 
In this section you should describe all kinds of requirements for your module: functional and non-functional requirements.

For LEIC-ES-2025-26, the requirements will be gathered and documented as user stories. 

Please add in this section a concise summary of all the user stories (not each user story!).

**User stories as GitHub Project Items**
The user stories themselves should be created and described as items in your GitHub Project with the label "user story". 

A user story is a description of a desired functionality told from the perspective of the user or customer. A starting template for the description of a user story is *As a < user role >, I want < goal > so that < reason >.*

Name the item with either the full user story or a shorter name (recommended). In the “comments” field, add relevant notes, mockup images, and acceptance test scenarios, linking to the acceptance tests when available, and finally estimate value and effort.

**INVEST in good user stories**. 
You may add more details after, but the shorter and complete, the better. In order to decide if the user story is good, please follow the [INVEST guidelines](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/).

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
For each user story you should write also the acceptance tests (textually in [Gherkin](https://cucumber.io/docs/gherkin/reference/)), i.e., a description of scenarios (situations) that will help to confirm that the system satisfies the requirements addressed by the user story.

**Value and effort**.
At the end, it is good to add a rough indication of the value of the user story to the customers (e.g. [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method) and the team should add an estimation of the effort to implement it using points in a kind-of-a Fibonnacci scale (1,2,3,5,8,13,20,40, no idea).

-->

The requirements of the module are documented as user stories, covering the main needs of both **citizens** and **municipality workers**.

For citizens, the user stories focus on the complete reporting flow, including capturing a photo, automatically detecting and adjusting the location, selecting an issue category, adding a description, and submitting the report. They also cover features for interacting with reports after submission, such as tracking report status, receiving notifications, filtering issues by city or category, viewing issues ordered by priority, voting on reports, and commenting on existing reports. In addition, some user stories address recycling support features, such as identifying recyclable materials and viewing recycling bins on a map.

For municipality workers, the user stories focus on dashboard access and report management. These include secure login, viewing reported city issues, receiving reports assigned to the correct municipality, filtering issues by category, updating issue status, archiving resolved issues, and accessing statistics to support decision-making and city management.

All user stories are maintained as items in the [GitHub Project board](https://github.com/orgs/LEIC-ES-2025-26-2LEIC11/projects/6). Each story includes supporting notes, mockups when applicable, acceptance tests written in Gherkin, and an estimation of value and implementation effort.

### Domain model

![UML Domain model](app/images/DomainUML.png)

Our application is a civic and environmental platform that connects citizens to municipal services to improve waste management and public spaces. The system allows a **User** to register **Materials** to learn how to handle them correctly (categorized into specific **Recycled Material** types) and direct them to the appropriate **Recycling Bin**.

In parallel, the application works as a reporting and continuous improvement network. Users can create geolocated **Reports/Suggestions** linked to a specific **Locality** (for example, reporting a damaged recycling bin or accumulated trash around the Asprela campus). To foster community engagement, these reports feature an interaction system allowing users to leave a **Comment**, as well as evaluate issues via **Upvote** or **Downvote** to help prioritize them.

All physical (**Recycling Bin**) and social (**Report/Suggestion**) infrastructure is mapped to a **Locality**. These localities belong to a specific **Municipality**, which in turn falls under a broader **District**. This hierarchical organization allows the **Municipality** (such as the Porto City Council) and its respective **Municipality Services** to manage their collection network efficiently and act faster according to the population's needs.

### Empirical Validation

[Link to the survey](https://tally.so/r/BzDWEA)  |  [Report Dataset (CSV)](./docs/survey_results_anonymized.csv)

<img width="390" height="221" alt="survey_banner" src="https://github.com/user-attachments/assets/fac7bb1a-b66b-4d93-8451-98e482380daf" />

#### 1. Survey Goals
Before defining our final Product Backlog, we conducted a survey with 40 potential users. The questions were carefully designed to find out:
* **Problem Validation:** How often do citizens actually face public issues (e.g., broken pavements, overflowing bins) and what is their current behavior?
* **Current Friction:** If they don't report these issues to the City Council, what is stopping them?
* **Feature Validation:** Would they use our proposed app? Which specific features (AI recycling scanner, karma system, direct link to the municipality) do they value the most?


#### 2. Results Analysis
The results provided clear insights into user behavior and validated our core application concept:

* **Massive Need:** **80%** of respondents stated they encounter public issues *every day* or *multiple times a week*. This validates that our app solves a very frequent and real-world problem.
* **High Friction in Current Systems:** When facing these issues, **70%** of users admitted they do absolutely nothing. When asked why, the main reasons were that they "feel it won't have any impact" (30%) or "don't know how to do it" (24%). So we know that our app needs to be fast and intuitive.
* **The Main Motivator:** **70%** of users said the biggest motivation to use our app would be *knowing the report actually reaches the City Council/Junta*. So we know that we need to make sure that feature is well implemented.
* **Feature Prioritization:** When asked to rank features, "Reporting issues easily" and "Guaranteeing issues reach responsible entities" consistently ranked as the top #1 and #2 priorities. Features like "AI garbage identification" and "Recycling bin maps" were pushed to the bottom of the priority list by most users.

<img width="800" height="400" alt="survey_ranking_results" src="https://github.com/user-attachments/assets/5efeaa4f-357d-4492-af81-9f159dd7039a" />


#### 3. Conclusion & Next Steps
The survey successfully proved that our core concept is strong and highly demanded by the community. However, it also highlighted that users prioritize basic efficiency over complex secondary features.


**Moving forward, this feedback will guide our development focus:**
* **Prioritizing the Core Flow:** We will focus our immediate efforts on making the "Submit Report" flow as fast as possible, directly combating the current user friction ("the process takes too long").
* **Focusing on Transparency:** Knowing that users are driven by impact, we will ensure that features related to tracking the issue status and forwarding it to the authorities remain at the top of our priority list.
* **Recalibrating priorities:** The features that scored higher (reporting and making sure it reaches the 'Câmara/Junta de freguesia', and, as requested by some users, knowing it's status), will be prioritized over the ones that scored lower in user priority (such as the AI scanner or recycling maps).


## Architecture and Design
<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->


### Logical architecture
![UML Logical architeture](app/images/PackageUML.png)

The logical architecture diagram illustrates the high-level organization of the application, emphasizing the separation of concerns across four main packages and their respective dependencies.

### 1. MobileApp
This package represents the core application running on the user's device, structured using a presentation architectural pattern (like MVVM):

* **UI:** The presentation layer responsible for handling user interactions and rendering screens. It delegates data handling to the underlying layers.
* **ViewModel:** Acts as the bridge between the UI and the services, managing presentation state, user input logic, and updating the views.
* **Service:** Handles local operations and orchestrates data flows. As shown by the dependencies, this layer communicates directly with both the **Backend** and specific **ExternalServices**.

### 2. Backend
This package represents the server-side infrastructure, which is consumed by the MobileApp. It follows a standard layered architecture:

* **API:** Exposes the necessary endpoints (e.g., REST or GraphQL) for the mobile client to communicate with the server.
* **BusinessLogic:** The core layer where the system's rules are enforced. It orchestrates data processing and connects with both the database layer and external modules.
* **DataAccess:** Responsible for database interactions, abstracting the storage, querying, and retrieval of information.

### 3. ExternalServices
This package groups the third-party platforms and APIs consumed by the system to expand its capabilities. It is accessed by both the **MobileApp** and the **Backend**:

* **MapsService:** Provides map rendering, geocoding, and location-based functionalities.
* **NotificationService:** Handles the delivery of real-time alerts and push notifications to the users' devices.
* **EmailService:** An external mailing service used for dispatching automated communications and alerts.

### 4. MunicipalManagement
A dedicated domain package that the **Backend** relies on to organize core entities related to city operations:

* **Reports:** Manages the submission, tracking, and lifecycle of the specific issues reported by citizens.
* **Recycling:** Handles operations, data, and business rules related to waste management and recycling points.
* **Localities:** Manages data concerning municipal zones, administrative regions, and specific geographic areas.

### Physical architecture
![UML Physical architeture](app/images/DeploymentUML.png)

The physical architecture (deployment) diagram presents five main device nodes communicating securely via HTTPS:

* **Smartphone:** Represents the user's mobile device. It features two distinct execution environments: **Android OS** (running the `cidadealerta.apk` artifact) and **iOS** (running the `cidadealerta.ipa` artifact). This node acts as the central client, interacting with the citizen and communicating directly with the backend and external APIs.
* **Supabase Cloud:** Acts as the core backend of the application. Its execution environment (`Supabase Platform`) hosts the `PostgreSQL Database` artifact for structured data storage and the `Backend Service` artifact to manage server-side logic and API requests coming from the smartphone.
* **Maps Provider:** An external service node hosting the `Maps Service` execution environment. It provides the `Map Tiles Api` artifact, which is consumed directly by the mobile app for map rendering and location-based features.
* **Firebase Cloud:** Responsible for delivering push notifications to the users. It hosts the `Cloud Messaging` execution environment and artifact, communicating directly with the client's smartphone.
* **Email Server:** An external email infrastructure that hosts the `EmailService` execution environment and its `Email API` artifact. Unlike the other external services, it receives backend commands directly from the **Supabase Cloud** to dispatch automated alerts (e.g., to municipal authorities).

### Functional prototype
<!--
To help on validating all the architectural, design and technological decisions made, we usually implement a functional prototype, a thin vertical slice of the system integrating as much technologies as we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).
-->

The functional prototype currently implements the main report submission flow of the application. Users can select a category, fill in report details, attach a photo, confirm the location, review the report information, and submit it.

This prototype already integrates important project technologies, including Supabase for data, authentication, and photo storage, and Stadia Maps for map support. It was developed to confirm that the main technologies of the system work well together.



https://github.com/user-attachments/assets/b04837a8-2f4d-4807-a654-42710cd514ee



## Project management
<!--
Software project management is the art and science of planning and leading software projects, in which they are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing agile software development with Scrum are: backlog management, release management, estimation, Sprint planning, Sprint development, acceptance tests, and Sprint retrospectives.

You can find below information and references related with the project management: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each Sprint;
  * retrospectives: meeting notes in a document in the repository, addressing the following questions:
    * Did well: things we did well and should continue;
    * Do differently: things we should do differently and how;
    * Puzzles: things we don’t know yet if they are right or wrong;
    * list of a few improvements to implement next Sprint;

-->

You can find below information and references related with the project management in our team:

* Backlog management: Product backlog and Sprint backlog in a [Github Projects Board](https://github.com/orgs/LEIC-ES-2025-26-2LEIC11/projects/6)
* Release management:
  * [Sprint 0](https://github.com/LEIC-ES-2025-26-2LEIC11/2LEIC11T5/releases/tag/sprint-0)
  * [Sprint 1](https://github.com/LEIC-ES-2025-26-2LEIC11/2LEIC11T5/releases/tag/sprint-1)
* Sprint planning and retrospectives:
  * [Sprint 0](#sprint-0)
  * [Sprint 1](#sprint-1)
* Git Workflow: Feature-branches workflow based on the `main` branch. Each feature or fix is developed on its own branch and merged via a pull request. Code reviews are required (using branch protection) to ensure code quality and consistency.
* CI/CD - Github Actions: Every pull request triggers a workflow that verifies code formatting and linting rules. This helps maintain code consistency and prevents errors from reaching the main branch.

### Sprint 0
**Project Board**

<p align="center">Start of Sprint 0</p>

<img width="1906" height="903" alt="sprint0_initial" src="https://github.com/user-attachments/assets/110a7918-cee9-42fb-9931-083cc80b8e59" />

<p align="center">End of Sprint 0</p>

<img width="1907" height="903" alt="sprint0_final" src="https://github.com/user-attachments/assets/4ad69bd3-7024-46ce-8919-71a43c2c5bad" />

**Sprint Retrospective**

* Did well:

    * Good advance in the app development.

    * Well defined product vision with clear user stories.

    * Effective use of AI tools to enhance productivity and support development tasks

* Do differently:

    * Manage the time better, starting the iteration as soon as possible to avoid delays due to unexpected problems.

    * Better divide the work between us; Keeping everyone totally dialed in.

    * Establish clearer priorities at the beginning of each sprint

* Puzzles:

    * Managing task dependencies between team members
      
### Sprint 1
**Project Board**

<p align="center">Start of Sprint 1</p>

<img width="1918" height="1078" alt="sprint1_initial" src="https://github.com/user-attachments/assets/86c947ed-56b5-486f-812e-7b0196ce6f82" />

<p align="center">End of Sprint 1</p>

<img width="1920" height="1075" alt="sprint1_end" src="https://github.com/user-attachments/assets/45379e08-855d-4505-bee0-c1516fddc242" />


**Sprint Retrospective**

* Did well:

    * Good advance in the app development.

    * Well defined product vision with clear user stories.

    * Effective use of AI tools to enhance productivity and support development tasks
      
    * Corrected bugs found during the Sprint
    
    * Refactored errors done in Sprint0
 
    * Good work division between the team

* Do differently:

    * Manage the time better, starting the iteration as soon as possible to avoid delays due to unexpected problems.

    * Ask for more feedback during the Sprint

* Puzzles:

    * How to improve team organization regarding pull requests, branch naming, and commit messages

<!--
### Sprint 2

### Sprint 3

### Sprint 4

### Final Release
-->
