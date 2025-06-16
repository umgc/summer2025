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

Last Edited: 06/15/2025

Edited By: Myles Davis

# DeepTrain Project Deployment

This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

The project is stood up and can be viewed [here](https://swen670-deeptrain.vercel.app/). 

If you are going to run the DeepTrain application locally, you will need to do the following:

Prerequisits: 
- Access to [Vercel](https://vercel.com/) Project (Deployment Application) for environmental variables
- Install [Node.js](https://nodejs.org/en), the package manager (Most Recent Version). 

Steps: 

1. Clone Project Repo

2. Install Libraries and Dependencies

```bash
npm install
or 
npm i
```
and
```bash
npm install -g vercel
```
3. Login to Vercel

```bash
vercel login
```

4. Link Local Project to Vercel Project

```bash
vercel link
```

5. Pull Environmental Variables

```bash
vercel env pull .env.local
```

6. run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Supabase Database

Currently, DeepTrain is using [Supabase](https://supabase.com) as it's Postgres database and authentication development platform. You will need access to the database project in order to view contents.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.
