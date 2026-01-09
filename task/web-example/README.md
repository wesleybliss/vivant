# Vivant Gastronomy

Vivant Gastronomy is a Point of Interest (POI) search application designed to help users discover restaurants, bars, and other establishments with enhanced, fine-grained search filters powered by Google's Maps and Places APIs. This application provides an interactive map view, personalized saved lists, and robust user authentication for a seamless experience.

## Features

*   **Point of Interest (POI) Search:** Discover restaurants, bars, and more using powerful search capabilities.
*   **Interactive Map View:** Visualize search results directly on an integrated Google Map.
*   **Fine-Grained Search Filters:** Utilize advanced filtering options to narrow down results beyond standard search.
*   **Saved Places & Lists:** Create personalized lists of your favorite POIs for easy access.
*   **User Authentication:** Securely manage your data and preferences with user accounts.

For a detailed breakdown of all features, please refer to the [Features Documentation](docs/features.md).

## Documentation

*   [Features](docs/features.md)
*   [Technologies Used](docs/technologies.md)
*   [API Usage & Setup](docs/api_usage.md)

## Linting & Code Quality

### Biome

**Setup an editor extension**

Get live errors as you type and format when you save.
Learn more at [https://biomejs.dev/guides/editors/first-party-extensions/](https://biomejs.dev/guides/editors/first-party-extensions/)

**Try a command**
`biome check` checks formatting, import sorting, and lint rules.
`biome --help` displays the available commands.

**Migrate from ESLint and Prettier**
`biome migrate eslint` migrates your ESLint configuration to Biome.
`biome migrate prettier` migrates your Prettier configuration to Biome.

**Read the documentation**
Find guides and documentation at [https://biomejs.dev/guides/getting-started/](https://biomejs.dev/guides/getting-started/)

**Examples**

```shell
# Format all files
pnpm exec biome format --write

# Format specific files
pnpm exec biome format --write <files>

# Lint and apply safe fixes to all files
pnpm exec biome lint --write

# Lint files and apply safe fixes to specific files
pnpm exec biome lint --write <files>

# Format, lint, and organize imports of all files
pnpm exec biome check --write

# Format, lint, and organize imports of specific files
pnpm exec biome check --write <files>
```

## Prettier Generated Readme

## Project info

**URL**: https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID

## How can I edit this code?

There are several ways of editing your application.

**Use Lovable**

Simply visit the [Lovable Project](https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID) and start prompting.

Changes made via Lovable will be committed automatically to this repo.

**Use your preferred IDE**

If you want to work locally using your own IDE, you can clone this repo and push changes. Pushed changes will also be reflected in Lovable.

The only requirement is having Node.js & pnpm installed - [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

Follow these steps:

```sh
# Step 1: Clone the repository using the project's Git URL.
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the project directory.
cd <YOUR_PROJECT_NAME>

# Step 3: Install the necessary dependencies.
pnpm i

# Step 4: Start the development server with auto-reloading and an instant preview.
pnpm run dev
```

**Edit a file directly in GitHub**

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

**Use GitHub Codespaces**

- Navigate to the main page of your repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

## What technologies are used for this project?

This project is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS
- Convex
- Clerk

## How can I deploy this project?

Simply open [Lovable](https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID) and click on Share -> Publish.

## Can I connect a custom domain to my Lovable project?

Yes, you can!

To connect a domain, navigate to Project > Settings > Domains and click Connect Domain.

Read more here: [Setting up a custom domain](https://docs.lovable.dev/features/custom-domain#custom-domain)