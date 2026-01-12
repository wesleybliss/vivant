# Google Takeout Saved Places Import Plan

## Overview
Create a Node.js script to import saved places from Google Takeout JSON export into the Convex database, mapping the Google Takeout schema to our existing Convex schema structure.

## Current State

### Google Takeout Schema (from sample)
```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "geometry": {
        "coordinates": [longitude, latitude],
        "type": "Point"
      },
      "properties": {
        "date": "ISO-8601 timestamp",
        "google_maps_url": "URL with cid parameter",
        "location": {
          "address": "Full address string",
          "country_code": "Two-letter code",
          "name": "Place name"
        }
      },
      "type": "Feature"
    }
  ]
}
```

**Note:** Some features may not have `geometry` field (coordinates missing).

### Current Convex Schema (savedPlaces table)
Located at: `/home/wes/localhost/vivant-gastronomy/convex/schema.ts`

```typescript
savedPlaces: defineTable({
    userId: v.id('users'),
    listId: v.id('lists'),
    placeId: v.string(),           // Google Places ID
    name: v.string(),
    rating: v.number(),
    reviewCount: v.number(),
    priceLevel: v.optional(v.number()),
    cuisine: v.optional(v.string()),
    address: v.string(),
    photoUrl: v.optional(v.string()),
    lat: v.optional(v.number()),
    lng: v.optional(v.number()),
    createdAt: v.number(),
})
```

## Required Changes

### 1. Update Convex Schema
Add the following optional fields to the `savedPlaces` table in `/home/wes/localhost/vivant-gastronomy/convex/schema.ts`:

- `importedFromGoogle: v.optional(v.boolean())` - Flag to denote imported places
- `googleMapsUrl: v.optional(v.string())` - Store the Google Maps URL with CID
- `countryCode: v.optional(v.string())` - Store country code from takeout data

**Rationale:** These fields preserve the original Google Takeout data and allow us to identify imported places.

### 2. Create Import Mutation
Add a new mutation `importGooglePlace` in `/home/wes/localhost/vivant-gastronomy/convex/savedPlaces.ts`:

