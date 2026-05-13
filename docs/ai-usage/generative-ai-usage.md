# AI Usage Documentation

This document describes how artificial intelligence tools were used during the development of **Cidade Alerta**.  
The main AI tools used throughout the project were **ChatGPT (OpenAI)** and **Figma AI**, which supported implementation, debugging, backlog definition, interface refinement, mockup generation, and documentation tasks.

---

## AI for Code Generation and Technical Assistance

We used **ChatGPT (OpenAI)** to assist in several technical areas during the development of the application.

### Code Implementation Assistance

During development, ChatGPT was used to help implement specific parts of the application based on requirements and partial code snippets provided by the team.

Examples of areas where AI support was used include:

- authentication flows such as **login** and **signup**
- integration-related code involving **Supabase**
- support for **Firebase push notifications**
- implementation of the **bottom navigation bar**
- development of parts of the **main feed**
- refinement of the **report details and comments modal**
- general Flutter widget structure and navigation improvements

For these tasks, requirements and existing code fragments were given to ChatGPT, which then suggested code structures, UI components, or implementation strategies. The generated output was always reviewed, tested, and adapted before being integrated into the project.

This helped reduce time spent on repetitive implementation tasks and allowed the team to focus more on project-specific logic.

---

## AI for Debugging and Problem Solving

ChatGPT was also used as a debugging assistant during development.

### Technical Debugging

A significant part of the AI usage involved identifying and solving implementation issues related to:

- Flutter navigation flow problems
- widget structure and screen organization
- integration of the custom navbar into the app architecture
- route configuration problems between screens

In these situations, the team provided ChatGPT with error messages, logs, screenshots, and code snippets. Based on that information, ChatGPT suggested likely causes, alternatives, and fixes.

A concrete example was the integration of the new **bottom navigation bar**, where multiple issues had to be resolved, including:

- incorrect routing to the old home page
- screen hierarchy problems
- placeholder pages not connected to the real screens
- layout inconsistencies between the intended mockup and the Flutter implementation

Another example involved the **report details modal**, where AI was used to help adjust the layout and interaction so that the detail view behaved like a partial sheet instead of a full screen.

In all cases, the AI suggestions were validated through manual testing and iterative refinement.

---

## AI for Requirements and Backlog Support

ChatGPT was also used to support the definition and refinement of project management artefacts.

### User Stories, Tasks, and Backlog Items

AI support was used to help write and improve:

- **user stories**
- **acceptance criteria**
- **task descriptions**
- **Jira issue text**

This was especially useful when converting implementation work into clearer backlog items written from the user’s perspective, or when deciding whether a feature should be represented as a **story** or as a **task**.

Examples of topics supported by AI include:

- report ordering by community priority
- municipality email notifications
- navbar implementation task descriptions
- report summary and confirmation steps
- sprint changelog writing
- development setup documentation

This helped improve consistency in the written project artefacts and reduced the time spent formatting repetitive management documentation.

---

## AI for Interface and Interaction Refinement

ChatGPT was used not only to generate code, but also to improve interface decisions and interaction flows.

### UI and UX Support

AI was used to discuss and refine aspects such as:

- naming of navigation items
- wording of buttons and labels
- organization of the bottom navigation bar
- report detail screen layout
- comments section presentation
- modal and card behaviour aligned with the intended design

The team often provided screenshots or described the expected visual result, and ChatGPT then suggested adjustments to structure, spacing, naming, or Flutter widget organization.

This was particularly useful for bridging the gap between mockup intent and implementation details.

---

## AI for Mockup and Interface Generation

We also used **Figma AI** extensively during the project to support the design of the application interface.

### Mockup Generation

Figma AI was used to generate and refine mockups for several application screens before or during implementation. This helped the team quickly visualise ideas, compare interface alternatives, and define a clearer design direction before writing frontend code.

Examples of screens and interface elements supported by Figma AI include:

- login and signup screens
- main feed layout
- bottom navigation bar design
- report summary and confirmation screens
- report detail and comments modal
- general layout ideas for key app sections

In these cases, textual descriptions of the desired feature or user story were given to Figma AI, which then generated visual proposals. These mockups were later reviewed and adjusted by the team to better fit the intended user experience and the technical constraints of the Flutter implementation.

This process was especially useful for transforming ideas into more concrete interface proposals at an early stage.

### Interface Inspiration and Iteration

Figma AI was not only used to generate initial mockups, but also to explore variations of layouts, components, and interaction ideas.

This helped the team:

- compare different visual approaches
- improve consistency between screens
- better communicate UI expectations during development
- align implementation work with a more concrete visual reference

As with ChatGPT outputs, all AI-generated mockups were reviewed and refined manually before being considered final references.

---

## Reflection and Best Practices

The use of AI during the project brought several benefits, but it also required careful validation.

### Main Lessons Learned

- **Human review is essential**  
  All AI-generated code, mockups, and documentation had to be reviewed, tested, and adapted before use.

- **AI is more effective with context**  
  Better results were obtained when prompts included requirements, existing code, screenshots, error messages, or examples of the intended behaviour.

- **AI was most useful for acceleration, not replacement**  
  The main value of AI was in speeding up routine implementation, debugging support, mockup generation, documentation, and UI refinement, while the final decisions and validation remained with the team.

- **Iterative interaction improved results**  
  In many cases, the first suggestion was not enough, and multiple follow-up iterations were required to reach a correct or acceptable solution.

---

## Tools Used

- **ChatGPT (OpenAI ChatGPT)**  
  Used for code generation, debugging support, UI refinement, and documentation assistance.

- **Figma AI**  
  Used for mockup generation, interface exploration, and design refinement.

---
