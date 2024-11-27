### **Vesta - Application Overview**

Vesta, named after the Roman goddess of hearth and wealth, is an application that allows it's users to create new investment portfolios and investments within them. An investment can be just about anything including stocks, crypto, art, ETFs, etc... Users can add one or more notes to their porfolios and investments, and can add one or more transactions (buy or sell) to an investment.

* * *

#### **Domain Models**

**User** - Model already exists but we will need to add a 1:N relationship with portfolios.

**Portfolio**

- **Attributes**:
    - **Name**: The name of the portfolio.
- **Relationships**:
    - **Investments**: Can have multiple investments (1:N).
    - **Notes**: Can have multiple notes (1:N).

**Investment**

- **Attributes**:
    - **Name**: The name of the investment.
    - **Symbol** (optional): The investment's symbol.
    - **Exit Target Type**: Exit strategy, which can be one of the following:
        - Specific date
        - Target unit value
        - Total investment value
    - **Current Units**: Calculated automatically based on transactions.
    - **Current Unit Price**: Manually entered at this time.
- **Relationships**:
    - **Transactions**: Can have multiple transactions (1:N).
    - **Notes**: Can have multiple notes (1:N).

**Transaction**

- **Attributes**:
    - **Transaction Date**: The date the transaction occurred.
    - **Transaction Type**: Either "buy" or "sell."
    - **Units**: The number of units transacted.
    - **Unit Price**: Price per unit at the time of the transaction.
- **Relationships**:
    - **Investment**: Each transaction belongs to a single investment (1:1).

**Note**

- **Attributes**:
    - **Content**: The content of the note.
    - **Importance**: Rated on a scale of 1-5, where 1 is the highest importance (default: 5).
    - **Timestamps**: Automatically tracked for creation and updates using ActiveRecord (`created_at`, `updated_at`).
- **Relationships**:
    - Can belong to Portfolios or Investments.

* * *

#### **Technical Requirements**

1.  **Framework and Language**:
    
    - Use **Ruby on Rails version 8** and **Ruby version 3.3.4**.
2.  **Frontend Features**:
    
    - Leverage **Turbo Frames** and **Turbo Streams** for a dynamic single-page application experience.
    - Use **Stimulus Controllers** for JavaScript interactions such as UI behavior for Flowbite components and custom page interactivity.
3.  **Styling and UI Framework**:
    
    - Use **Flowbite version 2.5.2** with **Tailwind CSS** for the UI theme and components. This includes tables, buttons, navigation bar, date/time pickers, forms, modals, alerts, cards, layout, and other visual elements.
    - Ensure a **modern, aesthetically pleasing design**.
    - *Configuration Note*: Flowbite and Tailwind have already been integrated into the project using Rails' **import map** functionality. No additional setup is required. Documentation for the configured versions is included in the project files.
4.  **Authentication**:
    
    - Authentication is **pre-configured** with Rails. No additional setup for authentication is needed.
5.  **Light/Dark Theme**:
    
    - Implement **Flowbite's theme chooser** to allow users to toggle between light and dark modes:
        - If logged out: Display the theme toggle icon next to the login link (in the navbar).
        - If logged in: Add the theme toggle option to a dropdown menu accessed via the user avatar.

* * *

#### **Functional Requirements**

1.  **Single-Page Application Design**:
    
    - Build the application as a **SPA** leveraging **Turbo Frames** and **Turbo Streams**.
    - The main page should include:
        - **Dashboard/Analytics**: Summarize relevant analytics.
        - **Tables**:
            - Transactions Table: Display transactions in reverse chronological (most recent first) order.
            - Notes Table: Order by **importance** (1 as highest priority) and apply a secondary sort based on creation date/time.
2.  **Dynamic Modals**:
    
    - Use **Flowbite modals** instead of navigating to separate pages for the following actions:
        - Add, edit, and delete **transactions**.
        - Add, edit, and delete **notes**.
        - Add and edit porfolios
        - We will need a confirmation dialog before deleting data
3.  **Navigation Bar**:
    
    - The navbar should have:
        - **Left Side**: Application name and a "heroicon" representing investments.
        - **Right Side**:
            - If logged out: A **login link** and the **theme toggle icon**.
            - If logged in:
                - An **avatar icon** (use a placeholder heroicon initially) with a dropdown menu containing:
                    - **Settings** (not functional yet).
                    - **Logout**.
                - The **theme toggle option** in the dropdown.
        - We will need a dropdown allowing the user to choose the portfolio to the left of the dropdown. It should only show if the user is logged in.
4.  **Usability Enhancements**:
    
    - Ensure the application is visually clean and responsive.
    - Transactions and notes should be presented in intuitive, easy-to-sort tables/cards for optimal usability.
