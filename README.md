# SWEN 760 - Summer 2025 - Generative Simulations (Team D) Application

Summer 2025 Cohort

SWEN 670: Software Engineering Capstone

[View Project](https://swen670-deeptrain.vercel.app/)

## Team D Members
| Id | Role                | Name               | GitHub                  |
|----|---------------------|--------------------|-------------------------|
| 1  | Team Lead & Project Manager | Steven Edwards  | Edwards97          |
| 2  | Technical Architect | David Aaron        | ddaaron                 |
| 3  | Programmer          | Myles Davis        | theburninginferno       |
| 4  | Programmer          | Bethelehem Gessese | Abysinia2511            |
| 6  | Testing & Analyst   | Nicole Pope        | nicolefpope             |
| 7  | Support             | Justin Adkins      | Justinadkins25          |
| 8  | UI/UX Designer      | Brandon Sutan      | UnmedicatedAndDoingFIne |
| 9  | Supplemental Developer | Alireza Minargar |aliminagar              |

Last Edited: 06/17/2025

Edited By: Myles Davis

# DeepTrain Project Deployment

This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

The project is stood up and can be viewed [here](https://swen670-deeptrain.vercel.app/). 

### Deploying the Application Locally

If you are going to run the DeepTrain application locally, you will need to do the following:

Prerequisits: 
- Access or Download Environment Variables
    - Download the ".env.local COPY" file from the team's designated development folder
    - Or gain access to [Vercel](https://vercel.com/) Project (Deployment Application) for environmental variables
- Install [Node.js](https://nodejs.org/en), the package manager (Most Recent Version). 

Steps: 

1. Clone Project Repo

2. Install Libraries and Dependencies

```bash
npm install
or 
npm i
```

3. Install & Login to Vercel (Optional)

```bash
npm install -g vercel
vercel login
```

4. Link Local Project to Vercel Project (Optional)

```bash
vercel link
```

5. Download or Pull Environmental Variables. 
    - If downloaded ".env.local COPY" file, please rename it to ".env.local". 
    - Otherwise, pull from Vercel using the following command:

```bash
vercel env pull .env.local
```

6. run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### Deploying Sentry

If initializing [Sentry](https://sentry.io/welcome/) locally, you will need to do the following:

Prerequisits: 
- Access or Download Environment Variables
    - Add Sentry DSN to env.local
- Sign up for Sentry Accound

Steps: 

1. Make sure Sentry is downloaded

```bash
npm install @sentry/nextjs
```

2. Initialize Sentry and Login

```bash
npx @sentry/wizard -i nextjs
```

3. Verify Setup and Files
    - sentry.client.config.js
    - sentry.server.config.js
    - next.config.js (if modified)

# Technology Stack

| Category              | Technology                                     | Purpose             |
|-----------------------|-----------------------------------------------------|---------------------|
| **Web/Desktop Frontend Framework**| [Next.js](https://nextjs.org/) (built on React)     | UI rendering, routing, SSR (Server-Side Rendering), and SSG support     |
| **Mobile Framework** | [Flutter](https://flutter.dev/) / [FlutterFlow](https://flutterflow.io/) | Cross-platform native app development                 |
| **Web/Desktop UI Libraries**  | [Material UI](https://mui.com/), [Framer Motion](https://www.framer.com/motion/) | Styling, layout, and animations                          |
| **Web/Desktop Backend/API**       | [Node.js](https://nodejs.org/) (via Next.js API routes) | Backend logic and RESTful API handling            |
| **Mobile Backend/API**       | [Spring/Spring Boot](https://spring.io/) (via Java API routes) | Backend logic and RESTful API handling            |
| **Web/Desktop Authentication**    | [Supabase Auth](https://supabase.com/auth)          | User sign-up, login, and session management                            |
| **Web/Desktop Database**          | [Supabase](https://supabase.com/) (PostgreSQL)      | Storing relational data such as users, projects, etc.                  |
| **Web/Desktop Asset Storage**           | [Vercel Blobs](https://vercel.com/docs/storage/vercel-blob) | Asset and file storage (images, files, etc.) for quick access |
| **Web/Desktop Deployment**        | [Vercel](https://vercel.com/)                       | Continuous deployment, hosting, environment variable management         |
| **Version Control**   | [Git](https://git-scm.com/) + [GitHub](https://github.com/) | Source code management and collaboration                    |
| **AI Integration**    | [DeepSeek](https://deepseek.com/) | Natural language features or assistant-based tools         |
| **Web/Desktop Charts & Data Viz** | [MUI X Charts](https://mui.com/x/react-charts/)     | Displaying analytical data (Bar/Line charts)                       |
| **Web/Desktop Icon Libraries** | [Material UI Icons](https://mui.com/material-ui/material-icons/), [Lucide React](https://lucide.dev/guide/packages/lucide-react), [React Icons](https://react-icons.github.io/react-icons/) | Icons   |
| **App Monitoring** | [Sentry](https://sentry.io/welcome/) | Monitoring, Error Tracking, etc.    |
 **Miscellaneous Libraries** | --- | --- |

# Learn More

For more information about our different technologies:

## Supabase Database 

Currently, DeepTrain is using [Supabase](https://supabase.com) as it's Postgres database and authentication development platform. You will need access to the database project in order to view contents.

## DeepSeek AI Integration 

DeepTrain integrates [DeepSeek](https://platform.deepseek.com/) to simulate user interactions (Currently) during workflow execution, ...., and more. DeepSeek is used to generate realistic answers based on the quiz question and options.

## Next.js Documentatiion

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deployment on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