- Accept parameters matching Google Takeout schema
- Accept a `userId` parameter (Convex user ID, not Firebase UID)
- Accept a `listId` parameter to specify which list to import to
- Check if place already exists by `googleMapsUrl` or `placeId` (if available)
- If exists: update the record with new data
- If doesn't exist: insert new record
- Set default values for missing required fields:
  - `rating: 0` (default since Takeout doesn't provide ratings)
  - `reviewCount: 0` (default since Takeout doesn't provide review counts)
  - `placeId`: Extract from `google_maps_url` CID parameter if available, otherwise use the URL as identifier
  - `createdAt`: Use the `date` field from Takeout, converted to milliseconds timestamp

### 3. Create Node.js Import Script
Create `/home/wes/localhost/vivant-gastronomy/scripts/import-saved-places.js`:

**Features:**
- ES7 syntax (async/await, no semicolons, no unnecessary brackets)
- Accept command-line arguments:
  - `--file <path>` - Path to Google Takeout JSON file
  - `--userId <id>` - Convex user ID (not Firebase UID)
  - `--listId <id>` - Convex list ID to import places into
- Read and parse the JSON file
- Iterate through each feature in the FeatureCollection
- For each place:
  - Extract coordinates from `geometry.coordinates` (if present)
  - Extract place info from `properties`
  - Extract CID from `google_maps_url` using regex
  - Call the Convex `importGooglePlace` mutation
- Handle errors gracefully with detailed logging
- Print summary: total places, imported, updated, failed

**Dependencies:**
- `convex` - For calling Convex mutations
- Standard Node.js modules (fs, path)

## Implementation Steps

1. Update Convex schema with new optional fields
2. Deploy schema changes: `npx convex dev` or `npx convex deploy`
3. Create the `importGooglePlace` mutation in savedPlaces.ts
4. Create the import script in `/home/wes/localhost/vivant-gastronomy/scripts/`
5. Test with the sample file: `task/saved-places-sample.json`
6. Document usage in script comments and/or README

## Usage Example

```bash
cd /home/wes/localhost/vivant-gastronomy
node scripts/import-saved-places.js \
  --file ~/Android/Projects/vivant/task/saved-places-sample.json \
  --userId k17abc123def4567 \
  --listId k27xyz789abc1234
```

## Mapping Details

| Google Takeout Field | Convex Field | Transformation |
|---------------------|--------------|----------------|
| `properties.location.name` | `name` | Direct |
| `properties.location.address` | `address` | Direct |
| `properties.location.country_code` | `countryCode` | Direct (new field) |
| `geometry.coordinates[1]` | `lat` | Direct (if present) |
| `geometry.coordinates[0]` | `lng` | Direct (if present) |
| `properties.google_maps_url` | `googleMapsUrl` | Direct (new field) |
| `properties.google_maps_url` (CID) | `placeId` | Extract CID parameter |
| `properties.date` | `createdAt` | Parse ISO-8601 to milliseconds |
| N/A | `rating` | Default: 0 |
| N/A | `reviewCount` | Default: 0 |
| N/A | `priceLevel` | Omit (optional) |
| N/A | `cuisine` | Omit (optional) |
| N/A | `photoUrl` | Omit (optional) |
| N/A | `importedFromGoogle` | Set to `true` (new field) |

## Notes

- The script should handle missing `geometry` fields gracefully (some places don't have coordinates)
- CID extraction: Google Maps URLs contain a `cid` parameter that can serve as a place identifier
- The script updates existing records if they match by `googleMapsUrl` to ensure idempotency
- All imported places will be flagged with `importedFromGoogle: true` for easy filtering

## Implementation Complete ✓

### Files Created/Modified:

1. **Schema Update** - `/home/wes/localhost/vivant-gastronomy/convex/schema.ts`
   - Added `importedFromGoogle`, `googleMapsUrl`, `countryCode` fields
   - Added `by_googleMapsUrl` index

2. **Import Mutation** - `/home/wes/localhost/vivant-gastronomy/convex/savedPlaces.ts`
   - Created `importGooglePlace` mutation
   - Handles upsert logic (insert or update)
   - Returns action type and ID

3. **Import Script** - `/home/wes/localhost/vivant-gastronomy/scripts/import-saved-places.js`
   - ES7 syntax, no semicolons
   - Command-line arguments parsing
   - Progress logging and error handling
   - Summary statistics

4. **Documentation** - `/home/wes/localhost/vivant-gastronomy/scripts/README.md`
   - Complete usage guide
   - Data mapping reference
   - Troubleshooting tips

5. **Helper Script** - `/home/wes/localhost/vivant-gastronomy/scripts/list-users-and-lists.js`
   - Instructions for finding user and list IDs

### Next Steps:

1. Deploy the schema changes:
   ```bash
   cd /home/wes/localhost/vivant-gastronomy
   npx convex deploy
   ```

2. Find your user and list IDs from the Convex dashboard

3. Run the bulk import (recommended):
   ```bash
   node scripts/import-saved-places-bulk.js \
     --csvDir ~/path/to/saved-lists-directory \
     --json ~/Android/Projects/vivant/task/saved-places-sample.json \
     --userId <your-user-id>
   ```
   This will auto-create lists based on CSV filenames.

## Update: CSV + JSON Merge Support ✓

### Additional Implementation:

**6. Import Library** - `/home/wes/localhost/vivant-gastronomy/lib/google-maps-import.js`
   - Reusable functions for parsing CSV and JSON exports
   - Hex Place ID to CID conversion
   - Smart merging by CID or name matching
   - Convex format conversion
   - Summary statistics generation

**7. Merged Import Script** - `/home/wes/localhost/vivant-gastronomy/scripts/import-saved-places-merged.js`
   - Supports both CSV and JSON input (separately or together)
   - Merges data to maximize completeness
   - Visual indicators for data quality (✓ = full data, ○ = minimal)
   - Detailed merge statistics

**8. Test Utility** - `/home/wes/localhost/vivant-gastronomy/scripts/test-conversion.js`
   - Verifies hex to CID conversion

**9. Bulk Import Script** - `/home/wes/localhost/vivant-gastronomy/scripts/import-saved-places-bulk.js`
   - Processes entire directory of CSV files (one per list)
   - Auto-creates lists based on CSV filenames
   - Uses `getOrCreateListByName` mutation
   - Merges all CSV files with single JSON export
   - Detailed per-list and overall statistics

**10. List Management Mutation** - `/home/wes/localhost/vivant-gastronomy/convex/lists.ts`
   - Added `getOrCreateListByName` mutation
   - Finds existing list by name or creates new one
   - Returns list ID and creation status

**11. Dry Run Feature**
   - Added `--dry-run` flag to bulk import script
   - Previews what would be imported without modifying data
   - Shows list creation, merge statistics, and place details
   - Recommended to always run dry-run first

### Why the Merge?

- **CSV exports** from Google Maps saved lists contain place names and detailed URLs but NO coordinates or addresses
- **JSON exports** from Google Takeout contain coordinates, addresses, country codes, and save dates
- **Merging** both sources provides complete data without expensive Places API calls

### Matching Logic:

1. **CID Matching** (primary): Converts hex Place ID from CSV URL to decimal CID, matches with JSON CID
2. **Name Matching** (fallback): Normalized name comparison for places without CID matches
3. **Priority**: JSON data for coordinates/address, CSV data for detailed URL format
